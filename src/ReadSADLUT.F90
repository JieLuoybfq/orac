!-------------------------------------------------------------------------------
! Name:
!    ReadSADLUT
!
! Purpose:
!
! Local variables:
!    Name Type Description
!
! History:
!    10th Oct 2014, Greg McGarragh:
!       Original version.
!
! $Id$
!-------------------------------------------------------------------------------


!-------------------------------------------------------------------------------
! Below are subroutines supporting the subroutine Read_SAD_LUT() defined at the
! end.
!-------------------------------------------------------------------------------


!-------------------------------------------------------------------------------
! Name:
!    grid_dimension_read
!
! Purpose:
!    Read a single grid dimension.
!
! Arguments:
!    Name Type In/Out/Both Description
!
! Algorithm:
!
! Local variables:
!    Name Type Description
!
! History:
!    10th Oct 2014, Greg McGarragh:
!       Original version.
!
! Bugs:
!    None known.
!
!-------------------------------------------------------------------------------
subroutine grid_dimension_read(filename, n_name, d_name, v_name, l_lun, &
                               i_chan, i_lut, nTau, dTau, MinTau, MaxTau, Tau)

   implicit none

   ! Argument declarations
   character(*), intent(in)    :: filename
   character(*), intent(in)    :: n_name
   character(*), intent(in)    :: d_name
   character(*), intent(in)    :: v_name
   integer,      intent(in)    :: l_lun
   integer,      intent(in)    :: i_chan
   integer,      intent(in)    :: i_lut
   integer,      intent(inout) :: nTau(:,:)
   real,         intent(inout) :: dTau(:,:)
   real,         intent(inout) :: MaxTau(:,:)
   real,         intent(inout) :: MinTau(:,:)
   real,         intent(inout) :: Tau(:,:,:)

   ! Local variables
   integer :: i
   integer :: iostat

   read(l_lun, *, iostat=iostat) nTau(i_chan, i_lut), dTau(i_chan, i_lut)
   if (iostat .ne. 0) then
      write(*,*) 'ERROR: grid_dimension_read(), Error reading ', trim(n_name), &
         ' and ', trim(d_name), ' from SAD LUT file: ', trim(filename)
      stop error_stop_code
   end if

   read(l_lun, *, iostat=iostat) (Tau(i_chan, i, i_lut), i=1, nTau(i_chan, i_lut))
   if (iostat .ne. 0) then
      write(*,*) 'ERROR: grid_dimension_read(), Error reading ', trim(v_name), &
                                ' from SAD LUT file: ', trim(filename)
      stop error_stop_code
   end if

   MinTau(i_chan,i_lut)  = Tau(i_chan, 1, i_lut)
   MaxTau(i_chan,i_lut)  = Tau(i_chan, nTau(i_chan, i_lut), i_lut)

end subroutine grid_dimension_read


!-------------------------------------------------------------------------------
! Name:
!    grid_dimension_copy
!
! Purpose:
!    Read a single grid dimension.
!
! Arguments:
!    Name Type In/Out/Both Description
!
! Algorithm:
!
! Local variables:
!    Name Type Description
!
! History:
!    10th Oct 2014, Greg McGarragh:
!       Original version.
!
! Bugs:
!    None known.
!
!-------------------------------------------------------------------------------
subroutine grid_dimension_copy(i_chan, i_lut1, i_lut2, nTau, dTau, MinTau, &
                               MaxTau, Tau)

   implicit none

   ! Argument declarations
   integer, intent(in)    :: i_chan
   integer, intent(in)    :: i_lut1
   integer, intent(in)    :: i_lut2
   integer, intent(inout) :: nTau(:,:)
   real,    intent(inout) :: dTau(:,:)
   real,    intent(inout) :: MaxTau(:,:)
   real,    intent(inout) :: MinTau(:,:)
   real,    intent(inout) :: Tau(:,:,:)

   dTau(i_chan,i_lut2)   = dTau(i_chan, i_lut1)
   nTau(i_chan,i_lut2)   = nTau(i_chan, i_lut1)

   Tau(i_chan,:,i_lut2)  = Tau(i_chan, :, i_lut1)

   MinTau(i_chan,i_lut2) = MinTau(i_chan, i_lut1)
   MaxTau(i_chan,i_lut2) = MaxTau(i_chan, i_lut1)

end subroutine grid_dimension_copy


