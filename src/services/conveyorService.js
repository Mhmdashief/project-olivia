import { apiClient } from './api';

// Get current conveyor status
export const getConveyorStatus = async () => {
  try {
    const response = await apiClient.get('/conveyor/status');
    return response;
  } catch (error) {
    console.error('Get conveyor status error:', error);
    throw error;
  }
};

// Get conveyor statistics (egg count, capacity, etc.)
export const getConveyorStatistics = async () => {
  try {
    const response = await apiClient.get('/conveyor/statistics');
    return response;
  } catch (error) {
    console.error('Get conveyor statistics error:', error);
    throw error;
  }
};

// Get conveyor operation logs
export const getConveyorLogs = async (params = {}) => {
  try {
    const queryParams = new URLSearchParams();
    
    // Add parameters to query string
    Object.keys(params).forEach(key => {
      if (params[key] !== undefined && params[key] !== null && params[key] !== '') {
        queryParams.append(key, params[key]);
      }
    });

    const response = await apiClient.get(`/conveyor/logs?${queryParams.toString()}`);
    return response;
  } catch (error) {
    console.error('Get conveyor logs error:', error);
    throw error;
  }
};

// Start conveyor
export const startConveyor = async () => {
  try {
    const response = await apiClient.post('/conveyor/start');
    return response;
  } catch (error) {
    console.error('Start conveyor error:', error);
    throw error;
  }
};

// Stop conveyor
export const stopConveyor = async () => {
  try {
    const response = await apiClient.post('/conveyor/stop');
    return response;
  } catch (error) {
    console.error('Stop conveyor error:', error);
    throw error;
  }
};

// Pause conveyor
export const pauseConveyor = async () => {
  try {
    const response = await apiClient.post('/conveyor/pause');
    return response;
  } catch (error) {
    console.error('Pause conveyor error:', error);
    throw error;
  }
};

// Get conveyor real-time data
export const getConveyorRealTimeData = async () => {
  try {
    const response = await apiClient.get('/conveyor/realtime');
    return response;
  } catch (error) {
    console.error('Get conveyor real-time data error:', error);
    throw error;
  }
};

// Helper function to format conveyor status
export const getStatusBadgeClass = (status) => {
  switch (status?.toLowerCase()) {
    case 'aktif':
    case 'active':
    case 'running':
      return 'bg-green-500';
    case 'dijeda':
    case 'paused':
      return 'bg-yellow-500';
    case 'tidak aktif':
    case 'inactive':
    case 'stopped':
      return 'bg-red-500';
    default:
      return 'bg-gray-500';
  }
};

// Helper function to format status text
export const getStatusText = (status) => {
  switch (status?.toLowerCase()) {
    case 'active':
    case 'running':
      return 'Aktif';
    case 'paused':
      return 'Dijeda';
    case 'inactive':
    case 'stopped':
      return 'Tidak Aktif';
    default:
      return status || 'Tidak Diketahui';
  }
};

// Helper function to format log time
export const formatLogTime = (timestamp) => {
  if (!timestamp) return '';
  
  const date = new Date(timestamp);
  return date.toLocaleTimeString('id-ID', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  });
};

// Helper function to format log date and time
export const formatLogDateTime = (timestamp) => {
  if (!timestamp) return '';
  
  const date = new Date(timestamp);
  return date.toLocaleString('id-ID', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  });
};

export default {
  getConveyorStatus,
  getConveyorStatistics,
  getConveyorLogs,
  startConveyor,
  stopConveyor,
  pauseConveyor,
  getConveyorRealTimeData,
  getStatusBadgeClass,
  getStatusText,
  formatLogTime,
  formatLogDateTime
}; 