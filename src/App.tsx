import React from 'react';
import { 
  CssBaseline, 
  Container, 
  Box, 
  CircularProgress, 
  Typography,
  ThemeProvider,
  createTheme
} from '@mui/material';
import { 
  BrowserRouter as Router, 
  Routes, 
  Route, 
  Navigate,
  useNavigate,
  useLocation
} from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import LoginPage from './pages/LoginPage';
import AppBar from './components/AppBar';
import AdminDashboard from './components/dashboard/AdminDashboard';
import LoadingRecordsPage from './pages/loading/LoadingRecordsPage';

// Create a theme instance with the new color scheme
const theme = createTheme({
  palette: {
    primary: {
      main: '#d32f2f', // red
      dark: '#b71c1c',
      light: '#ef5350',
      contrastText: '#ffffff',
    },
    secondary: {
      main: '#ff6d00', // orange
      dark: '#e65100',
      light: '#ff9e40',
      contrastText: '#ffffff',
    },
    error: {
      main: '#d32f2f',
    },
    warning: {
      main: '#f57c00',
    },
    info: {
      main: '#0288d1',
    },
    success: {
      main: '#388e3c',
    },
    background: {
      default: '#f5f5f5',
      paper: '#ffffff',
    },
    text: {
      primary: '#212121',
      secondary: '#757575',
    },
  },
  typography: {
    fontFamily: [
      '-apple-system',
      'BlinkMacSystemFont',
      '"Segoe UI"',
      'Roboto',
      '"Helvetica Neue"',
      'Arial',
      'sans-serif',
    ].join(','),
    h1: { 
      color: '#212121',
      fontWeight: 500,
    },
    h2: { 
      color: '#212121',
      fontWeight: 500,
    },
    h3: { 
      color: '#212121',
      fontWeight: 500,
    },
    h4: { 
      color: '#212121',
      fontWeight: 500,
    },
    h5: { 
      color: '#212121',
      fontWeight: 500,
    },
    h6: { 
      color: '#212121',
      fontWeight: 500,
    },
    button: {
      textTransform: 'none',
      fontWeight: 500,
    },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 4,
          padding: '8px 16px',
        },
        contained: {
          boxShadow: 'none',
          '&:hover': {
            boxShadow: '0px 2px 4px -1px rgba(0,0,0,0.2), 0px 4px 5px 0px rgba(0,0,0,0.14), 0px 1px 10px 0px rgba(0,0,0,0.12)',
          },
        },
      },
    },
    MuiAppBar: {
      styleOverrides: {
        root: {
          boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          boxShadow: '0 2px 8px rgba(0,0,0,0.05)',
          '&:hover': {
            boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
          },
        },
      },
    },
    MuiTextField: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-root': {
            '&:hover fieldset': {
              borderColor: '#d32f2f',
            },
            '&.Mui-focused fieldset': {
              borderColor: '#d32f2f',
            },
          },
        },
      },
    },
  },
});

// Main app content that requires authentication
const AuthenticatedApp = () => {
  const { user } = useAuth();

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  return (
    <ThemeProvider theme={theme}>
      <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
        <AppBar />
        <Box component="main" sx={{ flex: 1, py: 4, bgcolor: 'background.default' }}>
          <Container maxWidth="lg">
            <Routes>
              <Route path="/" element={
                <ProtectedRoute>
                  <AdminDashboard />
                </ProtectedRoute>
              } />
              
              {/* Loading Records Routes */}
              <Route path="/loading/records" element={
                <ProtectedRoute allowedRoles={['LOADING_ADMIN', 'OVERALL_ADMIN']}>
                  <LoadingRecordsPage />
                </ProtectedRoute>
              } />
              
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </Container>
        </Box>
      </Box>
    </ThemeProvider>
  );
};

// Authentication routes
const AuthRoutes = () => (
  <Routes>
    <Route path="/login" element={<LoginPage />} />
    <Route path="/unauthorized" element={
      <Box textAlign="center" mt={10}>
        <Typography variant="h4">Unauthorized</Typography>
        <Typography>You don't have permission to view this page.</Typography>
      </Box>
    } />
    <Route path="*" element={<Navigate to="/login" replace />} />
  </Routes>
);

// Main App component with routing
const App = () => {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="100vh">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Router>
      <CssBaseline />
      {user ? <AuthenticatedApp /> : <AuthRoutes />}
    </Router>
  );
};

// Wrap with AuthProvider
const AppWithProviders = () => (
  <AuthProvider>
    <App />
  </AuthProvider>
);

export default AppWithProviders;
