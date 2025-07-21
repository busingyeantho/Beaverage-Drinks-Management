import { useAuth } from '../context/AuthContext';
import { UserRole } from '../types/user';

type FieldType = 'LOADING' | 'RETURN' | 'SALES' | 'SALES_AMOUNT';

export const useFieldPermission = () => {
  const { user } = useAuth();

  const canEditField = (fieldType: FieldType): boolean => {
    if (!user) return false;
    
    switch (user.role) {
      case 'LOADING_ADMIN':
        return fieldType === 'LOADING';
      case 'RETURNS_ADMIN':
        return fieldType === 'RETURN';
      case 'CASHIER_MANAGER':
        return fieldType === 'SALES' || fieldType === 'SALES_AMOUNT';
      case 'OVERALL_ADMIN':
        return false; // Can only approve, not directly edit
      default:
        return false;
    }
  };

  const canViewField = (fieldType: FieldType): boolean => {
    if (!user) return false;
    
    // All admins can view all fields
    if (fieldType !== 'SALES_AMOUNT') return true;
    
    // Only cashier and overall admin can view sales amount
    return ['CASHIER_MANAGER', 'OVERALL_ADMIN'].includes(user.role);
  };

  const canApprove = (): boolean => {
    return user?.role === 'OVERALL_ADMIN';
  };

  return {
    canEditField,
    canViewField,
    canApprove,
    userRole: user?.role,
  };
};
