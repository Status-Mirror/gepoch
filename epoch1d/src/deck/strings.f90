! Copyright (C) 2010-2015 Keith Bennett <K.Bennett@warwick.ac.uk>
! Copyright (C) 2009      Chris Brady <C.S.Brady@warwick.ac.uk>
!
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with this program.  If not, see <http://www.gnu.org/licenses/>.

MODULE strings

  USE shared_data

  IMPLICIT NONE

  PRIVATE :: integer4_as_string, integer8_as_string

  INTERFACE integer_as_string
    MODULE PROCEDURE integer4_as_string, integer8_as_string
  END INTERFACE integer_as_string

CONTAINS

  SUBROUTINE integer4_as_string(int_in, string)

    INTEGER(i4), INTENT(IN) :: int_in
    CHARACTER(LEN=*), INTENT(OUT) :: string

    INTEGER :: n_nums
    CHARACTER(LEN=9) :: numfmt

    IF (int_in == 0) THEN
      n_nums = 1
    ELSE
      n_nums = 1 + INT(LOG10(REAL(ABS(int_in), num)))
    ENDIF
    WRITE(numfmt, '(''(I'', I6.6, '')'')') n_nums
    WRITE(string, numfmt) int_in

  END SUBROUTINE integer4_as_string



  SUBROUTINE integer8_as_string(int_in, string)

    INTEGER(i8), INTENT(IN) :: int_in
    CHARACTER(LEN=*), INTENT(OUT) :: string

    INTEGER :: n_nums
    CHARACTER(LEN=12) :: numfmt

    IF (int_in == 0) THEN
      n_nums = 1
    ELSE
      n_nums = 1 + INT(LOG10(REAL(ABS(int_in), num)))
    ENDIF
    WRITE(numfmt, '(''(I'', I9.9, '')'')') n_nums
    WRITE(string, numfmt) int_in

  END SUBROUTINE integer8_as_string



  FUNCTION str_cmp(str_in, str_test)

    CHARACTER(*), INTENT(IN) ::  str_in, str_test
    CHARACTER(LEN=string_length) :: str_trim
    INTEGER :: test_len, in_len
    LOGICAL :: str_cmp

    str_trim = TRIM(ADJUSTL(str_in))
    test_len = LEN(TRIM(str_test))
    in_len = LEN(TRIM(str_trim))

    IF (test_len > 0) THEN
      IF (IACHAR(str_test(test_len:test_len)) == 0) test_len = test_len - 1
    ENDIF
    IF (in_len > 0) THEN
      IF (IACHAR(str_trim(in_len:in_len)) == 0) in_len = in_len - 1
    ENDIF

    IF (test_len /= in_len) THEN
      str_cmp = .FALSE.
      RETURN
    ENDIF

    str_cmp = (str_trim(1:test_len) == str_test(1:test_len))

  END FUNCTION str_cmp



  FUNCTION as_real_simple(str_in, err)

    CHARACTER(*), INTENT(IN) :: str_in
    INTEGER, INTENT(INOUT) :: err
    INTEGER :: f
    REAL(num) :: as_real_simple
    REAL(num) :: value = 0.0_num
    CHARACTER :: chr

    f = 1
    chr = str_in(1:1)
    IF (chr >= '0' .AND. chr <= '9' .OR. chr == '.') THEN
      READ(unit=str_in, fmt=*, iostat=f) value
    ENDIF
    IF (f /= 0) err = IOR(err, c_err_bad_value)
    as_real_simple = value

  END FUNCTION as_real_simple



  FUNCTION as_integer_simple(str_in, err)

    CHARACTER(*), INTENT(IN) :: str_in
    INTEGER, INTENT(INOUT) :: err
    INTEGER :: as_integer_simple, value = 0
    INTEGER :: f
    CHARACTER :: chr

    f = 1
    chr = str_in(1:1)
    IF (chr >= '0' .AND. chr <= '9') THEN
      READ(unit=str_in, fmt=*, iostat=f) value
    ENDIF
    IF (f /= 0) err = IOR(err, c_err_bad_value)
    as_integer_simple = value

  END FUNCTION as_integer_simple



  FUNCTION as_long_integer_simple(str_in, err)

    CHARACTER(*), INTENT(IN) :: str_in
    INTEGER, INTENT(INOUT) :: err
    INTEGER(i8) :: as_long_integer_simple, value = 0
    INTEGER :: f
    CHARACTER :: chr

    f = 1
    chr = str_in(1:1)
    IF (chr >= '0' .AND. chr <= '9') THEN
      READ(unit=str_in, fmt=*, iostat=f) value
    ENDIF
    IF (f /= 0) err = IOR(err, c_err_bad_value)
    as_long_integer_simple = value

  END FUNCTION as_long_integer_simple



  FUNCTION as_boundary(str_in, err)

    CHARACTER(*), INTENT(IN) :: str_in
    INTEGER, INTENT(INOUT) :: err
    INTEGER :: as_boundary

    as_boundary = -1

    IF (str_cmp(str_in, 'x_min') .OR. str_cmp(str_in, 'left')) &
        as_boundary = c_bd_x_min
    IF (str_cmp(str_in, 'x_max') .OR. str_cmp(str_in, 'right')) &
        as_boundary = c_bd_x_max

    IF (as_boundary == -1) err = IOR(err, c_err_bad_value)

  END FUNCTION as_boundary



  FUNCTION as_logical(str_in, err)

    CHARACTER(*), INTENT(IN) :: str_in
    INTEGER, INTENT(INOUT) :: err
    LOGICAL :: as_logical

    as_logical = .FALSE.
    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'T')) THEN
      as_logical = .TRUE.
      RETURN
    ENDIF
    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'F')) THEN
      as_logical = .FALSE.
      RETURN
    ENDIF

    err = IOR(err, c_err_bad_value)

  END FUNCTION as_logical



  FUNCTION as_bc(str_in, err)

    CHARACTER(*), INTENT(IN) :: str_in
    INTEGER, INTENT(INOUT) :: err
    INTEGER :: as_bc

    as_bc = -1

    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'periodic')) THEN
      as_bc = c_bc_periodic
      RETURN
    ENDIF

    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'simple_laser')) THEN
      as_bc = c_bc_simple_laser
      RETURN
    ENDIF

    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'simple_outflow')) THEN
      as_bc = c_bc_simple_outflow
      RETURN
    ENDIF

    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'other')) THEN
      as_bc = c_bc_other
      RETURN
    ENDIF

    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'reflect')) THEN
      as_bc = c_bc_reflect
      RETURN
    ENDIF

    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'conduct')) THEN
      as_bc = c_bc_conduct
      RETURN
    ENDIF

    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'open')) THEN
      as_bc = c_bc_open
      RETURN
    ENDIF

    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'thermal')) THEN
      as_bc = c_bc_thermal
      RETURN
    ENDIF

    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'cpml_laser')) THEN
      as_bc = c_bc_cpml_laser
      RETURN
    ENDIF

    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'cpml_outflow')) THEN
      as_bc = c_bc_cpml_outflow
      RETURN
    ENDIF

    err = IOR(err, c_err_bad_value)

  END FUNCTION as_bc



  FUNCTION as_domain(str_in, err)

    CHARACTER(*), INTENT(IN) :: str_in
    INTEGER, INTENT(INOUT) :: err
    INTEGER :: as_domain

    as_domain = -1

    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'decomposed')) THEN
      as_domain = c_do_decomposed
      RETURN
    ENDIF
    IF (str_cmp(TRIM(ADJUSTL(str_in)), 'full')) THEN
      as_domain = c_do_full
      RETURN
    ENDIF

    err = IOR(err, c_err_bad_value)

  END FUNCTION as_domain



  FUNCTION as_bc_print(str_in, element, err) RESULT(res)

    CHARACTER(*), INTENT(IN) :: str_in, element
    INTEGER, INTENT(INOUT) :: err
    INTEGER :: res

    res = as_bc(str_in, err)

    IF (.NOT.print_deck_constants .OR. rank /= 0) RETURN

    WRITE(du,'(A,I9)') TRIM(element) // ' = ', res

  END FUNCTION as_bc_print



  FUNCTION as_boundary_print(str_in, element, err) RESULT(res)

    CHARACTER(*), INTENT(IN) :: str_in, element
    INTEGER, INTENT(INOUT) :: err
    INTEGER :: res

    res = as_boundary(str_in, err)

    IF (.NOT.print_deck_constants .OR. rank /= 0) RETURN

    WRITE(du,'(A,I9)') TRIM(element) // ' = ', res

  END FUNCTION as_boundary_print



  FUNCTION as_logical_print(str_in, element, err) RESULT(res)

    CHARACTER(*), INTENT(IN) :: str_in, element
    INTEGER, INTENT(INOUT) :: err
    LOGICAL :: res

    res = as_logical(str_in, err)

    IF (.NOT.print_deck_constants .OR. rank /= 0) RETURN

    WRITE(du,'(A,L1)') TRIM(element) // ' = ', res

  END FUNCTION as_logical_print

END MODULE strings