!-------------------------------------------------------------------------------
! Name:
!    read_grid_dimensions
!
! Purpose:
!    Read all required grid dimensions
!
! Arguments:
!    Name Type In/Out/Both Description
!
! Algorithm:
!
! Local variables:
!    Name Type Description
!
! History:
!    10th Oct 2014, Greg McGarragh:
!       Original version.
!
! Bugs:
!    None known.
!
!-------------------------------------------------------------------------------
subroutine read_grid_dimensions(filename, l_lun, i_chan, SAD_LUT, has_sol_zen, &
                                has_sat_zen, has_rel_azi, i_lut, i_lut2)

   implicit none

   ! Argument declarations
   character(*),    intent(in)           :: filename
   integer,         intent(in)           :: l_lun
   integer,         intent(in)           :: i_chan
   type(SAD_LUT_t), intent(inout)        :: SAD_LUT
   logical,         intent(in)           :: has_sol_zen
   logical,         intent(in)           :: has_sat_zen
   logical,         intent(in)           :: has_rel_azi
   integer,         intent(in)           :: i_lut
   integer,         intent(in), optional :: i_lut2

   ! Read the Tau dimension
   call grid_dimension_read(filename, 'nTau', 'dTau', 'Tau', &
                            l_lun, i_chan, i_lut, &
                            SAD_LUT%Grid%nTau, SAD_LUT%Grid%dTau, &
                            SAD_LUT%Grid%MinTau, SAD_LUT%Grid%MaxTau, &
                            SAD_LUT%Grid%Tau)

   if (present(i_lut2)) then
      call grid_dimension_copy(i_chan, i_lut, i_lut2, &
                               SAD_LUT%Grid%nTau, SAD_LUT%Grid%dTau, &
                               SAD_LUT%Grid%MinTau, SAD_LUT%Grid%MaxTau, &
                               SAD_LUT%Grid%Tau)
   end if

   if (has_sat_zen) then
      ! Read the Satzen dimension
      call grid_dimension_read(filename, 'nSatzen', 'dSatzen', 'Satzen', &
                               l_lun, i_chan, i_lut, &
                               SAD_LUT%Grid%nSatzen, SAD_LUT%Grid%dSatzen, &
                               SAD_LUT%Grid%MinSatzen, SAD_LUT%Grid%MaxSatzen, &
                               SAD_LUT%Grid%Satzen)

      if (present(i_lut2)) then
         call grid_dimension_copy(i_chan, i_lut, i_lut2, &
                                  SAD_LUT%Grid%nSatzen, SAD_LUT%Grid%dSatzen, &
                                  SAD_LUT%Grid%MinSatzen, SAD_LUT%Grid%MaxSatzen, &
                                  SAD_LUT%Grid%Satzen)
      end if
   end if

   if (has_sol_zen) then
      ! Read the Solzen dimension
      call grid_dimension_read(filename, 'nSolzen', 'dSolzen', 'Solzen', &
                               l_lun, i_chan, i_lut, &
                               SAD_LUT%Grid%nSolzen, SAD_LUT%Grid%dSolzen, &
                               SAD_LUT%Grid%MinSolzen, SAD_LUT%Grid%MaxSolzen, &
                               SAD_LUT%Grid%Solzen)

      if (present(i_lut2)) then
         call grid_dimension_copy(i_chan, i_lut, i_lut2, &
                                  SAD_LUT%Grid%nSolzen, SAD_LUT%Grid%dSolzen, &
                                  SAD_LUT%Grid%MinSolzen, SAD_LUT%Grid%MaxSolzen, &
                                  SAD_LUT%Grid%Solzen)
      end if
   end if

   if (has_rel_azi) then
      ! Read the Relazi dimension
      call grid_dimension_read(filename, 'nRelazi', 'dRelazi', 'Relazi', &
                               l_lun, i_chan, i_lut, &
                               SAD_LUT%Grid%nRelazi, SAD_LUT%Grid%dRelazi, &
                               SAD_LUT%Grid%MinRelazi, SAD_LUT%Grid%MaxRelazi, &
                               SAD_LUT%Grid%Relazi)

      if (present(i_lut2)) then
         call grid_dimension_copy(i_chan, i_lut, i_lut2, &
                                  SAD_LUT%Grid%nRelazi, SAD_LUT%Grid%dRelazi, &
                                  SAD_LUT%Grid%MinRelazi, SAD_LUT%Grid%MaxRelazi, &
                                  SAD_LUT%Grid%Relazi)
      end if
   endif

   ! Read the Re dimension
   call grid_dimension_read(filename, 'nRe', 'dRe', 'Re', &
                            l_lun, i_chan, i_lut, &
                            SAD_LUT%Grid%nRe, SAD_LUT%Grid%dRe, &
                            SAD_LUT%Grid%MinRe, SAD_LUT%Grid%MaxRe, &
                            SAD_LUT%Grid%Re)

   if (present(i_lut2)) then
      call grid_dimension_copy(i_chan, i_lut, i_lut2, &
                               SAD_LUT%Grid%nRe, SAD_LUT%Grid%dRe, &
                               SAD_LUT%Grid%MinRe, SAD_LUT%Grid%MaxRe, &
                               SAD_LUT%Grid%Re)
   end if

