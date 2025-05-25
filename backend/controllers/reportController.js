const { executeQuery } = require('../config/database');
const PDFDocument = require('pdfkit');
const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

// Generate and download report
const generateReport = async (req, res) => {
  try {
    const { report_type, period, date, format } = req.body;
    const userId = req.user.user_id;

    // Validate required fields
    if (!report_type || !period || !format) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: report_type, period, format'
      });
    }

    // Get data based on report type and period
    const reportData = await getReportData(report_type, period, date);
    
    // Generate file based on format
    let filePath, fileName, mimeType;
    
    switch (format.toLowerCase()) {
      case 'pdf':
        ({ filePath, fileName } = await generatePDFReport(reportData, report_type, period, date));
        mimeType = 'application/pdf';
        break;
      case 'excel':
        ({ filePath, fileName } = await generateExcelReport(reportData, report_type, period, date));
        mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        break;
      case 'csv':
        ({ filePath, fileName } = await generateCSVReport(reportData, report_type, period, date));
        mimeType = 'text/csv';
        break;
      default:
        return res.status(400).json({
          success: false,
          message: 'Unsupported format. Use pdf, excel, or csv'
        });
    }

    // Save report record to database using existing table structure
    const fileStats = fs.statSync(filePath);
    const reportName = `${getReportTypeDisplayName(report_type)} - ${formatPeriodForDisplay(period, date)}`;
    const parameters = JSON.stringify({ report_type, period, date, format });
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30); // Expire after 30 days
    
    const insertQuery = `
      INSERT INTO reports (
        user_id, 
        report_name, 
        report_type, 
        parameters, 
        file_path, 
        file_format, 
        file_size, 
        generated_at, 
        expires_at, 
        download_count
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), ?, 0)
    `;
    
    await executeQuery(insertQuery, [
      userId,
      reportName,
      report_type,
      parameters,
      fileName,
      format,
      fileStats.size,
      expiresAt
    ]);

    // Send file to client
    res.setHeader('Content-Type', mimeType);
    res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);
    res.setHeader('Content-Length', fileStats.size);

    const fileStream = fs.createReadStream(filePath);
    fileStream.pipe(res);

    // Clean up file after sending (optional)
    fileStream.on('end', () => {
      fs.unlink(filePath, (err) => {
        if (err) console.error('Error deleting temp file:', err);
      });
    });

  } catch (error) {
    console.error('Generate report error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate report'
    });
  }
};

// Get report history
const getReportHistory = async (req, res) => {
  try {
    const { limit = 10, offset = 0, report_type, format } = req.query;
    const userId = req.user.user_id;

    let query = `
      SELECT 
        report_id as id,
        report_name,
        report_type,
        parameters,
        file_format as format,
        file_size,
        generated_at as created_at,
        expires_at,
        download_count
      FROM reports 
      WHERE user_id = ? AND (expires_at IS NULL OR expires_at > NOW())
    `;
    
    const params = [userId];

    // Add filters
    if (report_type) {
      query += ' AND report_type = ?';
      params.push(report_type);
    }

    if (format) {
      query += ' AND file_format = ?';
      params.push(format);
    }

    query += ' ORDER BY generated_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const result = await executeQuery(query, params);

    if (result.success) {
      // Parse parameters for each report
      const reports = result.data.map(report => {
        let parsedParams = {};
        try {
          parsedParams = JSON.parse(report.parameters || '{}');
        } catch (e) {
          console.error('Error parsing parameters:', e);
        }
        
        return {
          ...report,
          period: parsedParams.period || 'unknown',
          date: parsedParams.date || null
        };
      });

      res.json({
        success: true,
        data: {
          reports: reports,
          total: reports.length
        }
      });
    } else {
      throw new Error('Database query failed');
    }

  } catch (error) {
    console.error('Get report history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch report history'
    });
  }
};

