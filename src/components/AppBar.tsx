import React from 'react';
import { 
  AppBar as MuiAppBar, 
  Toolbar, 
  Typography, 
  Button, 
  Box,
  IconButton,
  Menu,
  MenuItem,
  Avatar
} from '@mui/material';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { UserRole } from '../types/user';

// Helper function to get role display name
const getRoleDisplayName = (role: UserRole): string => {
  switch (role) {
    case 'LOADING_ADMIN':
      return 'Loading Admin';
    case 'RETURNS_ADMIN':
      return 'Returns Admin';
    case 'CASHIER_MANAGER':
      return 'Cashier Manager';
    case 'OVERALL_ADMIN':
      return 'Overall Admin';
    default:
      return 'User';
  }
};

const AppBar: React.FC = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [anchorEl, setAnchorEl] = React.useState<null | HTMLElement>(null);

  const handleMenu = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = () => {
    handleClose();
    logout();
    navigate('/login');
  };

  const getInitials = (name: string) => {
    return name.split(' ').map(n => n[0]).join('').toUpperCase();
  };

  if (!user) {
    return null; // Don't show app bar if not logged in
  }

  return (
    <MuiAppBar position="sticky" elevation={1}>
      <Toolbar>
        <Typography variant="h6" component="div" sx={{ 
          flexGrow: 1, 
          fontWeight: 600,
          letterSpacing: '0.5px'
        }}>
          John Pombe Management System
        </Typography>
        
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Box sx={{ display: { xs: 'none', sm: 'flex' }, flexDirection: 'column', alignItems: 'flex-end', mr: 2 }}>
            <Typography variant="subtitle2" noWrap>
              {user && (
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <Box sx={{ 
                    bgcolor: 'rgba(255, 255, 255, 0.1)',
                    px: 1.5,
                    py: 0.5,
                    borderRadius: 1,
                    display: 'flex',
                    alignItems: 'center',
                    gap: 1
                  }}>
                    <Box sx={{ 
                      width: 8, 
                      height: 8, 
                      borderRadius: '50%',
                      bgcolor: 'success.main'
                    }} />
                    <Typography variant="body2" sx={{ 
                      fontWeight: 500,
                      color: 'rgba(255, 255, 255, 0.9)'
                    }}>
                      {getRoleDisplayName(user.role)}
                    </Typography>
                  </Box>
                  <IconButton
                    size="medium"
                    onClick={handleMenu}
                    color="inherit"
                    aria-label="account of current user"
                    aria-controls="menu-appbar"
                    aria-haspopup="true"
                    sx={{
                      p: 1,
                      border: '1px solid rgba(255, 255, 255, 0.1)',
                      '&:hover': {
                        bgcolor: 'rgba(255, 255, 255, 0.1)'
                      }
                    }}
                  >
                    <Avatar 
                      sx={{ 
                        width: 32, 
                        height: 32, 
                        bgcolor: 'secondary.main',
                        color: 'white',
                        fontWeight: 600,
                        fontSize: '0.875rem'
                      }}
                    >
                      {getInitials(user.name)}
                    </Avatar>
                  </IconButton>
                </Box>
              )}
            </Typography>
          </Box>
          
          <Menu
            id="menu-appbar"
            anchorEl={anchorEl}
            anchorOrigin={{
              vertical: 'bottom',
              horizontal: 'right',
            }}
            keepMounted
            transformOrigin={{
              vertical: 'top',
              horizontal: 'right',
            }}
            open={Boolean(anchorEl)}
            onClose={handleClose}
          >
            <MenuItem onClick={() => {
              handleClose();
              navigate('/profile');
            }}>Profile</MenuItem>
            <MenuItem onClick={handleLogout}>Logout</MenuItem>
          </Menu>
        </Box>
      </Toolbar>
    </MuiAppBar>
  );
};

export default AppBar;