end subroutine read_grid_dimensions


!-------------------------------------------------------------------------------
! Name:
!    read_values_2d
!
! Purpose:
!    Read 2d LUT values
!
! Arguments:
!    Name Type In/Out/Both Description
!
! Algorithm:
!
! Local variables:
!    Name Type Description
!
! History:
!    10th Oct 2014, Greg McGarragh:
!       Original version.
!
! Bugs:
!    None known.
!
!-------------------------------------------------------------------------------
subroutine read_values_2d(filename, v_name, l_lun, i_chan, i_lut, &
                          n_i, n_j, values)

   implicit none

   ! Argument declarations
   character(*), intent(in)    :: filename
   character(*), intent(in)    :: v_name
   integer,      intent(in)    :: l_lun
   integer,      intent(in)    :: i_chan
   integer,      intent(in)    :: i_lut
   integer,      intent(inout) :: n_i(:,:)
   integer,      intent(inout) :: n_j(:,:)
   real,         intent(inout) :: values(:,:,:)

   ! Local variables
   integer :: i, j
   integer :: iostat

   read(l_lun, *, iostat=iostat) ((values(i_chan, i, j), &
      i = 1, n_i(i_chan, i_lut)), j = 1, n_j(i_chan, i_lut))
   if (iostat .ne. 0) then
      write(*,*) 'ERROR: read_values_2d(), Error reading ', v_name, &
         ' from file: ', trim(v_name), trim(filename)
      stop error_stop_code
   end if

end subroutine read_values_2d


!-------------------------------------------------------------------------------
! Read 3d LUT values
!-------------------------------------------------------------------------------
subroutine read_values_3d(filename, v_name, l_lun, i_chan, i_lut, &
                          n_i, n_j, n_k, values)

   implicit none

   character(*), intent(in)    :: filename
   character(*), intent(in)    :: v_name
   integer,      intent(in)    :: l_lun
   integer,      intent(in)    :: i_chan
   integer,      intent(in)    :: i_lut
   integer,      intent(inout) :: n_i(:,:)
   integer,      intent(inout) :: n_j(:,:)
   integer,      intent(inout) :: n_k(:,:)
   real,         intent(inout) :: values(:,:,:,:)

   ! Local variables
   integer :: i, j, k
   integer :: iostat

   read(l_lun, *, iostat=iostat) (((values(i_chan, i, j, k), &
      i = 1, n_i(i_chan, i_lut)), j = 1, n_j(i_chan, i_lut)), &
      k = 1, n_k(i_chan, i_lut))
   if (iostat .ne. 0) then
      write(*,*) 'ERROR: read_values_3d(), Error reading ', v_name, &
         ' from file: ', trim(v_name), trim(filename)
      stop error_stop_code
   end if

end subroutine read_values_3d


!-------------------------------------------------------------------------------
! Name:
!    read_values_5d
!
! Purpose:
!    Read 5d LUT values
!
! Arguments:
!    Name Type In/Out/Both Description
!
! Algorithm:
!
! Local variables:
!    Name Type Description
!
! History:
!    10th Oct 2014, Greg McGarragh:
!       Original version.
!
! Bugs:
!    None known.
!
!-------------------------------------------------------------------------------
subroutine read_values_5d(filename, v_name, l_lun, i_chan, i_lut, &
                          n_i, n_j, n_k, n_l, n_m, values)

   implicit none

   ! Argument declarations
   character(*), intent(in)    :: filename
   character(*), intent(in)    :: v_name
   integer,      intent(in)    :: l_lun
   integer,      intent(in)    :: i_chan
   integer,      intent(in)    :: i_lut
   integer,      intent(inout) :: n_i(:,:)
   integer,      intent(inout) :: n_j(:,:)
   integer,      intent(inout) :: n_k(:,:)
   integer,      intent(inout) :: n_l(:,:)
   integer,      intent(inout) :: n_m(:,:)
   real,         intent(inout) :: values(:,:,:,:,:,:)

   ! Local variables
   integer :: i, j, k, l, m
   integer :: iostat

   read(l_lun, *, iostat=iostat) (((((values(i_chan, i, j, k, l, m), &
      i = 1, n_i(i_chan, i_lut)), j = 1, n_j(i_chan, i_lut)), &
      k = 1, n_k(i_chan, i_lut)), l = 1, n_l(i_chan, i_lut)), &
      m = 1, n_m(i_chan, i_lut))
   if (iostat .ne. 0) then
      write(*,*) 'ERROR: read_values_5d(), Error reading ', v_name, &
         ' from file: ', trim(v_name), trim(filename)
      stop error_stop_code
   end if

