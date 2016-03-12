#!/bin/sh
set -ex
PGM=letkf_eigenexa.exe
F90=mpifrtpx
OMP= #'-Kopenmp'

F90OPT='-O3' # -Hs' -Kfast,parallel

BLAS=1 #0: no blas 1: using blas

rm -f *.mod
rm -f *.o

COMMONDIR=../../common/

cat $COMMONDIR/netlib.f > netlib2.f
if test $BLAS -eq 1
then
LBLAS="-SSL2BLAMP"
LSCALAPACK="-SCALAPACK"
INCLUDE="-I${HOME}/share/EigenExa-2.3c/"
Leigen="-L${HOME}/share/EigenExa-2.3c/ -lEigenExa"

else
cat $COMMONDIR/netlibblas.f >> netlib2.f
LBLAS=""
fi

LIB_NETCDF="-L${HOME}/share/Libs/netcdf/4.1.1/lib -lnetcdf"
INC_NETCDF="-I${HOME}/share/Libs//netcdf/4.1.1/include/"


COMMONDIR=../../common/
ln -fs $COMMONDIR/SFMT.f90 ./
ln -fs $COMMONDIR/common.f90 ./
ln -fs $COMMONDIR/common_mpi.f90 ./
ln -fs $COMMONDIR/common_mtx_eigenexa.f90 ./
ln -fs $COMMONDIR/common_letkf.f90 ./
ln -fs $COMMONDIR/common_smooth2d.f90 ./

ln -fs ../common/common_wrf.f90 ./
ln -fs ../common/common_mpi_wrf.f90 ./
ln -fs ../common/common_obs_wrf.f90 ./
ln -fs ../common/module_map_utils.f90 ./
ln -fs ../common/common_namelist.f90 ./


$F90 $F90OPT $INLINE -c SFMT.f90
$F90 $F90OPT $INLINE -c common.f90
$F90 $F90OPT -c common_mpi.f90
$F90 $F90OPT $INLINE $INCLUDE $Leigen -c common_mtx_eigenexa.f90
$F90 $F90OPT $INLINE -c netlib2.f
$F90 $F90OPT $INCLUDE $Leigen -c common_letkf.f90
$F90 $F90OPT $INLINE -c module_map_utils.f90
$F90 $F90OPT $INLINE $INC_NETCDF -c common_wrf.f90
$F90 $F90OPT $INLINE -c common_namelist.f90
$F90 $F90OPT $INLINE -c common_smooth2d.f90
$F90 $F90OPT -c common_obs_wrf.f90
$F90 $F90OPT -c common_mpi_wrf.f90
$F90 $F90OPT $INCLUDE $Leigen -c letkf_obs.f90
$F90 $F90OPT $INCLUDE $Leigen -c letkf_tools.f90
$F90 $F90OPT $INCLUDE $Leigen -c letkf_eigenexa.f90
$F90 $OMP $F90OPT -o ${PGM} *.o $LBLAS $LSCALAPACK $LIB_NETCDF $Leigen

rm -f *.mod
rm -f *.o
rm -f netlib2.f

rm SFMT.f90 
rm common.f90 
rm common_mpi.f90 
rm common_mtx_eigenexa.f90 
rm common_letkf.f90 
rm common_wrf.f90 
rm common_mpi_wrf.f90 
rm common_obs_wrf.f90
rm module_map_utils.f90 
rm common_smooth2d.f90
rm common_namelist.f90

echo "NORMAL END"