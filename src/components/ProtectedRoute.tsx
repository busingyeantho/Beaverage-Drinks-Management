import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { UserRole } from '../types/user';
import { Box, CircularProgress } from '@mui/material';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredRole?: UserRole;
  allowedRoles?: UserRole[];
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ 
  children, 
  requiredRole,
  allowedRoles = []
}) => {
  const { user, isLoading } = useAuth();
  const location = useLocation();

  if (isLoading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="100vh">
        <CircularProgress />
      </Box>
    );
  }

  if (!user) {
    // Redirect to login page, but save the current location they were trying to go to
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // Check if user has required role or is in allowed roles
  const hasRequiredRole = requiredRole ? user.role === requiredRole : true;
  const hasAllowedRole = allowedRoles.length > 0 ? allowedRoles.includes(user.role) : true;
  
  if (!hasRequiredRole || !hasAllowedRole) {
    // User doesn't have the required role or is not in allowed roles
    return <Navigate to="/unauthorized" state={{ from: location }} replace />;
  }

  return <>{children}</>;
};

// Role-based route components
export const LoadingAdminRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <ProtectedRoute requiredRole="LOADING_ADMIN">
    {children}
  </ProtectedRoute>
);

export const ReturnsAdminRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <ProtectedRoute requiredRole="RETURNS_ADMIN">
    {children}
  </ProtectedRoute>
);

export const CashierManagerRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <ProtectedRoute requiredRole="CASHIER_MANAGER">
    {children}
  </ProtectedRoute>
);

export const OverallAdminRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <ProtectedRoute requiredRole="OVERALL_ADMIN">
    {children}
  </ProtectedRoute>
);
