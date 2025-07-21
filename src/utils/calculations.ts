interface SalesData {
  // B.STEADY
  loadingBSteady24x200: number;
  loadingBSteadyPieces: number;
  loadingBSteady12x200: number;
  returnedBSteady24x200: number;
  returnedBSteadyPieces: number;
  returnedBSteady12x200: number;
  // JIM POMBE
  loadingJimPombe24x200: number;
  loadingJimPombe12x200: number;
  loadingJimPombePieces: number;
  returnedJimPombe24x200: number;
  returnedJimPombe12x200: number;
  returnedJimPombePieces: number;
}

export const calculateBSteadySales = (data: Omit<SalesData, keyof {
  loadingJimPombe24x200: never;
  loadingJimPombe12x200: never;
  loadingJimPombePieces: never;
  returnedJimPombe24x200: never;
  returnedJimPombe12x200: never;
  returnedJimPombePieces: never;
}>): number => {
  const {
    loadingBSteady24x200,
    loadingBSteadyPieces,
    loadingBSteady12x200,
    returnedBSteady24x200,
    returnedBSteadyPieces,
    returnedBSteady12x200
  } = data;

  const hasLoadedItems = loadingBSteady24x200 > 0 || loadingBSteady12x200 > 0;
  const hasReturnedItems = returnedBSteady24x200 > 0 || returnedBSteady12x200 > 0;

  if (hasLoadedItems || hasReturnedItems) {
    return (
      (loadingBSteady24x200 || 0) + 
      ((loadingBSteady12x200 || 0) / 2) + 
      ((loadingBSteadyPieces || 0) / 24) - 
      ((returnedBSteady24x200 || 0) + 
       ((returnedBSteadyPieces || 0) / 24) + 
       ((returnedBSteady12x200 || 0) / 2))
    );
  }

  return 0;
};

export const calculateJimPombeSales = (data: Omit<SalesData, keyof {
  loadingBSteady24x200: never;
  loadingBSteadyPieces: never;
  loadingBSteady12x200: never;
  returnedBSteady24x200: never;
  returnedBSteadyPieces: never;
  returnedBSteady12x200: never;
}>): number => {
  const {
    loadingJimPombe24x200,
    loadingJimPombe12x200,
    loadingJimPombePieces,
    returnedJimPombe24x200,
    returnedJimPombe12x200,
    returnedJimPombePieces
  } = data;

  const hasLoadedItems = loadingJimPombe24x200 > 0 || loadingJimPombe12x200 > 0;
  const hasReturnedItems = returnedJimPombe24x200 > 0 || returnedJimPombe12x200 > 0;

  if (hasLoadedItems || hasReturnedItems) {
    return (
      (loadingJimPombe24x200 || 0) + 
      ((loadingJimPombe12x200 || 0) / 2) + 
      ((loadingJimPombePieces || 0) / 24) - 
      ((returnedJimPombe24x200 || 0) + 
       ((returnedJimPombePieces || 0) / 24) + 
       ((returnedJimPombe12x200 || 0) / 2))
    );
  }

  return 0;
};
