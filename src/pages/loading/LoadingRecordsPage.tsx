import React, { useState, useEffect } from 'react';
import {
  Box,
  Button,
  Card,
  CardContent,
  Container,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TablePagination,
  TextField,
  Typography,
  IconButton,
  Tooltip,
  Chip,
  useTheme,
  InputAdornment,
  MenuItem,
  Select,
  FormControl,
  InputLabel,
  CircularProgress,
} from '@mui/material';
import {
  Search as SearchIcon,
  Edit as EditIcon,
  Print as PrintIcon,
  FileDownload as ExportIcon,
  Refresh as RefreshIcon,
} from '@mui/icons-material';

import { format } from 'date-fns';
import { useNavigate } from 'react-router-dom';

// Define the LoadingRecord type
type LoadingRecord = {
  id: string;
  date: Date;
  driverName: string;
  vehicleNumber: string;
  products: {
    name: string;
    unit: string;
    quantity: number;
  }[];
  status: 'pending' | 'completed' | 'cancelled';
  totalItems: number;
  createdBy: string;
};

// Mock data - replace with API call
const mockLoadingRecords: LoadingRecord[] = [
  {
    id: 'LDR-001',
    date: new Date('2023-07-18'),
    driverName: 'John Doe',
    vehicleNumber: 'KAA 123A',
    products: [
      { name: 'Bera Steady', unit: '24 x 200ml', quantity: 50 },
      { name: 'Bera Steady', unit: '12 x 200ml', quantity: 30 },
      { name: 'Jim Pombe', unit: '24 x 200ml', quantity: 40 },
    ],
    status: 'completed',
    totalItems: 120,
    createdBy: 'admin@example.com',
  },
  // Add more mock records as needed
];