// Download existing report
const downloadReport = async (req, res) => {
  try {
    const { reportId } = req.params;
    const userId = req.user.user_id;

    // Get report info from database
    const query = 'SELECT * FROM reports WHERE report_id = ? AND user_id = ? AND (expires_at IS NULL OR expires_at > NOW())';
    const result = await executeQuery(query, [reportId, userId]);

    if (!result.success || result.data.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Report not found or expired'
      });
    }

    const report = result.data[0];
    const filePath = path.join(__dirname, '../uploads/reports', report.file_path);

    // Check if file exists
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        message: 'Report file not found'
      });
    }

    // Increment download count
    const updateQuery = 'UPDATE reports SET download_count = download_count + 1 WHERE report_id = ?';
    await executeQuery(updateQuery, [reportId]);

    // Send file
    const mimeTypes = {
      'pdf': 'application/pdf',
      'excel': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'csv': 'text/csv'
    };

    res.setHeader('Content-Type', mimeTypes[report.file_format] || 'application/octet-stream');
    res.setHeader('Content-Disposition', `attachment; filename="${report.file_path}"`);
    
    const fileStream = fs.createReadStream(filePath);
    fileStream.pipe(res);

  } catch (error) {
    console.error('Download report error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to download report'
    });
  }
};

// Helper function to get report data
const getReportData = async (reportType, period, date) => {
  let query = '';
  let params = [];
  
  // Build date filter based on period
  let dateFilter = '';
  const now = new Date();
  
  switch (period) {
    case 'today':
      dateFilter = 'DATE(created_at) = CURDATE()';
      break;
    case 'last7days':
      dateFilter = 'created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)';
      break;
    case 'last30days':
      dateFilter = 'created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)';
      break;
    case 'custom':
      if (date) {
        dateFilter = 'DATE(created_at) = ?';
        params.push(date);
      }
      break;
  }

  // Build query based on report type
  switch (reportType) {
    case 'kualitas-telur':
      query = `
        SELECT 
          egg_id,
          egg_code,
          quality,
          weight,
          length,
          width,
          height,
          quality_score,
          created_at
        FROM eggs
        ${dateFilter ? `WHERE ${dateFilter}` : ''}
        ORDER BY created_at DESC
      `;
      break;
      
    case 'performa-conveyor':
      // Mock data for conveyor performance
      return {
        total_operations: 150,
        successful_operations: 145,
        failed_operations: 5,
        average_speed: 65.5,
        uptime_percentage: 96.7,
        period: period,
        date: date
      };
      
    case 'statistik-produksi':
      query = `
        SELECT 
          DATE(created_at) as date,
          COUNT(*) as total_eggs,
          SUM(CASE WHEN quality = 'good' THEN 1 ELSE 0 END) as good_eggs,
          SUM(CASE WHEN quality = 'medium' THEN 1 ELSE 0 END) as medium_eggs,
          SUM(CASE WHEN quality = 'poor' THEN 1 ELSE 0 END) as poor_eggs,
          AVG(quality_score) as avg_quality_score
        FROM eggs
        ${dateFilter ? `WHERE ${dateFilter}` : ''}
        GROUP BY DATE(created_at)
        ORDER BY date DESC
      `;
      break;
      
    case 'riwayat-aktivitas':
      // Mock data for activity logs
      return {
        activities: [
          { timestamp: new Date(), action: 'System Start', user: 'System', details: 'Conveyor system started' },
          { timestamp: new Date(), action: 'Scan Complete', user: 'Scanner-001', details: 'Egg batch scanned successfully' }
        ],
        period: period,
        date: date
      };
      
    default:
      throw new Error('Unknown report type');
  }

  const result = await executeQuery(query, params);
  return result.success ? result.data : [];
};