end subroutine read_values_5d


!-------------------------------------------------------------------------------
! Name:
!    Read_LUT_Xd_sat
!
! Purpose:
!    Read an LUT that has a variable satellite zenith angle
!
! Arguments:
!    Name Type In/Out/Both Description
!
! Algorithm:
!
! Local variables:
!    Name Type Description
!
! History:
!    10th Oct 2014, Greg McGarragh:
!       Original version.
!
! Bugs:
!    None known.
!
!-------------------------------------------------------------------------------
subroutine Read_LUT_Xd_sat(Ctrl, LUT_file, i_chan, SAD_LUT, i_lut, name, &
                           values, i_lut2, name2, values2)

   use Ctrl_def
   use ECP_Constants

   implicit none

   ! Argument declarations
   type(CTRL_t),    intent(in)              :: Ctrl
   character(*),    intent(in)              :: LUT_file
   integer,         intent(in)              :: i_chan
   type(SAD_LUT_t), intent(inout)           :: SAD_LUT
   integer,         intent(in)              :: i_lut
   character(*),    intent(in)              :: name
   real,            intent(inout)           :: values(:,:,:,:)
   integer,         intent(in),    optional :: i_lut2
   character(*),    intent(in),    optional :: name2
   real,            intent(inout), optional :: values2(:,:,:)

   ! Local variables
   integer :: l_lun
   integer :: iostat

   call Find_LUN(l_lun)
   open(unit = l_lun, file = LUT_file, status = 'old', iostat = iostat)
   if (iostat .ne. 0) then
      write(*,*) 'ERROR: Read_LUT_Xd_sat(), Error opening file: ', trim(LUT_file)
      stop error_stop_code
   end if

   SAD_LUT%table_used_for_channel(i_chan, i_lut)  = .true.

   SAD_LUT%table_uses_solzen(i_lut) = .false.
   SAD_LUT%table_uses_relazi(i_lut) = .false.
   SAD_LUT%table_uses_satzen(i_lut) = .true.

   if (present(i_lut2)) then
      SAD_LUT%table_used_for_channel(i_chan, i_lut2) = .true.

      SAD_LUT%table_uses_solzen(i_lut2) = .false.
      SAD_LUT%table_uses_relazi(i_lut2) = .false.
      SAD_LUT%table_uses_satzen(i_lut2) = .false.
   end if

   ! Read Wavelength
   read(l_lun, *, iostat=iostat) SAD_LUT%Wavelength(i_chan)

   ! Read the grid dimensions
   call read_grid_dimensions(LUT_file, l_lun, i_chan, SAD_LUT, .false., .true., &
                             .false., i_lut, i_lut2)

   ! Read in the i_lut array
   call read_values_3d(LUT_file, name,  l_lun, i_chan, i_lut, &
           SAD_LUT%Grid%nTau, SAD_LUT%Grid%nSatzen, SAD_LUT%Grid%nRe, values)

   if (present(i_lut2)) then
      ! Read in the i_lut2 array.
      call read_values_2d(LUT_file, name2, l_lun, i_chan, i_lut2, &
              SAD_LUT%Grid%nTau, SAD_LUT%Grid%nRe, values2)
   endif

   close(unit = l_lun)

end subroutine Read_LUT_Xd_sat


