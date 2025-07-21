import React, { useState } from 'react';
import { 
  Button, 
  TextField, 
  Typography, 
  Paper, 
  Divider
} from '@mui/material';

// Create a simple div with display: grid for layout
interface GridContainerProps {
  children: React.ReactNode;
  spacing?: number;
  style?: React.CSSProperties;
}

const GridContainer = ({ children, spacing = 3, style = {} }: GridContainerProps) => {
  const containerStyle: React.CSSProperties = {
    display: 'grid',
    gap: `${spacing * 8}px`,
    gridTemplateColumns: 'repeat(12, 1fr)',
    ...style
  };
  return <div style={containerStyle}>{children}</div>;
};

// Create a grid item component
interface GridItemProps extends React.HTMLAttributes<HTMLDivElement> {
  xs?: number;
  md?: number;
  children: React.ReactNode;
}

const GridItem = ({ 
  xs = 12, 
  md, 
  children, 
  style = {}, 
  ...props 
}: GridItemProps) => {
  const baseStyle: React.CSSProperties = {
    ...style,
    gridColumn: `span ${Math.min(12, xs)}`
  };
  
  const mdStyle = md ? {
    '@media (min-width: 900px)': {
      gridColumn: `span ${Math.min(12, md)}`
    }
  } : {};
  
  const gridStyle = {
    ...baseStyle,
    ...mdStyle,
    ...style
  } as React.CSSProperties;
  
  return <div style={gridStyle} {...props}>{children}</div>;
};



interface FormData {
  date: string;
  driverName: string;
  vehicleNumber: string;
  // Loading
  loadingBSteady24x200: number;
  loadingBSteadyPieces: number;
  loadingBSteady12x200: number;
  loadingJimPombe24x200: number;
  loadingJimPombe12x200: number;
  loadingJimPombePieces: number;
  // Returns
  returnedBSteady24x200: number;
  returnedBSteadyPieces: number;
  returnedBSteady12x200: number;
  returnedJimPombe24x200: number;
  returnedJimPombe12x200: number;
  returnedJimPombePieces: number;
}

const LoadingReturnsForm: React.FC = () => {
  const [formData, setFormData] = useState<FormData>({
    date: new Date().toISOString().split('T')[0],
    driverName: '',
    vehicleNumber: '',
    loadingBSteady24x200: 0,
    loadingBSteadyPieces: 0,
    loadingBSteady12x200: 0,
    loadingJimPombe24x200: 0,
    loadingJimPombe12x200: 0,
    loadingJimPombePieces: 0,
    returnedBSteady24x200: 0,
    returnedBSteadyPieces: 0,
    returnedBSteady12x200: 0,
    returnedJimPombe24x200: 0,
    returnedJimPombe12x200: 0,
    returnedJimPombePieces: 0,
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name.includes('date') ? value : Number(value) || 0
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Form submitted:', formData);
    // TODO: Connect to Google Sheets
  };

  return (
    <Paper elevation={3} sx={{ p: 3, maxWidth: 1000, mx: 'auto', my: 4 }}>
      <div>
        <div style={{ marginBottom: '24px' }}>
          <Typography variant="h5" gutterBottom>
            Loading & Returns Form
          </Typography>
        </div>
        <form onSubmit={handleSubmit}>
          <GridContainer spacing={3}>
            {/* Basic Information */}
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="date"
                name="date"
                label="Date"
                value={formData.date}
                onChange={handleChange}
                InputLabelProps={{ shrink: true }}
                required
              />
            </GridItem>
            
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                name="driverName"
                label="Driver's Name"
                value={formData.driverName}
                onChange={handleChange}
                required
              />
            </GridItem>
            
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                name="vehicleNumber"
                label="Vehicle Number"
                value={formData.vehicleNumber}
                onChange={handleChange}
                required
              />
            </GridItem>

            {/* Loading Section */}
            <GridItem xs={12}>
              <Typography variant="h6" sx={{ mt: 2, mb: 1 }}>Loading Details</Typography>
              <Divider />
            </GridItem>

            {/* B.STEADY Loading */}
            <GridItem xs={12}>
              <Typography variant="subtitle1" color="primary">B.STEADY</Typography>
            </GridItem>
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="number"
                name="loadingBSteady24x200"
                label="24×200 Cartons"
                value={formData.loadingBSteady24x200}
                onChange={handleChange}
              />
            </GridItem>
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="number"
                name="loadingBSteadyPieces"
                label="24×200 Pieces"
                value={formData.loadingBSteadyPieces}
                onChange={handleChange}
              />
            </GridItem>
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="number"
                name="loadingBSteady12x200"
                label="12×200 Cartons"
                value={formData.loadingBSteady12x200}
                onChange={handleChange}
              />
            </GridItem>

            {/* JIM POMBE Loading */}
            <GridItem xs={12} style={{ marginTop: '16px' }}>
              <Typography variant="subtitle1" color="primary">JIM POMBE</Typography>
            </GridItem>
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="number"
                name="loadingJimPombe24x200"
                label="24×200 Cartons"
                value={formData.loadingJimPombe24x200}
                onChange={handleChange}
              />
            </GridItem>
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="number"
                name="loadingJimPombePieces"
                label="24×200 Pieces"
                value={formData.loadingJimPombePieces}
                onChange={handleChange}
              />
            </GridItem>
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="number"
                name="loadingJimPombe12x200"
                label="12×200 Cartons"
                value={formData.loadingJimPombe12x200}
                onChange={handleChange}
              />
            </GridItem>

            {/* Returns Section */}
            <GridItem xs={12} style={{ marginTop: '24px' }}>
              <Typography variant="h6" sx={{ mb: 1 }}>Returns</Typography>
              <Divider />
            </GridItem>

            {/* B.STEADY Returns */}
            <GridItem xs={12}>
              <Typography variant="subtitle1" color="error">B.STEADY Returns</Typography>
            </GridItem>
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="number"
                name="returnedBSteady24x200"
                label="24×200 Cartons"
                value={formData.returnedBSteady24x200}
                onChange={handleChange}
              />
            </GridItem>
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="number"
                name="returnedBSteadyPieces"
                label="24×200 Pieces"
                value={formData.returnedBSteadyPieces}
                onChange={handleChange}
              />
            </GridItem>
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="number"
                name="returnedBSteady12x200"
                label="12×200 Cartons"
                value={formData.returnedBSteady12x200}
                onChange={handleChange}
              />
            </GridItem>

            {/* JIM POMBE Returns */}
            <GridItem xs={12} style={{ marginTop: '16px' }}>
              <Typography variant="subtitle1" color="error">JIM POMBE Returns</Typography>
            </GridItem>
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="number"
                name="returnedJimPombe24x200"
                label="24×200 Cartons"
                value={formData.returnedJimPombe24x200}
                onChange={handleChange}
              />
            </GridItem>
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="number"
                name="returnedJimPombePieces"
                label="24×200 Pieces"
                value={formData.returnedJimPombePieces}
                onChange={handleChange}
              />
            </GridItem>
            <GridItem xs={12} md={4}>
              <TextField
                fullWidth
                type="number"
                name="returnedJimPombe12x200"
                label="12×200 Cartons"
                value={formData.returnedJimPombe12x200}
                onChange={handleChange}
              />
            </GridItem>

            {/* Submit Button */}
            <GridItem xs={12} style={{ marginTop: '24px' }}>
              <Button 
                type="submit" 
                variant="contained" 
                color="primary" 
                size="large"
                fullWidth
              >
                Save Record
              </Button>
            </GridItem>
          </GridContainer>
        </form>
      </div>
    </Paper>
  );
};

export default LoadingReturnsForm;