// Generate PDF Report
const generatePDFReport = async (data, reportType, period, date) => {
  const doc = new PDFDocument();
  const fileName = `${reportType}_${period}_${Date.now()}.pdf`;
  const filePath = path.join(__dirname, '../uploads/reports', fileName);
  
  // Ensure directory exists
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  doc.pipe(fs.createWriteStream(filePath));

  // Add content to PDF
  doc.fontSize(20).text('Smarternak IoT Monitoring', 50, 50);
  doc.fontSize(16).text(`Laporan ${getReportTypeDisplayName(reportType)}`, 50, 80);
  doc.fontSize(12).text(`Periode: ${formatPeriodForDisplay(period, date)}`, 50, 110);
  doc.text(`Tanggal Generate: ${new Date().toLocaleDateString('id-ID')}`, 50, 130);

  // Add data based on report type
  if (Array.isArray(data) && data.length > 0) {
    doc.text('Data:', 50, 160);
    let yPosition = 180;
    
    data.slice(0, 20).forEach((item, index) => { // Limit to 20 items for PDF
      doc.text(`${index + 1}. ${JSON.stringify(item)}`, 50, yPosition);
      yPosition += 20;
    });
  } else {
    doc.text('Tidak ada data untuk periode yang dipilih.', 50, 160);
  }

  doc.end();

  return { filePath, fileName };
};

// Generate Excel Report
const generateExcelReport = async (data, reportType, period, date) => {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet('Report');
  
  const fileName = `${reportType}_${period}_${Date.now()}.xlsx`;
  const filePath = path.join(__dirname, '../uploads/reports', fileName);
  
  // Ensure directory exists
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  // Add headers
  worksheet.addRow(['Smarternak IoT Monitoring Report']);
  worksheet.addRow([`Laporan: ${getReportTypeDisplayName(reportType)}`]);
  worksheet.addRow([`Periode: ${formatPeriodForDisplay(period, date)}`]);
  worksheet.addRow([`Tanggal Generate: ${new Date().toLocaleDateString('id-ID')}`]);
  worksheet.addRow([]);

  // Add data
  if (Array.isArray(data) && data.length > 0) {
    const headers = Object.keys(data[0]);
    worksheet.addRow(headers);
    
    data.forEach(item => {
      const row = headers.map(header => item[header]);
      worksheet.addRow(row);
    });
  } else {
    worksheet.addRow(['Tidak ada data untuk periode yang dipilih']);
  }

  await workbook.xlsx.writeFile(filePath);
  return { filePath, fileName };
};

// Generate CSV Report
const generateCSVReport = async (data, reportType, period, date) => {
  const fileName = `${reportType}_${period}_${Date.now()}.csv`;
  const filePath = path.join(__dirname, '../uploads/reports', fileName);
  
  // Ensure directory exists
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  let csvContent = `Smarternak IoT Monitoring Report\n`;
  csvContent += `Laporan: ${getReportTypeDisplayName(reportType)}\n`;
  csvContent += `Periode: ${formatPeriodForDisplay(period, date)}\n`;
  csvContent += `Tanggal Generate: ${new Date().toLocaleDateString('id-ID')}\n\n`;

  if (Array.isArray(data) && data.length > 0) {
    const headers = Object.keys(data[0]);
    csvContent += headers.join(',') + '\n';
    
    data.forEach(item => {
      const row = headers.map(header => `"${item[header] || ''}"`);
      csvContent += row.join(',') + '\n';
    });
  } else {
    csvContent += 'Tidak ada data untuk periode yang dipilih\n';
  }

  fs.writeFileSync(filePath, csvContent, 'utf8');
  return { filePath, fileName };
};

// Helper functions
const getReportTypeDisplayName = (reportType) => {
  const names = {
    'kualitas-telur': 'Laporan Kualitas Telur',
    'performa-conveyor': 'Laporan Performa Conveyor', 
    'statistik-produksi': 'Laporan Statistik Produksi',
    'riwayat-aktivitas': 'Laporan Riwayat Aktivitas'
  };
  
  const result = names[reportType] || `Laporan Tidak Diketahui (${reportType})`;
  
  return result;
};

const formatPeriodForDisplay = (period, date) => {
  const periods = {
    'today': 'Hari Ini',
    'last7days': '7 Hari Terakhir',
    'last30days': '30 Hari Terakhir',
    'custom': date ? `Tanggal ${new Date(date).toLocaleDateString('id-ID')}` : 'Tanggal Tertentu'
  };
  
  const result = periods[period] || `Periode Tidak Diketahui (${period})`;
  
  return result;
};

module.exports = {
  generateReport,
  getReportHistory,
  downloadReport
}; 