!-------------------------------------------------------------------------------
! Name:
!    Read_LUT_Xd_sol
!
! Purpose:
!    Read an LUT that has a variable solar zenith angle
!
! Arguments:
!    Name Type In/Out/Both Description
!
! Algorithm:
!
! Local variables:
!    Name Type Description
!
! History:
!    10th Oct 2014, Greg McGarragh:
!       Original version.
!
! Bugs:
!    None known.
!
!-------------------------------------------------------------------------------
subroutine Read_LUT_Xd_sol(Ctrl, LUT_file, i_chan, SAD_LUT, i_lut, name, &
                           values, i_lut2, name2, values2)

   use Ctrl_def
   use ECP_Constants

   implicit none

   ! Argument declarations
   type(CTRL_t),    intent(in)              :: Ctrl
   character(*),    intent(in)              :: LUT_file
   integer,         intent(in)              :: i_chan
   type(SAD_LUT_t), intent(inout)           :: SAD_LUT
   integer,         intent(in)              :: i_lut
   character(*),    intent(in)              :: name
   real,            intent(inout)           :: values(:,:,:,:)
   integer,         intent(in),    optional :: i_lut2
   character(*),    intent(in),    optional :: name2
   real,            intent(inout), optional :: values2(:,:,:)

   ! Local variables
   integer :: l_lun
   integer :: iostat

   call Find_LUN(l_lun)
   open(unit = l_lun, file = LUT_file, status = 'old', iostat = iostat)
   if (iostat .ne. 0) then
      write(*,*) 'ERROR: Read_LUT_Xd_sol(), Error opening file: ', trim(LUT_file)
      stop error_stop_code
   end if

   SAD_LUT%table_used_for_channel(i_chan, i_lut)  = .true.

   SAD_LUT%table_uses_solzen(i_lut) = .true.
   SAD_LUT%table_uses_relazi(i_lut) = .false.
   SAD_LUT%table_uses_satzen(i_lut) = .false.

   if (present(i_lut2)) then
      SAD_LUT%table_used_for_channel(i_chan, i_lut2) = .true.

      SAD_LUT%table_uses_solzen(i_lut2) = .true.
      SAD_LUT%table_uses_relazi(i_lut2) = .false.
      SAD_LUT%table_uses_satzen(i_lut2) = .false.
   end if

   ! Read Wavelength
   read(l_lun, *, iostat=iostat) SAD_LUT%Wavelength(i_chan)

   ! Read the grid dimensions
   call read_grid_dimensions(LUT_file, l_lun, i_chan, SAD_LUT, .true., .false., &
                             .false., i_lut, i_lut2)

   ! Read in the i_lut array
   call read_values_3d(LUT_file, name, l_lun, i_chan, i_lut, &
           SAD_LUT%Grid%nTau, SAD_LUT%Grid%nSolzen, SAD_LUT%Grid%nRe, values)

   if (present(i_lut2)) then
      ! Read in the i_lut2 array.
      call read_values_2d(LUT_file, name2, l_lun, i_chan, i_lut2, &
              SAD_LUT%Grid%nTau, SAD_LUT%Grid%nRe, values2)
      endif

   close(unit = l_lun)

end subroutine Read_LUT_Xd_sol


!-------------------------------------------------------------------------------
! Name:
!    Read_LUT_Xd_both
!
! Purpose:
!    Read an LUT that has a variable solar and satellite zenith angle, in which
!    case relative azimuth angle also matters.
!
! Arguments:
!    Name Type In/Out/Both Description
!
! Algorithm:
!
! Local variables:
!    Name Type Description
!
! History:
!    10th Oct 2014, Greg McGarragh:
!       Original version.
!
! Bugs:
!    None known.
!
!-------------------------------------------------------------------------------
subroutine Read_LUT_Xd_both(Ctrl, LUT_file, i_chan, SAD_LUT, i_lut, name, &
                            values, i_lut2, name2, values2)

   use Ctrl_def
   use ECP_Constants

   implicit none

   ! Argument declarations
   type(CTRL_t),    intent(in)              :: Ctrl
   character(*),    intent(in)              :: LUT_file
   integer,         intent(in)              :: i_chan
   type(SAD_LUT_t), intent(inout)           :: SAD_LUT
   integer,         intent(in)              :: i_lut
   character(*),    intent(in)              :: name
   real,            intent(inout)           :: values(:,:,:,:,:,:)
   integer,         intent(in),    optional :: i_lut2
   character(*),    intent(in),    optional :: name2
   real,            intent(inout), optional :: values2(:,:,:,:)

   ! Local variables
   integer :: l_lun
   integer :: iostat

   call Find_LUN(l_lun)
   open(unit = l_lun, file = LUT_file, status = 'old', iostat = iostat)
   if (iostat .ne. 0) then
      write(*,*) 'ERROR: Read_LUT_Xd_both(), Error opening file: ', trim(LUT_file)
      stop error_stop_code
   end if

   SAD_LUT%table_used_for_channel(i_chan, i_lut)  = .true.

   SAD_LUT%table_uses_solzen(i_lut) = .true.
   SAD_LUT%table_uses_relazi(i_lut) = .true.
   SAD_LUT%table_uses_satzen(i_lut) = .true.

   if (present(i_lut2)) then
      SAD_LUT%table_used_for_channel(i_chan, i_lut2) = .true.

      SAD_LUT%table_uses_solzen(i_lut2) = .true.
      SAD_LUT%table_uses_relazi(i_lut2) = .false.
      SAD_LUT%table_uses_satzen(i_lut2) = .false.
   end if

   ! Read Wavelength
   read(l_lun, *, iostat=iostat) SAD_LUT%Wavelength(i_chan)

   ! Read the grid dimensions
   call read_grid_dimensions(LUT_file, l_lun, i_chan, SAD_LUT, .true., .true., &
                             .true., i_lut, i_lut2)

   ! Read in the i_lut array
   call read_values_5d(LUT_file, name, l_lun, i_chan, i_lut, &
           SAD_LUT%Grid%nTau, SAD_LUT%Grid%nSatzen, SAD_LUT%Grid%nSolzen, &
           SAD_LUT%Grid%nRelazi, SAD_LUT%Grid%nRe, values)

   if (present(i_lut2)) then
      ! Read in the i_lut2 array.
      call read_values_3d(LUT_file, name2, l_lun, i_chan, i_lut2, &
              SAD_LUT%Grid%nTau, SAD_LUT%Grid%nSolzen, SAD_LUT%Grid%nRe, values2)
      endif

   close(unit = l_lun)

