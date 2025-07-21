export type UserRole = 'LOADING_ADMIN' | 'RETURNS_ADMIN' | 'CASHIER_MANAGER' | 'OVERALL_ADMIN';

export interface User {
  id: string;
  email: string;
  name: string;
  role: UserRole;
}

export interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  hasPermission: (requiredRole: UserRole) => boolean;
  isLoading: boolean;
  roles: UserRole[];
}

export interface RecordBase {
  id: string;
  createdAt: Date;
  createdBy: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  approvedBy?: string;
  approvedAt?: Date;
}

export interface LoadingRecord extends RecordBase {
  type: 'LOADING';
  // Add loading-specific fields here
}

export interface ReturnRecord extends RecordBase {
  type: 'RETURN';
  // Add return-specific fields here
}

export interface SalesRecord extends RecordBase {
  type: 'SALES';
  totalAmount: number;
  // Add sales-specific fields here
}

export type RecordType = LoadingRecord | ReturnRecord | SalesRecord;
