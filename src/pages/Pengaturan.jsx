import { useState, useEffect } from 'react';
import { useTheme } from '../contexts/ThemeContext';
import { useAuth } from '../contexts/AuthContext';

const Pengaturan = () => {
  const { isDarkMode, toggleTheme } = useTheme();
  const { user, updateProfile } = useAuth();
  const [activeTab, setActiveTab] = useState('profile');
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [isAvatarLoading, setIsAvatarLoading] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });
  const [profileData, setProfileData] = useState({
    name: '',
    email: '',
    phone: '',
    role: '',
    avatar_url: null,
    bio: ''
  });

  const [securitySettings, setSecuritySettings] = useState({
    twoFactor: false,
    loginNotifications: true,
    sessionTimeout: '30',
    passwordLastChanged: '2023-05-15'
  });

  const tabs = [
    { id: 'profile', label: 'Profil', icon: 'user' },
    { id: 'account', label: 'Akun', icon: 'cog' },
    { id: 'security', label: 'Keamanan', icon: 'shield-alt' }
  ];

  // Load user data when component mounts or user changes
  useEffect(() => {
    if (user) {
      setProfileData({
        name: user.name || '',
        email: user.email || '',
        phone: user.phone || '',
        role: user.role || '',
        avatar_url: user.avatar_url || null,
        bio: user.bio || ''
      });
    }
  }, [user]);

  const handleProfileSave = async () => {
    try {
      setIsSaving(true);
      setMessage({ type: '', text: '' });

      const result = await updateProfile({
        name: profileData.name,
        phone: profileData.phone,
        bio: profileData.bio,
        avatar_url: profileData.avatar_url
      });

      if (result.success) {
        setMessage({ type: 'success', text: 'Profil berhasil diperbarui' });
        setIsEditing(false);
      } else {
        setMessage({ type: 'error', text: result.message || 'Gagal memperbarui profil' });
      }
    } catch (error) {
      console.error('Error saving profile:', error);
      setMessage({ type: 'error', text: 'Terjadi kesalahan saat menyimpan profil' });
    } finally {
      setIsSaving(false);
      // Auto hide message after 3 seconds
      setTimeout(() => {
        setMessage({ type: '', text: '' });
      }, 3000);
    }
  };

  const handleAvatarChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      // Validate file type
      if (!file.type.startsWith('image/')) {
        setMessage({ type: 'error', text: 'File harus berupa gambar' });
        return;
      }

      // Validate file size (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        setMessage({ type: 'error', text: 'Ukuran gambar terlalu besar (maks 5MB)' });
        return;
      }

      // Show loading indicator
      setIsAvatarLoading(true);

      const reader = new FileReader();
      reader.onload = (e) => {
        setProfileData(prev => ({ ...prev, avatar_url: e.target.result }));
        setIsAvatarLoading(false);
      };
      reader.onerror = () => {
        setMessage({ type: 'error', text: 'Gagal memproses gambar' });
        setIsAvatarLoading(false);
      };
      reader.readAsDataURL(file);
    }
  };

  const renderProfileTab = () => (
    <div className="space-y-6">
      {/* Status Message */}
      {message.text && (
        <div className={`${
          message.type === 'success' 
            ? 'bg-green-100 dark:bg-green-900/30 border-green-400 dark:border-green-700 text-green-700 dark:text-green-300' 
            : 'bg-red-100 dark:bg-red-900/30 border-red-400 dark:border-red-700 text-red-700 dark:text-red-300'
        } px-4 py-3 rounded-xl border`}>
          <div className="flex items-center">
            <i className={`fas fa-${message.type === 'success' ? 'check-circle' : 'exclamation-triangle'} mr-2`}></i>
            <span>{message.text}</span>
          </div>
        </div>
      )}
      
      {/* Theme Toggle */}
      <div className="bg-white dark:bg-gray-800 p-6 rounded-2xl shadow-md border border-gray-100 dark:border-gray-700">
        <h3 className="text-lg font-semibold text-gray-800 dark:text-gray-100 mb-4">Tema Aplikasi</h3>
        <div className="flex justify-between items-center p-4 border border-gray-200 dark:border-gray-600 rounded-lg">
          <div>
            <h4 className="font-medium text-gray-800 dark:text-gray-200">Mode Gelap</h4>
            <p className="text-sm text-gray-600 dark:text-gray-400">Ubah tampilan aplikasi ke mode gelap</p>
          </div>
          <label className="relative inline-flex items-center cursor-pointer">
            <input
              type="checkbox"
              checked={isDarkMode}
              onChange={toggleTheme}
              className="sr-only peer"
            />
            <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
          </label>
        </div>
      </div>

      {/* Avatar Section */}
      <div className="bg-white dark:bg-gray-800 p-6 rounded-2xl shadow-md border border-gray-100 dark:border-gray-700">
        <h3 className="text-lg font-semibold text-gray-800 dark:text-gray-100 mb-4">Foto Profil</h3>
        <div className="flex items-center space-x-6">
          <div className="relative">
            <div className="w-24 h-24 rounded-full bg-gradient-to-r from-blue-500 to-purple-600 flex items-center justify-center text-white text-2xl font-bold">
              {isAvatarLoading ? (
                <div className="flex items-center justify-center">
                  <i className="fas fa-spinner fa-spin text-white"></i>
                </div>
              ) : profileData.avatar_url ? (
                <img src={profileData.avatar_url} alt="Avatar" className="w-24 h-24 rounded-full object-cover" />
              ) : (
                profileData.name.charAt(0)
              )}
            </div>
            {isEditing && (
              <label className="absolute bottom-0 right-0 bg-blue-500 text-white p-2 rounded-full cursor-pointer hover:bg-blue-600 transition-colors">
                <i className="fas fa-camera text-sm"></i>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleAvatarChange}
                  disabled={isAvatarLoading}
                  className="hidden"
                />
              </label>
            )}
          </div>
          <div>
            <h4 className="text-xl font-semibold text-gray-800 dark:text-gray-100">{profileData.name}</h4>
            <p className="text-gray-600 dark:text-gray-300">{profileData.role}</p>
            <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">{profileData.email}</p>
          </div>
        </div>
      </div>

      {/* Profile Information */}
      <div className="bg-white dark:bg-gray-800 p-6 rounded-2xl shadow-md border border-gray-100 dark:border-gray-700">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold text-gray-800 dark:text-gray-100">Informasi Profil</h3>
          <button
            onClick={() => isEditing ? handleProfileSave() : setIsEditing(true)}
            disabled={isSaving}
            className={`px-4 py-2 rounded-lg font-medium transition-colors ${
              isEditing 
                ? 'bg-green-500 hover:bg-green-600 text-white' 
                : 'bg-blue-500 hover:bg-blue-600 text-white'
            } ${isSaving ? 'opacity-75 cursor-not-allowed' : ''}`}
          >
            {isSaving ? (
              <>
                <i className="fas fa-spinner fa-spin mr-2"></i>
                Menyimpan...
              </>
            ) : (
              <>
                <i className={`fas fa-${isEditing ? 'save' : 'edit'} mr-2`}></i>
                {isEditing ? 'Simpan' : 'Edit'}
              </>
            )}
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Nama Lengkap</label>
            <input
              type="text"
              value={profileData.name}
              onChange={(e) => setProfileData(prev => ({ ...prev, name: e.target.value }))}
              disabled={!isEditing || isSaving}
              className={`w-full border rounded-lg px-4 py-2 ${
                isEditing 
                  ? 'border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-blue-500 focus:border-blue-500' 
                  : 'border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-100'
              } focus:outline-none ${isSaving ? 'opacity-75 cursor-not-allowed' : ''}`}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Email</label>
            <input
              type="email"
              value={profileData.email}
              disabled={true} // Email can't be edited
              className="w-full border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 rounded-lg px-4 py-2 text-gray-900 dark:text-gray-100"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Nomor Telepon</label>
            <input
              type="tel"
              value={profileData.phone}
              onChange={(e) => setProfileData(prev => ({ ...prev, phone: e.target.value }))}
              disabled={!isEditing || isSaving}
              className={`w-full border rounded-lg px-4 py-2 ${
                isEditing 
                  ? 'border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-blue-500 focus:border-blue-500' 
                  : 'border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-100'
              } focus:outline-none ${isSaving ? 'opacity-75 cursor-not-allowed' : ''}`}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Role</label>
            <input
              type="text"
              value={profileData.role}
              disabled
              className="w-full border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 rounded-lg px-4 py-2 text-gray-600 dark:text-gray-400"
            />
          </div>
        </div>

        <div className="mt-6">
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Bio</label>
          <textarea
            value={profileData.bio}
            onChange={(e) => setProfileData(prev => ({ ...prev, bio: e.target.value }))}
            disabled={!isEditing || isSaving}
            rows={3}
            className={`w-full border rounded-lg px-4 py-2 ${
              isEditing 
                ? 'border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-blue-500 focus:border-blue-500' 
                : 'border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-100'
            } focus:outline-none ${isSaving ? 'opacity-75 cursor-not-allowed' : ''}`}
          />
        </div>
      </div>
    </div>
  );

  const renderAccountTab = () => (
    <div className="space-y-6">
      {/* Change Password */}
      <div className="bg-white dark:bg-gray-800 p-6 rounded-2xl shadow-md border border-gray-100 dark:border-gray-700">
        <h3 className="text-lg font-semibold text-gray-800 dark:text-gray-100 mb-4">Ubah Password</h3>
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Password Lama</label>
            <input
              type="password"
              className="w-full border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Masukkan password lama"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Password Baru</label>
            <input
              type="password"
              className="w-full border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Masukkan password baru"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Konfirmasi Password Baru</label>
            <input
              type="password"
              className="w-full border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Konfirmasi password baru"
            />
          </div>
          <button className="bg-blue-500 hover:bg-blue-600 dark:bg-blue-600 dark:hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-medium transition-colors">
            Update Password
          </button>
        </div>
      </div>

      {/* Account Actions */}
      <div className="bg-white dark:bg-gray-800 p-6 rounded-2xl shadow-md border border-gray-100 dark:border-gray-700">
        <h3 className="text-lg font-semibold text-gray-800 dark:text-gray-100 mb-4">Aksi Akun</h3>
        <div className="space-y-4">
          <div className="flex justify-between items-center p-4 border border-red-200 dark:border-red-800 rounded-lg bg-red-50 dark:bg-red-900/20">
            <div>
              <h4 className="font-medium text-red-800 dark:text-red-300">Hapus Akun</h4>
              <p className="text-sm text-red-600 dark:text-red-400">Hapus akun secara permanen (tidak dapat dibatalkan)</p>
            </div>
            <button className="bg-red-500 hover:bg-red-600 dark:bg-red-600 dark:hover:bg-red-700 text-white px-4 py-2 rounded-lg font-medium transition-colors">
              Hapus Akun
            </button>
          </div>
        </div>
      </div>
    </div>
  );

  const renderSecurityTab = () => (
    <div className="space-y-6">
      {/* Login History */}
      <div className="bg-white dark:bg-gray-800 p-6 rounded-2xl shadow-md border border-gray-100 dark:border-gray-700">
        <h3 className="text-lg font-semibold text-gray-800 dark:text-gray-100 mb-4">Riwayat Login</h3>
        <div className="space-y-3">
          {[
            { time: '2023-06-23 14:30', device: 'Chrome - Windows', location: 'Jakarta, Indonesia', status: 'success', isCurrent: true },
            { time: '2023-06-22 09:15', device: 'Firefox - Windows', location: 'Jakarta, Indonesia', status: 'success', isCurrent: false },
            { time: '2023-06-21 16:45', device: 'Mobile App - Android', location: 'Jakarta, Indonesia', status: 'failed', isCurrent: false }
          ].map((login, index) => (
            <div key={index} className="flex items-center justify-between p-3 border border-gray-200 dark:border-gray-600 rounded-lg">
              <div className="flex items-center space-x-3">
                <div className={`w-3 h-3 rounded-full ${login.status === 'success' ? 'bg-green-500' : 'bg-red-500'}`}></div>
                <div>
                  <p className="text-sm font-medium text-gray-800 dark:text-gray-200">
                    {login.device} 
                    {login.isCurrent && <span className="ml-2 text-xs bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-300 px-2 py-1 rounded">Sesi Saat Ini</span>}
                  </p>
                  <p className="text-xs text-gray-600 dark:text-gray-400">{login.time} - {login.location}</p>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                <span className={`text-xs px-2 py-1 rounded ${
                  login.status === 'success' 
                    ? 'bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-300' 
                    : 'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-300'
                }`}>
                  {login.status === 'success' ? 'Berhasil' : 'Gagal'}
                </span>
                {login.status === 'success' && (
                  <button 
                    onClick={() => {
                      if (login.isCurrent) {
                        if (confirm('Anda akan logout dari sesi saat ini. Lanjutkan?')) {
                          console.log('Logging out current session');
                          // In real app, this would logout current user
                        }
                      } else {
                        console.log(`Logging out device: ${login.device}`);
                        // In real app, this would terminate the remote session
                      }
                    }}
                    className={`text-sm font-medium px-3 py-1 rounded border transition-colors ${
                      login.isCurrent 
                        ? 'text-orange-600 dark:text-orange-400 hover:text-orange-800 dark:hover:text-orange-300 border-orange-200 dark:border-orange-700 hover:bg-orange-50 dark:hover:bg-orange-900/20'
                        : 'text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300 border-red-200 dark:border-red-700 hover:bg-red-50 dark:hover:bg-red-900/20'
                    }`}
                  >
                    Logout
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  return (
    <div className="max-w-7xl mx-auto px-4 py-6">
      {/* Header Section */}
      <div className="bg-gradient-to-r from-blue-600 to-indigo-700 dark:from-blue-700 dark:to-indigo-800 rounded-2xl mb-8 shadow-lg">
        <div className="px-8 py-10 text-white">
          <h1 className="text-3xl font-bold mb-2">Pengaturan</h1>
          <p className="text-blue-100">Kelola profil, akun, dan preferensi sistem Anda.</p>
        </div>
      </div>

      <div className="flex flex-col lg:flex-row gap-6">
        {/* Sidebar Navigation */}
        <div className="lg:w-1/4">
          <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-md border border-gray-100 dark:border-gray-700 p-4">
            <nav className="space-y-2">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg text-left transition-colors ${
                    activeTab === tab.id
                      ? 'bg-blue-50 dark:bg-blue-900 text-blue-700 dark:text-blue-300 border border-blue-200 dark:border-blue-700'
                      : 'text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700'
                  }`}
                >
                  <i className={`fas fa-${tab.icon} text-lg`}></i>
                  <span className="font-medium">{tab.label}</span>
                </button>
              ))}
            </nav>
          </div>
        </div>

        {/* Main Content */}
        <div className="lg:w-3/4">
          {activeTab === 'profile' && renderProfileTab()}
          {activeTab === 'account' && renderAccountTab()}
          {activeTab === 'security' && renderSecurityTab()}
        </div>
      </div>
    </div>
  );
};

export default Pengaturan; 