end subroutine Read_LUT_Xd_both


!-------------------------------------------------------------------------------
! Name:
!    create_lut_filename
!
! Purpose:
!    Create an LUT filename given the lut name and string channel number.
!
! Arguments:
!    Name Type In/Out/Both Description
!
! Algorithm:
!
! Local variables:
!    Name Type Description
!
! History:
!    10th Oct 2014, Greg McGarragh:
!       Original version.
!
! Bugs:
!    None known.
!
!-------------------------------------------------------------------------------
subroutine create_lut_filename(Ctrl, lut_name, chan_num, LUT_file)

   use CTRL_def

   implicit none

   ! Argument declarations
   type(CTRL_t), intent(in)  :: Ctrl
   character(*), intent(in)  :: lut_name
   character(*), intent(in)  :: chan_num
   character(*), intent(out) :: LUT_file

   LUT_file = trim(Ctrl%SAD_Dir) // '/' // trim(Ctrl%Inst%Name) // '_' // &
              trim(Ctrl%CloudClass%Name) // '_' // trim(lut_name) // '_' &
              // trim(chan_num) // '.sad'

end subroutine create_lut_filename


!-------------------------------------------------------------------------------
! Name:
!    Read_SAD_LUT
!
! Purpose:
!    Reads the required SAD LUTs.
!
! Arguments:
!    Name     Type   In/Out/Both Description
!    Ctrl     struct In          Control structure
!    SAD_Chan struct out         SAD_Chan structure filled from a read using
!                                Read_SAD_Chan()
!    SAD_LUT  struct out         Structure to hold the values from the LUT
!                                files.
!
! Algorithm:
!
! Local variables:
!    Name Type Description
!
! History:
!    13th Oct 2000, Andy Smith: Original version
!    23rd Nov 2000, Andy Smith:
!       Channel file names updated: using 'Ch' instead of 'CH'
!     9th Jan 2001, Andy Smith:
!       Emissivity files available. Read_LUT_EM call un-commented.
!       Added breakpoint output.
!       Ctrl%Ind%Y renamed Y_Id
!    12th Jan 2001, Andy Smith:
!       Arrays of LUT values (RBd etc) made allocatable. Allocate sizes here.
!    18th Jan 2001, Andy Smith:
!       Bug fix in array allocation. Rfd, TFd arrays must always be allocated
!       even if the choice of channels means they're unused, because they are
!       read from the same files as Rd, Td by the same routines.
!     9th Feb 2001, Andy Smith:
!       Using pre-defined constants (ECPConstants.f90) for breakpoint levels.
!     1st Mar 2001, Andy Smith:
!       LUT array values are now divided by 100 since values in files are
!       percentages and we require fractions later on.
!       (Temporary fix until files are re-written?)
!     7th Jun 2001, Andy Smith:
!       Debug log message removed from routine Read_LUT_Rbd
!    **************** ECV work starts here *************************************
!    22nd Mar 2011, Andy Smith:
!       Remove phase change, phase 2 only 1 cloud class per run.
!       SAD_LUT is also now reduced from dimension N cloud classes to 1.
!     6th Apr 2011, Andy Smith:
!       Removed two redundant breakpoint outputs now that only 1 cloud class.
!    3rd May 2011, Andy Smith:
!       Extension to multiple instrument views. Wavelength array is now allocated.
!       Added wavelength to breakpoint outputs to allow checking when >1 view
!       selected.
!    3rd May 2011, Caroline Poulsen: removed allocation of LUTs into individual
!      routine so ntau,nrensatzen etc could be read and used directly from LUT
!      files and are not replicated else where
!    16th Jan 2014, Greg McGarragh:
!       Added allocation of SAD_LUT%table_use* arrays.
!    23th Jan 2014, Greg McGarragh:
!       Cleaned up code.
!     4th Feb 2014, Matthias Jerg:
!       Implements code for AVHRR to assign channel numbers for LUT names.
!    20th Sep 2014, Greg McGarragh:
!       Use a subroutine to create the LUT filenames.
!    10th Oct 2014, Greg McGarragh:
!       Use the new LUT read code.
!
! Bugs:
!   None known.
!
!-------------------------------------------------------------------------------

