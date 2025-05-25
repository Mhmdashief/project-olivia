import { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const Sidebar = ({ isOpen, onClose }) => {
  const location = useLocation();
  const { user, isSuperAdmin, logout } = useAuth();
  const [showLogoutModal, setShowLogoutModal] = useState(false);

  const menuItems = [
    {
      path: '/dashboard',
      name: 'Dashboard',
      icon: 'fas fa-tachometer-alt',
      requiredRole: null
    },
    {
      path: '/data-kualitas-telur',
      name: 'Data Kualitas Telur',
      icon: 'fas fa-egg',
      requiredRole: null
    },
    {
      path: '/pantau-conveyor',
      name: 'Pantau Conveyor',
      icon: 'fas fa-cogs',
      requiredRole: null
    },
    {
      path: '/unduh-laporan',
      name: 'Unduh Laporan',
      icon: 'fas fa-download',
      requiredRole: null
    },
    {
      path: '/manajemen-akun',
      name: 'Manajemen Akun',
      icon: 'fas fa-users-cog',
      requiredRole: 'superadmin',
      superAdminOnly: true
    },
    {
      path: '/pengaturan',
      name: 'Pengaturan',
      icon: 'fas fa-cog',
      requiredRole: null
    }
  ];

  const handleLogout = () => {
    logout();
    setShowLogoutModal(false);
  };

  // Filter menu items based on user role
  const filteredMenuItems = menuItems.filter(item => {
    if (item.superAdminOnly && !isSuperAdmin()) {
      return false;
    }
    return true;
  });

  return (
    <>
      {/* Overlay for mobile */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
          onClick={onClose}
        ></div>
      )}

      {/* Sidebar */}
      <div className={`fixed left-0 top-0 h-full w-64 bg-white dark:bg-gray-800 shadow-lg transform transition-transform duration-300 ease-in-out z-50 ${
        isOpen ? 'translate-x-0' : '-translate-x-full'
      } lg:translate-x-0 lg:static lg:z-auto border-r border-gray-200 dark:border-gray-700`}>
        
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-700">
          <div className="flex items-center">
            <div className="w-10 h-10 bg-gradient-to-r from-blue-500 to-indigo-600 rounded-lg flex items-center justify-center mr-3">
              <i className="fas fa-egg text-white text-lg"></i>
            </div>
            <div>
              <h1 className="text-xl font-bold text-gray-800 dark:text-white">Smarternak</h1>
              <p className="text-xs text-gray-500 dark:text-gray-400">IoT Monitoring</p>
            </div>
          </div>
          <button 
            onClick={onClose}
            className="lg:hidden text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200"
          >
            <i className="fas fa-times text-xl"></i>
          </button>
        </div>

        {/* User Info */}
        <div className="p-4 border-b border-gray-200 dark:border-gray-700">
          <div className="flex items-center">
            <div className="w-10 h-10 bg-gradient-to-r from-purple-500 to-indigo-600 rounded-full flex items-center justify-center text-white font-medium">
              {user?.name?.charAt(0)?.toUpperCase() || 'U'}
            </div>
            <div className="ml-3">
              <p className="text-sm font-medium text-gray-900 dark:text-white">{user?.name}</p>
              <p className="text-xs text-gray-500 dark:text-gray-400 capitalize">{user?.role}</p>
            </div>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-4">
          <ul className="space-y-2">
            {filteredMenuItems.map((item) => {
              const isActive = location.pathname === item.path;
              return (
                <li key={item.path}>
                  <Link
                    to={item.path}
                    onClick={onClose}
                    className={`flex items-center px-4 py-3 rounded-lg transition-all duration-200 group ${
                      isActive
                        ? 'bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 border-r-2 border-blue-600 dark:border-blue-400'
                        : 'text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 hover:text-blue-600 dark:hover:text-blue-400'
                    }`}
                  >
                    <i className={`${item.icon} w-5 text-center mr-3 ${
                      isActive ? 'text-blue-600 dark:text-blue-400' : 'text-gray-400 dark:text-gray-500 group-hover:text-blue-600 dark:group-hover:text-blue-400'
                    }`}></i>
                    <span className="font-medium">{item.name}</span>
                    {item.superAdminOnly && (
                      <span className="ml-auto text-xs bg-purple-100 dark:bg-purple-900 text-purple-600 dark:text-purple-300 px-2 py-1 rounded-full">
                        Super
                      </span>
                    )}
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>

        {/* Logout Button */}
        <div className="p-4 border-t border-gray-200 dark:border-gray-700">
          <button
            onClick={() => setShowLogoutModal(true)}
            className="w-full flex items-center px-4 py-3 text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors duration-200"
          >
            <i className="fas fa-sign-out-alt w-5 text-center mr-3"></i>
            <span className="font-medium">Logout</span>
          </button>
        </div>
      </div>

      {/* Logout Confirmation Modal */}
      {showLogoutModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-sm w-full border border-gray-100 dark:border-gray-700">
            <div className="p-6">
              <div className="flex items-center mb-4">
                <div className="w-12 h-12 bg-red-100 dark:bg-red-900 rounded-full flex items-center justify-center mr-4">
                  <i className="fas fa-sign-out-alt text-red-600 dark:text-red-400 text-xl"></i>
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 dark:text-white">Konfirmasi Logout</h3>
                  <p className="text-sm text-gray-500 dark:text-gray-400">Apakah Anda yakin ingin keluar?</p>
                </div>
              </div>
              
              <div className="flex justify-end gap-3">
                <button
                  onClick={() => setShowLogoutModal(false)}
                  className="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                >
                  Batal
                </button>
                <button
                  onClick={handleLogout}
                  className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
                >
                  Logout
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default Sidebar; 