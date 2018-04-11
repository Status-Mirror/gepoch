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

MODULE deck_window_block

  USE strings_advanced

  IMPLICIT NONE

  PRIVATE
  PUBLIC :: window_deck_initialise, window_deck_finalise
  PUBLIC :: window_block_start, window_block_end
  PUBLIC :: window_block_handle_element, window_block_check

CONTAINS

  SUBROUTINE window_deck_initialise

  END SUBROUTINE window_deck_initialise



  SUBROUTINE window_deck_finalise

    IF (move_window) need_random_state = .TRUE.

  END SUBROUTINE window_deck_finalise



  SUBROUTINE window_block_start

    IF (deck_state /= c_ds_first) RETURN

    bc_x_min_after_move = bc_field(c_bd_x_min)
    bc_x_max_after_move = bc_field(c_bd_x_max)

  END SUBROUTINE window_block_start



  SUBROUTINE window_block_end

  END SUBROUTINE window_block_end



  FUNCTION window_block_handle_element(element, value) RESULT(errcode)

    CHARACTER(*), INTENT(IN) :: element, value
    INTEGER :: errcode

    errcode = c_err_none
    IF (deck_state /= c_ds_first) RETURN
    IF (element == blank .OR. value == blank) RETURN

    IF (str_cmp(element, 'move_window')) THEN
      move_window = as_logical_print(value, element, errcode)
      RETURN
    ENDIF

    IF (str_cmp(element, 'window_v_x')) THEN
      window_v_x = as_real_print(value, element, errcode)
      RETURN
    ENDIF

    IF (str_cmp(element, 'window_start_time')) THEN
      window_start_time = as_real_print(value, element, errcode)
      RETURN
    ENDIF

    IF (str_cmp(element, 'bc_x_min_after_move') &
        .OR. str_cmp(element, 'xbc_left_after_move')) THEN
      bc_x_min_after_move = as_bc_print(value, element, errcode)
      RETURN
    ENDIF

    IF (str_cmp(element, 'bc_x_max_after_move') &
        .OR. str_cmp(element, 'xbc_right_after_move')) THEN
      bc_x_max_after_move = as_bc_print(value, element, errcode)
      RETURN
    ENDIF

    errcode = c_err_unknown_element

  END FUNCTION window_block_handle_element



  FUNCTION window_block_check() RESULT(errcode)

    INTEGER :: errcode
    errcode = c_err_none

  END FUNCTION window_block_check

END MODULE deck_window_block