subroutine Read_SAD_LUT(Ctrl, SAD_Chan, SAD_LUT)

   use CTRL_def
   use SAD_Chan_def

   implicit none

   ! Argument declarations

   type(CTRL_t),                   intent(in)    :: Ctrl
   type(SAD_Chan_t), dimension(:), intent(in)    :: SAD_Chan
   type(SAD_LUT_t),                intent(inout) :: SAD_LUT

   ! Local variables

   integer                :: i       ! Array counters
   character(FilenameLen) :: LUT_file! Name of LUT file
   character(4)           :: chan_num! Channel number converted to a string
#ifdef BKP
   integer                :: bkp_lun ! Unit number for breakpoint file
   integer                :: ios     ! I/O status returned by file open etc
#endif

   ! Open breakpoint file if required.
#ifdef BKP
   if (Ctrl%Bkpl > 0) then
      call Find_Lun(bkp_lun)
      open(unit=bkp_lun,      &
           file=Ctrl%FID%Bkp, &
	   status='old',      &
	   position='append', &
	   iostat=ios)
      if (ios /= 0) then
         status = BkpFileOpenErr
	 call Write_Log(Ctrl, 'Read_LUT: Error opening breakpoint file', status)
      else
         write(bkp_lun,*)'Read_LUT:'
      end if
   end if
#endif

   ! For each cloud class, construct the LUT filename from the instrument name,
   ! cloud class ID, variable name and channel number. Then call the appropriate
   ! LUT file read function. Just pass the current SAD_LUT struct, rather than
   ! the whole array.
   call Alloc_SAD_LUT(Ctrl, SAD_LUT)

   SAD_LUT%table_used_for_channel = .false.

   SAD_LUT%table_uses_satzen      = .false.
   SAD_LUT%table_uses_solzen      = .false.
   SAD_LUT%table_uses_relazi      = .false.


   do i=1, Ctrl%Ind%Ny
      if (Ctrl%Ind%Y_Id(Ctrl%Ind%Chi(i)) < 10) then
         if (trim(Ctrl%Inst%Name(1:5)) .ne. 'AVHRR') then
            write(chan_num, '(a2,i1)') 'Ch',Ctrl%Ind%Y_Id(Ctrl%Ind%Chi(i))
         else
            if (Ctrl%Ind%Y_Id(Ctrl%Ind%Chi(i)) .eq. 1) then
               chan_num='Ch1'
            else if (Ctrl%Ind%Y_Id(Ctrl%Ind%Chi(i)) .eq. 2) then
               chan_num='Ch2'
            else if (Ctrl%Ind%Y_Id(Ctrl%Ind%Chi(i)) .eq. 3) then
               chan_num='Ch3a'
            else if (Ctrl%Ind%Y_Id(Ctrl%Ind%Chi(i)) .eq. 4) then
               chan_num='Ch3b'
            else if (Ctrl%Ind%Y_Id(Ctrl%Ind%Chi(i)) .eq. 5) then
               chan_num='Ch4'
            else if (Ctrl%Ind%Y_Id(Ctrl%Ind%Chi(i)) .eq. 6) then
               chan_num='Ch5'
            end if

         end if
      else
         write(chan_num, '(a2,i2)') 'Ch',Ctrl%Ind%Y_Id(Ctrl%Ind%Chi(i))
      end if
      write(*,*) 'Channel number',trim(adjustl(chan_num))


      ! Read the Rd, Td files for all channels (solar and thermal)
      call create_lut_filename(Ctrl, 'RD', chan_num, LUT_File)
      call Read_LUT_Xd_sat(Ctrl, LUT_file, i, SAD_LUT, IRd, "Rd", SAD_LUT%Rd, &
                           i_lut2 = IRfd, name2 = "Rfd", values2 = SAD_LUT%Rfd)

      call create_lut_filename(Ctrl, 'TD', chan_num, LUT_File)
      call Read_LUT_Xd_sat(Ctrl, LUT_file, i, SAD_LUT, ITd, "Td", SAD_LUT%Td, &
                           i_lut2 = ITfd, name2 = "Tfd", values2 = SAD_LUT%Tfd)

      ! Read solar channel LUTs
      if (SAD_Chan(i)%Solar%Flag > 0) then

         ! Read the Rbd file
         call create_lut_filename(Ctrl, 'RBD', chan_num, LUT_File)
         call Read_LUT_Xd_both(Ctrl, LUT_file, i, SAD_LUT, IRbd, "Rbd", &
                               SAD_LUT%Rbd)

         ! Read the Tb file
         call create_lut_filename(Ctrl, 'TB', chan_num, LUT_File)
         call Read_LUT_Xd_sol(Ctrl, LUT_file, i, SAD_LUT, ITb, "Tb", &
                              SAD_LUT%Tb)

         ! Read the Tbd/TFbd file
         call create_lut_filename(Ctrl, 'TBD', chan_num, LUT_File)
         call Read_LUT_Xd_both(Ctrl, LUT_file, i, SAD_LUT, ITbd, "Tbd", &
                               SAD_LUT%Tbd, i_lut2 = ITfbd, name2 = "Tfbd", &
                               values2 = SAD_LUT%Tfbd)
      end if


      ! Read thermal channel LUTs
      if (SAD_Chan(i)%Thermal%Flag > 0) then

         ! Read the Em file
         call create_lut_filename(Ctrl, 'EM', chan_num, LUT_File)
         call Read_LUT_Xd_sat(Ctrl, LUT_file, i, SAD_LUT, IEm, "EM", SAD_LUT%Em)
      end if
   end do

