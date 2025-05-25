import { useState, useEffect } from 'react';
import {
  getConveyorStatus,
  getConveyorStatistics,
  getConveyorLogs,
  startConveyor,
  stopConveyor,
  pauseConveyor,
  getConveyorRealTimeData,
  getStatusBadgeClass,
  getStatusText,
  formatLogTime
} from '../services/conveyorService';

const PantauConveyor = () => {
  const [status, setStatus] = useState('Tidak Diketahui');
  const [eggCount, setEggCount] = useState(0);
  const [totalCapacity, setTotalCapacity] = useState(1500);
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isControlling, setIsControlling] = useState(false);
  const [lastUpdate, setLastUpdate] = useState(new Date());

  // Load conveyor status
  const loadConveyorStatus = async () => {
    try {
      const response = await getConveyorStatus();
      if (response.success) {
        setStatus(getStatusText(response.data.status));
      }
    } catch (error) {
      console.error('Error loading conveyor status:', error);
    }
  };

  // Load conveyor statistics
  const loadConveyorStatistics = async () => {
    try {
      const response = await getConveyorStatistics();
      if (response.success) {
        setEggCount(response.data.eggs_scanned || 0);
        setTotalCapacity(response.data.total_capacity || 1500);
      }
    } catch (error) {
      console.error('Error loading conveyor statistics:', error);
    }
  };

  // Load conveyor logs
  const loadConveyorLogs = async () => {
    try {
      const response = await getConveyorLogs({ limit: 20, sort_order: 'DESC' });
      if (response.success) {
        setLogs(response.data.logs || []);
      }
    } catch (error) {
      console.error('Error loading conveyor logs:', error);
      // Fallback to empty array if API fails
      setLogs([]);
    }
  };

  // Load all data
  const loadAllData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      await Promise.all([
        loadConveyorStatus(),
        loadConveyorStatistics(),
        loadConveyorLogs()
      ]);
      
      setLastUpdate(new Date());
    } catch (error) {
      console.error('Error loading conveyor data:', error);
      setError('Gagal memuat data conveyor');
    } finally {
      setLoading(false);
    }
  };

  // Handle conveyor control actions
  const handleConveyorAction = async (action, actionFunction) => {
    try {
      setIsControlling(true);
      setError(null);
      
      const response = await actionFunction();
      
      if (response.success) {
        // Update status immediately
        setStatus(getStatusText(response.data.status));
        
        // Reload logs to get the latest activity
        await loadConveyorLogs();
        
        // Update last update time
        setLastUpdate(new Date());
      } else {
        setError(response.message || `Gagal ${action} conveyor`);
      }
    } catch (error) {
      console.error(`Error ${action} conveyor:`, error);
      setError(`Terjadi kesalahan saat ${action} conveyor`);
    } finally {
      setIsControlling(false);
    }
  };

  const handleStart = () => handleConveyorAction('memulai', startConveyor);
  const handleStop = () => handleConveyorAction('menghentikan', stopConveyor);
  const handlePause = () => handleConveyorAction('menjeda', pauseConveyor);

  const handleRefreshLogs = async () => {
    try {
      setError(null);
      await loadAllData();
    } catch (error) {
      console.error('Error refreshing data:', error);
      setError('Gagal memperbarui data');
    }
  };

  // Auto-refresh data every 30 seconds
  useEffect(() => {
    loadAllData();
    
    const interval = setInterval(() => {
      loadAllData();
    }, 30000); // 30 seconds

    return () => clearInterval(interval);
  }, []);

  if (loading && logs.length === 0) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="flex justify-center items-center h-64">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
          <span className="ml-3 text-gray-600 dark:text-gray-300">Memuat data conveyor...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 py-6">
      {/* Header Section with Gradient Background */}
      <div className="bg-gradient-to-r from-blue-600 to-indigo-700 dark:from-blue-700 dark:to-indigo-800 rounded-2xl mb-8 shadow-lg">
        <div className="px-8 py-10 text-white">
          <h1 className="text-3xl font-bold mb-2">Pantau Conveyor</h1>
          <p className="text-blue-100">Monitoring real-time status dan kontrol operasi conveyor.</p>
          <div className="flex items-center gap-2 mt-4 text-blue-200 text-sm">
            <i className="fas fa-clock"></i>
            <span>Terakhir diperbarui: {lastUpdate.toLocaleTimeString('id-ID')}</span>
          </div>
        </div>
      </div>

      {/* Error Message */}
      {error && (
        <div className="bg-red-100 dark:bg-red-900 border border-red-400 dark:border-red-700 text-red-700 dark:text-red-300 px-4 py-3 rounded-xl mb-6">
          <div className="flex items-center">
            <i className="fas fa-exclamation-triangle mr-2"></i>
            <span>{error}</span>
            <button 
              onClick={() => {
                setError(null);
                loadAllData();
              }}
              className="ml-auto text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-200"
            >
              <i className="fas fa-redo"></i>
            </button>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        {/* Status Conveyor Card */}
        <div className="bg-gradient-to-br from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20 p-6 rounded-2xl shadow-md border border-green-100 dark:border-green-800">
          <h2 className="text-xl font-semibold text-gray-800 dark:text-gray-100 mb-6">Status Conveyor</h2>
          <div className="flex items-center">
            <div className={`w-4 h-4 rounded-full mr-3 ${getStatusBadgeClass(status)}`}></div>
            <span className="text-2xl font-medium text-gray-800 dark:text-gray-100">
              {status}
            </span>
            {loading && (
              <div className="ml-3">
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-green-500"></div>
              </div>
            )}
          </div>
        </div>

        {/* Telur Terpindai Card */}
        <div className="bg-gradient-to-br from-purple-50 to-pink-50 dark:from-purple-900/20 dark:to-pink-900/20 p-6 rounded-2xl shadow-md border border-purple-100 dark:border-purple-800">
          <h2 className="text-xl font-semibold text-gray-800 dark:text-gray-100 mb-6">Telur Terpindai</h2>
          <div className="flex items-center justify-between">
            <div className="text-3xl font-bold text-gray-800 dark:text-gray-100">
              {eggCount.toLocaleString('id-ID')} <span className="text-gray-500 dark:text-gray-400 text-xl">/ {totalCapacity.toLocaleString('id-ID')}</span>
            </div>
            <div className="text-purple-600 dark:text-purple-400">
              <i className="fas fa-egg text-3xl"></i>
            </div>
          </div>
          <div className="mt-4 w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2.5">
            <div 
              className="bg-purple-600 dark:bg-purple-500 h-2.5 rounded-full transition-all duration-500" 
              style={{ width: `${Math.min((eggCount / totalCapacity) * 100, 100)}%` }}
            ></div>
          </div>
          <div className="text-right mt-2 text-sm text-gray-500 dark:text-gray-400">
            {Math.round((eggCount / totalCapacity) * 100)}% Kapasitas
          </div>
        </div>
      </div>

      {/* Control Section */}
      <div className="bg-white dark:bg-gray-800 p-8 rounded-2xl shadow-md mb-8 border border-gray-100 dark:border-gray-700">
        <h2 className="text-xl font-semibold text-gray-800 dark:text-gray-100 mb-6">Kontrol Conveyor</h2>
        
        <div className="flex flex-wrap gap-4">
          <button 
            onClick={handleStart}
            disabled={isControlling || loading}
            className="px-8 py-4 bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-xl hover:opacity-90 shadow-md font-medium transition-all flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isControlling ? (
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
            ) : (
              <i className="fas fa-play"></i>
            )}
            <span>Start</span>
          </button>
          
          <button 
            onClick={handleStop}
            disabled={isControlling || loading}
            className="px-8 py-4 bg-gradient-to-r from-red-500 to-red-600 text-white rounded-xl hover:opacity-90 shadow-md font-medium transition-all flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isControlling ? (
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
            ) : (
              <i className="fas fa-stop"></i>
            )}
            <span>Stop</span>
          </button>
          
          <button 
            onClick={handlePause}
            disabled={isControlling || loading}
            className="px-8 py-4 bg-gradient-to-r from-yellow-500 to-amber-600 text-white rounded-xl hover:opacity-90 shadow-md font-medium transition-all flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isControlling ? (
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
            ) : (
              <i className="fas fa-pause"></i>
            )}
            <span>Pause</span>
          </button>
        </div>
      </div>

      {/* Log Section */}
      <div className="bg-white dark:bg-gray-800 p-8 rounded-2xl shadow-md border border-gray-100 dark:border-gray-700">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-semibold text-gray-800 dark:text-gray-100">Log Operasi</h2>
          <div className="flex items-center gap-3">
            <div className="bg-blue-50 dark:bg-blue-900 px-3 py-1.5 rounded-lg text-blue-700 dark:text-blue-300 text-sm font-medium">
              {logs.length} aktivitas
            </div>
            <button 
              onClick={handleRefreshLogs}
              disabled={loading}
              className="bg-blue-500 hover:bg-blue-600 dark:bg-blue-600 dark:hover:bg-blue-700 text-white p-2 rounded-lg transition-colors flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed"
              title="Refresh Log"
            >
              {loading ? (
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
              ) : (
                <i className="fas fa-sync-alt"></i>
              )}
            </button>
          </div>
        </div>
        
        {loading && logs.length === 0 ? (
          <div className="flex justify-center items-center h-32">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
            <span className="ml-3 text-gray-600 dark:text-gray-300">Memuat log operasi...</span>
          </div>
        ) : logs.length === 0 ? (
          <div className="text-center py-12">
            <i className="fas fa-clipboard-list text-4xl text-gray-300 dark:text-gray-600 mb-4"></i>
            <p className="text-gray-500 dark:text-gray-400 text-lg">Belum ada log operasi</p>
            <p className="text-gray-400 dark:text-gray-500 text-sm mt-2">Log akan muncul setelah conveyor mulai beroperasi</p>
          </div>
        ) : (
          <div className="space-y-4 max-h-[400px] overflow-y-auto pr-2">
            {logs.map((log, index) => (
              <div key={log.id || index} className="flex items-start border-l-4 border-blue-500 dark:border-blue-400 pl-4 py-2 bg-gray-50 dark:bg-gray-700 rounded-r-lg">
                <div className="bg-blue-100 dark:bg-blue-800 text-blue-800 dark:text-blue-200 px-2 py-1 rounded text-xs font-medium mr-3">
                  [{formatLogTime(log.timestamp || log.created_at)}]
                </div>
                <div className="text-gray-700 dark:text-gray-300">{log.message || log.activity}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default PantauConveyor; 