const LoadingRecordsPage: React.FC = () => {
  const theme = useTheme();
  const navigate = useNavigate();
  const [loading, setLoading] = useState<boolean>(false);
  const [page, setPage] = useState<number>(0);
  const [rowsPerPage, setRowsPerPage] = useState<number>(10);
  const [searchTerm, setSearchTerm] = useState<string>('');
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [records, setRecords] = useState<LoadingRecord[]>([]);

  // Fetch records (mocked for now)
  useEffect(() => {
    const fetchRecords = async () => {
      setLoading(true);
      // Simulate API call
      setTimeout(() => {
        setRecords(mockLoadingRecords);
        setLoading(false);
      }, 500);
    };

    fetchRecords();
  }, []);

  // Handle search and filter
  const filteredRecords = records.filter((record) => {
    const matchesSearch = 
      record.driverName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      record.vehicleNumber.toLowerCase().includes(searchTerm.toLowerCase()) ||
      record.id.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesStatus = statusFilter === 'all' || record.status === statusFilter;
    
    return matchesSearch && matchesStatus;
  });

  // Pagination handlers
  const handleChangePage = (event: unknown, newPage: number) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  // Status chip color
  const getStatusChipColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'success';
      case 'cancelled':
        return 'error';
      default:
        return 'default';
    }
  };

  // Handle edit record
  const handleEditRecord = (recordId: string) => {
    navigate(`/loading/edit/${recordId}`);
  };

  // Handle refresh
  const handleRefresh = () => {
    // Refresh logic here
  };

  return (
    <Box>
      <Box
        sx={{
          display: 'flex',
          flexDirection: { xs: 'column', sm: 'row' },
          justifyContent: 'space-between',
          alignItems: { xs: 'stretch', sm: 'center' },
          mb: 3,
          gap: 2,
        }}
      >
        <Typography variant="h4" component="h1" gutterBottom={false}>
          Loading Records
        </Typography>
        <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
          <Button
            variant="contained"
            color="primary"
            onClick={() => navigate('/loading/new')}
            startIcon={<EditIcon />}
          >
            New Loading
          </Button>
          <Button
            variant="outlined"
            onClick={handleRefresh}
            startIcon={<RefreshIcon />}
            disabled={loading}
          >
            Refresh
          </Button>
        </Box>
      </Box>

      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Box
            sx={{
              display: 'flex',
              flexDirection: { xs: 'column', md: 'row' },
              gap: 2,
              mb: 3,
            }}
          >
            <TextField
              fullWidth
              variant="outlined"
              placeholder="Search by driver, vehicle, or ID..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <SearchIcon color="action" />
                  </InputAdornment>
                ),
              }}
            />
            <FormControl sx={{ minWidth: 200 }}>
              <InputLabel id="status-filter-label">Status</InputLabel>
              <Select
                labelId="status-filter-label"
                value={statusFilter}
                label="Status"
                onChange={(e: any) => setStatusFilter(e.target.value)}
              >
                <MenuItem value="all">All Status</MenuItem>
                <MenuItem value="pending">Pending</MenuItem>
                <MenuItem value="completed">Completed</MenuItem>
                <MenuItem value="cancelled">Cancelled</MenuItem>
              </Select>
            </FormControl>
          </Box>

          <TableContainer component={Paper} sx={{ borderRadius: 2, overflow: 'hidden' }}>
            <Table>
              <TableHead>
                <TableRow sx={{ bgcolor: theme.palette.grey[100] }}>
                  <TableCell>ID</TableCell>
                  <TableCell>Date</TableCell>
                  <TableCell>Driver</TableCell>
                  <TableCell>Vehicle</TableCell>
                  <TableCell>Products</TableCell>
                  <TableCell>Total Items</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={8} align="center" sx={{ py: 4 }}>
                      <CircularProgress size={24} />
                    </TableCell>
                  </TableRow>
                ) : filteredRecords.length > 0 ? (
                  filteredRecords
                    .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                    .map((record) => (
                      <TableRow
                        key={record.id}
                        hover
                        sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                      >
                        <TableCell>{record.id}</TableCell>
                        <TableCell>
                          {format(new Date(record.date), 'dd MMM yyyy')}
                        </TableCell>
                        <TableCell>{record.driverName}</TableCell>
                        <TableCell>{record.vehicleNumber}</TableCell>
                        <TableCell>
                          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
                            {record.products.map((product, idx) => (
                              <Box key={idx} sx={{ display: 'flex', gap: 1 }}>
                                <span>{product.quantity}x</span>
                                <strong>{product.name}</strong>
                                <span>({product.unit})</span>
                              </Box>
                            ))}
                          </Box>
                        </TableCell>
                        <TableCell>{record.totalItems}</TableCell>
                        <TableCell>
                          <Chip
                            label={record.status.charAt(0).toUpperCase() + record.status.slice(1)}
                            color={getStatusChipColor(record.status) as any}
                            size="small"
                          />
                        </TableCell>
                        <TableCell align="right">
                          <Box sx={{ display: 'flex', gap: 1, justifyContent: 'flex-end' }}>
                            <Tooltip title="Edit">
                              <IconButton
                                size="small"
                                onClick={() => handleEditRecord(record.id)}
                                color="primary"
                              >
                                <EditIcon fontSize="small" />
                              </IconButton>
                            </Tooltip>
                            <Tooltip title="Print">
                              <IconButton size="small" color="default">
                                <PrintIcon fontSize="small" />
                              </IconButton>
                            </Tooltip>
                          </Box>
                        </TableCell>
                      </TableRow>
                    ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={8} align="center" sx={{ py: 4 }}>
                      <Typography variant="body2" color="textSecondary">
                        No records found
                      </Typography>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </TableContainer>

          <TablePagination
            rowsPerPageOptions={[5, 10, 25]}
            component="div"
            count={filteredRecords.length}
            rowsPerPage={rowsPerPage}
            page={page}
            onPageChange={handleChangePage}
            onRowsPerPageChange={handleChangeRowsPerPage}
          />
        </CardContent>
      </Card>
    </Box>
  );
};

export default LoadingRecordsPage;