#ifdef BKP
   if (Ctrl%Bkpl >= BkpL_Read_LUT_1) then
      ! Write out SAD_LUT Name and Wavelength
      write(bkp_lun, *)'Name in cloud class struct: ', &
           Ctrl%CloudClass%Name
   end if

   if (Ctrl%Bkpl >= BkpL_Read_LUT_2) then
      ! Write out SAD_LUT Grid substructs.
      write(bkp_lun,*)'Wavelengths: ',(SAD_LUT%Wavelength(i),i=1,Ctrl%Ind%Ny)

      write(bkp_lun,*)'Max, min, delta Tau:',SAD_LUT%Grid%MaxTau, &
           SAD_LUT%Grid%MinTau, SAD_LUT%Grid%dTau
      write(bkp_lun,'(a, 9(f6.3, 1x),/)') ' Tau: ', &
           (SAD_LUT%Grid%Tau(k), k=1,SAD_LUT%Grid%nTau)

      write(bkp_lun,*)'Max, min, delta Re:',SAD_LUT%Grid%MaxRe, &
           SAD_LUT%Grid%MinRe, SAD_LUT%Grid%dRe
      write(bkp_lun,'(a, 12(f7.1, 1x),/)') ' Re: ', &
           (SAD_LUT%Grid%Re(k), k=1,SAD_LUT%Grid%nRe)

      write(bkp_lun,*)'Max, min, delta SatZen:', &
           SAD_LUT%Grid%MaxSatZen, &
           SAD_LUT%Grid%MinSatZen, SAD_LUT%Grid%dSatZen
      write(bkp_lun,'(a, 10(f6.1, 1x),/)') ' SatZen: ', &
           (SAD_LUT%Grid%SatZen(k), k=1,SAD_LUT%Grid%nSatZen)

      write(bkp_lun,*)'Max, min, delta SolZen:',SAD_LUT%Grid%MaxSolZen, &
           SAD_LUT%Grid%MinSolZen, SAD_LUT%Grid%dSolZen
      write(bkp_lun,'(a, 10(f6.1, 1x),/)') ' SolZen: ', &
           (SAD_LUT%Grid%SolZen(k), k=1,SAD_LUT%Grid%nSolZen)

      write(bkp_lun,*)'Max, min, delta RelAzi:',SAD_LUT%Grid%MaxRelAzi, &
           SAD_LUT%Grid%MinRelAzi, SAD_LUT%Grid%dRelAzi
      write(bkp_lun,'(a, 11(f6.1, 1x),/)') ' RelAzi: ', &
           (SAD_LUT%Grid%RelAzi(k), k=1,SAD_LUT%Grid%nRelAzi)
   end if
#endif

   ! Convert from percentage to fractional values
   SAD_LUT%Rd  = SAD_LUT%Rd / 100.
   SAD_LUT%Td  = SAD_LUT%Td / 100.
   SAD_LUT%Tfd = SAD_LUT%Tfd / 100.
   SAD_LUT%Rfd = SAD_LUT%Rfd / 100.

   if (Ctrl%Ind%NSolar > 0) then
      SAD_LUT%Rbd  = SAD_LUT%Rbd  / 100.
      SAD_LUT%Tbd  = SAD_LUT%Tbd  / 100.
      SAD_LUT%Tb   = SAD_LUT%Tb   / 100.
      SAD_LUT%Tfbd = SAD_LUT%Tfbd / 100.
   end if

   if (Ctrl%Ind%NThermal > 0) then
      SAD_LUT%Em = SAD_LUT%Em / 100.
   end if

#ifdef BKP
   if (Ctrl%Bkpl > 0) then
      write(bkp_lun, *) 'Read_LUT: end'
      close(unit=bkp_lun)
   end if
#endif

end subroutine Read_SAD_LUT