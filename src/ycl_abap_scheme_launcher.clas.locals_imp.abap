*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include           YY_LIB_LISP
*& https://github.com/nomssi/abap_scheme
*& https://github.com/mydoghasworms/abap-lisp
*& Lisp interpreter written in ABAP
*& Copy and paste this code into a type I (include) program
*&---------------------------------------------------------------------*
*& MIT License (see below)
*& Martin Ceronio, martin.ceronio@infosize.co.za June 2015
*& Jacques Nomssi Nzali, www.informatik-dv.com February 2020
*&---------------------------------------------------------------------*
*  The MIT License (MIT)
*
*  Copyright (c) 2018 Jacques Nomssi Nzali
*  Copyright (c) 2015 Martin Ceronio
*
*  Permission is hereby granted, free of charge, to any person obtaining a copy
*  of this software and associated documentation files (the "Software"), to deal
*  in the Software without restriction, including without limitation the rights
*  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*  copies of the Software, and to permit persons to whom the Software is
*  furnished to do so, subject to the following conditions:
*
*  The above copyright notice and this permission notice shall be included in
*  all copies or substantial portions of the Software.
*
*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
*  THE SOFTWARE.

  CLASS lcl_demo_output DEFINITION.
    PUBLIC SECTION.
      METHODS CONSTRUCTOR IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
      METHODS write IMPORTING iv_text TYPE any.
      METHODS display.
      METHODS begin_section IMPORTING iv_text TYPE any.
    PRIVATE SECTION.
      DATA out TYPE REF TO if_oo_adt_classrun_out.
  ENDCLASS.

  CLASS lcl_demo_output IMPLEMENTATION.

    METHOD constructor.
      me->out = out.
    ENDMETHOD.

    METHOD write.
      out->write( iv_text ).
    ENDMETHOD.

    METHOD begin_section.
      out->write( iv_text ).
    ENDMETHOD.

    METHOD display.
      "out->write( ).
    ENDMETHOD.

  ENDCLASS.

*--------------------------------------------------------------------*
* EXCEPTIONS
*--------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  CLASS lcx_lisp_exception DEFINITION
*----------------------------------------------------------------------*
*  General Lisp exception
*----------------------------------------------------------------------*
  CLASS lcx_lisp_exception DEFINITION INHERITING FROM cx_dynamic_check.
    PUBLIC SECTION.
      METHODS constructor IMPORTING message TYPE string
                                    area    TYPE string OPTIONAL.
      METHODS get_text REDEFINITION.
    PROTECTED SECTION.
      DATA mv_area TYPE string.
      DATA mv_message TYPE string.
  ENDCLASS.                    "lcx_lisp_exception DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcx_lisp_exception IMPLEMENTATION
*----------------------------------------------------------------------*
  CLASS lcx_lisp_exception IMPLEMENTATION.
    METHOD constructor.
      super->constructor( ).
      IF message IS INITIAL.
        mv_message = c_error_message.
      ELSE.
        mv_message = message.
      ENDIF.
      IF area IS NOT INITIAL.
        mv_area = area && `: `.
      ENDIF.
    ENDMETHOD.                    "constructor

    METHOD get_text.
      result = mv_area && mv_message.
    ENDMETHOD.                    "get_text

  ENDCLASS.                    "lcx_lisp_exception IMPLEMENTATION

  CLASS lcl_lisp_environment DEFINITION DEFERRED.

  CLASS lcl_sexps DEFINITION.   " Symbolic expression (S-expression)
    PUBLIC SECTION.
      TYPES tv_type TYPE tv_char.
*      Type definitions for the various elements
      CONSTANTS:
        type_symbol   TYPE tv_type VALUE 'S',
        type_integer  TYPE tv_type VALUE 'N',
        type_real     TYPE tv_type VALUE 'R',
        type_complex  TYPE tv_type VALUE 'z',
        type_rational TYPE tv_type VALUE 'r',
        type_string   TYPE tv_type VALUE '"'.
      CONSTANTS:
        type_boolean     TYPE tv_type VALUE 'b',
        type_char        TYPE tv_type VALUE 'c',
        type_null        TYPE tv_type VALUE '0',
        type_pair        TYPE tv_type VALUE 'C',
        type_lambda      TYPE tv_type VALUE 'L',
        type_case_lambda TYPE tv_type VALUE 'A',
        type_native      TYPE tv_type VALUE 'n',
        type_primitive   TYPE tv_type VALUE 'I',
        type_syntax      TYPE tv_type VALUE 'y',
        type_hash        TYPE tv_type VALUE 'h',
        type_vector      TYPE tv_type VALUE 'v',
        type_bytevector  TYPE tv_type VALUE '8',
        type_port        TYPE tv_type VALUE 'o',
        type_undefined   TYPE tv_type VALUE '#'.
*      Types for ABAP integration:
      CONSTANTS:
        type_abap_data     TYPE tv_type VALUE 'D',
        type_abap_table    TYPE tv_type VALUE 'T',
        type_abap_query    TYPE tv_type VALUE 'q',
        type_abap_sql_set  TYPE tv_type VALUE 's',
        type_abap_function TYPE tv_type VALUE 'F'.
*        type_abap_class    TYPE tv_type VALUE 'a',
*        type_abap_method   TYPE tv_type VALUE 'm'.

*      Types for Turtles graphic:
      CONSTANTS:
        type_abap_turtle TYPE tv_type VALUE 't'.

      DATA type TYPE tv_char.
  ENDCLASS.

  CLASS lcl_lisp_iterator DEFINITION DEFERRED.
  CLASS lcl_lisp_new DEFINITION DEFERRED.
  CLASS lcl_lisp_interpreter DEFINITION DEFERRED.

* Single element that will capture cons cells, atoms etc.
*----------------------------------------------------------------------*
*       CLASS lcl_lisp DEFINITION
*----------------------------------------------------------------------*
  CLASS lcl_lisp DEFINITION INHERITING FROM lcl_sexps FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
*     Can this be replaced by a mesh? cf. DEMO_RND_PARSER_AST
      DATA mutable TYPE abap_boolean VALUE abap_true READ-ONLY.

      DATA macro TYPE abap_boolean.
      DATA value TYPE string.

      DATA car TYPE REF TO lcl_lisp.
      DATA cdr TYPE REF TO lcl_lisp.
      DATA mv_label TYPE string.

      CLASS-METHODS class_constructor.

      CLASS-DATA nil        TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA false      TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA true       TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA undefined  TYPE REF TO  lcl_lisp READ-ONLY.

      CLASS-DATA quote            TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA quasiquote       TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA unquote          TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA unquote_splicing TYPE REF TO  lcl_lisp READ-ONLY.

      CLASS-DATA append           TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA cons             TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA list             TYPE REF TO  lcl_lisp READ-ONLY.

      CLASS-DATA char_alarm       TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA char_backspace   TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA char_delete      TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA char_escape      TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA char_newline     TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA char_null        TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA char_return      TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA char_space       TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA char_tab         TYPE REF TO  lcl_lisp READ-ONLY.

      CLASS-DATA new_line   TYPE REF TO  lcl_lisp READ-ONLY.
      CLASS-DATA eof_object TYPE REF TO  lcl_lisp READ-ONLY.

*     Specifically for lambdas:
      DATA environment TYPE REF TO lcl_lisp_environment.
*     Format
      METHODS to_string RETURNING VALUE(str) TYPE string
                        RAISING   lcx_lisp_exception.
      METHODS to_text RETURNING VALUE(str) TYPE string
                      RAISING   lcx_lisp_exception.
*     Utilities
      METHODS new_iterator RETURNING VALUE(ro_iter) TYPE REF TO lcl_lisp_iterator
                           RAISING   lcx_lisp_exception.

      METHODS is_equivalent IMPORTING io_elem       TYPE REF TO lcl_lisp
                            RETURNING VALUE(result) TYPE REF TO lcl_lisp
                            RAISING   lcx_lisp_exception.

      METHODS is_equal IMPORTING io_elem       TYPE REF TO lcl_lisp
                                 comp          TYPE REF TO lcl_lisp DEFAULT nil
                                 interpreter   TYPE REF TO lcl_lisp_interpreter OPTIONAL
                                 environment   TYPE REF TO lcl_lisp_environment OPTIONAL
                       RETURNING VALUE(result) TYPE REF TO lcl_lisp
                       RAISING   lcx_lisp_exception.

      METHODS set_shared_structure RAISING lcx_lisp_exception.

      METHODS is_procedure RETURNING VALUE(result) TYPE REF TO lcl_lisp.

      METHODS is_number RETURNING VALUE(result) TYPE REF TO lcl_lisp.

      METHODS error_not_a_pair IMPORTING context TYPE string DEFAULT space
                               RAISING   lcx_lisp_exception.

      CLASS-METHODS throw IMPORTING message TYPE string
                          RAISING   lcx_lisp_exception.
    PROTECTED SECTION.
      METHODS list_to_string RETURNING VALUE(str) TYPE string
                             RAISING   lcx_lisp_exception.

      METHODS format_quasiquote IMPORTING io_elem TYPE REF TO lcl_lisp
                                EXPORTING ev_skip TYPE abap_boolean
                                          ev_str  TYPE string.
  ENDCLASS.                    "lcl_lisp DEFINITION

  TYPES tt_lisp TYPE STANDARD TABLE OF REF TO lcl_lisp WITH EMPTY KEY.

  CLASS lcl_lisp_char DEFINITION INHERITING FROM lcl_lisp
    CREATE PROTECTED FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      CLASS-METHODS new IMPORTING value          TYPE any
                        RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp_char.
    PROTECTED SECTION.
      TYPES: BEGIN OF ts_char,
               char TYPE c LENGTH 1,
               elem TYPE REF TO lcl_lisp_char,
             END OF ts_char.
      CLASS-DATA char_table TYPE HASHED TABLE OF ts_char WITH UNIQUE KEY char.

      METHODS constructor IMPORTING value TYPE any.
  ENDCLASS.

  CLASS lcl_lisp_char IMPLEMENTATION.

    METHOD new.
      DATA lv_char TYPE c LENGTH 1.
      lv_char = value.
      ro_elem = VALUE #( char_table[ char = lv_char ]-elem DEFAULT NEW lcl_lisp_char( lv_char ) ).
    ENDMETHOD.

    METHOD constructor.
      super->constructor( ).
      type = lcl_lisp=>type_char.
      me->value = value.
      IF value EQ space.   " Special treatment for space,
        me->value = ` `.   " see https://blogs.sap.com/2016/08/10/trailing-blanks-in-character-string-processing/
      ENDIF.
      mutable = abap_false.
      INSERT VALUE #( char = value
                      elem = me ) INTO TABLE char_table.
    ENDMETHOD.

  ENDCLASS.

  CLASS lcl_lisp_null DEFINITION INHERITING FROM lcl_lisp FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
  ENDCLASS.

  CLASS lcl_lisp_boolean DEFINITION INHERITING FROM lcl_lisp FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      METHODS constructor IMPORTING value TYPE any.
  ENDCLASS.

  CLASS lcl_lisp_boolean IMPLEMENTATION.

    METHOD constructor.
      super->constructor( ).
      type = type_boolean.
      me->value = value.
    ENDMETHOD.

  ENDCLASS.

  CLASS lcl_lisp_string DEFINITION INHERITING FROM lcl_lisp
    CREATE PROTECTED FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
    PROTECTED SECTION.
      METHODS constructor IMPORTING value      TYPE any
                                    iv_mutable TYPE abap_boolean.
  ENDCLASS.

  CLASS lcl_lisp_string IMPLEMENTATION.

    METHOD constructor.
      super->constructor( ).
      type = type_string.
      me->value = value.
      mutable = iv_mutable.
    ENDMETHOD.

  ENDCLASS.

  CLASS lcl_lisp_number DEFINITION INHERITING FROM lcl_lisp ABSTRACT.
    PUBLIC SECTION.
      METHODS is_exact RETURNING VALUE(result) TYPE REF TO lcl_lisp.
      METHODS is_inexact RETURNING VALUE(result) TYPE REF TO lcl_lisp.
      DATA exact TYPE abap_boolean READ-ONLY.
  ENDCLASS.

  CLASS lcl_lisp_number IMPLEMENTATION.

    METHOD is_exact.
      result = false.
      CHECK exact EQ abap_true.
      result = true.
    ENDMETHOD.

    METHOD is_inexact.
      result = true.
      CHECK exact EQ abap_true.
      result = false.
    ENDMETHOD.

  ENDCLASS.

  CLASS lcl_lisp_integer DEFINITION INHERITING FROM lcl_lisp_number
    CREATE PROTECTED FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      DATA integer TYPE tv_int READ-ONLY.
    PROTECTED SECTION.
      METHODS constructor IMPORTING value TYPE any.
  ENDCLASS.

  CLASS lcl_lisp_rational DEFINITION INHERITING FROM lcl_lisp_integer
    CREATE PROTECTED FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      CLASS-METHODS new IMPORTING nummer        TYPE tv_int
                                  denom         TYPE tv_int
                        RETURNING VALUE(result) TYPE REF TO lcl_lisp_integer.

      DATA denominator TYPE tv_int READ-ONLY.
      METHODS to_string REDEFINITION.
      CLASS-METHODS gcd IMPORTING n             TYPE numeric
                                  d             TYPE numeric
                        RETURNING VALUE(result) TYPE tv_int
                        RAISING   lcx_lisp_exception.
    PROTECTED SECTION.
      METHODS constructor IMPORTING nummer TYPE tv_int
                                    denom  TYPE tv_int.
      METHODS normalize RAISING lcx_lisp_exception.
  ENDCLASS.

  CLASS lcl_lisp_integer IMPLEMENTATION.

    METHOD constructor.
      super->constructor( ).
      type = lcl_lisp=>type_integer.
      integer = value.
      exact = abap_true.
    ENDMETHOD.

  ENDCLASS.

  CLASS lcl_lisp_rational IMPLEMENTATION.

    METHOD new.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      CREATE OBJECT lo_rat
        EXPORTING
          nummer = nummer
          denom  = denom.
      IF lo_rat->denominator EQ 1.
        CREATE OBJECT result TYPE lcl_lisp_integer
          EXPORTING value = lo_rat->integer.
      ELSE.
        result = lo_rat.
      ENDIF.
    ENDMETHOD.

    METHOD constructor.
      super->constructor( nummer ).
      type = type_rational.
      denominator = denom.
      normalize( ).
    ENDMETHOD.

    METHOD to_string.
      str = |{ integer }/{ denominator }|.
    ENDMETHOD.

    METHOD normalize.
      DATA(g) = gcd( n = integer
                     d = denominator ).
      integer = trunc( integer / g ).
      denominator = trunc( denominator / g ).
      IF denominator LT 0.
        integer = - integer.
        denominator = - denominator.
      ENDIF.
      exact = xsdbool( denominator NE 0 ).
    ENDMETHOD.

    METHOD gcd.
      DATA num TYPE tv_int.
      DATA den TYPE tv_int.
      DATA lv_save TYPE tv_int.

      num = n.
      den = d.
      WHILE den NE 0.
        lv_save = den.
        TRY.
            den = num MOD den.  " num - den * trunc( num / den ).
          CATCH cx_sy_arithmetic_error INTO DATA(lx_error).
            throw( lx_error->get_text( ) ).
        ENDTRY.
        num = lv_save.
      ENDWHILE.
      result = abs( num ).
    ENDMETHOD.

  ENDCLASS.

  CLASS lcl_lisp_real DEFINITION INHERITING FROM lcl_lisp_number
    CREATE PROTECTED FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      DATA real TYPE tv_real READ-ONLY.
      METHODS float_eq IMPORTING iv_real       TYPE tv_real
                       RETURNING VALUE(result) TYPE abap_boolean.
      CLASS-METHODS gcd IMPORTING n             TYPE numeric
                                  d             TYPE numeric
                        RETURNING VALUE(result) TYPE tv_real
                        RAISING   lcx_lisp_exception.
    PROTECTED SECTION.
      METHODS constructor IMPORTING value TYPE any.
  ENDCLASS.

  CLASS lcl_lisp_real IMPLEMENTATION.

    METHOD constructor.
      super->constructor( ).
      type = lcl_lisp=>type_real.
      real = value.
      exact = abap_false.
    ENDMETHOD.

    METHOD float_eq.
      CONSTANTS: c_epsilon    TYPE tv_real VALUE cl_abap_math=>min_decfloat16,
                 c_min_normal TYPE tv_real VALUE cl_abap_math=>min_decfloat34,
                 c_max_value  TYPE tv_real VALUE cl_abap_math=>max_decfloat34.
      DATA diff TYPE tv_real.
      DATA sum TYPE tv_real.
      DATA abs_a TYPE tv_real.
      DATA abs_b TYPE tv_real.

      result = abap_false.
      IF real EQ iv_real.
        result = abap_true.
      ELSE.
        abs_a = abs( real ).
        abs_b = abs( iv_real ).
        diff = abs( real - iv_real ).
        sum = abs_a + abs_b.

        IF real = 0 OR iv_real = 0 OR sum < c_min_normal.
*         real or iv_real is zero or both are extremely close to it
*         relative error is less meaningfull here
          IF diff < c_epsilon * c_min_normal.
            result = abap_true.
          ELSE. " use relative error
            IF diff / nmin( val1 = sum val2 = c_max_value ) < c_epsilon.
              result = abap_true.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDMETHOD.

    METHOD gcd.
      DATA num TYPE REF TO lcl_lisp_real.
      DATA den TYPE REF TO lcl_lisp_real.
      DATA lo_save TYPE REF TO lcl_lisp_real.

      num = NEW #( n ).
      den = NEW #( d ).
      WHILE NOT den->float_eq( 0 ).
        lo_save = den.
        TRY.
            den = NEW #( num->real MOD den->real ).
*            den = NEW #( num->real - den->real * trunc( num->real / den->real ) ).
          CATCH cx_sy_arithmetic_error INTO DATA(lx_error).
            throw( lx_error->get_text( ) ).
        ENDTRY.
        num = lo_save.
      ENDWHILE.
      result = abs( num->real ).
    ENDMETHOD.

  ENDCLASS.

  CLASS lcl_lisp_pair DEFINITION INHERITING FROM lcl_lisp FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
    PROTECTED SECTION.
  ENDCLASS.

  CLASS lcl_lisp_lambda DEFINITION INHERITING FROM lcl_lisp_pair FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      DATA parameter_object TYPE abap_boolean.
    PROTECTED SECTION.
  ENDCLASS.

  CLASS lcl_lisp_case_lambda DEFINITION INHERITING FROM lcl_lisp FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      METHODS match IMPORTING args          TYPE REF TO lcl_lisp
                    RETURNING VALUE(result) TYPE REF TO lcl_lisp_lambda
                    RAISING   lcx_lisp_exception.
    PROTECTED SECTION.
      DATA clauses TYPE tt_lisp.
  ENDCLASS.

  CLASS lcl_lisp_case_lambda IMPLEMENTATION.

    METHOD match.
*     Find the first lambda where we can assign each argument to its corresponding symbol
      DATA lo_lambda TYPE REF TO lcl_lisp_lambda.
      DATA lo_clause TYPE REF TO lcl_lisp.

      LOOP AT clauses INTO lo_clause.
        IF lo_clause->type NE type_lambda.
          EXIT.
        ENDIF.
        lo_lambda ?= lo_clause.
        DATA(lo_var) = lo_lambda->car.      " pointer to formal parameters
        DATA(lo_arg) = args.                " Pointer to arguments

        CASE lo_arg->type.
          WHEN lcl_lisp=>type_pair OR lcl_lisp=>type_null.   "Do we have a proper list?

            WHILE lo_var NE lcl_lisp=>nil.         " Nil would mean no parameters to map

              IF lo_var->type EQ lcl_lisp=>type_symbol.
*               dotted pair after fixed number of parameters, to be bound to a variable number of arguments
                result = lo_lambda.
                RETURN.
              ENDIF.

*             Part of the list with fixed number of parameters
              IF lo_arg = lcl_lisp=>nil.           " Premature end of arguments
                EXIT.
              ENDIF.

              lo_var = lo_var->cdr.
              lo_arg = lo_arg->cdr.
              CHECK lo_arg IS NOT BOUND.
              lo_arg = lcl_lisp=>nil.
            ENDWHILE.

            IF lo_arg EQ lcl_lisp=>nil AND lo_var EQ lcl_lisp=>nil.  " Correct number of arguments
              result = lo_lambda.
              RETURN.
            ENDIF.

          WHEN lcl_lisp=>type_symbol.
*           args is a symbol to be bound to a variable number of parameters
            result = lo_lambda.
            RETURN.

        ENDCASE.

      ENDLOOP.

      throw( `no clause matching the arguments` ).

    ENDMETHOD.

  ENDCLASS.

  CLASS lcl_lisp_symbol DEFINITION INHERITING FROM lcl_lisp FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      METHODS constructor IMPORTING value TYPE any
                                    index TYPE tv_int.
      DATA index TYPE tv_int READ-ONLY.
  ENDCLASS.

  CLASS lcl_lisp_symbol IMPLEMENTATION.

    METHOD constructor.
      super->constructor( ).
      type = type_symbol.
      me->index = index.
      me->value = value.
    ENDMETHOD.

  ENDCLASS.

  CLASS lcl_lisp_data DEFINITION INHERITING FROM lcl_lisp FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      DATA data TYPE REF TO data.            " for ABAP integrations
    PROTECTED SECTION.
  ENDCLASS.

  CLASS lcl_lisp_table DEFINITION INHERITING FROM lcl_lisp_data FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
    PROTECTED SECTION.
  ENDCLASS.

  INTERFACE lif_native.
    METHODS proc IMPORTING list          TYPE REF TO lcl_lisp
                 RETURNING VALUE(result) TYPE REF TO lcl_lisp
                 RAISING   lcx_lisp_exception.
  ENDINTERFACE.

  INTERFACE lif_log.
    METHODS put IMPORTING io_elem TYPE REF TO lcl_lisp.
    METHODS get RETURNING VALUE(result) TYPE string.
  ENDINTERFACE.

  CLASS lcl_lisp_vector DEFINITION DEFERRED.
*  CLASS lcl_lisp_abapfunction DEFINITION DEFERRED.
  CLASS lcl_lisp_hash DEFINITION DEFERRED.

  INTERFACE lif_input_port.
    METHODS read IMPORTING iv_title        TYPE string OPTIONAL
                 RETURNING VALUE(rv_input) TYPE string.
    METHODS peek_char RETURNING VALUE(rv_char) TYPE tv_char.
    METHODS is_char_ready RETURNING VALUE(rv_flag) TYPE abap_boolean.
    METHODS read_char RETURNING VALUE(rv_char) TYPE tv_char.
    METHODS put IMPORTING iv_text TYPE string.
  ENDINTERFACE.

  INTERFACE lif_output_port.
    METHODS write IMPORTING element TYPE REF TO lcl_lisp.
    METHODS display IMPORTING element TYPE REF TO lcl_lisp
                    RAISING   lcx_lisp_exception.
  ENDINTERFACE.

  CLASS lcl_lisp_port DEFINITION INHERITING FROM lcl_lisp FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      TYPES tv_port_type TYPE tv_char.
      CONSTANTS:
        c_port_textual TYPE tv_port_type VALUE 't',
        c_port_binary  TYPE tv_port_type VALUE 'b'.

      INTERFACES lif_input_port.
      INTERFACES lif_output_port.

      ALIASES: read FOR lif_input_port~read,
               write FOR lif_output_port~write,
               display FOR lif_output_port~display,
               set_input_string FOR lif_input_port~put.
      METHODS constructor IMPORTING iv_port_type TYPE lcl_lisp_port=>tv_port_type DEFAULT c_port_textual
                                    iv_input     TYPE abap_boolean
                                    iv_output    TYPE abap_boolean
                                    iv_error     TYPE abap_boolean DEFAULT abap_false
                                    out TYPE REF TO if_oo_adt_classrun_out.
      METHODS close.
      METHODS close_input.
      METHODS close_output.

      METHODS read_stream IMPORTING iv_title        TYPE string OPTIONAL
                          RETURNING VALUE(rv_input) TYPE string.

      DATA port_type TYPE tv_port_type READ-ONLY.
      DATA input TYPE abap_boolean READ-ONLY.
      DATA output TYPE abap_boolean READ-ONLY.
      DATA error TYPE abap_boolean READ-ONLY.
    PROTECTED SECTION.
*     input is always buffered
      DATA last_input TYPE string.
      DATA last_index TYPE tv_index.
      DATA last_len TYPE tv_index.
      DATA finite_size TYPE abap_boolean.
      DATA out TYPE REF TO if_oo_adt_classrun_out.

      METHODS block_read RETURNING VALUE(rv_char) TYPE tv_char.
  ENDCLASS.

  CLASS lcl_lisp_buffered_port DEFINITION INHERITING FROM lcl_lisp_port FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      INTERFACES lif_log.
      METHODS write REDEFINITION.
      METHODS read REDEFINITION.
      METHODS lif_input_port~peek_char REDEFINITION.
      METHODS display REDEFINITION.
      METHODS flush RETURNING VALUE(rv_text) TYPE string.
      METHODS constructor IMPORTING iv_port_type TYPE lcl_lisp_port=>tv_port_type DEFAULT c_port_textual
                                    iv_input     TYPE abap_boolean
                                    iv_output    TYPE abap_boolean
                                    iv_error     TYPE abap_boolean DEFAULT abap_false
                                    iv_separator TYPE string DEFAULT c_expr_separator
                                    iv_string    TYPE abap_boolean
                                    out TYPE REF TO if_oo_adt_classrun_out.
    PROTECTED SECTION.
      DATA string_mode TYPE abap_boolean.
      DATA buffer TYPE string.
      DATA separator TYPE string.

      METHODS add IMPORTING text TYPE string.
  ENDCLASS.

"  INCLUDE yy_lib_turtle.
*&---------------------------------------------------------------------*
*&  Include           YY_LIB_TURTLE
*&---------------------------------------------------------------------*
* Ported from https://github.com/FreHu/abap-turtle-graphics

"TYPES tv_real TYPE decfloat34.  " real data type

CLASS lcx_turtle_problem DEFINITION CREATE PRIVATE
  INHERITING FROM cx_no_check.

  PUBLIC SECTION.
    CLASS-METHODS raise IMPORTING text TYPE string.
    METHODS constructor IMPORTING text     TYPE string
                                  previous TYPE REF TO cx_root OPTIONAL.
  PRIVATE SECTION.
    DATA text TYPE string.
ENDCLASS.

CLASS lcx_turtle_problem IMPLEMENTATION.

  METHOD raise.
    RAISE EXCEPTION TYPE lcx_turtle_problem EXPORTING text = text.
  ENDMETHOD.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( ).
    me->text = text.
    me->previous = previous.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_turtle_math DEFINITION.
  PUBLIC SECTION.
    TYPES numbers_i TYPE STANDARD TABLE OF tv_int WITH DEFAULT KEY.

    CLASS-METHODS find_max_int
      IMPORTING numbers       TYPE numbers_i
      RETURNING VALUE(result) TYPE tv_int.
ENDCLASS.

CLASS lcl_turtle_math IMPLEMENTATION.

  METHOD find_max_int.
    DATA(max) = numbers[ 1 ].
    LOOP AT numbers ASSIGNING FIELD-SYMBOL(<num>) FROM 2.
      CHECK <num> > max.
      max = <num>.
    ENDLOOP.

    result = max.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_turtle_convert DEFINITION.
  PUBLIC SECTION.
    CONSTANTS pi TYPE tv_real
      VALUE '3.1415926535897932384626433832795'.

    CLASS-METHODS degrees_to_radians
      IMPORTING degrees        TYPE tv_real
      RETURNING VALUE(radians) TYPE tv_real.

    CLASS-METHODS radians_to_degrees
      IMPORTING radians        TYPE tv_real
      RETURNING VALUE(degrees) TYPE tv_real.
ENDCLASS.

CLASS lcl_turtle_convert IMPLEMENTATION.

  METHOD degrees_to_radians.
    radians = degrees * pi / 180.
  ENDMETHOD.

  METHOD radians_to_degrees.
    degrees = radians * 180 / pi.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_number_range DEFINITION.
  PUBLIC SECTION.
    TYPES number_range TYPE STANDARD TABLE OF i WITH EMPTY KEY.

    "! Returns the list of numbers &lt;min, max).
    "! This method repeats the mistake of Python 2.x and will consume a lot of memory if used with large ranges
    CLASS-METHODS get
      IMPORTING min           TYPE i
                max           TYPE i
      RETURNING VALUE(result) TYPE number_range.
ENDCLASS.

CLASS lcl_number_range IMPLEMENTATION.

  METHOD get.
    DATA(i) = min.
    WHILE i < max.
      APPEND i TO result.
      i = i + 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_turtle_colors DEFINITION.
  PUBLIC SECTION.
    TYPES: rgb_hex_color  TYPE string,
           rgb_hex_colors TYPE STANDARD TABLE OF rgb_hex_color WITH EMPTY KEY.

    TYPES: BEGIN OF t_pen,
             stroke_color TYPE rgb_hex_color,
             stroke_width TYPE i,
             fill_color   TYPE rgb_hex_color,
             is_up        TYPE abap_bool,
           END OF t_pen.

    CLASS-METHODS class_constructor.
    CLASS-METHODS get_random_color
      IMPORTING colors       TYPE rgb_hex_colors
      RETURNING VALUE(color) TYPE rgb_hex_color.

    CLASS-DATA default_color_scheme TYPE rgb_hex_colors.
    CLASS-DATA default_pen TYPE t_pen.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA random TYPE REF TO cl_abap_random.
ENDCLASS.


CLASS lcl_turtle_colors IMPLEMENTATION.

  METHOD class_constructor.
    default_color_scheme = VALUE #(
      ( `#8a295c` )
      ( `#5bbc6d` )
      ( `#cb72d3` )
      ( `#a8b03f` )
      ( `#6973d8` )
      ( `#c38138` )
      ( `#543788` )
      ( `#768a3c` )
      ( `#ac4595` )
      ( `#47bf9c` )
      ( `#db6697` )
      ( `#5f8dd3` )
      ( `#b64e37` )
      ( `#c287d1` )
      ( `#ba4758` )  ).

    random = cl_abap_random=>create( seed = 42 ).

    default_pen = VALUE t_pen( stroke_width = 1
                               stroke_color = `#FF0000`
                               is_up = abap_false ).
  ENDMETHOD.

  METHOD get_random_color.
    DATA(random_index) = random->intinrange( low = 1 high = lines( colors ) ).
    color = colors[ random_index ].
  ENDMETHOD.
ENDCLASS.

CLASS lcl_turtle DEFINITION DEFERRED.

CLASS lcl_turtle_svg DEFINITION.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF t_point,
        x TYPE i,
        y TYPE i,
      END OF t_point,
      t_points TYPE STANDARD TABLE OF t_point WITH DEFAULT KEY.

    TYPES:
      BEGIN OF line_params,
        x_from TYPE i,
        y_from TYPE i,
        x_to   TYPE i,
        y_to   TYPE i,
      END OF line_params,


      BEGIN OF polygon_params,
        points TYPE t_points,
      END OF polygon_params,
      polyline_params TYPE polygon_params,

      BEGIN OF text_params,
        x    TYPE i,
        y    TYPE i,
        text TYPE string,
      END OF text_params,

      BEGIN OF circle_params,
        center_x TYPE i,
        center_y TYPE i,
        radius   TYPE i,
      END OF circle_params.

    CLASS-METHODS:
      new
        IMPORTING turtle        TYPE REF TO lcl_turtle
        RETURNING VALUE(result) TYPE REF TO lcl_turtle_svg.

    METHODS:
      line
        IMPORTING params          TYPE line_params
        RETURNING VALUE(svg_line) TYPE string,

      polygon
        IMPORTING params             TYPE polygon_params
        RETURNING VALUE(svg_polygon) TYPE string,

      polyline
        IMPORTING params              TYPE polyline_params
        RETURNING VALUE(svg_polyline) TYPE string,

      text
        IMPORTING params          TYPE text_params
        RETURNING VALUE(svg_text) TYPE string,

      circle
        IMPORTING params            TYPE circle_params
        RETURNING VALUE(svg_circle) TYPE string.

    DATA turtle TYPE REF TO lcl_turtle READ-ONLY.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS lcl_turtle DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF defaults,
        height TYPE tv_int VALUE 800,
        width  TYPE tv_int VALUE 600,
        title  TYPE string VALUE `abapTurtle`,
      END OF defaults.

    TYPES: t_point  TYPE lcl_turtle_svg=>t_point,
           t_points TYPE lcl_turtle_svg=>t_points.

    TYPES t_pen TYPE lcl_turtle_colors=>t_pen.
    TYPES rgb_hex_color TYPE lcl_turtle_colors=>rgb_hex_color.
    TYPES rgb_hex_colors TYPE lcl_turtle_colors=>rgb_hex_colors.

    TYPES:
      BEGIN OF turtle_position,
        x     TYPE tv_int,
        y     TYPE tv_int,
        angle TYPE tv_real,
      END OF turtle_position.

    TYPES multiple_turtles TYPE STANDARD TABLE OF REF TO lcl_turtle.

    CLASS-METHODS new
      IMPORTING height           TYPE tv_int DEFAULT defaults-height
                width            TYPE tv_int DEFAULT defaults-width
                background_color TYPE rgb_hex_color OPTIONAL
                title            TYPE string DEFAULT defaults-title
                out TYPE REF TO if_oo_adt_classrun_out
      RETURNING VALUE(turtle)    TYPE REF TO lcl_turtle.

    "! Creates a new turtle based on an existing instance. The position, angle and pen are preserved.
    "! Does not preserve content.
    METHODS clone RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    "! Merges drawings of multiple turtles into one.
    CLASS-METHODS compose
      IMPORTING turtles       TYPE multiple_turtles
      RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS constructor
      IMPORTING height           TYPE tv_int
                width            TYPE tv_int
                background_color TYPE rgb_hex_color OPTIONAL
                title            TYPE string
                out TYPE REF TO if_oo_adt_classrun_out.

    METHODS right
      IMPORTING degrees       TYPE tv_real
      RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS left IMPORTING degrees       TYPE tv_real
                 RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS set_pen IMPORTING pen           TYPE t_pen
                    RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS goto
      IMPORTING x             TYPE tv_int
                y             TYPE tv_int
      RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS set_angle IMPORTING angle TYPE tv_real.

    METHODS forward IMPORTING how_far       TYPE tv_int
                    RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS to_offset
      IMPORTING delta_x       TYPE numeric
                delta_y       TYPE numeric
      RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS back IMPORTING how_far       TYPE tv_int
                 RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS pen_up RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS pen_down RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS show RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS polygon_flower IMPORTING number_of_polygons TYPE tv_int
                                     polygon_sides      TYPE tv_int
                                     side_length        TYPE tv_int
                           RETURNING VALUE(turtle)      TYPE REF TO lcl_turtle.

    METHODS filled_square IMPORTING side_length TYPE tv_int
                                    start       TYPE t_point
                          RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS regular_polygon IMPORTING num_sides     TYPE tv_int
                                      side_length   TYPE tv_int
                            RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.

    METHODS download
      IMPORTING filename TYPE string DEFAULT `abap-turtle.html`.

    METHODS enable_random_colors.
    METHODS disable_random_colors.

    METHODS get_svg RETURNING VALUE(svg) TYPE string.
    METHODS append_svg IMPORTING svg_to_append TYPE string.

    METHODS:
      get_position RETURNING VALUE(result) TYPE turtle_position,
      set_position IMPORTING position TYPE turtle_position,
      set_color_scheme IMPORTING color_scheme TYPE rgb_hex_colors,
      set_width IMPORTING width TYPE tv_int,
      set_height IMPORTING height TYPE tv_int,
      set_svg IMPORTING svg TYPE string.

    DATA: title        TYPE string READ-ONLY,
          svg          TYPE string READ-ONLY,
          width        TYPE tv_int READ-ONLY,
          height       TYPE tv_int READ-ONLY,
          position     TYPE turtle_position READ-ONLY,
          pen          TYPE t_pen READ-ONLY,
          color_scheme TYPE rgb_hex_colors READ-ONLY,
          svg_builder  TYPE REF TO lcl_turtle_svg READ-ONLY.

  PROTECTED SECTION.
    DATA out TYPE REF TO if_oo_adt_classrun_out.
  PRIVATE SECTION.
    DATA use_random_colors TYPE abap_bool.

    METHODS get_html RETURNING VALUE(html) TYPE string.

    METHODS line
      IMPORTING x_from        TYPE tv_int
                y_from        TYPE tv_int
                x_to          TYPE tv_int
                y_to          TYPE tv_int
      RETURNING VALUE(turtle) TYPE REF TO lcl_turtle.
ENDCLASS.

CLASS lcl_turtle IMPLEMENTATION.

  METHOD back.
    right( degrees = 180 ).
    forward( how_far ).
    right( degrees = 180 ).
  ENDMETHOD.

  METHOD constructor.
    me->width = width.
    me->height = height.
    me->pen = lcl_turtle_colors=>default_pen.
    me->color_scheme = lcl_turtle_colors=>default_color_scheme.
    me->use_random_colors = abap_true.
    me->title = title.
    me->out = out.
  ENDMETHOD.

  METHOD disable_random_colors.
    me->use_random_colors = abap_false.
  ENDMETHOD.

  METHOD download.
    RETURN.
*    DATA(file_name) = filename.
*    DATA(path) = ``.
*    DATA(full_path) = ``.
*
*    cl_gui_frontend_services=>file_save_dialog(
*      EXPORTING
*        default_extension = `html`
*        default_file_name = filename
*        initial_directory = ``
*      CHANGING
*        filename = file_name
*        path = path
*        fullpath = full_path
*      EXCEPTIONS
*        OTHERS = 1 ).
*
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*    SPLIT me->get_html( ) AT |\r\n| INTO TABLE DATA(lines).
*    cl_gui_frontend_services=>gui_download(
*      EXPORTING
*        filename = file_name
*      CHANGING
*        data_tab = lines
*      EXCEPTIONS OTHERS = 1 ).
*
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.

  ENDMETHOD.

  METHOD enable_random_colors.
    me->use_random_colors = abap_true.
  ENDMETHOD.

  METHOD to_offset.
    DATA(old_position) = position.
    DATA(new_position) = VALUE turtle_position( x = round( val = old_position-x + delta_x dec = 0 )
                                                y = round( val = old_position-y + delta_y dec = 0 )
                                            angle = old_position-angle ).
    IF pen-is_up = abap_false.
      me->line( x_from = position-x
                y_from = position-y
                x_to = new_position-x
                y_to = new_position-y ).
    ENDIF.

    set_position( new_position ).

    turtle = me.
  ENDMETHOD.

  METHOD forward.
    DATA(angle) = CONV f( lcl_turtle_convert=>degrees_to_radians( position-angle ) ).

    turtle = to_offset( delta_x = how_far * cos( angle )
                        delta_y = how_far * sin( angle ) ).
  ENDMETHOD.

  METHOD get_html.
    html = |<html><body><h1>abapTurtle</h1><svg width="{ width }" height="{ height }">{ svg }</svg></body></html>|.
  ENDMETHOD.

  METHOD get_position.
    result = me->position.
  ENDMETHOD.

  METHOD get_svg.
    svg = me->svg.
  ENDMETHOD.

  METHOD append_svg.
    svg = svg && svg_to_append.
  ENDMETHOD.

  METHOD goto.
    position-x = x.
    position-y = y.
    turtle = me.
  ENDMETHOD.

  METHOD left.
    position-angle = position-angle - degrees.
    position-angle = position-angle MOD 360.
    turtle = me.
  ENDMETHOD.

  METHOD line.

    IF use_random_colors = abap_true.
      pen-stroke_color = lcl_turtle_colors=>get_random_color( me->color_scheme ).
    ENDIF.

    svg = svg && |<line x1="{ x_from }" y1="{ y_from }" x2="{ x_to }" y2="{ y_to }"|
        && |stroke="{ pen-stroke_color }" stroke-width="{ pen-stroke_width }"/>|.

    turtle = me.
  ENDMETHOD.

  METHOD new.
    turtle = NEW lcl_turtle( width = width
                             height = height
                             background_color = background_color
                             title = title
                             out = out ).
  ENDMETHOD.

  METHOD clone.
    turtle = NEW #( width = width
                    height = height
                    title = title
                    out = out ).

    turtle->set_pen( pen ).
    turtle->set_color_scheme( color_scheme ).
    turtle->set_position( position ).
    turtle->set_angle( position-angle ).
  ENDMETHOD.

  METHOD compose.

    IF lines( turtles ) < 1.
      lcx_turtle_problem=>raise( `Not enough turtles to compose anything.` ).
    ENDIF.

    " start where the last one left off
    DATA(lo_turtle) = turtles[ lines( turtles ) ].
    turtle = lo_turtle->clone( ).

    " new image size is the largest of composed turtles
    DATA(new_width) = lcl_turtle_math=>find_max_int(
      VALUE #( FOR <x> IN turtles ( <x>->width ) ) ).

    DATA(new_height) = lcl_turtle_math=>find_max_int(
      VALUE #( FOR <x> IN turtles ( <x>->height ) ) ).

    turtle->set_height( new_height ).
    turtle->set_width( new_width ).

    DATA(composed_svg) = REDUCE string( INIT result = ``
        FOR <svg> IN VALUE string_table( FOR <x> IN turtles ( <x>->svg ) )
          NEXT result = result && <svg> ).

    turtle->append_svg( composed_svg ).

  ENDMETHOD.

  METHOD pen_down.
    me->pen-is_up = abap_false.
    turtle = me.
  ENDMETHOD.

  METHOD pen_up.
    me->pen-is_up = abap_true.
    turtle = me.
  ENDMETHOD.

  METHOD right.
    position-angle = position-angle + degrees.
    position-angle = position-angle MOD 360.
    turtle = me.
  ENDMETHOD.

  METHOD set_angle.
    me->position-angle = angle.
  ENDMETHOD.

  METHOD set_color_scheme.
    me->color_scheme = color_scheme.
  ENDMETHOD.

  METHOD set_width.
    me->width = width.
  ENDMETHOD.

  METHOD set_height.
    me->height = height.
  ENDMETHOD.

  METHOD set_svg.
    me->svg = svg.
  ENDMETHOD.

  METHOD set_pen.
    me->pen = pen.
    turtle = me.
  ENDMETHOD.

  METHOD set_position.
    me->position = position.
  ENDMETHOD.

  METHOD show.
    out->write( get_html( ) ).
    turtle = me.
  ENDMETHOD.

  METHOD regular_polygon.
    DATA(angle) = CONV tv_real( 360 / num_sides ).
    DATA(n) = nmax( val1 = 0 val2 = num_sides ).
    DO n TIMES.
      forward( side_length ).
      right( angle ).
    ENDDO.

    turtle = me.
  ENDMETHOD.

  METHOD polygon_flower.
    DATA(current_polygon) = 0.
    WHILE current_polygon < number_of_polygons.

      regular_polygon( num_sides   = polygon_sides
                       side_length = side_length ).

      " rotate before painting next polygon
      right( 360 / number_of_polygons ).

      current_polygon = current_polygon + 1.
    ENDWHILE.

    turtle = me.
  ENDMETHOD.

  METHOD filled_square.
    DATA(points) = VALUE t_points( ( start )
                                   ( x = start-x + side_length y = start-y )
                                   ( x = start-x + side_length y = start-y + side_length )
                                   ( x = start-x y = start-y + side_length ) ).

    append_svg( turtle->svg_builder->polyline( VALUE #( points = points ) )  ).

    turtle = me.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_turtle_lsystem DEFINITION.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF lsystem_rewrite_rule,
        from TYPE string,
        to   TYPE string,
      END OF lsystem_rewrite_rule,
      lsystem_rewrite_rules TYPE STANDARD TABLE OF lsystem_rewrite_rule WITH DEFAULT KEY.

    TYPES lsystem_instruction_kind TYPE string.

    CONSTANTS:
      BEGIN OF instruction_kind,
        "! Doesn't do anything. Can be used for helper symbols.
        noop       TYPE lsystem_instruction_kind VALUE `noop`,
        "! Go forward by 'amount' pixels
        forward    TYPE lsystem_instruction_kind VALUE `forwrad`,
        "! Go back by 'amount' pixels
        back       TYPE lsystem_instruction_kind VALUE `back`,
        "! Turn left by 'amount' degrees
        left       TYPE lsystem_instruction_kind VALUE `left`,
        "! Turn right by 'amount' degrees
        right      TYPE lsystem_instruction_kind VALUE `right`,
        "! Push position on the stack
        stack_push TYPE lsystem_instruction_kind VALUE `stack_push`,
        "! Pop position from the stack
        stack_pop  TYPE lsystem_instruction_kind VALUE `stack_pop`,
      END OF instruction_kind.

    TYPES:
      BEGIN OF lsystem_instruction,
        symbol TYPE c LENGTH 1,
        kind   TYPE lsystem_instruction_kind,
        "! Distance or angle (if the operation requires it)
        amount TYPE tv_int,
*        move_distance  TYPE i,        "! For move instructions, how many pixels to move by
*        rotate_by      TYPE tv_real, "! For rotate instructions, how many degrees to rotate by
      END OF lsystem_instruction,
      lsystem_instructions TYPE HASHED TABLE OF lsystem_instruction WITH UNIQUE KEY symbol.

    TYPES:
      BEGIN OF params,
        "! Starting symbols
        initial_state  TYPE string,
        "! How many times the rewrite rules will be applied
        num_iterations TYPE i,
        instructions   TYPE lsystem_instructions,
        "! A list of rewrite patterns which will be applied each iteration in order.
        "! E.g. initial state F with rule F -> FG and 3 iterations
        "! will produce FG, FGG, FGGG in each iteration respectively.
        "! Currently allows up to 3 variables F,G,H
        rewrite_rules  TYPE lsystem_rewrite_rules,
      END OF params.

    CLASS-METHODS new
      IMPORTING turtle        TYPE REF TO lcl_turtle
                parameters    TYPE params
                out TYPE REF TO if_oo_adt_classrun_out
      RETURNING VALUE(result) TYPE REF TO lcl_turtle_lsystem.

    CLASS-METHODS koch_curve_params RETURNING VALUE(params) TYPE params.
    CLASS-METHODS pattern_params RETURNING VALUE(params) TYPE params.
    CLASS-METHODS plant_params RETURNING VALUE(params) TYPE params.
    CLASS-METHODS plant_2_params RETURNING VALUE(params) TYPE params.

    METHODS execute.
    METHODS show.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_final_value
      RETURNING VALUE(result) TYPE string.

    TYPES t_position_stack TYPE STANDARD TABLE OF lcl_turtle=>turtle_position WITH EMPTY KEY.
    METHODS:
      push_stack IMPORTING position TYPE lcl_turtle=>turtle_position,
      pop_stack RETURNING VALUE(position) TYPE lcl_turtle=>turtle_position.

    DATA turtle TYPE REF TO lcl_turtle.
    DATA parameters TYPE params.
    DATA position_stack TYPE t_position_stack.
ENDCLASS.

CLASS lcl_turtle_lsystem IMPLEMENTATION.

  METHOD execute.
    DATA(final_value) = get_final_value( ).

    DATA(index) = 0.
    WHILE index < strlen( final_value ).
      DATA(symbol) = final_value+index(1).  " char
      DATA(rule) = VALUE #( parameters-instructions[ symbol = symbol ] OPTIONAL ).
      CASE rule-kind.
        WHEN instruction_kind-noop.
          CONTINUE.
        WHEN instruction_kind-forward.      " WHEN `F` OR `G` OR `H`.
          turtle->forward( rule-amount ).   " turtle->forward( parameters-move_distance ).
        WHEN instruction_kind-back.
          turtle->back( rule-amount ).
        WHEN instruction_kind-left.                      " WHEN `+`.
          turtle->right( CONV tv_real( rule-amount ) ).  "   turtle->right( parameters-rotate_by ).
        WHEN instruction_kind-right.                     " WHEN `-`.
          turtle->left( CONV tv_real( rule-amount ) ).   "   turtle->left( parameters-rotate_by ).
        WHEN instruction_kind-stack_push.                " WHEN `[`.
          push_stack( turtle->position ).                "   push_stack( turtle->position ).
        WHEN instruction_kind-stack_pop.                 " WHEN `]`.
          DATA(position) = pop_stack( ).
          turtle->goto( x = position-x y = position-y ).
          turtle->set_angle( position-angle ).
        WHEN OTHERS.
          lcx_turtle_problem=>raise( |Lsystem - unconfigured symbol { symbol }.| ).
      ENDCASE.

      index = index + 1.
    ENDWHILE.

  ENDMETHOD.

  METHOD get_final_value.
    DATA(instructions) = parameters-initial_state.
    DO parameters-num_iterations TIMES.
      LOOP AT parameters-rewrite_rules ASSIGNING FIELD-SYMBOL(<rule>).
        REPLACE ALL OCCURRENCES OF <rule>-from IN instructions WITH <rule>-to.
      ENDLOOP.
    ENDDO.

    result = instructions.
  ENDMETHOD.

  METHOD new.
    result = NEW #( ).
    result->turtle = turtle.
    result->parameters = parameters.
  ENDMETHOD.

  METHOD pop_stack.
    position = position_stack[ lines( position_stack ) ].
    DELETE position_stack INDEX lines( position_stack ).
  ENDMETHOD.

  METHOD push_stack.
    APPEND position TO position_stack.
  ENDMETHOD.

  METHOD show.
    turtle->show( ).
  ENDMETHOD.

  METHOD koch_curve_params.
    params = VALUE #(
      initial_state = `F`
      " Move distance 10, Rotate right by 90, Rotate left by 90
      instructions = VALUE #(
        ( symbol = 'F' kind = instruction_kind-forward amount = 10 )
        ( symbol = '+' kind = instruction_kind-right amount = 90 )
        ( symbol = '-' kind = instruction_kind-left amount = 90 ) )
      num_iterations = 3
      rewrite_rules = VALUE #( ( from = `F` to = `F+F-F-F+F` ) ) ).

  ENDMETHOD.

  METHOD pattern_params.
    params = VALUE #( initial_state = `F-F-F-F`
      instructions = VALUE #(
        ( symbol = 'F' kind = instruction_kind-forward amount = 10 )
        ( symbol = '+' kind = instruction_kind-right amount = 90 )
        ( symbol = '-' kind = instruction_kind-left amount = 90 ) )
      num_iterations = 3
      rewrite_rules = VALUE #( ( from = `F` to = `FF-F+F-F-FF` ) ) ).
  ENDMETHOD.

  METHOD plant_params.
    params = VALUE #( LET distance = 10 rotation = 25 IN
      initial_state = `F`
      instructions = VALUE #(
        ( symbol = `F` kind = instruction_kind-forward amount = distance )
        ( symbol = `+` kind = instruction_kind-right amount = rotation )
        ( symbol = `-` kind = instruction_kind-left amount = rotation )
        ( symbol = `[` kind = instruction_kind-stack_push )
        ( symbol = `]` kind = instruction_kind-stack_pop ) )
      num_iterations = 5
      rewrite_rules = VALUE #( ( from = `F` to = `F[+F]F[-F][F]` ) ) ).
  ENDMETHOD.

  METHOD plant_2_params.
    params = VALUE #( initial_state = `F`
      instructions = VALUE #(
        ( symbol = `F` kind = instruction_kind-forward amount = 10 )
        ( symbol = `+` kind = instruction_kind-right amount = 21 )
        ( symbol = `-` kind = instruction_kind-left amount = 21 )
        ( symbol = `[` kind = instruction_kind-stack_push )
        ( symbol = `]` kind = instruction_kind-stack_pop ) )
      num_iterations = 4
      rewrite_rules = VALUE #( ( from = `F` to = `FF-[+F+F+F]+[-F-F+F]` ) ) ).
  ENDMETHOD.


ENDCLASS.

CLASS lcl_turtle_svg IMPLEMENTATION.

  METHOD circle.
    svg_circle = |<circle cx="{ params-center_x }" cy="{ params-center_y }" r="{ params-radius }" |
        && |stroke="{ turtle->pen-stroke_color }" |
        && |stroke-width="{ turtle->pen-stroke_width }" fill="{ turtle->pen-fill_color }"/>|.
  ENDMETHOD.

  METHOD line.
    svg_line = |<line x1="{ params-x_from }" y1="{ params-y_from }" x2="{ params-x_to }" y2="{ params-y_to }" |
      && |stroke="{ turtle->pen-stroke_color }" stroke-width="{ turtle->pen-stroke_width }"/>|.
  ENDMETHOD.

  METHOD new.
    result = NEW #( ).
    result->turtle = turtle.
  ENDMETHOD.


  METHOD polygon.
    DATA(point_data) = REDUCE string(
      INIT res = ||
      FOR point IN params-points
      NEXT res = res && |{ point-x },{ point-y } | ).

    svg_polygon = |<polygon points="{ point_data }"|
      && | stroke="{ turtle->pen-stroke_color }"|
      && | stroke-width="{ turtle->pen-stroke_width }" fill="{ turtle->pen-fill_color }" />|.

  ENDMETHOD.

  METHOD polyline.
    DATA(point_data) = REDUCE string(
      INIT res = ||
      FOR point IN params-points
      NEXT res = res && |{ point-x },{ point-y } | ).

    svg_polyline = |<polyline points="{ point_data }"|
      && |stroke="{ turtle->pen-stroke_color }" |
      && |stroke-width="{ turtle->pen-stroke_width }" fill="{ turtle->pen-fill_color }" />|.

  ENDMETHOD.

  METHOD text.
    svg_text = |<text x="{ params-x }" y="{ params-y }">{ params-text }</text>|.
  ENDMETHOD.
ENDCLASS.

  CLASS lcl_lisp_turtle DEFINITION INHERITING FROM lcl_lisp FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      METHODS constructor IMPORTING width TYPE REF TO lcl_lisp_integer
                                    height TYPE REF TO lcl_lisp_integer
                                    init_x TYPE REF TO lcl_lisp_integer
                                    init_y TYPE REF TO lcl_lisp_integer
                                    init_angle TYPE REF TO lcl_lisp_real
                                    out TYPE REF TO if_oo_adt_classrun_out.
      DATA turtle TYPE REF TO lcl_turtle.
  ENDCLASS.

  CLASS lcl_lisp_new DEFINITION.
    PUBLIC SECTION.
      CLASS-METHODS atom IMPORTING value          TYPE string
                         RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp.
      CLASS-METHODS null RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp.
      CLASS-METHODS undefined RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp.
      CLASS-METHODS symbol IMPORTING value          TYPE any
                                     index          TYPE tv_int OPTIONAL
                           RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp_symbol.
      CLASS-METHODS boolean IMPORTING value          TYPE any
                            RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp.
      CLASS-METHODS integer IMPORTING value          TYPE any
                            RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp_integer.
      CLASS-METHODS rational IMPORTING nummer         TYPE tv_int
                                       denom          TYPE tv_int
                             RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp_integer
                             RAISING   lcx_lisp_exception.

      CLASS-METHODS real IMPORTING value          TYPE any
                         RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp_real.

      CLASS-METHODS number IMPORTING value          TYPE any
                                     iv_exact       TYPE abap_boolean OPTIONAL
                           RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp
                           RAISING   cx_sy_conversion_no_number.

      CLASS-METHODS binary_integer IMPORTING value         TYPE csequence
                                   RETURNING VALUE(rv_int) TYPE tv_int
                                   RAISING   cx_sy_conversion_no_number.
      CLASS-METHODS binary IMPORTING value          TYPE any
                           RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp
                           RAISING   cx_sy_conversion_no_number.
      CLASS-METHODS octal IMPORTING value          TYPE any
                          RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp
                          RAISING   lcx_lisp_exception cx_sy_conversion_no_number.
      CLASS-METHODS octal_integer IMPORTING value         TYPE csequence
                                  RETURNING VALUE(rv_int) TYPE tv_int
                                  RAISING   lcx_lisp_exception cx_sy_conversion_no_number.

      CLASS-METHODS hex IMPORTING value          TYPE any
                        RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp
                        RAISING   lcx_lisp_exception cx_sy_conversion_no_number.
      CLASS-METHODS hex_integer IMPORTING value         TYPE csequence
                                RETURNING VALUE(rv_int) TYPE tv_int
                                RAISING   lcx_lisp_exception cx_sy_conversion_no_number.

      CLASS-METHODS string IMPORTING value          TYPE any
                                     iv_mutable     TYPE abap_boolean DEFAULT abap_true
                           RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp_string.
      CLASS-METHODS char IMPORTING value          TYPE any
                         RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp_char.
      CLASS-METHODS charx IMPORTING value          TYPE any
                          RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp_char.
      CLASS-METHODS port IMPORTING iv_port_type   TYPE lcl_lisp_port=>tv_port_type
                                   iv_input       TYPE abap_boolean
                                   iv_output      TYPE abap_boolean
                                   iv_error       TYPE abap_boolean
                                   iv_buffered    TYPE abap_boolean
                                   iv_separator   TYPE string OPTIONAL
                                   iv_string      TYPE abap_boolean DEFAULT abap_false
                                   io_out TYPE REF TO if_oo_adt_classrun_out
                         RETURNING VALUE(ro_port) TYPE REF TO lcl_lisp_port.

      CLASS-METHODS elem IMPORTING type           TYPE lcl_lisp=>tv_type
                                   value          TYPE any OPTIONAL
                                   parameter      TYPE abap_boolean DEFAULT abap_false
                         RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp.
      CLASS-METHODS data IMPORTING ref            TYPE REF TO data OPTIONAL
                         RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp_data.
      CLASS-METHODS table IMPORTING ref            TYPE REF TO data OPTIONAL
                          RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp_table.
*      CLASS-METHODS query IMPORTING value          TYPE any OPTIONAL
*                          RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp.
      CLASS-METHODS cons IMPORTING io_car         TYPE REF TO lcl_lisp DEFAULT lcl_lisp=>nil
                                   io_cdr         TYPE REF TO lcl_lisp DEFAULT lcl_lisp=>nil
                         RETURNING VALUE(ro_cons) TYPE REF TO lcl_lisp.

      CLASS-METHODS list3 IMPORTING io_first       TYPE REF TO lcl_lisp
                                    io_second      TYPE REF TO lcl_lisp
                                    io_third       TYPE REF TO lcl_lisp
                          RETURNING VALUE(ro_cons) TYPE REF TO lcl_lisp.

      CLASS-METHODS vector IMPORTING it_vector     TYPE tt_lisp
                                     iv_mutable    TYPE abap_boolean
                           RETURNING VALUE(ro_vec) TYPE REF TO lcl_lisp_vector.

      CLASS-METHODS lambda IMPORTING io_car              TYPE REF TO lcl_lisp
                                     io_cdr              TYPE REF TO lcl_lisp
                                     io_env              TYPE REF TO lcl_lisp_environment
                                     iv_macro            TYPE abap_boolean DEFAULT abap_false
                                     iv_parameter_object TYPE abap_boolean DEFAULT abap_false
                           RETURNING VALUE(ro_lambda)    TYPE REF TO lcl_lisp.

      CLASS-METHODS case_lambda IMPORTING it_clauses       TYPE tt_lisp
                                RETURNING VALUE(ro_lambda) TYPE REF TO lcl_lisp.

*      CLASS-METHODS function IMPORTING io_list        TYPE REF TO lcl_lisp
*                             RETURNING VALUE(ro_func) TYPE REF TO lcl_lisp_abapfunction
*                             RAISING   lcx_lisp_exception.

      CLASS-METHODS hash IMPORTING io_list        TYPE REF TO lcl_lisp
                         RETURNING VALUE(ro_hash) TYPE REF TO lcl_lisp_hash
                         RAISING   lcx_lisp_exception.

      CLASS-METHODS box_quote IMPORTING io_elem        TYPE REF TO lcl_lisp
                              RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp.

      CLASS-METHODS box IMPORTING io_proc        TYPE REF TO lcl_lisp
                                  io_elem        TYPE REF TO lcl_lisp
                        RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp.

      CLASS-METHODS quote IMPORTING io_elem        TYPE REF TO lcl_lisp
                          RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp.

      CLASS-METHODS quasiquote IMPORTING io_elem        TYPE REF TO lcl_lisp
                               RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp.

      CLASS-METHODS unquote IMPORTING io_elem        TYPE REF TO lcl_lisp
                            RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp.

      CLASS-METHODS splice_unquote IMPORTING io_elem        TYPE REF TO lcl_lisp
                                   RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp.

      CLASS-METHODS turtles IMPORTING width            TYPE REF TO lcl_lisp_integer
                                      height           TYPE REF TO lcl_lisp_integer
                                      init_x           TYPE REF TO lcl_lisp_integer
                                      init_y           TYPE REF TO lcl_lisp_integer
                                      init_angle       TYPE REF TO lcl_lisp_real
                                      out TYPE REF TO if_oo_adt_classrun_out
                            RETURNING VALUE(ro_turtle) TYPE REF TO lcl_lisp_turtle.
  ENDCLASS.

  CLASS lcl_port_dummy DEFINITION INHERITING FROM lcl_lisp_port.
    PUBLIC SECTION.
      METHODS read REDEFINITION.
      METHODS write REDEFINITION.
  ENDCLASS.                    "lcl_console DEFINITION

  CLASS lcl_port_dummy IMPLEMENTATION.

    METHOD write.
    ENDMETHOD.

    METHOD read.
      rv_input = c_lisp_eof.
    ENDMETHOD.

  ENDCLASS.                    "lcl_console DEFINITION

  CLASS lcl_lisp_port IMPLEMENTATION.

    METHOD constructor.
      super->constructor( ).
      type = lcl_lisp=>type_port.

      port_type = iv_port_type.
      input = iv_input.
      output = iv_output.
      error = iv_error.
      me->out = out.
    ENDMETHOD.

    METHOD close.
      input = abap_false.
      output = abap_false.
    ENDMETHOD.

    METHOD close_input.
      input = abap_false.
    ENDMETHOD.

    METHOD close_output.
      output = abap_false.
    ENDMETHOD.

    METHOD lif_output_port~write.
      CHECK output EQ abap_true.
      RETURN.
    ENDMETHOD.

    METHOD lif_output_port~display.
      CHECK output EQ abap_true.
      RETURN.
    ENDMETHOD.

    METHOD read_stream.
      rv_input = out->get( name = iv_title ).
    ENDMETHOD.

    METHOD set_input_string.
      last_input = last_input && iv_text.
      last_len = strlen( last_input ).
      finite_size = abap_true.
    ENDMETHOD.

    METHOD block_read.
      IF finite_size EQ abap_true.
        last_input = c_lisp_eof.
        last_len = 0.
      ELSE.
        last_input = read_stream( ).
        last_len = strlen( last_input ).
      ENDIF.
      rv_char = last_input+0(1).
    ENDMETHOD.

    METHOD lif_input_port~peek_char.
      CHECK input EQ abap_true.
      IF last_index < last_len.
        rv_char = last_input+last_index(1).
      ELSE.
        rv_char = block_read( ).
      ENDIF.
    ENDMETHOD.

    METHOD lif_input_port~read_char.
      CHECK input EQ abap_true.
      IF last_index < last_len.
        rv_char = last_input+last_index(1).
      ELSE.
        rv_char = block_read( ).
      ENDIF.
      last_index += 1.
    ENDMETHOD.

    METHOD lif_input_port~is_char_ready.
      rv_flag = abap_false.
      CHECK input EQ abap_true.
      rv_flag = xsdbool( last_index < last_len ).
    ENDMETHOD.

    METHOD lif_input_port~read.
      CHECK input EQ abap_true.
      IF last_index < last_len.
        rv_input = last_input+last_index.
        CLEAR: last_input, last_index, last_len.
      ELSE.
        rv_input = read_stream( iv_title ).
      ENDIF.
    ENDMETHOD.

  ENDCLASS.

  CLASS lcl_lisp_buffered_port IMPLEMENTATION.

    METHOD constructor.
      super->constructor( iv_port_type = iv_port_type
                          iv_input = iv_input
                          iv_output = iv_output
                          iv_error = iv_error
                          out = out ).
      separator = iv_separator.
      string_mode = iv_string.
    ENDMETHOD.

    METHOD lif_log~put.
      write( io_elem ).
    ENDMETHOD.

    METHOD lif_log~get.
      result = flush( ).
    ENDMETHOD.

    METHOD write.
      CHECK element IS BOUND.
      TRY.
          add( element->to_string( ) ).
        CATCH lcx_lisp_exception INTO DATA(lx_error).
          add( lx_error->get_text( ) ).
      ENDTRY.
    ENDMETHOD.

    METHOD display.
      CHECK element IS BOUND.
      TRY.
          add( element->to_text( ) ).
        CATCH lcx_lisp_exception INTO DATA(lx_error).
          add( lx_error->get_text( ) ).
      ENDTRY.
    ENDMETHOD.

    METHOD read.
      CHECK input EQ abap_true.
      IF string_mode EQ abap_false.
        rv_input = super->read( ).
        RETURN.
      ENDIF.
      IF last_index < last_len.
        rv_input = last_input+last_index.
      ELSE.
        rv_input = c_lisp_eof.
      ENDIF.
      CLEAR: last_input, last_index, last_len.
    ENDMETHOD.

    METHOD lif_input_port~peek_char.
      CHECK input EQ abap_true.
      IF string_mode EQ abap_false.
        rv_char = super->lif_input_port~peek_char( ).
        RETURN.
      ENDIF.
      IF last_index < last_len.
        rv_char = last_input+last_index(1).
      ELSE.
        rv_char = c_lisp_eof.
      ENDIF.
    ENDMETHOD.

    METHOD flush.
      rv_text = buffer.
      CLEAR buffer.
    ENDMETHOD.

    METHOD add.
      IF buffer IS INITIAL.
        buffer = text.
      ELSE.
        buffer = |{ buffer }{ separator }{ text }|.
      ENDIF.
    ENDMETHOD.                    "add

  ENDCLASS.

*----------------------------------------------------------------------*
*       CLASS lcl_lisp_iterator DEFINITION
*----------------------------------------------------------------------*
  CLASS lcl_lisp_iterator DEFINITION CREATE PRIVATE FRIENDS lcl_lisp.
    PUBLIC SECTION.
      DATA first TYPE abap_boolean VALUE abap_true READ-ONLY.
      METHODS has_next RETURNING VALUE(rv_flag) TYPE abap_boolean.
      METHODS next RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp
                   RAISING   cx_dynamic_check.
    PRIVATE SECTION.
      DATA elem TYPE REF TO lcl_lisp.

      METHODS constructor IMPORTING io_elem TYPE REF TO lcl_lisp
                          RAISING   lcx_lisp_exception.
  ENDCLASS.                    "lcl_lisp_iterator DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_lisp_hash DEFINITION
*----------------------------------------------------------------------*
* Hash is a specialized ABAP Lisp type for quick lookup of elements
* using a symbol or string key (backed by an ABAP hash table)
*----------------------------------------------------------------------*
  CLASS lcl_lisp_hash DEFINITION INHERITING FROM lcl_lisp
    CREATE PROTECTED FRIENDS lcl_lisp_new.
    PUBLIC SECTION.
      CLASS-METHODS from_list IMPORTING list           TYPE REF TO lcl_lisp
                                        msg            TYPE string
                              RETURNING VALUE(ro_hash) TYPE REF TO lcl_lisp_hash
                              RAISING   lcx_lisp_exception.

      METHODS get IMPORTING list          TYPE REF TO lcl_lisp
                  RETURNING VALUE(result) TYPE REF TO lcl_lisp
                  RAISING   lcx_lisp_exception.
      METHODS insert IMPORTING list          TYPE REF TO lcl_lisp
                     RETURNING VALUE(result) TYPE REF TO lcl_lisp
                     RAISING   lcx_lisp_exception.
      METHODS delete IMPORTING list          TYPE REF TO lcl_lisp
                     RETURNING VALUE(result) TYPE REF TO lcl_lisp
                     RAISING   lcx_lisp_exception.
      METHODS get_hash_keys RETURNING VALUE(result) TYPE REF TO lcl_lisp.

      METHODS eval IMPORTING environment   TYPE REF TO lcl_lisp_environment
                             interpreter   TYPE REF TO lcl_lisp_interpreter
                   RETURNING VALUE(result) TYPE REF TO lcl_lisp_hash
                   RAISING   lcx_lisp_exception.

    PROTECTED SECTION.
      TYPES: BEGIN OF ts_hash,
               key     TYPE string,
               element TYPE REF TO lcl_lisp,
             END OF ts_hash.
      TYPES tt_hash TYPE HASHED TABLE OF ts_hash WITH UNIQUE KEY key.
      DATA hash TYPE tt_hash.

      METHODS fill IMPORTING list TYPE REF TO lcl_lisp
                   RAISING   lcx_lisp_exception.
  ENDCLASS.                    "lcl_lisp_hash DEFINITION

  CLASS lcl_lisp_vector DEFINITION INHERITING FROM lcl_lisp
    CREATE PROTECTED FRIENDS lcl_lisp_new.
    PUBLIC SECTION.

      CLASS-METHODS init IMPORTING size             TYPE tv_index
                                   io_fill          TYPE REF TO lcl_lisp DEFAULT nil
                                   iv_mutable       TYPE abap_boolean DEFAULT abap_true
                         RETURNING VALUE(ro_vector) TYPE REF TO lcl_lisp_vector
                         RAISING   lcx_lisp_exception.

      CLASS-METHODS from_list IMPORTING io_list          TYPE REF TO lcl_lisp
                                        iv_mutable       TYPE abap_boolean DEFAULT abap_true
                              RETURNING VALUE(ro_vector) TYPE REF TO lcl_lisp_vector
                              RAISING   lcx_lisp_exception.

      METHODS to_list         RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp
                              RAISING   lcx_lisp_exception.

      METHODS set IMPORTING index         TYPE tv_index
                            io_elem       TYPE REF TO lcl_lisp
                  RETURNING VALUE(result) TYPE REF TO lcl_lisp_vector
                  RAISING   lcx_lisp_exception.

      METHODS get IMPORTING index          TYPE tv_index
                  RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp
                  RAISING   lcx_lisp_exception.

      METHODS get_list IMPORTING from           TYPE tv_index DEFAULT 0
                                 to             TYPE tv_index OPTIONAL
                       RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp
                       RAISING   lcx_lisp_exception.

      METHODS fill IMPORTING from           TYPE tv_index DEFAULT 0
                             to             TYPE tv_index OPTIONAL
                             elem           TYPE REF TO lcl_lisp
                   RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp_vector
                   RAISING   lcx_lisp_exception.

      METHODS length RETURNING VALUE(ro_length) TYPE REF TO lcl_lisp.

      METHODS to_string REDEFINITION.
      METHODS is_equal REDEFINITION.
      METHODS set_shared_structure REDEFINITION.

      METHODS eval IMPORTING environment   TYPE REF TO lcl_lisp_environment
                             interpreter   TYPE REF TO lcl_lisp_interpreter
                   RETURNING VALUE(result) TYPE REF TO lcl_lisp_vector
                   RAISING   lcx_lisp_exception.
    PROTECTED SECTION.
      DATA vector TYPE tt_lisp.
      DATA mo_length TYPE REF TO lcl_lisp.
  ENDCLASS.

*----------------------------------------------------------------------*
*       CLASS lcl_lisp_abapfunction DEFINITION
*----------------------------------------------------------------------*
* Specialized element representing an ABAP function module that can
* be called
*----------------------------------------------------------------------*
*  CLASS lcl_lisp_abapfunction DEFINITION INHERITING FROM lcl_lisp_data CREATE PROTECTED
*    FRIENDS lcl_lisp_new.
*    PUBLIC SECTION.
*
*      METHODS call IMPORTING list           TYPE REF TO lcl_lisp
*                   RETURNING VALUE(ro_elem) TYPE REF TO lcl_lisp
*                   RAISING   lcx_lisp_exception.
*
*      METHODS get_function_parameter IMPORTING identifier   TYPE REF TO lcl_lisp
*                                     RETURNING VALUE(rdata) TYPE REF TO data
*                                     RAISING   lcx_lisp_exception.
*    PROTECTED SECTION.
*      TYPES tt_rsexc TYPE STANDARD TABLE OF rsexc WITH DEFAULT KEY.   " Exceptions
*      TYPES tt_rsexp TYPE STANDARD TABLE OF rsexp WITH DEFAULT KEY.   " Exporting
*      TYPES tt_rsimp TYPE STANDARD TABLE OF rsimp WITH DEFAULT KEY.   " Importing
*      TYPES tt_rscha TYPE STANDARD TABLE OF rscha WITH DEFAULT KEY.   " Changing
*      TYPES tt_rstbl TYPE STANDARD TABLE OF rstbl WITH DEFAULT KEY.   " Tables
*
*      TYPES: BEGIN OF ts_interface,
*               exc         TYPE tt_rsexc,
*               exp         TYPE tt_rsexp,
*               imp         TYPE tt_rsimp,
*               cha         TYPE tt_rscha,
*               tbl         TYPE tt_rstbl,
*               enh_exp     TYPE tt_rsexp,
*               enh_imp     TYPE tt_rsimp,
*               enh_cha     TYPE tt_rscha,
*               enh_tbl     TYPE tt_rstbl,
*               remote_call TYPE rs38l-remote,
*               update_task TYPE rs38l-utask,
*             END OF ts_interface.
*
*      DATA parameters TYPE abap_func_parmbind_tab.
*      DATA exceptions TYPE abap_func_excpbind_tab.
*      DATA param_active TYPE abap_func_parmbind_tab.
*      DATA interface TYPE ts_interface.
*
*      METHODS read_interface IMPORTING iv_name              TYPE csequence
*                             RETURNING VALUE(function_name) TYPE rs38l-name
*                             RAISING   lcx_lisp_exception.
*      METHODS create_parameters RAISING   lcx_lisp_exception.
*      METHODS create_exceptions.
*
*      METHODS error_message RETURNING VALUE(rv_message) TYPE string.
*    PRIVATE SECTION.
*      CONSTANTS c_error_message TYPE i VALUE 99.
*
*      DATA parameters_generated TYPE abap_boolean.
*
*      METHODS create_table_params IMPORTING it_table TYPE tt_rstbl.
*      METHODS create_params IMPORTING it_table TYPE STANDARD TABLE
*                                      iv_kind  TYPE i.
*  ENDCLASS.                    "lcl_lisp_abapfunction DEFINITION

*  CLASS lcl_lisp_sql_result DEFINITION INHERITING FROM lcl_lisp_data.
*    PUBLIC SECTION.
*      METHODS constructor IMPORTING io_result TYPE REF TO cl_sql_result_set.
*      METHODS clear.
*      METHODS close.
*    PROTECTED SECTION.
*      DATA result_set TYPE REF TO cl_sql_result_set.
*  ENDCLASS.
*
*  CLASS lcl_lisp_query DEFINITION INHERITING FROM lcl_lisp_data
*     CREATE PROTECTED FRIENDS lcl_lisp_new.
*    PUBLIC SECTION.
*      METHODS constructor IMPORTING osql TYPE string OPTIONAL
*                          RAISING   cx_sql_exception.
*      METHODS execute IMPORTING query         TYPE string
*                      RETURNING VALUE(result) TYPE REF TO lcl_lisp_sql_result
*                      RAISING   cx_sql_exception.
*    PROTECTED SECTION.
*      DATA mv_hold_cursor TYPE abap_boolean.
*      DATA sql_query TYPE string.
*      DATA connection TYPE REF TO cl_sql_connection.
*      DATA statement TYPE REF TO cl_sql_statement.
*  ENDCLASS.

  CLASS lcl_lisp_env_factory DEFINITION DEFERRED.

*----------------------------------------------------------------------*
*       CLASS lcl_lisp_environment DEFINITION
*----------------------------------------------------------------------*
  CLASS lcl_lisp_environment DEFINITION CREATE PRIVATE FRIENDS lcl_lisp_env_factory.
    PUBLIC SECTION.
      DATA top_level TYPE abap_boolean VALUE abap_false READ-ONLY.

      METHODS:
        scope_of IMPORTING symbol     TYPE any
                 RETURNING VALUE(env) TYPE REF TO lcl_lisp_environment
                 RAISING   lcx_lisp_exception,
        get IMPORTING symbol      TYPE any
            RETURNING VALUE(cell) TYPE REF TO lcl_lisp
            RAISING   lcx_lisp_exception,
        set IMPORTING symbol  TYPE string
                      element TYPE REF TO lcl_lisp
                      once    TYPE abap_boolean DEFAULT abap_false
            RAISING   lcx_lisp_exception,
*       Convenience method to add a value and create the cell
        define_value IMPORTING symbol         TYPE string
                               type           TYPE lcl_lisp=>tv_type
                               value          TYPE any OPTIONAL
                     RETURNING VALUE(element) TYPE REF TO lcl_lisp.

      METHODS parameters_to_symbols IMPORTING io_pars TYPE REF TO lcl_lisp
                                              io_args TYPE REF TO lcl_lisp
                                    RAISING   lcx_lisp_exception.
    PROTECTED SECTION.
*     Reference to
      DATA outer TYPE REF TO lcl_lisp_environment.  " outer (parent) environment:

      TYPES: BEGIN OF ts_map,
               symbol TYPE string,
               value  TYPE REF TO lcl_lisp,
             END OF ts_map.
      TYPES tt_map TYPE HASHED TABLE OF ts_map WITH UNIQUE KEY symbol.

      DATA map TYPE tt_map.

      METHODS unbound_symbol IMPORTING symbol TYPE any
                             RAISING   lcx_lisp_exception.
      METHODS prepare.
  ENDCLASS.                    "lcl_lisp_environment DEFINITION

  CLASS lcl_lisp_env_factory DEFINITION ABSTRACT.
    PUBLIC SECTION.
      CLASS-METHODS:
        new   RETURNING VALUE(env)  TYPE REF TO lcl_lisp_environment,
        clone IMPORTING io_outer   TYPE REF TO lcl_lisp_environment
              RETURNING VALUE(env) TYPE REF TO lcl_lisp_environment,
        make_top_level IMPORTING io_outer   TYPE REF TO lcl_lisp_environment OPTIONAL
                       RETURNING VALUE(env) TYPE REF TO lcl_lisp_environment.
  ENDCLASS.

  CLASS lcl_lisp_env_factory  IMPLEMENTATION.

    METHOD new.
      env = NEW lcl_lisp_environment( ).
    ENDMETHOD.                    "new

    METHOD clone.
      env = new( ).
      env->outer = io_outer.
    ENDMETHOD.

    METHOD make_top_level.
      env = clone( io_outer ).
      env->prepare( ).
      env->top_level = abap_true.
    ENDMETHOD.

  ENDCLASS.

*----------------------------------------------------------------------*
*       CLASS lcl_parser DEFINITION
*----------------------------------------------------------------------*
  CLASS lcl_parser DEFINITION.
    PUBLIC SECTION.
      TYPES tt_element TYPE STANDARD TABLE OF REF TO lcl_lisp WITH DEFAULT KEY.
      TYPES tv_char2 TYPE c LENGTH 2.
      CONSTANTS:
        c_lisp_dot    TYPE tv_char VALUE '.',
        c_open_paren  TYPE tv_char VALUE '(',
        c_close_paren TYPE tv_char VALUE ')',
        c_lisp_equal  TYPE tv_char VALUE '=',
        c_lisp_xx     TYPE tv_char2 VALUE 'xX'.
      CONSTANTS:
        c_escape_char    TYPE tv_char VALUE '\',
        c_text_quote     TYPE tv_char VALUE '"',
        c_lisp_quote     TYPE tv_char VALUE '''', "LISP single quote = QUOTE
        c_lisp_backquote TYPE tv_char VALUE '`',  " backquote = quasiquote
        c_lisp_unquote   TYPE tv_char VALUE ',',
        c_lisp_splicing  TYPE tv_char VALUE '@',
        c_lisp_hash      TYPE tv_char VALUE '#',
        c_lisp_comment   TYPE tv_char VALUE ';',
        c_block_comment  TYPE tv_char VALUE '|', " start #|, end |#
        c_open_curly     TYPE tv_char VALUE '{',
        c_close_curly    TYPE tv_char VALUE '}',
        c_open_bracket   TYPE tv_char VALUE '[',
        c_close_bracket  TYPE tv_char VALUE ']'.
      CONSTANTS:
        c_number_exact   TYPE tv_char2 VALUE 'eE',
        c_number_inexact TYPE tv_char2 VALUE 'iI',
        c_number_octal   TYPE tv_char2 VALUE 'oO',
        c_number_binary  TYPE tv_char2 VALUE 'bB',
        c_number_decimal TYPE tv_char2 VALUE 'dD'.

      METHODS:
        constructor,
        parse IMPORTING iv_code         TYPE clike
              RETURNING VALUE(elements) TYPE tt_element
              RAISING   lcx_lisp_exception,
        read_from IMPORTING ii_port        TYPE REF TO lif_input_port
                  RETURNING VALUE(element) TYPE REF TO lcl_lisp
                  RAISING   lcx_lisp_exception.

    PRIVATE SECTION.
      DATA code TYPE string.
      DATA length TYPE i.
      DATA index TYPE i.
      DATA char TYPE tv_char.

      DATA mv_eol TYPE tv_char.
      DATA mv_whitespace TYPE c LENGTH 7. " Case sensitive
      DATA mv_delimiters TYPE c LENGTH 13. " Case sensitive

      METHODS:
        next_char RAISING lcx_lisp_exception,
        peek_char RETURNING VALUE(rv_char) TYPE tv_char,
        peek_bytevector RETURNING VALUE(rv_flag) TYPE abap_boolean,
        match_label IMPORTING iv_limit        TYPE tv_char
                    EXPORTING ev_label        TYPE string
                    RETURNING VALUE(rv_found) TYPE abap_boolean,
        skip_label,
        skip_whitespace
          RETURNING VALUE(rv_has_next) TYPE abap_boolean
          RAISING   lcx_lisp_exception,
        parse_list IMPORTING delim         TYPE tv_char DEFAULT c_open_paren
                   RETURNING VALUE(result) TYPE REF TO lcl_lisp
                   RAISING   lcx_lisp_exception,
        parse_token RETURNING VALUE(element) TYPE REF TO lcl_lisp
                    RAISING   lcx_lisp_exception.
      METHODS match_string CHANGING cv_val TYPE string
                           RAISING  lcx_lisp_exception.
      METHODS match_atom CHANGING cv_val TYPE string.

      METHODS throw IMPORTING message TYPE string
                    RAISING   lcx_lisp_exception.
      METHODS skip_one_datum RAISING lcx_lisp_exception.
      METHODS skip_block_comment RAISING lcx_lisp_exception.

  ENDCLASS.                    "lcl_parser DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_lisp_interpreter DEFINITION
*----------------------------------------------------------------------*
  CLASS lcl_lisp_interpreter DEFINITION INHERITING FROM lcl_parser.

    PUBLIC SECTION.
      DATA env TYPE REF TO lcl_lisp_environment READ-ONLY. "Global environment
      DATA nil TYPE REF TO lcl_lisp READ-ONLY.
      DATA false TYPE REF TO lcl_lisp READ-ONLY.
      DATA true TYPE REF TO lcl_lisp READ-ONLY.

      CLASS-METHODS new IMPORTING io_port       TYPE REF TO lcl_lisp_port
                                  ii_log        TYPE REF TO lif_log
                        RETURNING VALUE(ro_int) TYPE REF TO lcl_lisp_interpreter.

      METHODS constructor IMPORTING io_port TYPE REF TO lcl_lisp_port
                                    ii_log  TYPE REF TO lif_log.

*     Methods for evaluation
      METHODS:
        eval
          IMPORTING element       TYPE REF TO lcl_lisp
                    environment   TYPE REF TO lcl_lisp_environment
          RETURNING VALUE(result) TYPE REF TO lcl_lisp
          RAISING   lcx_lisp_exception,
* To enable a REPL, the following convenience method wraps parsing and evaluating
* and stringifies the response/error
        eval_source
          IMPORTING code            TYPE clike
          RETURNING VALUE(response) TYPE string,
        eval_repl
          IMPORTING code            TYPE clike
          EXPORTING output          TYPE string  " for console output (text format)
          RETURNING VALUE(response) TYPE string
          RAISING   lcx_lisp_exception,
        validate_source
          IMPORTING code            TYPE clike
          RETURNING VALUE(response) TYPE string.

    PROTECTED SECTION.

* Macro to simplify the definition of a native procedure
* Functions for dealing with lists:
METHODS proc_append         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_append_unsafe  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_reverse        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_set_car        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_set_cdr        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_car            IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cdr            IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_caar           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cadr           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cdar           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cddr           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_caaar          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cdaar          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_caadr          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cdadr          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cadar          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cddar          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_caddr          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cdddr          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_caaaar         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cdaaar         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cadaar         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cddaar         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_caaadr         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cdaadr         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cadadr         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cddadr         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_caadar         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cdadar         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_caddar         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cdddar         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_caaddr         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cdaddr         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cadddr         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cddddr         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_memq           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_memv           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_member         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_assq           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_assv           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_assoc          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.


*     Constructor
METHODS proc_cons                 IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_list                 IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_make_list            IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_iota                 IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_list_copy            IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_list_tail            IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_list_ref             IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_list_to_vector       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_length               IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_nilp                 IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.


* Native functions:

METHODS proc_add              IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_subtract         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_multiply         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_divide           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_gt               IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_gte              IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_lt               IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_lte              IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_eql              IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_eqv              IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_not              IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_is_number         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_integer        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_exact_integer  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_rational       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_real           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_complex        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_is_string        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_char          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_symbol        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_hash          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_procedure     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_list          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_pair          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_boolean       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_boolean_list_is_equal IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_vector             IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_alist              IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_is_exact    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_inexact  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_to_exact    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_to_inexact  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

* Math
METHODS proc_abs      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_quotient IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_sin      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cos      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_tan      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_asin     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_acos     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_atan     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_sinh     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_cosh     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_tanh     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_asinh    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_acosh    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_atanh    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_exp      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_expt     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_log      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_sqrt     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_is_zero     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_positive IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_negative IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_odd      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_even     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_floor       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_ceiling     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_truncate    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_round       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_numerator   IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_denominator IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_remainder   IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_modulo      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_max         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_min         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_gcd         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_lcm         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

* Formating
METHODS proc_newline            IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_write              IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_display            IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_read               IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_write_char         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_write_string       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_read_char          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_read_string        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_peek_char          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_char_ready      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_is_char_alphabetic  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_char_numeric     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_char_whitespace  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_char_upper_case  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_char_lower_case  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_digit_value         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_char_to_integer     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_integer_to_char     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_char_upcase         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_char_downcase       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_char_list_is_eq     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_char_list_is_lt     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_char_list_is_gt     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_char_list_is_le     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_char_list_is_ge     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_char_ci_list_is_eq    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_char_ci_list_is_lt    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_char_ci_list_is_gt    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_char_ci_list_is_le    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_char_ci_list_is_ge    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_string_list_is_eq     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_list_is_lt     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_list_is_gt     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_list_is_le     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_list_is_ge     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

METHODS proc_string_ci_list_is_eq  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_ci_list_is_lt  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_ci_list_is_gt  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_ci_list_is_le  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_ci_list_is_ge  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.


METHODS proc_string            IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_make_string       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_num_to_string     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_list_to_string    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_symbol_to_string  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_length     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_copy       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_to_num     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_ref        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_set        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_append     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_to_list    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_string_to_symbol  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

* Turtle library
METHODS proc_turtle_new            IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_exist          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_move           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_draw           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_erase          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_move_offset    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_draw_offset    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_erase_offset   IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_turn_degrees   IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_turn_radians   IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_set_pen_width  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_set_pen_color  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_merge          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_clean          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_width          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_height         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_state          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_pen_width      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_pen_color      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_regular_poly   IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_turtle_regular_polys  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

* Continuation
METHODS proc_call_cc IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

* Exceptions
METHODS proc_error IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_raise IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

* Not in the spec: Just adding it anyway
METHODS proc_random IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_eq     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_equal  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

* SQL
*METHODS proc_sql_prepare IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
*METHODS proc_sql_query   IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

* Functions for dealing with vectors:
METHODS proc_make_vector     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_vector          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_vector_length   IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_vector_set      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_vector_fill     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_vector_ref      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_vector_to_list  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

* Functions for dealing with hashes:
METHODS proc_make_hash    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_hash_get     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_hash_insert  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_hash_remove  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_hash_keys    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

* Ports
METHODS proc_make_parameter       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_parameterize         IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_input_port        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_output_port       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_textual_port      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_binary_port       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_port              IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_eof_object        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_open_input_port   IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_is_open_output_port  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_eof_object           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_close_input_port     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_close_output_port    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_close_port           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_current_input_port   IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_current_output_port  IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_current_error_port   IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_open_output_string   IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_open_input_string    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_get_output_string    IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

* Built-in functions for ABAP integration:
METHODS proc_abap_data           IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
*METHODS proc_abap_function       IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
*METHODS proc_abap_function_param IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_abap_table          IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_abap_append_row     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_abap_delete_row     IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_abap_get_row        IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_abap_get_value      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_abap_set_value      IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_abap_set            IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.
METHODS proc_abap_get            IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

* Called internally only:
"METHODS proc_abap_function_call IMPORTING list TYPE REF TO lcl_lisp RETURNING VALUE(result) TYPE REF TO lcl_lisp RAISING lcx_lisp_exception ##called.

      METHODS define_syntax
        IMPORTING element       TYPE REF TO lcl_lisp
                  environment   TYPE REF TO lcl_lisp_environment
        RETURNING VALUE(result) TYPE  REF TO lcl_lisp
        RAISING   lcx_lisp_exception.

      METHODS bind_symbol
        IMPORTING element       TYPE REF TO lcl_lisp
                  environment   TYPE REF TO lcl_lisp_environment
                  iv_macro      TYPE abap_boolean DEFAULT abap_false
        RETURNING VALUE(result) TYPE  REF TO lcl_lisp
        RAISING   lcx_lisp_exception.

      METHODS assign_symbol
        IMPORTING element       TYPE REF TO lcl_lisp
                  environment   TYPE REF TO lcl_lisp_environment
        RETURNING VALUE(result) TYPE  REF TO lcl_lisp
        RAISING   lcx_lisp_exception.

      METHODS is_macro_call
        IMPORTING element       TYPE REF TO lcl_lisp
                  environment   TYPE REF TO lcl_lisp_environment
        RETURNING VALUE(result) TYPE abap_boolean
        RAISING   lcx_lisp_exception.

      METHODS syntax_expand
        IMPORTING element       TYPE REF TO lcl_lisp
                  environment   TYPE REF TO lcl_lisp_environment
        RETURNING VALUE(result) TYPE  REF TO lcl_lisp
        RAISING   lcx_lisp_exception.

      METHODS generate_symbol IMPORTING list          TYPE REF TO lcl_lisp
                              RETURNING VALUE(result) TYPE  REF TO lcl_lisp
                              RAISING   lcx_lisp_exception.

*----  ABAP Integration support functions; mapping -----
      METHODS:
*       Convert ABAP data to Lisp element
        data_to_element IMPORTING VALUE(data)    TYPE any
                        RETURNING VALUE(element) TYPE REF TO lcl_lisp
                        RAISING   lcx_lisp_exception,

        structure_to_element IMPORTING VALUE(struct)  TYPE any
                             RETURNING VALUE(element) TYPE REF TO lcl_lisp
                             RAISING   lcx_lisp_exception,

        table_to_element IMPORTING VALUE(data)    TYPE any
                         RETURNING VALUE(element) TYPE REF TO lcl_lisp
                         RAISING   lcx_lisp_exception,
*       Convert Lisp element to ABAP Data
        element_to_data IMPORTING VALUE(element) TYPE REF TO lcl_lisp
                        CHANGING  VALUE(data)    TYPE any "ref to data
                        RAISING   lcx_lisp_exception,
*       Determine an ABAP data component from an element and an identifier
        get_element IMPORTING list         TYPE REF TO lcl_lisp
                    RETURNING VALUE(rdata) TYPE REF TO data
                    RAISING   lcx_lisp_exception.

      CLASS-DATA gi_log TYPE REF TO lif_log.
      CLASS-DATA: go_out  TYPE REF TO if_oo_adt_classrun_out.
      CLASS-DATA: go_input_port  TYPE REF TO lcl_lisp_lambda,
                  go_output_port TYPE REF TO lcl_lisp_lambda,
                  go_error_port  TYPE REF TO lcl_lisp_lambda.
      CLASS-DATA gensym_counter TYPE i.

      METHODS write IMPORTING io_elem       TYPE REF TO lcl_lisp
                              io_arg        TYPE REF TO lcl_lisp DEFAULT lcl_lisp=>nil
                    RETURNING VALUE(result) TYPE REF TO lcl_lisp
                    RAISING   lcx_lisp_exception.

      METHODS display IMPORTING io_elem       TYPE REF TO lcl_lisp
                                io_arg        TYPE REF TO lcl_lisp
                      RETURNING VALUE(result) TYPE REF TO lcl_lisp
                      RAISING   lcx_lisp_exception.

      METHODS read IMPORTING io_arg        TYPE REF TO lcl_lisp
                   RETURNING VALUE(result) TYPE REF TO lcl_lisp
                   RAISING   lcx_lisp_exception.

      METHODS read_char IMPORTING io_arg        TYPE REF TO lcl_lisp
                        RETURNING VALUE(result) TYPE REF TO lcl_lisp
                        RAISING   lcx_lisp_exception.

      METHODS read_string IMPORTING io_arg        TYPE REF TO lcl_lisp
                          RETURNING VALUE(result) TYPE REF TO lcl_lisp
                          RAISING   lcx_lisp_exception.
    PRIVATE SECTION.
      TYPES: BEGIN OF ts_digit,
               zero  TYPE x LENGTH 3,
               langu TYPE string,
             END OF ts_digit.
      TYPES tt_digit TYPE SORTED TABLE OF ts_digit WITH UNIQUE KEY zero.
      DATA mt_zero TYPE tt_digit.

      METHODS string_to_number IMPORTING iv_text       TYPE string
                                         iv_radix      TYPE i DEFAULT 10
                               RETURNING VALUE(result) TYPE REF TO lcl_lisp
                               RAISING   lcx_lisp_exception.

      METHODS unicode_digit_zero RETURNING VALUE(rt_zero) TYPE tt_digit.

      METHODS unicode_to_digit IMPORTING iv_char         TYPE tv_char
                               RETURNING VALUE(rv_digit) TYPE i.

      METHODS char_to_integer IMPORTING io_char       TYPE REF TO lcl_lisp
                              RETURNING VALUE(rv_int) TYPE tv_int
                              RAISING   lcx_lisp_exception.

      METHODS fold_case IMPORTING element          TYPE REF TO lcl_lisp
                        RETURNING VALUE(rv_string) TYPE string.

      METHODS char_fold_case_to_integer IMPORTING element       TYPE REF TO lcl_lisp
                                        RETURNING VALUE(rv_int) TYPE tv_int.

      METHODS char_case_identity IMPORTING element          TYPE REF TO lcl_lisp
                                 RETURNING VALUE(rv_string) TYPE string.

      METHODS throw IMPORTING message TYPE string
                    RAISING   lcx_lisp_exception.

      METHODS create_element_from_data
        IMPORTING ir_data       TYPE REF TO data
        RETURNING VALUE(result) TYPE REF TO lcl_lisp.

      METHODS get_structure_field IMPORTING element           TYPE REF TO lcl_lisp_data
                                            VALUE(identifier) TYPE REF TO lcl_lisp
                                  RETURNING VALUE(rdata)      TYPE REF TO data
                                  RAISING   lcx_lisp_exception.
      METHODS get_table_row_with_key IMPORTING element           TYPE REF TO lcl_lisp_data
                                               VALUE(identifier) TYPE REF TO lcl_lisp
                                     RETURNING VALUE(rdata)      TYPE REF TO data
                                     RAISING   lcx_lisp_exception.
      METHODS get_index_table_row IMPORTING element           TYPE REF TO lcl_lisp_data
                                            VALUE(identifier) TYPE REF TO lcl_lisp
                                  RETURNING VALUE(rdata)      TYPE REF TO data
                                  RAISING   lcx_lisp_exception.

      METHODS evaluate_parameters IMPORTING io_list        TYPE REF TO lcl_lisp
                                            environment    TYPE REF TO lcl_lisp_environment
                                  RETURNING VALUE(ro_head) TYPE REF TO lcl_lisp
                                  RAISING   lcx_lisp_exception.

      METHODS expand_apply IMPORTING io_list       TYPE REF TO lcl_lisp
                                     environment   TYPE REF TO lcl_lisp_environment
                           RETURNING VALUE(result) TYPE REF TO lcl_lisp
                           RAISING   lcx_lisp_exception.

      METHODS expand_map IMPORTING io_list       TYPE REF TO lcl_lisp
                                   environment   TYPE REF TO lcl_lisp_environment
                         RETURNING VALUE(result) TYPE REF TO lcl_lisp
                         RAISING   lcx_lisp_exception.

      METHODS expand_for_each IMPORTING io_list       TYPE REF TO lcl_lisp
                                        environment   TYPE REF TO lcl_lisp_environment
                              RETURNING VALUE(result) TYPE REF TO lcl_lisp
                              RAISING   lcx_lisp_exception.

      METHODS eval_list_tco IMPORTING VALUE(io_head) TYPE REF TO lcl_lisp
                                      io_environment TYPE REF TO lcl_lisp_environment
                            EXPORTING eo_elem        TYPE REF TO lcl_lisp
                            RETURNING VALUE(result)  TYPE REF TO lcl_lisp
                            RAISING   lcx_lisp_exception.

      METHODS lambda_environment IMPORTING io_head       TYPE REF TO lcl_lisp
                                           io_args       TYPE REF TO lcl_lisp
                                           environment   TYPE REF TO lcl_lisp_environment
                                 RETURNING VALUE(ro_env) TYPE  REF TO lcl_lisp_environment
                                 RAISING   lcx_lisp_exception.

      METHODS extract_arguments IMPORTING io_head TYPE REF TO lcl_lisp
                                EXPORTING eo_pars TYPE REF TO lcl_lisp
                                          eo_args TYPE REF TO lcl_lisp
                                RAISING   lcx_lisp_exception.

      METHODS extract_parameter_objects IMPORTING io_head TYPE REF TO lcl_lisp
                                                  io_env  TYPE REF TO lcl_lisp_environment
                                        EXPORTING eo_pars TYPE REF TO lcl_lisp
                                                  eo_args TYPE REF TO lcl_lisp
                                        RAISING   lcx_lisp_exception.

      METHODS eval_do_step IMPORTING io_command TYPE REF TO lcl_lisp
                                     io_steps   TYPE REF TO lcl_lisp
                                     io_env     TYPE REF TO lcl_lisp_environment
                           RAISING   lcx_lisp_exception.

      METHODS eval_do_init IMPORTING io_head       TYPE REF TO lcl_lisp
                                     VALUE(io_env) TYPE REF TO lcl_lisp_environment
                           EXPORTING eo_step       TYPE REF TO lcl_lisp
                                     eo_env        TYPE REF TO lcl_lisp_environment
                           RAISING   lcx_lisp_exception.

      METHODS eval_ast IMPORTING element       TYPE REF TO lcl_lisp
                                 environment   TYPE REF TO lcl_lisp_environment
                       RETURNING VALUE(result) TYPE REF TO lcl_lisp
                       RAISING   lcx_lisp_exception.

      METHODS evaluate_in_sequence IMPORTING io_pars TYPE REF TO lcl_lisp
                                             io_args TYPE REF TO lcl_lisp
                                             io_env  TYPE REF TO lcl_lisp_environment
                                   RAISING   lcx_lisp_exception.
      METHODS environment_letrec IMPORTING io_head       TYPE REF TO lcl_lisp
                                           io_env        TYPE REF TO lcl_lisp_environment
                                 RETURNING VALUE(ro_env) TYPE REF TO lcl_lisp_environment
                                 RAISING   lcx_lisp_exception.
      METHODS environment_letrec_star IMPORTING io_head       TYPE REF TO lcl_lisp
                                                io_env        TYPE REF TO lcl_lisp_environment
                                      RETURNING VALUE(ro_env) TYPE REF TO lcl_lisp_environment
                                      RAISING   lcx_lisp_exception.

      METHODS environment_let_star IMPORTING io_head       TYPE REF TO lcl_lisp
                                             io_env        TYPE REF TO lcl_lisp_environment
                                   RETURNING VALUE(ro_env) TYPE REF TO lcl_lisp_environment
                                   RAISING   lcx_lisp_exception.
      METHODS environment_named_let IMPORTING VALUE(io_env) TYPE REF TO lcl_lisp_environment
                                    CHANGING  co_head       TYPE REF TO lcl_lisp
                                    RETURNING VALUE(ro_env) TYPE REF TO lcl_lisp_environment
                                    RAISING   lcx_lisp_exception.
      METHODS environment_parameterize IMPORTING VALUE(io_env)  TYPE REF TO lcl_lisp_environment
                                                 VALUE(io_head) TYPE REF TO lcl_lisp
                                       RETURNING VALUE(ro_env)  TYPE REF TO lcl_lisp_environment
                                       RAISING   lcx_lisp_exception.

      METHODS table_of_lists IMPORTING io_head         TYPE REF TO lcl_lisp
                                       environment     TYPE REF TO lcl_lisp_environment
                             RETURNING VALUE(rt_table) TYPE tt_lisp
                             RAISING   lcx_lisp_exception.

      METHODS map_next_expr IMPORTING io_proc       TYPE REF TO lcl_lisp
                            EXPORTING ev_has_next   TYPE abap_boolean
                            CHANGING  ct_list       TYPE tt_lisp
                            RETURNING VALUE(result) TYPE REF TO lcl_lisp
                            RAISING   lcx_lisp_exception.

      METHODS is_constant IMPORTING exp            TYPE REF TO lcl_lisp
                          RETURNING VALUE(rv_flag) TYPE abap_boolean.
      METHODS combine IMPORTING left          TYPE REF TO lcl_lisp
                                right         TYPE REF TO lcl_lisp
                                exp           TYPE REF TO lcl_lisp
                                environment   TYPE REF TO lcl_lisp_environment
                      RETURNING VALUE(result) TYPE REF TO lcl_lisp.

      METHODS quasiquote IMPORTING exp           TYPE REF TO lcl_lisp
                                   nesting       TYPE tv_index
                                   environment   TYPE REF TO lcl_lisp_environment
                         RETURNING VALUE(result) TYPE REF TO lcl_lisp
                         RAISING   lcx_lisp_exception.  " ?

      METHODS list_reverse IMPORTING io_list       TYPE REF TO lcl_lisp
                           RETURNING VALUE(result) TYPE REF TO lcl_lisp
                           RAISING   lcx_lisp_exception.

      METHODS list_length IMPORTING list          TYPE REF TO lcl_lisp
                          RETURNING VALUE(result) TYPE tv_int
                          RAISING   lcx_lisp_exception.

      METHODS list_tail IMPORTING list          TYPE REF TO lcl_lisp
                                  k             TYPE tv_index
                                  area          TYPE string
                        RETURNING VALUE(result) TYPE REF TO lcl_lisp
                        RAISING   lcx_lisp_exception.

      METHODS get_equal_params IMPORTING io_list    TYPE REF TO lcl_lisp
                               EXPORTING eo_sublist TYPE REF TO lcl_lisp
                                         eo_compare TYPE REF TO lcl_lisp
                                         eo_key     TYPE REF TO lcl_lisp
                               RAISING   lcx_lisp_exception.
  ENDCLASS.                    "lcl_lisp_interpreter DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_parser IMPLEMENTATION
*----------------------------------------------------------------------*
  CLASS lcl_parser IMPLEMENTATION.

    METHOD constructor.
*     End of line value
      mv_eol = cl_abap_char_utilities=>newline.
*     Whitespace values
      CLEAR mv_whitespace.
      mv_whitespace+0(1) = ' '.
      mv_whitespace+1(1) = cl_abap_char_utilities=>newline.        " \n
      mv_whitespace+2(1) = cl_abap_char_utilities=>cr_lf(1).       " \r
      mv_whitespace+3(1) = cl_abap_char_utilities=>cr_lf(2).       " \n
      mv_whitespace+4(1) = cl_abap_char_utilities=>horizontal_tab. " \t
      mv_whitespace+5(1) = cl_abap_char_utilities=>vertical_tab.
      mv_whitespace+6(1) = cl_abap_char_utilities=>form_feed.

*     Delimiters value
      mv_delimiters = mv_whitespace.
      mv_delimiters+7(1) = c_close_paren.
      mv_delimiters+8(1) = c_open_paren.
      mv_delimiters+9(1) = c_close_bracket.
      mv_delimiters+10(1) = c_open_bracket.
      mv_delimiters+11(1) = c_close_curly.
      mv_delimiters+12(1) = c_open_curly.
    ENDMETHOD.                    "constructor

    METHOD skip_whitespace.
      WHILE char CA mv_whitespace AND index LT length.
        next_char( ).
      ENDWHILE.
      rv_has_next = xsdbool( index LT length ).

      IF char EQ c_lisp_comment AND rv_has_next EQ abap_true.
*       skip until end of line
        WHILE char CN mv_eol AND index LT length.
          next_char( ).
        ENDWHILE.
        rv_has_next = skip_whitespace( ).
      ENDIF.

      IF char EQ c_lisp_hash AND rv_has_next EQ abap_true AND peek_char( ) EQ c_lisp_comment.
        skip_one_datum( ).
        rv_has_next = skip_whitespace( ).
      ENDIF.

      IF char EQ c_lisp_hash AND rv_has_next EQ abap_true AND peek_char( ) EQ c_block_comment.
        skip_block_comment( ).
        rv_has_next = skip_whitespace( ).
      ENDIF.

    ENDMETHOD.

    METHOD skip_block_comment.
*     skip block comment, from #| to |#
      next_char( ).   " skip |#
      next_char( ).
      WHILE index LT length AND NOT ( char EQ c_block_comment AND peek_char( ) EQ c_lisp_hash ).
        next_char( ).
      ENDWHILE.

      IF char EQ c_block_comment AND peek_char( ) EQ c_lisp_hash.
        next_char( ).  " skip #|
        next_char( ).
      ENDIF.
    ENDMETHOD.

    METHOD skip_one_datum.
*     Character constant  #; comment
      next_char( ).       " skip #;
      next_char( ).
*     skip optional blanks, max. until end of line
      WHILE char CN mv_eol AND index LT length AND peek_char( ) EQ ` `.
        next_char( ).
      ENDWHILE.
*     skip one datum
      DATA sval TYPE string.
      match_atom( CHANGING cv_val = sval ).
    ENDMETHOD.

    METHOD next_char.
      index = index + 1.
      IF index < length.
        char = code+index(1).
      ELSEIF index = length.
        char = space.
      ELSEIF index > length.
        throw( c_error_unexpected_end ).
      ENDIF.
    ENDMETHOD.                    "next_char

    METHOD throw.
      RAISE EXCEPTION TYPE lcx_lisp_exception
        EXPORTING
          message = message
          area    = c_area_parse.
    ENDMETHOD.

    METHOD peek_char.
      DATA(lv_idx) = index + 1.

      IF lv_idx < length.
        rv_char = code+lv_idx(1).
      ELSE.
        rv_char = c_lisp_eof.
      ENDIF.
    ENDMETHOD.

    METHOD peek_bytevector.
      CONSTANTS c_prefix TYPE c LENGTH 3 VALUE 'U8('.
      DATA lv_token TYPE string.

      DATA(lv_idx) = index.
      rv_flag = abap_false.
      DO 3 TIMES.  " length( 'u8(' ) = 3
        lv_idx = lv_idx + 1.

        IF lv_idx < length.
          lv_token = to_upper( lv_token ).
          CONCATENATE lv_token code+lv_idx(1) INTO lv_token RESPECTING BLANKS.
        ELSE.
          RETURN.
        ENDIF.
      ENDDO.
      CHECK lv_token EQ c_prefix.
      rv_flag = abap_true.
    ENDMETHOD.

    METHOD parse.
*     Entry point for parsing code. This is not thread-safe, but as an ABAP
*     process does not have the concept of threads, we are safe :-)
      code = iv_code.
      length = strlen( code ).

      IF length = 0.
        APPEND lcl_lisp=>eof_object TO elements.
        RETURN.
      ENDIF.

      index = 0.
      char = code+index(1).           "Kick off things by reading first char
      WHILE skip_whitespace( ).
        IF char = c_open_paren OR char = c_open_bracket OR char = c_open_curly.
          APPEND parse_list( char ) TO elements.
        ELSEIF index < length.
          APPEND parse_token( ) TO elements.
        ENDIF.
      ENDWHILE.

    ENDMETHOD.                    "parse

    METHOD read_from.
      code = ii_port->read( ).
      length = strlen( code ).
      element = lcl_lisp=>eof_object.

      CHECK code NE c_lisp_eof AND length GT 0.

      index = 0.
      char = code+index(1).           "Kick off things by reading first char
      skip_whitespace( ).
      IF char = c_open_paren OR char = c_open_bracket OR char = c_open_curly.
        element = parse_list( char ).
      ELSEIF index < length.
        element = parse_token( ).
      ENDIF.
      ii_port->put( substring( val = code off = index ) ).
    ENDMETHOD.

    METHOD parse_list.
      DATA lo_cell TYPE REF TO lcl_lisp.
      DATA lv_empty_list TYPE abap_boolean VALUE abap_true.
      DATA lv_proper_list TYPE abap_boolean VALUE abap_true.

*     Set pointer to start of list
      result = lo_cell = lcl_lisp_new=>cons( ).
      DATA(lv_close_delim) = SWITCH #( delim WHEN c_open_bracket THEN c_close_bracket
                                             WHEN c_open_curly THEN c_close_curly
                                             ELSE c_close_paren ).

      next_char( ).                 " Skip past opening paren
      WHILE skip_whitespace( ).
        CASE char.
          WHEN lv_close_delim.
            IF lv_empty_list = abap_true.
              result = lcl_lisp=>nil.           " Result = empty list
            ELSEIF lv_proper_list EQ abap_true.
              lo_cell->cdr = lcl_lisp=>nil.     " Terminate list
*            ELSE.
*              " pair, no termination with nil, nothing to do
            ENDIF.
            next_char( ).              " Skip past closing paren
            RETURN.

          WHEN c_close_paren OR c_close_bracket OR c_close_curly.
            throw( |a { char } found while { lv_close_delim } expected| ).

          WHEN OTHERS.
        ENDCASE.

        IF lv_proper_list EQ abap_false.
*         inconsistent input
          throw( `dotted pair` ).
        ENDIF.

        IF lv_empty_list = abap_true. " First

          lv_empty_list = abap_false. " Next char was not closing paren
          lo_cell->car = parse_token( ).

        ELSE.  " lv_empty_list = abap_false.
*         On at least the second item; add new cell and move pointer

          DATA(lo_peek) = parse_token( ).

          IF lo_peek->type = lcl_lisp=>type_symbol AND lo_peek->value = c_lisp_dot.
            " dotted Pair
            lo_cell->cdr = parse_token( ).
            " match closing parens
            lv_proper_list = abap_false.
          ELSE.

            lo_cell = lo_cell->cdr = lcl_lisp_new=>cons( io_car = lo_peek ).

          ENDIF.

        ENDIF.

      ENDWHILE.
      throw( |missing a { lv_close_delim } to close expression| ).
    ENDMETHOD.                    "parse_list

    METHOD match_string.
      CONSTANTS:
        c_esc_a          TYPE tv_char VALUE 'a',
        c_esc_b          TYPE tv_char VALUE 'b',
        c_esc_t          TYPE tv_char VALUE 't',
        c_esc_n          TYPE tv_char VALUE 'n',
        c_esc_r          TYPE tv_char VALUE 'r',
        c_esc_semi_colon TYPE tv_char VALUE ';',
        c_esc_vline      TYPE tv_char VALUE '|'.

      DATA pchar TYPE tv_char.
*     " is included in a string as \"

      next_char( ).                 " Skip past opening quote
      WHILE index < length AND NOT ( char = c_text_quote AND pchar NE c_escape_char ).
*       cv_val = |{ cv_val }{ char }|.
        pchar = char.
        next_char( ).
        IF pchar EQ c_escape_char.
          CASE char.
            WHEN space.         " \ : intraline whitespace
              skip_whitespace( ).
              CONTINUE.

            WHEN c_text_quote   " \" : double quote, U+0022
              OR c_escape_char  " \\ : backslash, U+005C
              OR c_esc_vline.   " \| : vertical line, U+007C
              pchar = char.
              next_char( ).

            WHEN c_esc_a.       " \a : alarm, U+0007
              pchar = lcl_lisp=>char_alarm->value+0(1).
              next_char( ).

            WHEN c_esc_b.       " \b : backspace, U+0008
              pchar = lcl_lisp=>char_backspace->value+0(1).
              next_char( ).

            WHEN c_esc_t.       " \t : character tabulation, U+0009
              pchar = lcl_lisp=>char_tab->value+0(1).
              next_char( ).

            WHEN c_esc_n.       " \n : linefeed, U+000A
              pchar = lcl_lisp=>char_newline->value+0(1).
              next_char( ).

            WHEN c_esc_r.       " \r : return, U+000D
              pchar = lcl_lisp=>char_return->value+0(1).
              next_char( ).

            WHEN c_lisp_xx+0(1) OR c_lisp_xx+1(1).      " hex scalar value terminated by semi-colon ;
              DATA lv_xstr TYPE string.
              DATA lo_char TYPE REF TO lcl_lisp_char.
              next_char( ).
              CLEAR lv_xstr.
              WHILE index < length.
                lv_xstr = |{ lv_xstr }{ char }|.
                next_char( ).
                CHECK char EQ c_esc_semi_colon.
                EXIT.
              ENDWHILE.
              CONDENSE lv_xstr.
              IF strlen( lv_xstr ) LE 4 AND char EQ c_esc_semi_colon.
                lo_char = lcl_lisp_new=>charx( lv_xstr ).
              ELSE.
                throw( |unknown char #\\x{ lv_xstr } found| ).
              ENDIF.

              pchar = lo_char->value+0(1).
              next_char( ).
          ENDCASE.
        ENDIF.
        CONCATENATE cv_val pchar INTO cv_val RESPECTING BLANKS.
      ENDWHILE.
      next_char( ).                 "Skip past closing quote
    ENDMETHOD.                    "match_string

    METHOD skip_label.
*     Skip if match was successful
      next_char( ).                 " Skip past hash
      WHILE index < length AND char CO c_decimal_digits.
        next_char( ).
      ENDWHILE.
      next_char( ).                 "Skip past closing iv_limit ( = or # )
    ENDMETHOD.

    METHOD match_label.
      rv_found = abap_false.
      CLEAR ev_label.

      DATA(lv_idx) = index.

      DATA(len_1) = length - 1.
      WHILE lv_idx < len_1.
        lv_idx = lv_idx + 1.

        DATA(lv_char) = code+lv_idx(1).
        IF lv_char CO c_decimal_digits.
          ev_label = ev_label && lv_char.
        ELSEIF lv_char = iv_limit AND ev_label IS NOT INITIAL.
          rv_found = abap_true.
          skip_label( ).
        ELSE.
          RETURN.
        ENDIF.
      ENDWHILE.
    ENDMETHOD.

    METHOD match_atom.              " run_to_delimiter.
      WHILE index < length.
        CONCATENATE cv_val char INTO cv_val RESPECTING BLANKS.
        next_char( ).
        CHECK char CA mv_delimiters.
        EXIT.
      ENDWHILE.
      CONDENSE cv_val.              " 29.04.2018 to be reviewed, remove?
      IF cv_val = cl_abap_char_utilities=>newline.
        cv_val = space.
      ENDIF.
    ENDMETHOD.                    "run_to_delimiter

    METHOD parse_token.
      DATA sval TYPE string.

      skip_whitespace( ).
*     create object cell.
      CASE char.
        WHEN c_open_paren OR c_open_bracket OR c_open_curly.
          element = parse_list( char ).
          RETURN.

        WHEN c_lisp_quote.
* ' is just a shortcut for QUOTE, so we wrap the consecutive element in a list starting with the quote symbol
* so that when it is evaluated later, it returns the quote elements unmodified
          next_char( ).            " Skip past single quote
          element = lcl_lisp_new=>quote( parse_token( ) ).
          RETURN.

        WHEN c_lisp_backquote.     " Quasiquote, TO DO
          next_char( ).            " Skip past single quote
          element = lcl_lisp_new=>quasiquote( parse_token( ) ).
          RETURN.

        WHEN c_lisp_unquote.
          IF peek_char( ) EQ c_lisp_splicing.  " unquote-splicing ,@
            next_char( ).        " Skip past ,
            next_char( ).        " Skip past @
            element = lcl_lisp_new=>splice_unquote( parse_token( ) ).  " token must evaluate to a list, not be a list
          ELSE.                                " unquote ,
            next_char( ).        " Skip past ,
            element = lcl_lisp_new=>unquote( parse_token( ) ).
          ENDIF.
          RETURN.

        WHEN c_text_quote.
          match_string( CHANGING cv_val = sval ).
          element = lcl_lisp_new=>string( value = sval
                                          iv_mutable = abap_false ).
          RETURN.

        WHEN c_lisp_hash.
          CASE peek_char( ).
            WHEN c_open_paren.   " Vector constant
              next_char( ).
              element = lcl_lisp_vector=>from_list( io_list = parse_list( )
                                                    iv_mutable = abap_false ).
              RETURN.

            WHEN c_escape_char.  " Character constant  #\a
              next_char( ).      " skip #
              next_char( ).      " skip \
              IF char EQ c_lisp_xx+0(1) OR char EQ c_lisp_xx+1(1).
                next_char( ).      " skip x
                match_atom( CHANGING cv_val = sval ).
                IF strlen( sval ) LE 4.
                  element = lcl_lisp_new=>charx( sval ).
                ELSE.
                  throw( |unknown char #\\x{ sval } found| ).
                ENDIF.
              ELSE.
                match_atom( CHANGING cv_val = sval ).
                CASE sval.
                  WHEN 'alarm'.
                    element = lcl_lisp=>char_alarm.
                  WHEN 'backspace'.
                    element = lcl_lisp=>char_backspace.
                  WHEN 'delete'.
                    element = lcl_lisp=>char_delete.
                  WHEN 'escape'.
                    element = lcl_lisp=>char_escape.
                  WHEN 'newline'.
                    element = lcl_lisp=>char_newline.
                  WHEN 'null'.
                    element = lcl_lisp=>char_null.
                  WHEN 'return'.
                    element = lcl_lisp=>char_return.
                  WHEN 'space' OR space.
                    element = lcl_lisp=>char_space.
                  WHEN 'tab'.
                    element = lcl_lisp=>char_tab.
                  WHEN OTHERS.
                    IF strlen( sval ) EQ 1.
                      element = lcl_lisp_new=>char( sval ).
                    ELSE.
                      throw( |unknown char #\\{ sval } found| ).
                    ENDIF.
                ENDCASE.
              ENDIF.

              RETURN.

*           Notation for numbers #e (exact) #i (inexact) #b (binary) #o (octal) #d (decimal) #x (hexadecimal)
*           further, instead of exp:  s (short), f (single), d (double), l (long)
*           positive infinity, negative infinity -inf / -inf.0, NaN +nan.0, positive zero, negative zero
            WHEN c_number_exact+0(1) OR c_number_exact+1(1).   "#e (exact)
              DATA lx_error TYPE REF TO cx_root.
              " _get_atom sval
              next_char( ).        " skip #
              next_char( ).        " skip
              match_atom( CHANGING cv_val = sval ).
              TRY.
                  element = lcl_lisp_new=>number( value = sval
                                                  iv_exact = abap_true ).
                  RETURN.
                CATCH cx_sy_conversion_no_number INTO lx_error.
                  throw( lx_error->get_text( ) ).
              ENDTRY.

            WHEN c_number_inexact+0(1) OR c_number_inexact+1(1). "#i (inexact)
              " _get_atom
              next_char( ).        " skip #
              next_char( ).        " skip
              match_atom( CHANGING cv_val = sval ).
              element = lcl_lisp_new=>number( value = sval
                                              iv_exact = abap_false ).
              RETURN.

            WHEN c_number_octal+0(1) OR c_number_octal+1(1).     "#o (octal)
              " _get_atom
              next_char( ).        " skip #
              next_char( ).        " skip
              match_atom( CHANGING cv_val = sval ).
              element = lcl_lisp_new=>octal( sval ).
              RETURN.

            WHEN c_number_binary+0(1) OR c_number_binary+1(1).  "#b (binary)
              " _get_atom
              next_char( ).        " skip #
              next_char( ).        " skip
              match_atom( CHANGING cv_val = sval ).
              element = lcl_lisp_new=>binary( sval ).
              RETURN.

            WHEN c_number_decimal+0(1) OR c_number_decimal+1(1). "#d (decimal)
              " _get_atom
              next_char( ).        " skip #
              next_char( ).        " skip
              match_atom( CHANGING cv_val = sval ).

              element = lcl_lisp_new=>number( sval ).
              RETURN.

            WHEN c_lisp_xx+0(1) OR c_lisp_xx+1(1).                "#x (hexadecimal)
              " _get_atom
              next_char( ).        " skip #
              next_char( ).        " skip
              match_atom( CHANGING cv_val = sval ).

              element = lcl_lisp_new=>hex( sval ).
              RETURN.

            WHEN OTHERS.
*             Boolean #t #f
              "will be handled in match_atom( )

              IF peek_bytevector( ).
**               Bytevector constant #u8( ... )
*
              ENDIF.

*             Referencing other literal data #<n>= #<n>#
              DATA lv_label TYPE string.
              IF match_label( EXPORTING iv_limit = c_lisp_equal
                              IMPORTING ev_label = lv_label ).
*               New datum
*               Now Add: (set! |#{ lv_label }#| element)
                element = parse_token( ).
                element->mv_label = |#{ lv_label }#|.

                RETURN.
              ELSEIF match_label( EXPORTING iv_limit = c_lisp_hash
                                  IMPORTING ev_label = lv_label ).
*               Reference to datum
                element = lcl_lisp_new=>symbol( |#{ lv_label }#| ).
                RETURN.
              ENDIF.

          ENDCASE.

      ENDCASE.
*     Others
      match_atom( CHANGING cv_val = sval ).
      element = lcl_lisp_new=>atom( sval ).
    ENDMETHOD.                    "parse_token

  ENDCLASS.                    "lcl_parser IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_lisp_interpreter IMPLEMENTATION
*----------------------------------------------------------------------*
  CLASS lcl_lisp_interpreter IMPLEMENTATION.

    METHOD new.
      CREATE OBJECT ro_int
        EXPORTING
          io_port = io_port
          ii_log  = ii_log.
    ENDMETHOD.

    METHOD constructor.
      super->constructor( ).
      nil = lcl_lisp=>nil.
      true = lcl_lisp=>true.
      false = lcl_lisp=>false.

      go_input_port ?= proc_make_parameter( lcl_lisp_new=>cons( io_car = io_port ) ).
      go_output_port = go_error_port = go_input_port.
      gi_log = ii_log.
      mt_zero = unicode_digit_zero( ).

      env = lcl_lisp_env_factory=>make_top_level( ).
    ENDMETHOD.                    "constructor

    METHOD throw.
      lcl_lisp=>throw( message ).
    ENDMETHOD.                    "throw

    METHOD bind_symbol.
      DATA lv_symbol TYPE string.
      DATA lo_params TYPE REF TO lcl_lisp.
*     Scheme does not return a value for define; but we are returning the new symbol reference
      DATA(lo_head) = element->car.
      CASE lo_head->type.
        WHEN lcl_lisp=>type_symbol.
*         call the set method of the current environment using the unevaluated first parameter
*         (second list element) as the symbol key and the evaluated second parameter as the value.
          lo_params = eval( element = element->cdr->car
                            environment = environment ).
          lo_params->macro = iv_macro.
          lv_symbol = lo_head->value.

*       Function shorthand (define (id arg ... ) body ...+)
        WHEN lcl_lisp=>type_pair.
          IF element->cdr EQ nil.
            throw( |{ lo_head->to_string( ) } no expression in body| ).
          ENDIF.
*         define's function shorthand allows us to define a function by specifying a list as the
*         first argument where the first element is a symbol and consecutive elements are arguments
          lo_params = lcl_lisp_new=>lambda( io_car = lo_head->cdr  "List of params following function symbol
                                            io_cdr = element->cdr
                                            io_env = environment
                                            iv_macro = iv_macro ).
          lv_symbol = lo_head->car->value.

        WHEN OTHERS.
          throw( |{ lo_head->to_string( ) } cannot be a variable identifier| ).
      ENDCASE.

*     Add function to the environment with symbol
      environment->set( symbol  = lv_symbol
                        element = lo_params
                        once = xsdbool( env NE environment ) ). " Internal definition => once!

      result = lcl_lisp_new=>symbol( lv_symbol ).
    ENDMETHOD.                    "assign_symbol

    METHOD define_syntax.
*
      result = bind_symbol( element = element
                            environment = environment
                            iv_macro = abap_true ).
    ENDMETHOD.

    METHOD is_macro_call.
*     returns true if element is a list that contains a symbol as the first element and that symbol refers to a function
*     in the environment and that function has the macro attribute set to true. Otherwise, it returns false.
      DATA lo_ptr TYPE REF TO lcl_lisp.
      "_validate element.
      IF element IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      result = abap_false.
      CHECK element->type EQ lcl_lisp=>type_pair AND element->car->type = lcl_lisp=>type_symbol.
      TRY.
          lo_ptr = environment->get( element->car->value ).
          CHECK lo_ptr->is_procedure( ) EQ true.
          result = lo_ptr->macro.
        CATCH lcx_lisp_exception.
          RETURN.
      ENDTRY.
    ENDMETHOD.

    METHOD syntax_expand.
      DATA lo_lambda TYPE REF TO lcl_lisp.
      DATA lo_args TYPE REF TO lcl_lisp.
      DATA lo_env TYPE REF TO lcl_lisp_environment.
      "_validate element.
      IF element IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = element.
      WHILE is_macro_call( element = result
                           environment = environment ).
        lo_lambda = environment->get( result->car->value ).
        lo_args = result->cdr.
        lo_env = lo_lambda->environment.

        lo_env->parameters_to_symbols( io_args = lo_args             " Pointer to argument
                                       io_pars = lo_lambda->car ).   " Pointer to formal parameters

        result = eval( element = lcl_lisp_new=>cons( io_car = lo_lambda
                                                     io_cdr = lo_args )
                       environment = lo_env ).
      ENDWHILE.
    ENDMETHOD.

    METHOD generate_symbol.
      DATA lv_index TYPE tv_index.
      DATA lv_suffix TYPE string VALUE 'G0as'.
      DATA lv_counter TYPE i.
      DATA lo_opt TYPE REF TO lcl_lisp.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_string TYPE REF TO lcl_lisp_string.

      gensym_counter += 1.
      lv_counter = lv_index = gensym_counter.

      IF list NE nil AND list->car IS BOUND.
        lo_opt = list->car.
      ENDIF.

      IF lo_opt IS BOUND AND lo_opt->type EQ lcl_lisp=>type_integer.
        lo_int ?= lo_opt.
        IF lo_int->integer GE 0.
          lv_counter = lo_int->integer.
        ENDIF.
      ENDIF.

      IF lo_opt IS BOUND AND lo_opt->type EQ lcl_lisp=>type_string.
        lo_string ?= lo_opt.
        lv_suffix = lo_string->value.
      ENDIF.

      DATA(lv_name) = |#:{ lv_suffix }{ lv_counter }|.
      result = lcl_lisp_new=>symbol( value = lv_name
                                     index = lv_index ). " uninterned symbols have integer > 0
    ENDMETHOD.

    METHOD assign_symbol.
      "_validate: element, element->car.
      IF element IS NOT BOUND OR element->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      result = element->car.

      CASE result->type.
        WHEN lcl_lisp=>type_symbol.
*         re-define symbol in the original environment, but evaluate parameters in the current environment
          environment->scope_of( result->value )->set( symbol  = result->value
                                                       element = eval( element = element->cdr->car
                                                                       environment = environment ) ).
        WHEN OTHERS.
          throw( |{ result->to_string( ) } is not a bound symbol| ).
      ENDCASE.
    ENDMETHOD.                    "re_assign_symbol

    METHOD evaluate_parameters.
*     This routine is called very, very often!
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lo_new TYPE REF TO lcl_lisp.
*     Before execution of the procedure or lambda, all parameters must be evaluated
      "_validate io_list.
      IF io_list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      ro_head = nil.
      CHECK io_list NE nil. " AND io_list->car NE nil.

      DATA(elem) = io_list.
*     TO DO: check if circular list are allowed
      WHILE elem->type EQ lcl_lisp=>type_pair.
        lo_new = lcl_lisp_new=>cons( io_car = eval_ast( element = elem->car
                                                        environment = environment ) ).
        IF ro_head = nil.
          lo_arg = ro_head = lo_new.
        ELSE.
          lo_arg = lo_arg->cdr = lo_new.
        ENDIF.
        elem = elem->cdr.
      ENDWHILE.

      "_validate_tail elem io_list space.
      IF elem NE nil.
*       if the last element in the list is not a cons cell, we cannot append
        throw( |: { io_list->to_string( ) } is not a proper list| ) ##NO_TEXT.
      ENDIF.

    ENDMETHOD.                    "evaluate_parameters

    METHOD expand_apply.
      "_validate io_list.
      IF io_list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      DATA(lo_proc) = io_list->car.     " proc
      DATA(lo_arg) = io_list->cdr.      " handle arg1 . . . rest-args

      "_validate lo_arg.
      IF lo_arg IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
*     (apply proc arg1 . . . argn rest)
*     Parameter io_list is list arg1 ... argn rest

      result = io_list.
      CHECK lo_arg NE nil.

*     At least one argument = rest
      DATA(lo_new) = lcl_lisp_new=>cons( io_car = lo_proc ).
      result = lo_new.

*     Collect arg1 to argn
*     TO DO: check if circular lists are allowed
      WHILE lo_arg->cdr->type EQ lcl_lisp=>type_pair.
*       At least two entries (argn and rest), build (list arg1 . . argn )

        lo_new = lo_new->cdr = lcl_lisp_new=>cons( io_car = lo_arg->car ).
        lo_arg = lo_arg->cdr.
      ENDWHILE.

*     now (append (list arg1 . . argn ) rest )
      DATA(lo_rest) = eval_ast( element = lo_arg->car
                                environment = environment ).

*     TO DO: check if circular lists are allowed
      WHILE lo_rest->type EQ lcl_lisp=>type_pair.  " e.g. NE nil
        lo_new = lo_new->cdr = lcl_lisp_new=>box_quote( lo_rest->car ).
        lo_rest = lo_rest->cdr.
      ENDWHILE.

      lo_new->cdr = lo_rest.

    ENDMETHOD.

*   (define (map f lst)
*     (if (null? lst)
*       '()
*       (cons (f (car lst)) (map f (cdr lst)))))
    METHOD expand_map.
*     (map proc list1 list2 ... ) The lists should all have the same length.
*     Proc should accept as many arguments as there are lists and return a single value.
*     Proc should not mutate any of the lists.
* The map procedure applies proc element-wise to the elements of the lists and returns a list of the results, in order.
* Proc is always called in the same dynamic environment as map itself. The order in which proc is applied to the
* elements of the list s is unspecified. If multiple returns occur from map, the values returned by earlier returns
* are not mutated.
      DATA lo_map TYPE REF TO lcl_lisp.
      "_validate: io_list, io_list->car.
      IF io_list IS NOT BOUND OR io_list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = nil.
      DATA(lo_proc) = io_list->car.

      DATA(lt_list) = table_of_lists( io_head = io_list->cdr         " parameter evaluated lists
                                      environment = environment ).

      DATA(lv_has_next) = xsdbool( lines( lt_list ) GT 0 ). " map terminates when the shortest list runs out.

      WHILE lv_has_next EQ abap_true.
        DATA(lo_next) = eval( element = map_next_expr( EXPORTING io_proc = lo_proc
                                                       IMPORTING ev_has_next = lv_has_next
                                                       CHANGING  ct_list = lt_list )
                              environment = environment ).
        DATA(lo_head) = lcl_lisp_new=>cons( io_car = lo_next ).
*       create function call (proc list1[k] list2[k]... listn[k]); add result as k-th list element
        IF result EQ nil. " 1st element of new list
          lo_map = result = lo_head.
        ELSE.
          lo_map = lo_map->cdr = lo_head.
        ENDIF.
      ENDWHILE.

    ENDMETHOD.

    METHOD expand_for_each.
*     (for-each proc list1 list2 ... ) The lists should all have the same length.
*     Proc should accept as many arguments as there are lists and return a single value.
*     Proc should not mutate any of the lists.
* The for-each procedure applies proc element-wise to the elements of the lists for its side effects, in order from the
* first elements to the last.
* Proc is always called in the same dynamic environment as for-each itself. The return values of for-each are unspecified.
      "_validate: io_list, io_list->car.
       IF io_list IS NOT BOUND OR io_list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      result = nil.
      DATA(lo_proc) = io_list->car.

      DATA(lt_list) = table_of_lists( io_head = io_list->cdr
                                      environment = environment ).

      DATA(lv_has_next) = xsdbool( lines( lt_list ) GT 0 ).  " for-each terminates when the shortest list runs out.
      WHILE lv_has_next EQ abap_true.
*       evaluate function call (proc list1[k] list2[k]... listn[k])
        DATA(lo_head) = map_next_expr( EXPORTING io_proc = lo_proc
                                       IMPORTING ev_has_next = lv_has_next
                                       CHANGING  ct_list = lt_list ).
        result = eval( element = lo_head
                       environment = environment ).
      ENDWHILE.
    ENDMETHOD.

    METHOD eval_do_init.
*     <init> expressions are evaluated (in unspecified order), the <variable>s are bound to fresh locations,
*     the results of the <init> expressions are stored in the bindings of the <variable>s.
*     A <step> can be omitted, in which case the effect is the same as if (<variable> <init> <variable>)
*     had been written instead of (<variable> <init>).
      "_validate io_head.
       IF io_head IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      eo_env = lcl_lisp_env_factory=>clone( io_env ).
      eo_step = nil.

      DATA(lo_loop) = io_head.
      WHILE lo_loop->type EQ lcl_lisp=>type_pair AND lo_loop->car->type EQ lcl_lisp=>type_pair.
        DATA(lo_spec) = lo_loop->car.
*       max. 3 entries
*       <variable>
        DATA(lo_var) = lo_spec->car.

*       <init>

        lo_spec = lo_spec->cdr.
        IF lo_spec NE nil.
          DATA(lo_init) = lo_spec->car.

          eo_env->set( symbol = lo_var->value
                       element = eval_ast( element = lo_init    " inits are evaluated in org. environment
                                           environment = io_env )
                       once = abap_true ).
          lo_spec = lo_spec->cdr.
          IF lo_spec NE nil.
*           <step>
            DATA(lo_next) = lcl_lisp_new=>cons( io_car = lcl_lisp_new=>cons( io_car = lo_var
                                                                             io_cdr = lo_spec->car ) ).
            IF eo_step EQ nil.  " first
              eo_step = lo_next.
              DATA(lo_ptr) = eo_step.
            ELSE.
              lo_ptr = lo_ptr->cdr = lo_next.
            ENDIF.

          ENDIF.
        ENDIF.
*       Next iteration control
        lo_loop = lo_loop->cdr.
      ENDWHILE.

    ENDMETHOD.

    METHOD eval_do_step.
*     <command> expressions are evaluated in order for effect
      DATA(lo_command) = io_command.

*     Evaluate in order
      WHILE lo_command->type EQ lcl_lisp=>type_pair.
        eval( element = lo_command->car
              environment = io_env ).
        lo_command = lo_command->cdr.
      ENDWHILE.

      DATA(lo_local_env) = lcl_lisp_env_factory=>new( ).
*     the <step> expressions are evaluated in some unspecified order
      DATA(lo_step) = io_steps.
      WHILE lo_step->type EQ lcl_lisp=>type_pair.
        DATA(lo_ptr) = lo_step->car.

*       <variable>s are bound to fresh locations to avoid dependencies in the next step
        lo_local_env->set( symbol = lo_ptr->car->value
                           element = eval_ast( element = lo_ptr->cdr
                                                environment = io_env ) ).
        lo_step = lo_step->cdr.
      ENDWHILE.

      lo_step = io_steps.
      WHILE lo_step->type EQ lcl_lisp=>type_pair.
        DATA(lv_symbol) = lo_step->car->car->value.

*       the results of the <step>s are stored in the bindings of the <variable>s
        io_env->set( symbol = lv_symbol
                     element = lo_local_env->get( lv_symbol ) ).
        lo_step = lo_step->cdr.
      ENDWHILE.

    ENDMETHOD.

    METHOD eval_list_tco. " Tail Call Optimization
*     Evaluate all expressions except the last one to be evaluated as a tail call
*     ( eval LOOP for the last evaluation step )
      "_validate io_head.
      IF io_head IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      result = nil.
      eo_elem = io_head.

      CHECK io_head NE nil.

      WHILE eo_elem IS BOUND AND eo_elem->type EQ lcl_lisp=>type_pair
        AND eo_elem->cdr NE nil.  " Do not evaluate the last list element

        result = eval_ast( element = eo_elem->car
                           environment = io_environment ).
        eo_elem = eo_elem->cdr.
      ENDWHILE.

      "_validate_tail eo_elem->cdr io_head space.
      IF eo_elem->cdr NE nil.
*       if the last element in the list is not a cons cell, we cannot append
        throw( |: { io_head->to_string( ) } is not a proper list| ) ##NO_TEXT.
      ENDIF.

    ENDMETHOD.

*    METHOD eval_list.
*      "_validate io_head.
*      IF io_head IS NOT BOUND.
*        lcl_lisp=>throw( c_error_incorrect_input ).
*      ENDIF.
*      result = nil.
*
*      DATA(elem) = io_head.
*      WHILE elem IS BOUND AND elem->type EQ lcl_lisp=>type_pair.
*        result = eval_ast( element = elem->car
*                           environment = io_environment ).
*        elem = elem->cdr.
*      ENDWHILE.
*
*      _validate_tail elem io_head space.
*    ENDMETHOD.

    METHOD lambda_environment.
      DATA lo_args TYPE REF TO lcl_lisp.
*     The function (LAMBDA) receives its own local environment in which to execute,
*     where parameters become symbols that are mapped to the corresponding arguments
      "_validate io_head.
       IF io_head IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      ro_env = lcl_lisp_env_factory=>clone( io_head->environment ).

      IF io_head->macro EQ abap_true.
        lo_args = io_args.
      ELSE.
        lo_args = evaluate_parameters( io_list = io_args           " Pointer to arguments
                                       environment = environment ).
      ENDIF.

      ro_env->parameters_to_symbols( io_args = lo_args
                                     io_pars = io_head->car ).   " Pointer to formal parameters
    ENDMETHOD.

    METHOD extract_arguments.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lo_par TYPE REF TO lcl_lisp.
      "_validate io_head.
      IF io_head IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      eo_args = eo_pars = nil.                "list of parameters

      CHECK io_head->car IS BOUND AND io_head->car NE nil.
      DATA(lo_ptr) = io_head->car.

      "_validate lo_ptr->car.
      IF lo_ptr->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      lo_par = lcl_lisp_new=>cons( io_car = lo_ptr->car ).

      IF lo_ptr->cdr IS BOUND AND lo_ptr->cdr NE nil.
        lo_arg = lcl_lisp_new=>cons( io_car = lo_ptr->cdr->car ).
      ENDIF.

      eo_pars = lo_par.
      eo_args = lo_arg.

      lo_ptr = io_head->cdr.
      WHILE lo_ptr->type EQ lcl_lisp=>type_pair. " IS BOUND AND lo_ptr NE nil.
*       Rest of list, pick head
        DATA(lo_first) = lo_ptr->car.
        IF lo_first IS BOUND AND lo_first->car NE nil.
          lo_par = lo_par->cdr = lcl_lisp_new=>cons( io_car = lo_first->car ).
        ENDIF.

        DATA(lo_second) = lo_first->cdr.
        IF lo_second IS BOUND AND lo_second NE nil.
          lo_arg = lo_arg->cdr = lcl_lisp_new=>cons( io_car = lo_second->car ).
        ENDIF.

        lo_ptr = lo_ptr->cdr.
      ENDWHILE.
      lo_par->cdr = lo_arg->cdr = nil.

*     Debug help: DATA lv_debug TYPE string.
*      lv_debug = |params { eo_pars->to_string( ) }\n arg { eo_args->to_string( ) }\n|.
    ENDMETHOD.                    "extract_arguments

    METHOD evaluate_in_sequence.
*     Before execution of the procedure or lambda, all parameters must be evaluated
      "_validate: io_args, io_pars.
        IF io_args IS NOT BOUND OR io_pars IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      DATA(lo_args) = io_args->new_iterator( ).
      DATA(lo_pars) = io_pars->new_iterator( ).

      WHILE lo_args->has_next( ) AND lo_pars->has_next( ).
        DATA(lo_par) = lo_pars->next( ).
        CHECK lo_par NE nil.        " Nil would mean no parameters to map
*       Assign argument to its corresponding symbol in the newly created environment
*       NOTE: element of the argument list is evaluated before being defined in the environment
        io_env->set( symbol = lo_par->value
                     element = eval( element = lo_args->next( )
                                     environment = io_env )
                     once = abap_false ).
      ENDWHILE.
    ENDMETHOD.

    METHOD extract_parameter_objects.
      DATA lo_val TYPE REF TO lcl_lisp.
      DATA lo_par TYPE REF TO lcl_lisp.
      DATA lo_param TYPE REF TO lcl_lisp.
      DATA lo_values TYPE REF TO lcl_lisp.
      DATA lo_lambda TYPE REF TO lcl_lisp_lambda.
      DATA lv_parameter_object TYPE abap_boolean VALUE abap_false.

      "_validate io_head.
        IF io_head IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      lo_values = eo_pars = eo_args = nil.                "list of parameter objects

      CHECK io_head->car IS BOUND AND io_head->car NE nil.
      DATA(lo_ptr) = io_head->car.

      "_validate lo_ptr->car.
        IF lo_ptr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
      "_to_param_object lo_ptr->car lo_param.
        lo_param = eval( element = lo_ptr->car
                   environment = io_env ).
        IF lo_param->type EQ lcl_lisp=>type_lambda.
          lo_lambda ?= lo_param.
          lv_parameter_object = lo_lambda->parameter_object.
        ENDIF.
        IF lv_parameter_object EQ abap_false.
          throw( |missing parameter object in parameterize| ).
        ENDIF.

      lo_par = lcl_lisp_new=>cons( io_car = lo_param ).

      IF lo_ptr->cdr IS BOUND AND lo_ptr->cdr NE nil.
        lo_val = lcl_lisp_new=>cons( io_car = lo_ptr->cdr->car ).
      ENDIF.

      eo_pars = lo_par.
      lo_values = lo_val.

      lo_ptr = io_head->cdr.
      WHILE lo_ptr->type EQ lcl_lisp=>type_pair. " IS BOUND AND lo_ptr NE nil.
*       Rest of list, pick head
        DATA(lo_first) = lo_ptr->car.
        IF lo_first IS BOUND AND lo_first->car NE nil.
          "_to_param_object lo_first->car lo_param.
            lo_param = eval( element = lo_first
                       environment = io_env ).
            IF lo_param->type EQ lcl_lisp=>type_lambda.
              lo_lambda ?= lo_param.
              lv_parameter_object = lo_lambda->parameter_object.
            ENDIF.
            IF lv_parameter_object EQ abap_false.
              throw( |missing parameter object in parameterize| ).
            ENDIF.

          lo_par = lo_par->cdr = lcl_lisp_new=>cons( io_car = lo_param ).
        ENDIF.

        DATA(lo_second) = lo_first->cdr.
        IF lo_second IS BOUND AND lo_second NE nil.
          lo_val = lo_val->cdr = lcl_lisp_new=>cons( io_car = lo_second->car ).
        ENDIF.

        lo_ptr = lo_ptr->cdr.
      ENDWHILE.
      lo_par->cdr = lo_val->cdr = nil.

      eo_args = evaluate_parameters( io_list = lo_values       " Pointer to values
                                     environment = io_env ).
    ENDMETHOD.

* A letrec expression is equivalent to a let where the bindings are initialized with dummy values,
* and then the initial values are computed and assigned into the bindings.
    METHOD environment_letrec.
      extract_arguments( EXPORTING io_head = io_head
                         IMPORTING eo_pars = DATA(lo_pars)
                                   eo_args = DATA(lo_args) ).

      ro_env = lcl_lisp_env_factory=>clone( io_env ).
*     setup the environment before evaluating the initial value expressions
      DATA(lo_par) = lo_pars.
      DATA(lo_arg) = lo_args.
      WHILE lo_par IS BOUND AND lo_par NE nil   " Nil means no parameters to map
        AND lo_arg IS BOUND AND lo_arg NE nil.  " Nil means no arguments

        ro_env->set( symbol = lo_par->car->value
                     element = lo_arg->car
                     once = abap_true ).
        lo_par = lo_par->cdr.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

*     the initial value computions execute inside the new environment
      DATA(lo_new_args) = evaluate_parameters( io_list = lo_args           " Pointer to arguments
                                               environment = ro_env ).

      ro_env->parameters_to_symbols( io_args = lo_new_args
                                     io_pars = lo_pars ).   " Pointer to formal parameters
*     to allow (define) with the same variable name as in (letrec ( )), create new scope
      ro_env = lcl_lisp_env_factory=>clone( ro_env ).
    ENDMETHOD.

    METHOD environment_letrec_star.
      extract_arguments( EXPORTING io_head = io_head
                         IMPORTING eo_pars = DATA(lo_pars)
                                   eo_args = DATA(lo_args) ).

      ro_env = lcl_lisp_env_factory=>clone( io_env ).

      DATA(lo_par) = lo_pars.
      DATA(lo_arg) = lo_args.
      WHILE lo_par IS BOUND AND lo_par NE nil   " Nil means no parameters to map
        AND lo_arg IS BOUND AND lo_arg NE nil.  " Nil means no parameters to map

        ro_env->set( symbol = lo_par->car->value
                     element = lo_arg->car
                     once = abap_true ).
        lo_par = lo_par->cdr.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      evaluate_in_sequence( io_args = lo_args      " Pointer to arguments e.g. (4, (+ x 4)
                            io_pars = lo_pars      " Pointer to formal parameters (x y)
                            io_env = ro_env ).
*     to allow (define) with the same variable name as in (let* ( )), create new scope
      ro_env = lcl_lisp_env_factory=>clone( ro_env ).
    ENDMETHOD.

*Here's an example loop, which prints out the integers from 0 to 9:
* (  let loop ((i 0))
*     (display i)
*     (if (< i 10)
*         (loop (+ i 1))))
*
*The example is exactly equivalent to:
*  (letrec ((loop (lambda (i)      ; define a recursive
*                    (display i)   ; procedure whose body
*                    (if (< i 10)  ; is the loop body
*                        (loop (+ i 1))))))
*     (loop 0)) ; start the recursion with 0 as arg i
    METHOD environment_named_let.
      CASE co_head->car->type.
        WHEN lcl_lisp=>type_symbol.
*named let:  (let <variable> (bindings) <body>)
          DATA(lo_var) = co_head->car.
          co_head = co_head->cdr.

        WHEN OTHERS. " lcl_lisp=>type_pair.
*(let ((x 10) (y 5)) (+ x y)) is syntactic sugar for  ( (lambda (x y) (+ x y)) 10 5)
          lo_var = nil.
      ENDCASE.

      extract_arguments( EXPORTING io_head = co_head->car
                         IMPORTING eo_pars = DATA(lo_pars)
                                   eo_args = DATA(lo_args) ).
      ro_env = lcl_lisp_env_factory=>clone( io_env ).

      DATA(lo_new_args) = evaluate_parameters( io_list = lo_args       " Pointer to arguments
                                               environment = io_env ).
      ro_env->parameters_to_symbols( io_args = lo_new_args
                                     io_pars = lo_pars ).              " Pointer to formal parameters

      IF lo_var IS BOUND AND lo_var NE nil.
*       named let
        ro_env->set( symbol = lo_var->value
                     element = lcl_lisp_new=>lambda( io_car = lo_pars                " List of parameters
                                                     io_cdr = co_head->cdr           " Body
                                                     io_env = ro_env )
                     once = abap_true ).
      ENDIF.
*     to allow (define) with the same variable name in the body of (let ( )), create new scope
      ro_env = lcl_lisp_env_factory=>clone( ro_env ).
    ENDMETHOD.

    METHOD environment_parameterize.
      extract_parameter_objects( EXPORTING io_head = io_head->car
                                           io_env = io_env
                                 IMPORTING eo_pars = DATA(lo_pars)
                                           eo_args = DATA(lo_new_args) ).

      ro_env = lcl_lisp_env_factory=>clone( io_env ).
      ro_env->parameters_to_symbols( io_args = lo_new_args
                                     io_pars = lo_pars ).              " Pointer to parameter objects

*     to allow (define) with the same variable name in the body of (let ( )), create new scope
      ro_env = lcl_lisp_env_factory=>clone( ro_env ).
    ENDMETHOD.

    METHOD environment_let_star.
      extract_arguments( EXPORTING io_head = io_head
                         IMPORTING eo_pars = DATA(lo_pars)
                                   eo_args = DATA(lo_args) ).
      ro_env = lcl_lisp_env_factory=>clone( io_env ).

      evaluate_in_sequence( io_args = lo_args      " Pointer to arguments e.g. (4, (+ x 4)
                            io_pars = lo_pars      " Pointer to formal parameters (x y)
                            io_env = ro_env ).
*     to allow (define) with the same variable name in the body of (let* ( )), create new scope
      ro_env = lcl_lisp_env_factory=>clone( ro_env ).
    ENDMETHOD.

    METHOD eval_ast.
*     Evaluate element, Element is not a list
      CASE element->type.
        WHEN lcl_lisp=>type_symbol. "Symbol
*         lookup the symbol in the environment and return the value or raise an error if no value is found
          result = environment->get( element->value ).

        WHEN lcl_lisp=>type_pair. " List
          result = eval( element = element
                         environment = environment ).

        WHEN lcl_lisp=>type_hash. " TEST
          result = CAST lcl_lisp_hash( element )->eval( environment = environment
                                                        interpreter = me ).

        WHEN lcl_lisp=>type_vector. " TEST
          result = CAST lcl_lisp_vector( element )->eval( environment = environment
                                                          interpreter = me ).

        WHEN OTHERS.
*         otherwise just return the original AST value
          result = element.  "Number or string evaluates to itself (also: vector constant)

      ENDCASE.

        IF result IS NOT BOUND.
          lcl_lisp=>throw( c_error_eval ).
        ENDIF.

    ENDMETHOD.

    METHOD is_constant.
*    (define (constant? exp)
*      (if (pair? exp) (eq? (car exp) 'quote) (not (symbol? exp))))
      IF exp->type EQ lcl_lisp=>type_pair.
        rv_flag = xsdbool( exp->car = lcl_lisp=>quote ).
      ELSE.
        rv_flag = xsdbool( exp->type NE lcl_lisp=>type_symbol ).
      ENDIF.
    ENDMETHOD.

    METHOD combine.
      IF is_constant( left ) AND is_constant( right ).
*       (eqv? (eval right) (cdr exp)))
        DATA(eval_left) = eval( element = left
                                environment = environment ).
        DATA(eval_right) = eval( element = right
                                environment = environment ).
        IF eval_left = exp->car AND eval_right = exp->cdr.
*         (list 'quote exp)
          result = lcl_lisp_new=>quote( exp ).
        ELSE.
*         (list 'quote (cons (eval left) (eval right)))))
          result = lcl_lisp_new=>quote( eval_left ).
          result->cdr->cdr = eval_right.
        ENDIF.
      ELSEIF right = nil.
*       ((null? right) (list 'list left))
        result = lcl_lisp_new=>box( io_proc = lcl_lisp=>list
                                    io_elem = left ).
      ELSEIF right->type = lcl_lisp=>type_pair AND right->car = lcl_lisp=>list.
*       ((and (pair? right) (eq? (car right) 'list))
*        (cons 'list (cons left (cdr right))))
        result = lcl_lisp_new=>cons( io_car = lcl_lisp=>list
                                     io_cdr = lcl_lisp_new=>cons( io_car = left
                                                                  io_cdr = right->cdr ) ).
      ELSE.
*      (else (list 'cons left right))))
        result = lcl_lisp_new=>list3( io_first = lcl_lisp=>cons
                                      io_second = left
                                      io_third = right ).
      ENDIF.
    ENDMETHOD.

*     `atom/nil  -> 'atom/nil
*     `,expr     -> expr
*     `,@expr    -> error
*     ``expr     -> `expr-expanded
*     `list-expr -> expand each element and handle dotted tails:
*        `(x1 x2 ... xn)     -> (append y1 y2 ... yn)
*        `(x1 x2 ... . xn)   -> (append y1 y2 ... 'xn)
*        `(x1 x2 ... . ,xn)  -> (append y1 y2 ... xn)
*        `(x1 x2 ... . ,@xn) -> error
*      where each yi is the output of (qq-transform xi)
    METHOD quasiquote.
*     adapted from http://norvig.com/jscheme/primitives.scm
      DATA(lo_ptr) = exp.

      CASE lo_ptr->type.
        WHEN lcl_lisp=>type_pair. "non empty list
*         ((and (eq? (car exp) 'unquote) (= (length exp) 2))
          DATA(lo_first) = lo_ptr->car.
          DATA(lo_next) = lo_ptr->cdr.
          "_validate lo_next.
            IF lo_next IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.

          IF ( lo_first = lcl_lisp=>unquote
              OR ( lo_first->type EQ lcl_lisp=>type_symbol AND lo_first->value EQ c_eval_unquote ) )
              AND list_length( exp ) EQ 2.
*           ((and (eq? (first = 'unquote) (= (length exp) 2))
            "_validate_quote lo_ptr c_eval_unquote.
          IF NOT ( lo_ptr->cdr->type = lcl_lisp=>type_pair AND lo_ptr->cdr->cdr = nil ).
            throw( |invalid form { lo_ptr->car->to_string( ) } in { c_eval_unquote }| ).
          ENDIF.

            IF nesting = 0.

              result = lo_next->car.

            ELSE.

              result = combine( left = lcl_lisp=>unquote
                                right = quasiquote( exp = lo_next
                                                    nesting = nesting - 1
                                                    environment = environment )
                                exp = exp
                                environment = environment ).
            ENDIF.

          ELSEIF ( lo_first = lcl_lisp=>quasiquote
              OR ( lo_first->type EQ lcl_lisp=>type_symbol AND lo_first->value EQ c_eval_quasiquote ) )
              AND list_length( exp ) EQ 2.
            "_validate_quote lo_ptr c_eval_quasiquote.
              IF NOT ( lo_ptr->cdr->type = lcl_lisp=>type_pair AND lo_ptr->cdr->cdr = nil ).
                throw( |invalid form { lo_ptr->car->to_string( ) } in { c_eval_quasiquote }| ).
              ENDIF.

*           (and (eq? (car exp) 'quasiquote) (= (length exp) 2))

            result = combine( left = lcl_lisp=>quasiquote
                              right = quasiquote( exp = lo_next
                                                  nesting = nesting + 1
                                                  environment = environment )
                              exp = exp
                              environment = environment ).

          ELSEIF lo_first->type EQ lcl_lisp=>type_pair AND
            ( lo_first->car = lcl_lisp=>unquote_splicing OR lo_first->car->value EQ c_eval_unquote_splicing )
            AND list_length( lo_first ) EQ 2.
*           ((and (pair? (car exp))
*                (eq? (caar exp) 'unquote-splicing)
*                (= (length (car exp)) 2))
            "_validate_quote lo_first c_eval_unquote_splicing.
              IF NOT ( lo_first->cdr->type = lcl_lisp=>type_pair AND lo_first->cdr->cdr = nil ).
                throw( |invalid form { lo_first->car->to_string( ) } in { c_eval_unquote_splicing }| ).
              ENDIF.

            IF nesting = 0.
*             (list 'append (second (first exp))
*                           (expand-quasiquote (cdr exp) nesting))
              result = lcl_lisp_new=>list3( io_first = lcl_lisp=>append
                                            io_second = lo_first->cdr->car
                                            io_third = quasiquote( exp = lo_next
                                                                   nesting = nesting
                                                                   environment = environment ) ).
            ELSE.

              result = combine( left = quasiquote( exp = lo_first
                                                   nesting = nesting - 1
                                                   environment = environment )
                                right = quasiquote( exp = lo_next
                                                    nesting = nesting
                                                    environment = environment )
                                exp = exp
                                environment = environment ).
            ENDIF.

          ELSE.

            result = combine( left = quasiquote( exp = lo_first
                                                 nesting = nesting
                                                 environment = environment )
                              right = quasiquote( exp = lo_next
                                                  nesting = nesting
                                                  environment = environment )
                              exp = exp
                              environment = environment ).
          ENDIF.

        WHEN lcl_lisp=>type_vector.
*         (list 'apply 'vector (expand-quasiquote (vector->list exp) nesting)))
          DATA(lo_vec) = CAST lcl_lisp_vector( exp ).
          result = lcl_lisp_new=>box( io_proc = lcl_lisp_new=>symbol( 'list->vector' )
                                      io_elem = quasiquote( exp = lo_vec->to_list( )
                                                            nesting = nesting
                                                            environment = environment ) ).
        WHEN OTHERS.
*         (if (constant? exp) exp (list 'quote exp)))
          IF is_constant( exp ).
            result = exp.
          ELSE.
            result = lcl_lisp_new=>quote( exp ).
          ENDIF.

      ENDCASE.

    ENDMETHOD.

**********************************************************************
*------------------------------- EVAL( ) ----------------------------
* eval takes an expression and an environment to a value
**********************************************************************
    METHOD eval.
      DATA(lo_elem) = element.
      DATA(lo_env) = environment.

      DO.
        "_validate lo_elem.
        IF lo_elem IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        CASE lo_elem.
          WHEN nil OR true OR false.
*           Return predefined symbols as themselves to save having to look them up in the environment
            result = lo_elem.

          WHEN OTHERS.
            IF lo_elem->type EQ lcl_lisp=>type_pair.
              lo_elem = syntax_expand( element = lo_elem
                                       environment = lo_env ).
            ENDIF.

*           Evaluate element
            CASE lo_elem->type.
              WHEN lcl_lisp=>type_pair. " List
*               return a new list that is the result of calling EVAL on each of the members of the list

*               To evaluate list, we must first evaluate head value
*               Evaluate first element of list to determine if it is a native procedure or lambda
                DATA(lr_head) = lo_elem->car.
                DATA(lr_tail) = lo_elem->cdr.

                CASE lr_head->value.

                  WHEN c_eval_quote. " Literal expression: Return the argument to quote unevaluated
                    IF lr_tail->cdr NE nil.
                      throw( |quote can only take a single argument| ).
                    ENDIF.
                    result = lr_tail->car.

                  WHEN c_eval_quasiquote.
                    IF lr_tail->cdr NE nil.
                      throw( |quasiquote can only take a single argument| ).
                    ENDIF.
                    lo_elem = quasiquote( exp = lr_tail->car
                                          nesting = 0
                                          environment = lo_env ).

                    CONTINUE.  "tail_expression lo_elem.

                  WHEN 'and'.
*                   Derived expression: Conditional (and <expression>* >tail expression>)
                    result = true.
                    DATA(lo_ptr) = lr_tail.
                    WHILE result NE false AND lo_ptr IS BOUND AND lo_ptr NE nil AND lo_ptr->cdr NE nil.
                      result = eval_ast( element = lo_ptr->car
                                         environment = lo_env ).
                      lo_ptr = lo_ptr->cdr.
                    ENDWHILE.
                    IF result NE false.
                      "_tail_expression lo_ptr.
                      IF lo_ptr NE nil.
                        lo_elem = lo_ptr->car.    " Tail context
                        CONTINUE.
                      ENDIF.
                    ENDIF.

                  WHEN 'or'.
*                   Derived expression: Conditional (or <expression>* <tail expression>)
                    result = false.
                    lo_ptr = lr_tail.
                    WHILE result EQ false AND lo_ptr IS BOUND AND lo_ptr NE nil AND lo_ptr->cdr NE nil.
                      result = eval_ast( element = lo_ptr->car
                                         environment = lo_env ).
                      lo_ptr = lo_ptr->cdr.
                    ENDWHILE.
                    IF result EQ false.
                      "_tail_expression lo_ptr.
                       IF lo_ptr NE nil.
                        lo_elem = lo_ptr->car.    " Tail context
                        CONTINUE.
                      ENDIF.

                    ENDIF.

                  WHEN 'cond'.
*                   Derived expression: Conditional
                    lo_ptr = lr_tail.
                    lo_elem = nil.
                    WHILE lo_ptr->type EQ lcl_lisp=>type_pair.
                      DATA(lo_clause) = lo_ptr->car.
                      IF lo_clause->car->value EQ c_lisp_else.
                        lo_elem = lo_clause->cdr.
                        EXIT.
                      ENDIF.
                      DATA(lo_test) = eval_ast( element = lo_clause->car
                                                environment = lo_env ).
                      IF lo_test NE false.
                        lo_elem = lo_clause->cdr.
                        EXIT.
                      ENDIF.
                      lo_ptr = lo_ptr->cdr.
                    ENDWHILE.
                    IF lo_elem EQ nil.
                      result = lo_test.
                    ELSEIF lo_elem->car->value = c_lisp_then.
                      lo_elem = lcl_lisp_new=>cons( io_car = lo_elem->cdr->car
                                                    io_cdr = lcl_lisp_new=>box_quote( lo_test ) ).
                      CONTINUE.
                      "tail_expression lo_elem.
                    ELSE.
                      "_tail_sequence.
                      IF lo_elem NE nil.
                        result = eval_list_tco( EXPORTING io_head = lo_elem
                                                          io_environment = lo_env
                                                IMPORTING eo_elem = lo_elem ).
                        "_tail_expression lo_elem.
                          IF lo_elem NE nil.
                            lo_elem = lo_elem->car.    " Tail context
                            CONTINUE.
                          ENDIF.

                      ELSEIF lo_env->top_level EQ abap_false.
                        throw( c_error_no_exp_in_body ).
                      ELSE.  " empty (begin) ?
                        CONTINUE.
                      ENDIF.

                    ENDIF.

                  WHEN 'define'.
*                   Variable definition:
*           call the set method of the current environment using the unevaluated first parameter
*           (second list element) as the symbol key and the evaluated second parameter as the value.
                    result = bind_symbol( element = lr_tail
                                          environment = lo_env ).

                  WHEN 'define-macro'.
                    result = bind_symbol( element = lr_tail
                                          environment = lo_env
                                          iv_macro = abap_true ).

                  WHEN 'define-syntax'.
                    result = define_syntax( element = lr_tail
                                            environment = lo_env ).

                  WHEN 'set!'.                        " Re-Assign symbol
                    result = assign_symbol( element     = lr_tail
                                            environment = lo_env ).

                  WHEN 'if'.
                    " _validate lr_tail->cdr. "I do not have a test case yet where it fails here
                    IF eval( element = lr_tail->car
                             environment = lo_env ) NE false.

                      lo_elem = lr_tail->cdr->car. " Tail context
                      CONTINUE.

                    ELSEIF lr_tail->cdr->cdr = nil.
                      result = lcl_lisp=>undefined.
                    ELSE.
                      "_validate lr_tail->cdr->cdr.
                        IF lr_tail->cdr->cdr IS NOT BOUND.
                          lcl_lisp=>throw( c_error_incorrect_input ).
                        ENDIF.
                      lo_elem = lr_tail->cdr->cdr->car. " Tail context
                      CONTINUE.

                    ENDIF.

                  WHEN 'begin'.
                    lo_elem = lr_tail.
*                    _tail_sequence.
                    IF lo_elem NE nil.
                      result = eval_list_tco( EXPORTING io_head = lo_elem
                                                        io_environment = lo_env
                                              IMPORTING eo_elem = lo_elem ).
                      "_tail_expression lo_elem.
                      IF lo_elem NE nil.
                        lo_elem = lo_elem->car.    " Tail context
                        CONTINUE.
                      ENDIF.

                    ELSE.  " empty (begin) ?
                      CONTINUE.
                    ENDIF.

                  WHEN 'let'.
                    lo_env = environment_named_let( EXPORTING io_env = lo_env
                                                    CHANGING co_head = lr_tail ).
                    lo_elem = lr_tail->cdr.
                    "_tail_sequence.
                  IF lo_elem NE nil.
                    result = eval_list_tco( EXPORTING io_head = lo_elem
                                                      io_environment = lo_env
                                            IMPORTING eo_elem = lo_elem ).
                    "_tail_expression lo_elem.
                      IF lo_elem NE nil.
                        lo_elem = lo_elem->car.    " Tail context
                        CONTINUE.
                      ENDIF.

                  ELSEIF lo_env->top_level EQ abap_false.
                    throw( c_error_no_exp_in_body ).
                  ELSE.  " empty (begin) ?
                    CONTINUE.
                  ENDIF.


                  WHEN 'let*'.
                    lo_env = environment_let_star( io_head = lr_tail->car
                                                   io_env = lo_env ).
                    lo_elem = lr_tail->cdr.
                    "_tail_sequence.
                      IF lo_elem NE nil.
                        result = eval_list_tco( EXPORTING io_head = lo_elem
                                                          io_environment = lo_env
                                                IMPORTING eo_elem = lo_elem ).
                        "_tail_expression lo_elem.
                          IF lo_elem NE nil.
                            lo_elem = lo_elem->car.    " Tail context
                            CONTINUE.
                          ENDIF.

                      ELSEIF lo_env->top_level EQ abap_false.
                        throw( c_error_no_exp_in_body ).
                      ELSE.  " empty (begin) ?
                        CONTINUE.
                      ENDIF.


                  WHEN 'letrec'.
*                   (letrec ((a 5) (b (+ a 3)) b)
                    lo_env = environment_letrec( io_head = lr_tail->car
                                                 io_env = lo_env ).
                    lo_elem = lr_tail->cdr.
                    "_tail_sequence.
                      IF lo_elem NE nil.
                        result = eval_list_tco( EXPORTING io_head = lo_elem
                                                          io_environment = lo_env
                                                IMPORTING eo_elem = lo_elem ).
                        "_tail_expression lo_elem.
                          IF lo_elem NE nil.
                            lo_elem = lo_elem->car.    " Tail context
                            CONTINUE.
                          ENDIF.

                      ELSEIF lo_env->top_level EQ abap_false.
                        throw( c_error_no_exp_in_body ).
                      ELSE.  " empty (begin) ?
                        CONTINUE.
                      ENDIF.

                  WHEN 'letrec*'.
                    lo_env = environment_letrec_star( io_head = lr_tail->car
                                                      io_env = lo_env ).
                    lo_elem = lr_tail->cdr.
                    "_tail_sequence.
                      IF lo_elem NE nil.
                        result = eval_list_tco( EXPORTING io_head = lo_elem
                                                          io_environment = lo_env
                                                IMPORTING eo_elem = lo_elem ).
                        "_tail_expression lo_elem.
                          IF lo_elem NE nil.
                            lo_elem = lo_elem->car.    " Tail context
                            CONTINUE.
                          ENDIF.

                      ELSEIF lo_env->top_level EQ abap_false.
                        throw( c_error_no_exp_in_body ).
                      ELSE.  " empty (begin) ?
                        CONTINUE.
                      ENDIF.

*                  WHEN 'let-values'.
*                  WHEN 'let*-values'.
*                  WHEN 'let-syntax'.
*                  WHEN 'letrec-syntax'.

                  WHEN 'parameterize'.
                    lo_env = environment_parameterize( io_env = lo_env
                                                       io_head = lr_tail ).
                    lo_elem = lr_tail->cdr.
                    "_tail_sequence.
                      IF lo_elem NE nil.
                        result = eval_list_tco( EXPORTING io_head = lo_elem
                                                          io_environment = lo_env
                                                IMPORTING eo_elem = lo_elem ).
                        "_tail_expression lo_elem.
                          IF lo_elem NE nil.
                            lo_elem = lo_elem->car.    " Tail context
                            CONTINUE.
                          ENDIF.

                      ELSEIF lo_env->top_level EQ abap_false.
                        throw( c_error_no_exp_in_body ).
                      ELSE.  " empty (begin) ?
                        CONTINUE.
                      ENDIF.

                  WHEN 'unless'.
                    result = nil.
                    IF eval( element = lr_tail->car
                             environment = lo_env ) EQ false.
                      "  _validate lr_tail->cdr. "I do not have a test case yet where it fails here
                      lo_elem = lr_tail->cdr.
                      "_tail_sequence.
                      IF lo_elem NE nil.
                        result = eval_list_tco( EXPORTING io_head = lo_elem
                                                          io_environment = lo_env
                                                IMPORTING eo_elem = lo_elem ).
                        "_tail_expression lo_elem.
                          IF lo_elem NE nil.
                            lo_elem = lo_elem->car.    " Tail context
                            CONTINUE.
                          ENDIF.

                      ELSEIF lo_env->top_level EQ abap_false.
                        throw( c_error_no_exp_in_body ).
                      ELSE.  " empty (begin) ?
                        CONTINUE.
                      ENDIF.

                    ENDIF.

                  WHEN 'when'.
                    result = nil.
                    IF eval( element = lr_tail->car
                             environment = lo_env  ) NE false.
                      "  _validate lr_tail->cdr. "I do not have a test case yet where it fails here
                      lo_elem = lr_tail->cdr.
                      "_tail_sequence.
                      IF lo_elem NE nil.
                        result = eval_list_tco( EXPORTING io_head = lo_elem
                                                          io_environment = lo_env
                                                IMPORTING eo_elem = lo_elem ).
                        "_tail_expression lo_elem.
                          IF lo_elem NE nil.
                            lo_elem = lo_elem->car.    " Tail context
                            CONTINUE.
                          ENDIF.

                      ELSEIF lo_env->top_level EQ abap_false.
                        throw( c_error_no_exp_in_body ).
                      ELSE.  " empty (begin) ?
                        CONTINUE.
                      ENDIF.

                    ENDIF.

                  WHEN 'lambda'.
                    result = lcl_lisp_new=>lambda( io_car = lr_tail->car         " List of parameters
                                                   io_cdr = lr_tail->cdr         " Body
                                                   io_env = lo_env ).

                  WHEN 'case-lambda'.
                    DATA lt_clauses TYPE tt_lisp.
                    "_validate lr_tail.
                    IF lr_tail IS NOT BOUND.
                      lcl_lisp=>throw( c_error_incorrect_input ).
                    ENDIF.

                    CLEAR lt_clauses.
                    lo_clause = lr_tail.
                    WHILE lo_clause->type = lcl_lisp=>type_pair.
                      lr_tail = lo_clause->car.
                      lo_ptr = lcl_lisp_new=>lambda( io_car = lr_tail->car         " List of parameters
                                                     io_cdr = lr_tail->cdr         " Body
                                                     io_env = lo_env ).
                      APPEND lo_ptr TO lt_clauses.
                      lo_clause = lo_clause->cdr.
                    ENDWHILE.
                    IF lo_clause NE nil.
                      throw( `Invalid case-lambda clause` ).
                    ENDIF.
                    result = lcl_lisp_new=>case_lambda( lt_clauses ).

*(do ((<variable1> <init1> <step1>) ... ) <-- iteration spec
*     (<test> <do result> ... )           <-- tail sequence
*     <command> ... )
* Example:
*   (do ((vec (make-vector 5) )
*         (i 0 (+ i 1) ) )
*         ((= i 5) vec)
*       (vector-set! vec i i))  => #(0 1 2 3 4)
* A do expression is an iteration construct. It specifies a set of variables to be bound,
* how they are to be initialized at the start, and how they are to be updated on each iteration.
* When a termination condition is met, the loop exits after evaluating the <expression>s.
                  WHEN 'do'.
                    DATA(lo_head) = lr_tail.
                    "_validate: lo_head, lo_head->cdr, lo_head->cdr->cdr.
                    IF lo_head IS NOT BOUND OR lo_head->cdr IS NOT BOUND OR lo_head->cdr->cdr IS NOT BOUND.
                      lcl_lisp=>throw( c_error_incorrect_input ).
                    ENDIF.

*                   Initialization
                    eval_do_init( EXPORTING io_head = lo_head->car
                                            io_env = lo_env
                                  IMPORTING eo_step = DATA(lo_steps)
                                            eo_env = lo_env ).
*                   Iteration
                    lo_test = lo_head->cdr->car.
                    DATA(lo_command) = lo_head->cdr->cdr.

                    DO.
*                     evaluate <test>;
                      CASE eval_ast( element = lo_test->car
                                     environment = lo_env ).
                        WHEN false.
                          eval_do_step( io_command = lo_command
                                        io_steps = lo_steps
                                        io_env = lo_env ).
*                         and the next iteration begins.

                        WHEN OTHERS. " <test> evaluates to a true value
* <expression>s are evaluated from left to right and the values of the last <expression> are returned.
* If no <expression>s are present, then the value of the do expression is unspecified.

                          lo_elem = lo_test->cdr.
                          result = nil.
                          EXIT.
                      ENDCASE.

                    ENDDO.

                    IF lo_elem EQ nil.
                      result = nil.
                    ELSE.
                      "_tail_sequence.
                      IF lo_elem NE nil.
                        result = eval_list_tco( EXPORTING io_head = lo_elem
                                                          io_environment = lo_env
                                                IMPORTING eo_elem = lo_elem ).
                        "_tail_expression lo_elem.
                          IF lo_elem NE nil.
                            lo_elem = lo_elem->car.    " Tail context
                            CONTINUE.
                          ENDIF.

                      ELSEIF lo_env->top_level EQ abap_false.
                        throw( c_error_no_exp_in_body ).
                      ELSE.  " empty (begin) ?
                        CONTINUE.
                      ENDIF.

                    ENDIF.

                  WHEN 'case'.
* (case <key> <clause1> <clause2> <clause3> ... )
* <key> can be any expression. Each <clause> has the form ((<datum1> ...) <expression1> <expression2> ...)
* It is an error if any of the <datum> are the same anywhere in the expression
* Alternatively, a <clause> can be of the form  ((<datum1> ...) => <expression1> )
* The last <clause> can be an "else clause" which has one of the forms
*  (else <expression1> <expression2> ... )
*  or
*  (else => <expression>).
                    "_validate lr_tail.
                    IF lr_tail IS NOT BOUND.
                      lcl_lisp=>throw( c_error_incorrect_input ).
                    ENDIF.

                    result = nil.

                    DATA(lo_key) = eval( element = lr_tail->car
                                         environment = lo_env ).

                    lr_tail = lr_tail->cdr.
                    "_validate: lr_tail, lr_tail->car, lo_key.
                    IF lr_tail IS NOT BOUND OR lr_tail->car IS NOT BOUND OR lo_key IS NOT BOUND.
                      lcl_lisp=>throw( c_error_incorrect_input ).
                    ENDIF.

                    IF lr_tail EQ nil.
                      throw( `case: no clause` ).
                    ENDIF.

                    lo_elem = nil.
                    DATA(lv_match) = abap_false.
                    WHILE lr_tail->type EQ lcl_lisp=>type_pair AND lv_match EQ abap_false.
                      lo_clause = lr_tail->car.

                      DATA(lo_datum) = lo_clause->car.
                      "_validate lo_datum.
                        IF lo_datum IS NOT BOUND.
                          lcl_lisp=>throw( c_error_incorrect_input ).
                        ENDIF.

                      WHILE lo_datum NE nil.

                        IF lo_datum->value EQ c_lisp_else.
                          IF lr_tail->cdr NE nil.
                            throw( `case: else must be the last clause` ).
                          ENDIF.
                          lo_elem = lo_clause->cdr.
                          lv_match = abap_true.
                          EXIT.
                        ENDIF.

                        " eqv? match
                        IF lo_key->is_equivalent( lo_datum->car ) NE false.
                          lo_elem = lo_clause->cdr.
                          lv_match = abap_true.
                          EXIT.
                        ENDIF.

                        lo_datum = lo_datum->cdr.
                      ENDWHILE.

                      lr_tail = lr_tail->cdr.
                    ENDWHILE.

                    IF lo_elem EQ nil.
                      result = nil.

                    ELSEIF lo_elem->car->value = c_lisp_then.

                      lo_elem = lcl_lisp_new=>cons(
                        io_car = lo_elem->cdr->car
                        io_cdr = lcl_lisp_new=>box_quote( lo_key ) ).
                      CONTINUE.
                      "tail_expression lo_elem.

                    ELSE.

                      "_tail_sequence.
                      IF lo_elem NE nil.
                        result = eval_list_tco( EXPORTING io_head = lo_elem
                                                          io_environment = lo_env
                                                IMPORTING eo_elem = lo_elem ).
                        "_tail_expression lo_elem.
                          IF lo_elem NE nil.
                            lo_elem = lo_elem->car.    " Tail context
                            CONTINUE.
                          ENDIF.

                      ELSEIF lo_env->top_level EQ abap_false.
                        throw( c_error_no_exp_in_body ).
                      ELSE.  " empty (begin) ?
                        CONTINUE.
                      ENDIF.

                    ENDIF.

                  WHEN 'for-each'.
                    result = expand_for_each( io_list = lr_tail
                                              environment = lo_env ).

                  WHEN 'map'.
                    result = expand_map( io_list = lr_tail
                                         environment = lo_env ).

                  WHEN 'apply'.
                    " (apply proc arg1 ... argn rest-args)
                    lo_elem = lcl_lisp_new=>cons( io_car = expand_apply( io_list = lr_tail
                                                                         environment = lo_env ) ).
                    "_tail_expression lo_elem.
                    IF lo_elem NE nil.
                      lo_elem = lo_elem->car.    " Tail context
                      CONTINUE.
                    ENDIF.

                  WHEN 'macroexpand'.
*                   for debugging
                    "_validate lr_tail->car.
                    IF lr_tail->car IS NOT BOUND.
                      lcl_lisp=>throw( c_error_incorrect_input ).
                    ENDIF.
                    result = syntax_expand( element = lr_tail->car
                                            environment = lo_env ).

                  WHEN 'gensym'.
                    result = generate_symbol( lr_tail ).

                  WHEN c_eval_unquote
                    OR c_eval_unquote_splicing.
                    throw( |{ lr_head->value } not valid outside of quasiquote| ).

*                  WHEN 'error'.

                  WHEN OTHERS.

*                   EXECUTE PROCEDURE (native or lambda)
*                   Take the first item of the evaluated list and call it as function
*                   using the rest of the evaluated list as its arguments.

*                   The evaluated head must be a native procedure or a lambda or an ABAP function module
                    DATA(lo_proc) = eval_ast( element = lr_head             " proc
                                              environment = lo_env ).
                    "_trace_call lo_proc lr_tail.
                    IF gv_lisp_trace EQ abap_true.
                      go_out->write( |call { lo_proc->value } { lo_proc->to_string( ) } param { lr_tail->to_string( ) }| ).
                    ENDIF.

                    CASE lo_proc->type.

                      WHEN lcl_lisp=>type_lambda.
                        lo_env = lambda_environment( io_head = lo_proc
                                                     io_args = lr_tail
                                                     environment = lo_env ).
                        lo_elem = lo_proc->cdr.
                        "_tail_sequence.
                      IF lo_elem NE nil.
                        result = eval_list_tco( EXPORTING io_head = lo_elem
                                                          io_environment = lo_env
                                                IMPORTING eo_elem = lo_elem ).
                        "_tail_expression lo_elem.
                          IF lo_elem NE nil.
                            lo_elem = lo_elem->car.    " Tail context
                            CONTINUE.
                          ENDIF.

                      ELSEIF lo_env->top_level EQ abap_false.
                        throw( c_error_no_exp_in_body ).
                      ELSE.  " empty (begin) ?
                        CONTINUE.
                      ENDIF.

                      WHEN lcl_lisp=>type_native.
*                       Evaluate native function:
                        CALL METHOD (lo_proc->value)
                          EXPORTING
                            list   = evaluate_parameters( io_list = lr_tail
                                                          environment = lo_env )
                          RECEIVING
                            result = result.

                      WHEN lcl_lisp=>type_primitive OR lcl_lisp=>type_syntax.
                        lo_elem = lcl_lisp_new=>cons( io_car = lo_proc
                                                      io_cdr = lr_tail ).
                        CONTINUE. "tail_expression lo_elem.

                      WHEN lcl_lisp=>type_abap_function.
*              >> TEST: Support evaluation of ABAP function directly
*  Recompose as if calling a PROC (which we are). This is part of the test. If we make an ABAP function call
*  first-class, then we would need to revisit evaluating the whole of ELEMENT in one shot
*                        result = proc_abap_function_call( lcl_lisp_new=>cons( io_car = lo_proc
*                                                                              io_cdr = lr_tail ) ).
                         throw( |Function calls not supported in SAP Cloud ABAP environment| ).
*              << TEST
*                      WHEN lcl_lisp=>type_abap_method.
*              >> TEST: Support evaluation of ABAP methods directly
*              << TEST

                      WHEN lcl_lisp=>type_case_lambda.
                        DATA lo_case TYPE REF TO lcl_lisp_case_lambda.
                        lo_case ?= lo_proc.
                        lo_proc = lo_case->match( lr_tail ).
                        lo_env = lambda_environment( io_head = lo_proc
                                                     io_args = lr_tail
                                                     environment = lo_env ).
                        lo_elem = lo_proc->cdr.
                        "_tail_sequence.
                      IF lo_elem NE nil.
                        result = eval_list_tco( EXPORTING io_head = lo_elem
                                                          io_environment = lo_env
                                                IMPORTING eo_elem = lo_elem ).
                        "_tail_expression lo_elem.
                          IF lo_elem NE nil.
                            lo_elem = lo_elem->car.    " Tail context
                            CONTINUE.
                          ENDIF.

                      ELSEIF lo_env->top_level EQ abap_false.
                        throw( c_error_no_exp_in_body ).
                      ELSE.  " empty (begin) ?
                        CONTINUE.
                      ENDIF.

                      WHEN OTHERS.
                        throw( |attempt to apply { lo_proc->to_string( ) } - not a procedure| ).

                    ENDCASE.

                ENDCASE.

              WHEN OTHERS.
                result = eval_ast( element = lo_elem
                                   environment = lo_env ).

            ENDCASE.

        ENDCASE.
*       Circular references
        result->set_shared_structure( ).
        "_trace_result result.
        IF gv_lisp_trace EQ abap_true.
          go_out->write( |=> { result->to_string( ) }| ).
        ENDIF.

        RETURN.

      ENDDO.
    ENDMETHOD.

    METHOD write.
      "_optional_port_arg output `write`.
      DATA li_port TYPE REF TO lif_output_port.

      TRY.
          IF io_arg->type EQ lcl_lisp=>type_pair.
            "_validate_port io_arg->car `write`.
            IF io_arg->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            IF io_arg->car->type NE lcl_lisp=>type_port.
              throw( io_arg->car->to_string( ) && ` is not a port in write` ) ##NO_TEXT.
            ENDIF.

            li_port ?= io_arg->car.
          ELSE.
            li_port ?= proc_current_output_port( nil ).
          ENDIF.
        CATCH cx_root INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.

      li_port->write( io_elem ).
      result = io_elem.
    ENDMETHOD.

    METHOD display.
      "_optional_port_arg output `display`.
      DATA li_port TYPE REF TO lif_output_port.

      TRY.
          IF io_arg->type EQ lcl_lisp=>type_pair.
            "_validate_port io_arg->car `display`.
            IF io_arg->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            IF io_arg->car->type NE lcl_lisp=>type_port.
              throw( io_arg->car->to_string( ) && ` is not a port in display` ) ##NO_TEXT.
            ENDIF.

            li_port ?= io_arg->car.
          ELSE.
            li_port ?= proc_current_output_port( nil ).
          ENDIF.
        CATCH cx_root INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.

      li_port->display( io_elem ).
      result = io_elem.
    ENDMETHOD.

    METHOD read.
      "_optional_port_arg input `read`.
      DATA li_port TYPE REF TO lif_input_port.

      TRY.
          IF io_arg->type EQ lcl_lisp=>type_pair.
            "_validate_port io_arg->car `read`.
            IF io_arg->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            IF io_arg->car->type NE lcl_lisp=>type_port.
              throw( io_arg->car->to_string( ) && ` is not a port in read` ) ##NO_TEXT.
            ENDIF.

            li_port ?= io_arg->car.
          ELSE.
            li_port ?= proc_current_input_port( nil ).
          ENDIF.
        CATCH cx_root INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.

      result = read_from( li_port ).
    ENDMETHOD.

    METHOD read_char.
      "_optional_port_arg input `read-char`.
      DATA li_port TYPE REF TO lif_input_port.

      TRY.
          IF io_arg->type EQ lcl_lisp=>type_pair.
            "_validate_port io_arg->car `read-char`.
            IF io_arg->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            IF io_arg->car->type NE lcl_lisp=>type_port.
              throw( io_arg->car->to_string( ) && ` is not a port in read-char` ) ##NO_TEXT.
            ENDIF.

            li_port ?= io_arg->car.
          ELSE.
            li_port ?= proc_current_input_port( nil ).
          ENDIF.
        CATCH cx_root INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.

      result = lcl_lisp_new=>char( li_port->read_char( ) ).
    ENDMETHOD.

    METHOD read_string.
      DATA k TYPE tv_index.
      DATA lv_input TYPE string.
      DATA lv_char TYPE tv_char.
      DATA li_port TYPE REF TO lif_input_port.

      "_validate io_arg.
        IF io_arg IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      "_validate_integer io_arg->car `read-string`.
        "_validate io_arg->car.
        IF io_arg->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        IF io_arg->type NE lcl_lisp=>type_integer.
          throw( io_arg->to_string( ) && ` is not an integer in read-string` ) ##NO_TEXT.
        ENDIF.

      k = CAST lcl_lisp_integer( io_arg->car )->integer.

      IF io_arg->cdr->type EQ lcl_lisp=>type_pair.
        "_validate_port io_arg->cdr->car `read-string`.
        IF io_arg->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF io_arg->cdr->car->type NE lcl_lisp=>type_port.
          throw( io_arg->cdr->car->to_string( ) && ` is not a port in read-string` ) ##NO_TEXT.
        ENDIF.

        li_port ?= io_arg->cdr->car.
      ELSE.
        li_port ?= proc_current_input_port( nil ).
      ENDIF.

      DO k TIMES.
        IF li_port->is_char_ready( ).
          lv_char = li_port->read_char( ).
          CONCATENATE lv_input lv_char INTO lv_input RESPECTING BLANKS.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
      result = lcl_lisp_new=>string( lv_input ).
    ENDMETHOD.

    METHOD eval_source.
      TRY.
          response = eval_repl( code ).
        CATCH cx_root INTO DATA(lx_root).
          response = lx_root->get_text( ).
      ENDTRY.
    ENDMETHOD.                    "eval_source

    METHOD eval_repl.
      LOOP AT parse( code ) INTO DATA(lo_element).
        DATA(lo_result) = eval( element = lo_element
                                environment = env ).
        gi_log->put( lo_result ).
      ENDLOOP.
      output = lo_result->to_text( ).
      response = gi_log->get( ).
    ENDMETHOD.

    METHOD validate_source.
      TRY.
          LOOP AT parse( code ) INTO DATA(lo_element).
            gi_log->put( lo_element ).
          ENDLOOP.
          response = gi_log->get( ).
        CATCH cx_root INTO DATA(lx_root).
          response = lx_root->get_text( ).
      ENDTRY.
    ENDMETHOD.

**********************************************************************
* NATIVE PROCEDURES
**********************************************************************
    METHOD proc_append.
*     Creates a new list appending all parameters
*     All parameters except the last must be lists, the last must be a cons cell.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

*     No arguments: return nil
      result = list.
      CHECK list NE nil.

*     One argument: return argument
      result = list->car.

      CHECK list->cdr NE nil.

      DATA(lo_iter) = list->new_iterator( ).
      WHILE lo_iter->has_next( ).

*       copy first list, reassign result
        DATA(first) = lo_iter->next( ).
        CHECK first NE nil.

        IF first->type = lcl_lisp=>type_pair.
          result = lcl_lisp_new=>cons( io_car = first->car ).

*         TO DO: Test for circular list! ------------------------------
          DATA(lo_last) = result.
          DATA(lo_arg) = first->cdr.
          WHILE lo_arg->type = lcl_lisp=>type_pair.
            lo_last = lo_last->cdr = lcl_lisp_new=>cons( io_car = lo_arg->car ).
            lo_arg = lo_arg->cdr.
          ENDWHILE.

          IF lo_arg NE nil.
            lo_last = lo_last->cdr = lo_arg.
          ENDIF.

        ELSE.

          lo_arg = result = first.
        ENDIF.

        EXIT.
      ENDWHILE.

*     Append next list
      WHILE lo_iter->has_next( ).

        "_validate_tail lo_arg first `append`.
        IF lo_arg NE nil.
*         if the last element in the list is not a cons cell, we cannot append
          throw( |append: { first->to_string( ) } is not a proper list| ) ##NO_TEXT.
        ENDIF.

        first = lo_arg = lo_iter->next( ).
        CHECK first NE nil.

*       TO DO: Check for circular list
*       Append lo_arg to result, from last element on
        WHILE lo_arg->type = lcl_lisp=>type_pair.
          lo_last = lo_last->cdr = lcl_lisp_new=>cons( io_car = lo_arg->car ).
          lo_arg = lo_arg->cdr.
        ENDWHILE.

        CHECK lo_arg NE nil.
        lo_last = lo_last->cdr = lo_arg.

      ENDWHILE.

    ENDMETHOD.

    METHOD list_reverse.
      "_validate io_list.
        IF io_list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      result = nil.
      DATA(lo_ptr) = io_list.

*     TO DO: check if circular lists are allowed
      WHILE lo_ptr->type EQ lcl_lisp=>type_pair.
        result = lcl_lisp_new=>cons( io_car = lo_ptr->car
                                     io_cdr = result ).
        lo_ptr = lo_ptr->cdr.
      ENDWHILE.
    ENDMETHOD.

    METHOD proc_reverse.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = list_reverse( list->car ).
    ENDMETHOD.                    "proc_reverse

    METHOD table_of_lists.
      "_validate io_head.
        IF io_head IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      CLEAR rt_table.
      CHECK io_head NE nil.

*     build internal table of list interators
      DATA(iter) = io_head->new_iterator( ).
      WHILE iter->has_next( ).
*       Evaluate next list entry
        DATA(lo_next) = eval( element = iter->next( )
                              environment = environment ).
        IF lo_next = nil.  " if any list is empty, the table is empty
          CLEAR rt_table.
          RETURN.
        ENDIF.
        APPEND lo_next TO rt_table.
      ENDWHILE.
    ENDMETHOD.

    METHOD map_next_expr.
*     determine expression (proc list1[k] list2[k]... listn[k])
      ev_has_next = abap_true.

      DATA(lo_next) = lcl_lisp_new=>cons( io_car = io_proc ).
      result = lo_next.
      LOOP AT ct_list ASSIGNING FIELD-SYMBOL(<lo_list>).
        IF <lo_list> EQ nil.
          ev_has_next = abap_false.
          result = nil.
          RETURN.
        ELSE.
*         Parameters are already evaluated, use special form to avoid repeated evaluation
          lo_next = lo_next->cdr = lcl_lisp_new=>box_quote( <lo_list>->car ).
          <lo_list> = <lo_list>->cdr.
        ENDIF.
        CHECK <lo_list> EQ nil.
        ev_has_next = abap_false.
      ENDLOOP.
    ENDMETHOD.

    METHOD proc_append_unsafe.  " append! (non functional)
*     Takes two parameters: the first must be a list, and the second can
*     be of any type. Appends the second param to the first.

*     But if the last element in the list is not a cons cell, we cannot append
      "_validate: list, list->car, list->cdr.
       IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
         lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      IF list->car EQ nil.
        result = list->cdr->car.
      ELSE.
*       Get to last element in list - this can make APPEND expensive, like LENGTH
        DATA(lo_last) = list->car.
        IF lo_last->type NE lcl_lisp=>type_pair.
          "_error_no_list list `append!`.
          throw( |append: { list->to_string( ) } is not a proper list| ) ##NO_TEXT.
        ENDIF.

        WHILE lo_last->cdr IS BOUND AND lo_last->cdr NE nil.
          lo_last = lo_last->cdr.
        ENDWHILE.

        "TO DO - replace with _validate_tail lo_last (?) list->car.
        IF lo_last->type NE lcl_lisp=>type_pair.
*         If the last item is not a cons cell, return an error
          "_error_no_list list->car  `append!`.
           throw( |append: { list->car->to_string( ) } is not a proper list| ) ##NO_TEXT.
        ENDIF.

*       Last item is a cons cell; tack on the new value
        lo_last->cdr = list->cdr->car.
        result = list->car.
      ENDIF.
    ENDMETHOD.                    "proc_append_unsafe

    METHOD proc_car.
      "_validate: list, list->car.
        IF list IS NOT BOUND OR list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      DATA(lo_arg) = list->car.
      "_validate_pair lo_arg `car: `.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `car: ` ).
      ENDIF.
      result = lo_arg->car.
    ENDMETHOD.                    "proc_car

    METHOD proc_set_car.
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      DATA(lo_arg) = list->car.
      "_validate_pair lo_arg `set-car!: `.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `set-car!: ` ).
      ENDIF.
      "_validate_mutable lo_arg `list in set-car!`.
        IF lo_arg IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF lo_arg->mutable EQ abap_false.
          throw( |constant list in set-car! cannot be changed| ) ##NO_TEXT.
        ENDIF.

      lo_arg->car = list->cdr->car.
      result = nil.
    ENDMETHOD.                    "proc_car

    METHOD proc_set_cdr.
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      DATA(lo_arg) = list->car.
      "_validate_pair lo_arg `set-cdr!: `.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `set-cdr!: ` ).
      ENDIF.
      "_validate_mutable lo_arg `list in set-cdr!`.
        IF lo_arg IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF lo_arg->mutable EQ abap_false.
          throw( |constant list in set-cdr! cannot be changed| ) ##NO_TEXT.
        ENDIF.

      lo_arg->cdr = list->cdr->car.
      result = nil.
    ENDMETHOD.

    METHOD proc_cdr.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      DATA(lo_arg) = list->car.
      "_validate_pair lo_arg `cdr: `.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdr: ` ).
      ENDIF.
      result = lo_arg->cdr.
    ENDMETHOD.                    "proc_cdr

    METHOD proc_cons.
*     Create new cell and prepend it to second parameter
      "_validate: list, list->car, list->cdr.
       IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      IF list->cdr->cdr NE nil.
        throw( `cons: only 2 arguments allowed` ).
      ENDIF.

      result = lcl_lisp_new=>cons( io_car = list->car
                                   io_cdr = list->cdr->car ).
    ENDMETHOD.                    "proc_cons

    METHOD proc_not.
*     Create new cell and prepend it to second parameter
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->car EQ false.
        result = true.
      ELSE.
        result = false.
      ENDIF.
    ENDMETHOD.                    "proc_cons

    METHOD proc_caar.
      "_execute_cxxr `caar: ` car car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `caar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caar: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.                    "proc_caar

    METHOD proc_cadr.
      "_execute_cxxr `cadr: ` cdr car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cadr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadr: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.                    "proc_cadr

    METHOD proc_cdar.
      "_execute_cxxr `cdar: ` car cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cdar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdar: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.                    "proc_cdar

    METHOD proc_cddr.
      "_execute_cxxr `cddr: ` cdr cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cddr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddr: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.                    "proc_cddr

    METHOD proc_caaar.
      "_execute_cx3r `caaar: ` car car car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `caaar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaar: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.

    METHOD proc_cdaar.
      "_execute_cx3r `cdaar: ` car car cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cdaar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaar: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.

    METHOD proc_caadr.
      "_execute_cx3r `caadr: ` cdr car car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `caadr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caadr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caadr: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caadr: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.

    METHOD proc_cdadr.
      "_execute_cx3r `cdadr: ` cdr car cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cdadr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdadr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdadr: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdadr: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.

    METHOD proc_cadar.
      "_execute_cx3r `cadar: ` car cdr car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cadar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadar: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadar: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.

    METHOD proc_cddar.
      "_execute_cx3r `cddar: ` car cdr cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cddar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddar: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddar: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.

    METHOD proc_caddr.
      "_execute_cx3r `caddr: ` cdr cdr car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `caddr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caddr: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.

    METHOD proc_cdddr.
      "_execute_cx3r `cdddr: ` cdr cdr cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cdddr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdddr: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.

    METHOD proc_caaaar.
      "_execute_cx4r `caaaar: ` car car car car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `caaaar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaaar: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.

    METHOD proc_cdaaar.
      "_execute_cx4r `cdaaar: ` car car car cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cdaaar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaaar: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.

    METHOD proc_cadaar.
      "_execute_cx4r `cadaar: ` car car cdr car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cadaar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadaar: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadaar: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.

    METHOD proc_cddaar.
      "_execute_cx4r `cddaar: ` car car cdr cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cddaar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddaar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddaar: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddaar: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.

    METHOD proc_caaadr.
      "_execute_cx4r `caaadr: ` cdr car car car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `caaadr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaadr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaadr: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaadr: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaadr: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.

    METHOD proc_cdaadr.
      "_execute_cx4r `cdaadr: ` cdr car car cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cdaadr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaadr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaadr: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaadr: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaadr: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.

    METHOD proc_cadadr.
      "_execute_cx4r `cadadr: ` cdr car cdr car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cadadr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadadr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadadr: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadadr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadadr: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.

    METHOD proc_cddadr.
      "_execute_cx4r `cddadr: ` cdr car cdr cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cddadr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddadr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddadr: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddadr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddadr: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.

    METHOD proc_caadar.
      "_execute_cx4r `caadar: ` car cdr car car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cddadr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddadr: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddadr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddadr: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddadr: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.

    METHOD proc_cdadar.
      "_execute_cx4r `cdadar: ` car cdr car cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cdadar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdadar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdadar: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdadar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdadar: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.

    METHOD proc_caddar.
      "_execute_cx4r `caddar: ` car cdr cdr car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `caddar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caddar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caddar: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caddar: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caddar: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.

    METHOD proc_cdddar.
      "_execute_cx4r `cdddar: ` car cdr cdr cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cdddar: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdddar: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdddar: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdddar: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdddar: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.

    METHOD proc_caaddr.
      "_execute_cx4r `caaddr: ` cdr cdr car car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `caaddr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaddr: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `caaddr: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.

    METHOD proc_cdaddr.
      "_execute_cx4r `cdaddr: ` cdr cdr car cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cdaddr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaddr: ` ).
      ENDIF.

      lo_arg = lo_arg->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cdaddr: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.

    METHOD proc_cadddr.
      "_execute_cx4r `cadddr: ` cdr cdr cdr car.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cadddr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cadddr: ` ).
      ENDIF.

      result = lo_arg->car.
    ENDMETHOD.

    METHOD proc_cddddr.
      "_execute_cx4r `cddddr: ` cdr cdr cdr cdr.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->type NE lcl_lisp=>type_pair.
        list->error_not_a_pair( `cddddr: ` ).
      ENDIF.

      DATA(lo_arg) = list->car.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddddr: ` ).
      ENDIF.

      lo_arg = lo_arg->cdr.
      IF lo_arg->type NE lcl_lisp=>type_pair.
        lo_arg->error_not_a_pair( `cddddr: ` ).
      ENDIF.

      result = lo_arg->cdr.
    ENDMETHOD.

    METHOD list_length.
      DATA lo_fast TYPE REF TO lcl_lisp.
      DATA lo_slow TYPE REF TO lcl_lisp.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = 0.
      lo_slow = lo_fast = list.
*     Iterate over list
      WHILE lo_fast->type EQ lcl_lisp=>type_pair.
        result += 1.  " count the number of items
        lo_fast = lo_fast->cdr.
        lo_slow = lo_slow->cdr.

        CHECK lo_fast->type EQ lcl_lisp=>type_pair.
        result += 1.  " count the number of items (using the fast pointer)
        lo_fast = lo_fast->cdr.

        CHECK lo_fast = lo_slow.           " are we stuck in a circular list?
*       If we are stuck in a circular list, then the fast pointer will eventually
*       be equal to the slow pointer. That fact justifies this implementation.
        RETURN.
      ENDWHILE.
      CHECK lo_fast NE nil.
*     If the last item is not a cons cell, return an error
      "_error_no_list list `list-length`.
       throw( |list-length: { list->to_string( ) } is not a proper list| ) ##NO_TEXT.
    ENDMETHOD.

    METHOD proc_length.
      "_validate: list, list->car, list->cdr.
       IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      IF list->cdr NE nil.
        throw( |length takes only one argument| ).
      ENDIF.

      result = lcl_lisp_new=>integer( list_length( list->car ) ).
    ENDMETHOD.                    "proc_length

    METHOD proc_list_copy.
      DATA lo_slow TYPE REF TO lcl_lisp.
      DATA lo_ptr TYPE REF TO lcl_lisp.
      DATA lo_new TYPE REF TO lcl_lisp.

      "_validate: list, list->cdr.
       IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      IF list->cdr NE nil.
        throw( |list-copy takes only one argument| ).
      ENDIF.

      "_validate list->car.
       IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      result = list->car.
      CHECK result->type EQ lcl_lisp=>type_pair.

      lo_slow = lo_ptr = result->cdr.
      result = lo_new = lcl_lisp_new=>cons( io_car = result->car ).

*     Iterate over list to count the number of items
      WHILE lo_ptr->type EQ lcl_lisp=>type_pair.
        lo_new = lo_new->cdr = lcl_lisp_new=>cons( io_car = lo_ptr->car ).
        lo_ptr = lo_ptr->cdr.
        lo_slow = lo_slow->cdr.
        CHECK lo_ptr->type EQ lcl_lisp=>type_pair.
        lo_new = lo_new->cdr = lcl_lisp_new=>cons( io_car = lo_ptr->car ).
        lo_ptr = lo_ptr->cdr.
        CHECK lo_ptr = lo_slow.
        throw( |list-copy: circular list| ).
      ENDWHILE.
      lo_new->cdr = lo_ptr.
    ENDMETHOD.                    "proc_length

    METHOD proc_list.
*     The items given to us are already in a list and evaluated; we just need to return the head
      result = list.
    ENDMETHOD.                    "proc_list

    METHOD proc_nilp.
      "_validate: list, list->car.
       IF list IS NOT BOUND OR list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      result = COND #( WHEN list->car = nil THEN true ELSE false ).
    ENDMETHOD.                    "proc_nilp

    METHOD proc_make_list.
      DATA k TYPE tv_int.
*     returns a list of length k and every atom is the default fill value supplied or the empty list
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_index list->car 'make-list'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in make-list` ) ##NO_TEXT.
        ENDIF.
        IF CAST lcl_lisp_integer( list->car )->integer LT 0.
          throw( list->car->to_string( ) && ` must be non-negative in make-list` ) ##NO_TEXT.
        ENDIF.

      result = lcl_lisp=>nil.

      k = CAST lcl_lisp_integer( list->car )->integer.
      CHECK k GT 0.

      IF list->cdr EQ nil.
        DATA(lo_default) = nil.
      ELSE.
        lo_default = list->cdr->car.
      ENDIF.

      result = lcl_lisp_new=>cons( io_car = lo_default ).  " first
      DATA(lo_ptr) = result.

      DO k - 1 TIMES.
        lo_ptr = lo_ptr->cdr = lcl_lisp_new=>cons( io_car = lo_default ).
      ENDDO.
    ENDMETHOD.

    METHOD proc_list_tail.
      "_validate: list, list->cdr.
        IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
      "_validate_index list->cdr->car 'list-tail'.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in list-tail` ) ##NO_TEXT.
        ENDIF.
        IF CAST lcl_lisp_integer( list->cdr->car )->integer LT 0.
          throw( list->cdr->car->to_string( ) && ` must be non-negative in list-tail` ) ##NO_TEXT.
        ENDIF.

      result = list_tail( list = list->car
                          k  = CAST lcl_lisp_integer( list->cdr->car )->integer
                          area = 'list-tail' ).
    ENDMETHOD.

    METHOD list_tail.
*     (list-tail list k) procedure
*     List should be a list of size at least k.  The list-tail procedure returns the subchain
*     of list obtained by omitting the first k elements:  (list-tail '(a b c d) 2)  => (c d)
*
*     we must check that list is a chain of pairs whose length is at least k.
*     we should not check that it is a list of pairs beyond this length.

      "_validate: list, list->cdr.
       IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.


      result = list.
      DO k TIMES.
        IF result->type NE lcl_lisp=>type_pair.
          throw( area && `: list too short` ).
        ENDIF.
        result = result->cdr.
        CHECK result IS NOT BOUND.
        throw( area && |: an entry before index { k } is not a pair| ).
      ENDDO.
    ENDMETHOD.

    METHOD proc_iota.
      DATA lv_count TYPE tv_int.
      DATA lv_start TYPE tv_int VALUE 0.
      DATA lv_step TYPE tv_int VALUE 1.
      DATA lo_ptr TYPE REF TO lcl_lisp.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.


      DATA(lo_count) = list->car.
      "_validate_index lo_count 'iota count'.
        IF lo_count IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF lo_count->type NE lcl_lisp=>type_integer.
          throw( lo_count->to_string( ) && ` is not an integer in iota count` ) ##NO_TEXT.
        ENDIF.
        IF CAST lcl_lisp_integer( lo_count )->integer LT 0.
          throw( lo_count->to_string( ) && ` must be non-negative in iota count` ) ##NO_TEXT.
        ENDIF.
       lv_count = CAST lcl_lisp_integer( lo_count )->integer.

      result = nil.
      CHECK lv_count GT 0.

      "_validate list->cdr.
        IF list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
      IF list->cdr NE nil.
        DATA(lo_start) = list->cdr->car.
        "_validate_integer lo_start 'iota start'.
        "_validate lo_start.
        IF lo_start IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        IF lo_start->type NE lcl_lisp=>type_integer.
          throw( lo_start->to_string( ) && ` is not an integer in iota start` ) ##NO_TEXT.
        ENDIF.

         lv_start = CAST lcl_lisp_integer( lo_start )->integer.

        "_validate list->cdr->cdr.
        IF list->cdr->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        IF list->cdr->cdr NE nil.
          DATA(lo_step) = list->cdr->cdr->car.
          "_validate_integer lo_step 'iota step'.
        "_validate lo_step.
           IF lo_step IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
           ENDIF.

        IF lo_step->type NE lcl_lisp=>type_integer.
          throw( lo_step->to_string( ) && ` is not an integer in iota step` ) ##NO_TEXT.
        ENDIF.

          lv_step = CAST lcl_lisp_integer( lo_step )->integer.
        ENDIF.
      ENDIF.

      result = lo_ptr = lcl_lisp_new=>cons( io_car = lcl_lisp_new=>integer( lv_start ) ).

      DO lv_count - 1 TIMES.
        lv_start += lv_step.
        lo_ptr = lo_ptr->cdr = lcl_lisp_new=>cons( io_car = lcl_lisp_new=>integer( lv_start ) ).
      ENDDO.
    ENDMETHOD.

*(car list-tail list k)
    METHOD proc_list_ref.
*    (list-ref list k) procedure
*    List must be a list whose length is at least k + 1.  The list-ref procedure returns the kth element of list.
*    (list-ref '(a b c d) 2) => c
*
*    The implementation must check that list is a chain of pairs whose length is at least k + 1.
*    It should not check that it is a list of pairs beyond this length.

      "_validate: list, list->cdr.
        IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
      "_validate_index list->cdr->car 'list-ref'.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in list-ref` ) ##NO_TEXT.
        ENDIF.
        IF CAST lcl_lisp_integer( list->cdr->car )->integer LT 0.
          throw( list->cdr->car->to_string( ) && ` must be non-negative in list-ref` ) ##NO_TEXT.
        ENDIF.

      result = list_tail( list = list->car
                          k = CAST lcl_lisp_integer( list->cdr->car )->integer
                          area = 'list-ref' ).
      result = result->car.
    ENDMETHOD.

    METHOD proc_make_vector.
      DATA lo_fill TYPE REF TO lcl_lisp.
      "_validate: list, list->cdr.
        IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      DATA(lo_size) = list->car.

      "_validate_index lo_size `make-vector`.
        IF lo_size IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF lo_size->type NE lcl_lisp=>type_integer.
          throw( lo_size->to_string( ) && ` is not an integer in make-vector` ) ##NO_TEXT.
        ENDIF.
        IF CAST lcl_lisp_integer( lo_size )->integer LT 0.
          throw( lo_size->to_string( ) && ` must be non-negative in make-vector` ) ##NO_TEXT.
        ENDIF.

      IF list->cdr NE lcl_lisp=>nil.
        lo_fill = list->cdr->car.
      ELSE.
        lo_fill = lcl_lisp=>nil.
      ENDIF.

      result = lcl_lisp_vector=>init( size = CAST lcl_lisp_integer( lo_size )->integer
                                      io_fill = lo_fill ).
    ENDMETHOD.

    METHOD proc_vector.
*     The items given to us are already in a list and evaluated; we just need to return the head
      result = lcl_lisp_vector=>from_list( list ).
    ENDMETHOD.

    METHOD proc_vector_length.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_vector list->car 'vector-length'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_vector.
          throw( list->car->to_string( ) && ` is not a vector in vector-length` ) ##NO_TEXT.
        ENDIF.

      result = CAST lcl_lisp_vector( list->car )->length( ).
    ENDMETHOD.

    METHOD proc_vector_ref.
*    (vector-ref vector k) procedure
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_vector list->car 'vector-ref'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_vector.
          throw( list->car->to_string( ) && ` is not a vector in vector-ref` ) ##NO_TEXT.
        ENDIF.

      DATA(lo_vec) = CAST lcl_lisp_vector( list->car ).

      "_validate list->cdr.
        IF list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      DATA(lo_idx) = list->cdr->car.
      "_validate_index lo_idx 'vector-ref'.
        IF lo_idx IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF lo_idx->type NE lcl_lisp=>type_integer.
          throw( lo_idx->to_string( ) && ` is not an integer in vector-ref` ) ##NO_TEXT.
        ENDIF.
        IF CAST lcl_lisp_integer( lo_idx )->integer LT 0.
          throw( lo_idx->to_string( ) && ` must be non-negative in vector-ref` ) ##NO_TEXT.
        ENDIF.

      result = lo_vec->get( CAST lcl_lisp_integer( lo_idx )->integer ).

    ENDMETHOD.

    METHOD proc_vector_set.
*    (vector-set! vector k obj) procedure
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_vector list->car 'vector-set!'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_vector.
          throw( list->car->to_string( ) && ` is not a vector in vector-length` ) ##NO_TEXT.
        ENDIF.

      DATA(lo_vec) = CAST lcl_lisp_vector( list->car ).

      "_validate: list->cdr.
        IF list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      DATA(lo_idx) = list->cdr->car.
      "_validate_index lo_idx 'vector-set!'.
        IF lo_idx IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF lo_idx->type NE lcl_lisp=>type_integer.
          throw( lo_idx->to_string( ) && ` is not an integer in vector-set!` ) ##NO_TEXT.
        ENDIF.
        IF CAST lcl_lisp_integer( lo_idx )->integer LT 0.
          throw( lo_idx->to_string( ) && ` must be non-negative in vector-set!` ) ##NO_TEXT.
        ENDIF.

      "_validate: list->cdr->cdr.
        IF list->cdr->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      DATA(lo_obj) = list->cdr->cdr.
      IF lo_obj NE nil.
        lo_obj = lo_obj->car.
      ENDIF.

      lo_vec->set( index = CAST lcl_lisp_integer( lo_idx )->integer
                   io_elem = lo_obj ).
*     Result is undefined, but must be valid
      result = lo_obj.
    ENDMETHOD.

    METHOD proc_vector_fill.
* (vector-fill! vector fill) procedure
* (vector-fill! vector fill start) procedure
* (vector-fill! vector fill start end) procedure
*The vector-fill! procedure stores fill in the elements of vector between start and end.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      DATA(lo_ptr) = list.

      "_validate_vector lo_ptr->car 'vector-fill!'.
        IF lo_ptr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF lo_ptr->car->type NE lcl_lisp=>type_vector.
          throw( lo_ptr->car->to_string( ) && ` is not a vector in vector-fill!` ) ##NO_TEXT.
        ENDIF.

      DATA(lo_vec) = CAST lcl_lisp_vector( lo_ptr->car ).

      lo_ptr = lo_ptr->cdr.
      "_validate: lo_ptr, lo_ptr->car.
        IF lo_ptr IS NOT BOUND OR lo_ptr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      DATA(lo_fill) = lo_ptr->car.

      lo_ptr = lo_ptr->cdr.
      "_validate lo_ptr.
        IF lo_ptr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      IF lo_ptr NE nil.
        "_validate_index lo_ptr->car 'vector-fill! start'.
        IF lo_ptr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF lo_ptr->car->type NE lcl_lisp=>type_integer.
          throw( lo_ptr->car->to_string( ) && ` is not an integer in vector-fill! start` ) ##NO_TEXT.
        ENDIF.
        IF CAST lcl_lisp_integer( lo_ptr->car )->integer LT 0.
          throw( lo_ptr->car->to_string( ) && ` must be non-negative in vector-fill! start` ) ##NO_TEXT.
        ENDIF.

        DATA lv_start TYPE tv_int.
        lv_start = CAST lcl_lisp_integer( lo_ptr->car )->integer.

        lo_ptr = lo_ptr->cdr.
        "_validate lo_ptr.
        IF lo_ptr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF lo_ptr NE nil.
          "_validate_index lo_ptr->car 'vector-fill! end'.
            IF lo_ptr->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            IF lo_ptr->car->type NE lcl_lisp=>type_integer.
              throw( lo_ptr->car->to_string( ) && ` is not an integer in vector-fill! end` ) ##NO_TEXT.
            ENDIF.
            IF CAST lcl_lisp_integer( lo_ptr->car )->integer LT 0.
              throw( lo_ptr->car->to_string( ) && ` must be non-negative in vector-fill! end` ) ##NO_TEXT.
            ENDIF.

          result = lo_vec->fill( from = lv_start
                                 to = CAST lcl_lisp_integer( lo_ptr->car )->integer
                                 elem = lo_fill ).
        ELSE.
          result = lo_vec->fill( from = lv_start
                                 elem = lo_fill ).
        ENDIF.

      ELSE.
        result = lo_vec->fill( elem = lo_fill ).
      ENDIF.

    ENDMETHOD.

    METHOD proc_vector_to_list.
*   (vector->list vector)
*   (vector->list vector start) procedure
*   (vector->list vector start end) procedure
* The vector->list procedure returns a newly allocated list of the objects contained
* in the elements of vector between start and end. Order is preserved.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_vector list->car 'vector->list'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_vector.
          throw( list->car->to_string( ) && ` is not a vector in vector->list` ) ##NO_TEXT.
        ENDIF.

      DATA lv_start TYPE tv_int.
      DATA(lo_vec) = CAST lcl_lisp_vector( list->car ).

      "_validate list->cdr.
        IF list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
      IF list->cdr NE nil.
        DATA(lo_start) = list->cdr->car.
        "_validate_index lo_start 'vector->list start'.
        IF lo_start IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF lo_start->type NE lcl_lisp=>type_integer.
          throw( lo_start->car->to_string( ) && ` is not an integer in vector->list start` ) ##NO_TEXT.
        ENDIF.
        IF CAST lcl_lisp_integer( lo_start )->integer LT 0.
          throw( lo_start->car->to_string( ) && ` must be non-negative in vector->list start` ) ##NO_TEXT.
        ENDIF.
        lv_start = CAST lcl_lisp_integer( lo_start )->integer.

        "_validate list->cdr->cdr.
        IF list->cdr->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        IF list->cdr->cdr NE nil.
          DATA(lo_end) = list->cdr->cdr->car.
          "_validate_index lo_end 'vector->list end'.
            IF lo_end IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            IF lo_end->type NE lcl_lisp=>type_integer.
              throw( lo_end->car->to_string( ) && ` is not an integer in vector->list end` ) ##NO_TEXT.
            ENDIF.
            IF CAST lcl_lisp_integer( lo_end )->integer LT 0.
              throw( lo_end->car->to_string( ) && ` must be non-negative in vector->list end` ) ##NO_TEXT.
            ENDIF.
          result = lo_vec->get_list( from = lv_start
                                     to = CAST lcl_lisp_integer( lo_end )->integer ).
        ELSE.
          result = lo_vec->get_list( from = lv_start ).
        ENDIF.

      ELSE.
        result = lo_vec->to_list( ).
      ENDIF.
    ENDMETHOD.

    METHOD proc_list_to_vector.
*   (list->vector list)
* The list->vector procedure returns a newly created vector initialized
* to the elements of the list list. Order is preserved.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = lcl_lisp_vector=>from_list( list->car ).
    ENDMETHOD.

* (memq obj list)  return the first sublist of
* list whose car is obj,  where  the  sublists  of list are the non-empty lists
* returned by (list-tail list  k) for k less than the length of list.
* If obj does not occur in list, then #f (not the empty list) is returned.
* Memq uses eq? to compare obj with the elements  of list
    METHOD proc_memq.
      "_validate: list, list->car, list->cdr.
       IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
         lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      result = false.

      CHECK list->cdr NE nil.

      DATA(lo_sublist) = list->cdr->car.
      DATA(lo_item) = list->car.
      WHILE lo_sublist NE nil AND lo_sublist->car->type EQ lo_item->type.

        CASE lo_item->type.
          WHEN lcl_lisp=>type_integer.
            IF CAST lcl_lisp_integer( lo_item )->integer = CAST lcl_lisp_integer( lo_sublist->car )->integer.
              result = lo_sublist.
              RETURN.
            ENDIF.

          WHEN lcl_lisp=>type_real.
            IF CAST lcl_lisp_real( lo_item )->float_eq( CAST lcl_lisp_real( lo_sublist->car )->real ).
              result = lo_sublist.
              RETURN.
            ENDIF.

          WHEN lcl_lisp=>type_symbol OR lcl_lisp=>type_string.
            DATA(lo_symbol) = CAST lcl_lisp_symbol( lo_item ).
            DATA(lo_s_car) = CAST lcl_lisp_symbol( lo_sublist->car ).
            IF lo_symbol->value = lo_s_car->value AND lo_symbol->index = lo_s_car->index.
              result = lo_sublist.
              RETURN.
            ENDIF.

          WHEN OTHERS.
            IF lo_item = lo_sublist->car.
              result = lo_sublist.
              RETURN.
            ENDIF.
        ENDCASE.

        lo_sublist = lo_sublist->cdr.
      ENDWHILE.
    ENDMETHOD.

    METHOD proc_memv.
      "_validate: list, list->car, list->cdr.
       IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      result = false.

      DATA(lo_sublist) = list->cdr->car.
      DATA(lo_item) = list->car.
      WHILE lo_sublist->type EQ lcl_lisp=>type_pair.
        IF lo_sublist->car->is_equivalent( lo_item ) NE false.
          result = lo_sublist.
          RETURN.
        ENDIF.
        lo_sublist = lo_sublist->cdr.
      ENDWHILE.
*      CHECK lo_sublist NE nil.
*      list->error_not_a_list( ).
    ENDMETHOD.

    METHOD get_equal_params.
      "_validate: io_list, io_list->car, io_list->cdr.
       IF io_list IS NOT BOUND OR io_list->car IS NOT BOUND OR io_list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.


      eo_sublist = io_list->cdr->car.
      eo_key = io_list->car.
      eo_compare = io_list->cdr->cdr.
    ENDMETHOD.

    METHOD proc_member.
      result = false.
      get_equal_params( EXPORTING io_list = list
                        IMPORTING eo_sublist = DATA(lo_sublist)
                                  eo_compare = DATA(lo_compare)
                                  eo_key = DATA(lo_key) ).

      WHILE lo_sublist->type EQ lcl_lisp=>type_pair.
        IF lo_key->is_equal( io_elem = lo_sublist->car
                             comp = lo_compare
                             interpreter = me
                             environment = env ) NE false.
          result = lo_sublist.
          RETURN.
        ENDIF.
        lo_sublist = lo_sublist->cdr.
      ENDWHILE.
*      CHECK lo_sublist NE nil.
*      list->error_not_a_list( ).
    ENDMETHOD.

    METHOD proc_assoc.

      result = false.
      get_equal_params( EXPORTING io_list = list
                        IMPORTING eo_sublist = DATA(lo_sublist)
                                  eo_compare = DATA(lo_compare)
                                  eo_key = DATA(lo_key) ).

      WHILE lo_sublist->type EQ lcl_lisp=>type_pair.
        DATA(lo_pair) = lo_sublist->car.
        IF lo_key->is_equal( io_elem = lo_pair->car
                             comp = lo_compare
                             interpreter = me
                             environment = env ) NE false.
          result = lo_pair.
          RETURN.
        ENDIF.
        lo_sublist = lo_sublist->cdr.
      ENDWHILE.
    ENDMETHOD.

* ( assq obj alist) - alist (for association list") must be a list of pairs.
* Find the first pair in alist whose car field is obj, and returns that pair.
* If no pair in alist has obj as its car, then #f (not the empty list) is returned.
* Assq uses eq? to compare obj with the car fields of the pairs in alist, while
* assv uses eqv? and assoc uses equal?
    METHOD proc_assq.
      "_validate: list, list->car, list->cdr.
       IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      result = false.

      CHECK list->cdr NE nil.

      DATA(lo_sublist) = list->cdr->car.
      DATA(lo_key) = list->car.
      WHILE lo_sublist->type EQ lcl_lisp=>type_pair.
        DATA(lo_pair) = lo_sublist->car.
        IF lo_pair->car->type EQ lo_key->type.

          CASE lo_key->type.
            WHEN lcl_lisp=>type_integer.
              IF CAST lcl_lisp_integer( lo_key )->integer = CAST lcl_lisp_integer( lo_pair->car )->integer.
                result = lo_pair.
                RETURN.
              ENDIF.

            WHEN lcl_lisp=>type_rational.
              DATA(lo_key_rat) = CAST lcl_lisp_rational( lo_key ).
              DATA(lo_target_rat) = CAST lcl_lisp_rational( lo_pair->car ).
              IF lo_key_rat->integer = lo_target_rat->integer AND lo_key_rat->denominator = lo_target_rat->denominator.
                result = lo_pair.
                RETURN.
              ENDIF.

            WHEN lcl_lisp=>type_real.
              IF CAST lcl_lisp_real( lo_key )->float_eq( CAST lcl_lisp_real( lo_pair->car )->real ).
                result = lo_pair.
                RETURN.
              ENDIF.

            WHEN lcl_lisp=>type_symbol OR lcl_lisp=>type_string.
              IF lo_key->value = lo_pair->car->value.
                result = lo_pair.
                RETURN.
              ENDIF.

            WHEN OTHERS.
              IF lo_key = lo_pair->car.
                result = lo_pair.
                RETURN.
              ENDIF.
          ENDCASE.

        ENDIF.

        lo_sublist = lo_sublist->cdr.
      ENDWHILE.
    ENDMETHOD.

    METHOD proc_assv.
      "_validate: list, list->car, list->cdr.
       IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      result = false.

      DATA(lo_sublist) = list->cdr->car.
      DATA(lo_key) = list->car.

      WHILE lo_sublist->type EQ lcl_lisp=>type_pair.
        DATA(lo_pair) = lo_sublist->car.
        "_validate lo_pair->car.
           IF lo_pair->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
           ENDIF.

        IF lo_pair->car->is_equivalent( lo_key ) NE false.
          result = lo_pair.
          RETURN.
        ENDIF.
        lo_sublist = lo_sublist->cdr.
      ENDWHILE.
    ENDMETHOD.

**********************************************************************
    METHOD proc_add.
      DATA lv_type TYPE lcl_sexps=>tv_type.
      DATA res_int TYPE tv_int.
      DATA res_real TYPE tv_real.
      DATA res_nummer TYPE tv_int.
      DATA res_denom TYPE tv_int VALUE 1.
      DATA lv_gcd TYPE tv_int.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      DATA(iter) = list->new_iterator( ).

      lv_type = lcl_lisp=>type_integer.
      WHILE iter->has_next( ).
        cell = iter->next( ).
        "_cell_arith + `[+]`.
          CASE cell->type.
            WHEN lcl_lisp=>type_integer.
              lo_int ?= cell.

              CASE lv_type.
                WHEN lcl_lisp=>type_real.
                  res_real = res_real + lo_int->integer.

                WHEN lcl_lisp=>type_rational.
                  res_nummer = res_nummer + ( lo_int->integer * res_denom ).
                  lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                    d = res_denom ).
                  res_nummer = res_nummer DIV lv_gcd.
                  res_denom = res_denom DIV lv_gcd.

                WHEN lcl_lisp=>type_integer.
                  res_int = res_int + lo_int->integer.

                WHEN OTHERS.
                  lv_type = lcl_lisp=>type_integer.
                  res_int = lo_int->integer.
              ENDCASE.

            WHEN lcl_lisp=>type_real.
              lo_real ?= cell.

              CASE lv_type.
                WHEN lcl_lisp=>type_real.
                  res_real = res_real + lo_real->real.

                WHEN lcl_lisp=>type_rational.
                  res_real = res_nummer / res_denom + lo_real->real.
                  lv_type = lcl_lisp=>type_real.

                WHEN lcl_lisp=>type_integer.
                  res_real = res_int + lo_real->real.
                  lv_type = lcl_lisp=>type_real.

                WHEN OTHERS.
                  lv_type = lcl_lisp=>type_real.
                  res_real = lo_real->real.
              ENDCASE.

            WHEN lcl_lisp=>type_rational.
              lo_rat ?= cell.

              CASE lv_type.
                WHEN lcl_lisp=>type_real.
                  res_real = res_real + lo_rat->integer / lo_rat->denominator.
                  lv_type = lcl_lisp=>type_real.

                WHEN lcl_lisp=>type_rational.
                  res_nummer = res_nummer * lo_rat->denominator + ( lo_rat->integer * res_denom ).
                  res_denom = res_denom * lo_rat->denominator.
                  lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                    d = res_denom ).
                  res_nummer = res_nummer DIV lv_gcd.
                  res_denom = res_denom DIV lv_gcd.


                WHEN lcl_lisp=>type_integer.
                  res_nummer = ( res_int * lo_rat->denominator ) + lo_rat->integer.
                  res_denom = lo_rat->denominator.

                  lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                    d = res_denom ).
                  res_nummer = res_nummer DIV lv_gcd.
                  res_denom = res_denom DIV lv_gcd.
                  lv_type = lcl_lisp=>type_rational.

                WHEN OTHERS.
                  lv_type = lcl_lisp=>type_rational.
                  res_nummer = lo_rat->integer.
                  res_denom = lo_rat->denominator.
              ENDCASE.

*            WHEN lcl_lisp=>type_complex.
            WHEN OTHERS.
              throw( |{ cell->to_string( ) } is not a number in [+]| ).
          ENDCASE.
      ENDWHILE.

      "_result_arith `[+]`.
      CASE lv_type.
        WHEN lcl_lisp=>type_integer.
          result = lcl_lisp_new=>integer( res_int ).

        WHEN lcl_lisp=>type_rational.
          IF res_denom EQ 1.
            result = lcl_lisp_new=>integer( res_nummer ).
          ELSE.
            result = lcl_lisp_new=>rational( nummer = res_nummer
                                             denom = res_denom ).
          ENDIF.

        WHEN lcl_lisp=>type_real.
          result = lcl_lisp_new=>real( res_real ).

        WHEN OTHERS.
          throw( |Error in result of [+]| ).
      ENDCASE.
    ENDMETHOD.                    "proc_add

    METHOD proc_multiply.
      DATA lv_type TYPE lcl_sexps=>tv_type.
      DATA res_int TYPE tv_int.
      DATA res_real TYPE tv_real.
      DATA res_nummer TYPE tv_int.
      DATA res_denom TYPE tv_int VALUE 1.
      DATA lv_gcd TYPE tv_int.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      DATA(iter) = list->new_iterator( ).

      res_int = 1.
      lv_type = lcl_lisp=>type_integer.
      WHILE iter->has_next( ).
        cell = iter->next( ).

        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
            lo_int ?= cell.

            CASE lv_type.
              WHEN lcl_lisp=>type_real.
                res_real = res_real * lo_int->integer.

              WHEN lcl_lisp=>type_rational.
                res_nummer = res_nummer * lo_int->integer.
                lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                  d = res_denom ).
                res_nummer = res_nummer DIV lv_gcd.
                res_denom = res_denom DIV lv_gcd.

              WHEN lcl_lisp=>type_integer.
                res_int = res_int * lo_int->integer.

              WHEN OTHERS.
                lv_type = lcl_lisp=>type_integer.
                res_int = lo_int->integer.
            ENDCASE.

          WHEN lcl_lisp=>type_real.
            lo_real ?= cell.

            CASE lv_type.
              WHEN lcl_lisp=>type_real.
                res_real = res_real * lo_real->real.

              WHEN lcl_lisp=>type_rational.
                res_real = res_nummer / res_denom * lo_real->real.
                lv_type = lcl_lisp=>type_real.

              WHEN lcl_lisp=>type_integer.
                res_real = res_int * lo_real->real.
                lv_type = lcl_lisp=>type_real.

              WHEN OTHERS.
                lv_type = lcl_lisp=>type_real.
                res_real = lo_real->real.
            ENDCASE.

          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.

            CASE lv_type.
              WHEN lcl_lisp=>type_real.
                res_real = res_real * lo_rat->integer / lo_rat->denominator.
                lv_type = lcl_lisp=>type_real.

              WHEN lcl_lisp=>type_rational.
                res_nummer = res_nummer * lo_rat->integer.
                res_denom = res_denom * lo_rat->denominator.
                lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                  d = res_denom ).
                res_nummer = res_nummer DIV lv_gcd.
                res_denom = res_denom DIV lv_gcd.

              WHEN lcl_lisp=>type_integer.
                res_nummer = res_int * lo_rat->integer.
                res_denom = lo_rat->denominator.

                lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                  d = res_denom ).
                res_nummer = res_nummer DIV lv_gcd.
                res_denom = res_denom DIV lv_gcd.
                lv_type = lcl_lisp=>type_rational.

              WHEN OTHERS.
                lv_type = lcl_lisp=>type_rational.
                res_nummer = lo_rat->integer.
                res_denom = lo_rat->denominator.
            ENDCASE.

*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [*]| ).
        ENDCASE.

      ENDWHILE.

      "_result_arith `[*]`.
      CASE lv_type.
        WHEN lcl_lisp=>type_integer.
          result = lcl_lisp_new=>integer( res_int ).

        WHEN lcl_lisp=>type_rational.
          IF res_denom EQ 1.
            result = lcl_lisp_new=>integer( res_nummer ).
          ELSE.
            result = lcl_lisp_new=>rational( nummer = res_nummer
                                             denom = res_denom ).
          ENDIF.

        WHEN lcl_lisp=>type_real.
          result = lcl_lisp_new=>real( res_real ).

        WHEN OTHERS.
          throw( |Error in result of [*]| ).
      ENDCASE.
    ENDMETHOD.                    "proc_multiply

    METHOD proc_subtract.
      DATA lv_type TYPE lcl_sexps=>tv_type.
      DATA res_int TYPE tv_int.
      DATA res_real TYPE tv_real.
      DATA res_nummer TYPE tv_int.
      DATA res_denom TYPE tv_int VALUE 1.
      DATA lv_gcd TYPE tv_int.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      DATA(iter) = list->new_iterator( ).
      IF iter->has_next( ) EQ abap_false.
        throw( |no number in [-]| ).
      ENDIF.

      cell = iter->next( ).
      "_cell_arith - `[-]`.
      CASE cell->type.
        WHEN lcl_lisp=>type_integer.
          lo_int ?= cell.

          CASE lv_type.
            WHEN lcl_lisp=>type_real.
              res_real = res_real - lo_int->integer.

            WHEN lcl_lisp=>type_rational.
              res_nummer = res_nummer - ( lo_int->integer * res_denom ).
              lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                d = res_denom ).
              res_nummer = res_nummer DIV lv_gcd.
              res_denom = res_denom DIV lv_gcd.

            WHEN lcl_lisp=>type_integer.
              res_int = res_int - lo_int->integer.

            WHEN OTHERS.
              lv_type = lcl_lisp=>type_integer.
              res_int = lo_int->integer.
          ENDCASE.

        WHEN lcl_lisp=>type_real.
          lo_real ?= cell.

          CASE lv_type.
            WHEN lcl_lisp=>type_real.
              res_real = res_real - lo_real->real.

            WHEN lcl_lisp=>type_rational.
              res_real = res_nummer / res_denom - lo_real->real.
              lv_type = lcl_lisp=>type_real.

            WHEN lcl_lisp=>type_integer.
              res_real = res_int - lo_real->real.
              lv_type = lcl_lisp=>type_real.

            WHEN OTHERS.
              lv_type = lcl_lisp=>type_real.
              res_real = lo_real->real.
          ENDCASE.

        WHEN lcl_lisp=>type_rational.
          lo_rat ?= cell.

          CASE lv_type.
            WHEN lcl_lisp=>type_real.
              res_real = res_real - lo_rat->integer / lo_rat->denominator.
              lv_type = lcl_lisp=>type_real.

            WHEN lcl_lisp=>type_rational.
              res_nummer = res_nummer * lo_rat->denominator - ( lo_rat->integer * res_denom ).
              res_denom = res_denom * lo_rat->denominator.
              lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                d = res_denom ).
              res_nummer = res_nummer DIV lv_gcd.
              res_denom = res_denom DIV lv_gcd.


            WHEN lcl_lisp=>type_integer.
              res_nummer = ( res_int * lo_rat->denominator ) - lo_rat->integer.
              res_denom = lo_rat->denominator.

              lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                d = res_denom ).
              res_nummer = res_nummer DIV lv_gcd.
              res_denom = res_denom DIV lv_gcd.
              lv_type = lcl_lisp=>type_rational.

            WHEN OTHERS.
              lv_type = lcl_lisp=>type_rational.
              res_nummer = lo_rat->integer.
              res_denom = lo_rat->denominator.
          ENDCASE.

*        WHEN lcl_lisp=>type_complex.
        WHEN OTHERS.
          throw( |{ cell->to_string( ) } is not a number in [-]| ).
      ENDCASE.

      IF iter->has_next( ) EQ abap_false.
        res_int = 0 - res_int.
        res_real = 0 - res_real.
        res_nummer = 0 - res_nummer.
      ELSE.
*       Subtract all consecutive numbers from the first
        WHILE iter->has_next( ).
          cell = iter->next( ).
          "_cell_arith - `[-]`.
          CASE cell->type.
            WHEN lcl_lisp=>type_integer.
              lo_int ?= cell.

              CASE lv_type.
                WHEN lcl_lisp=>type_real.
                  res_real = res_real - lo_int->integer.

                WHEN lcl_lisp=>type_rational.
                  res_nummer = res_nummer - ( lo_int->integer * res_denom ).
                  lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                    d = res_denom ).
                  res_nummer = res_nummer DIV lv_gcd.
                  res_denom = res_denom DIV lv_gcd.

                WHEN lcl_lisp=>type_integer.
                  res_int = res_int - lo_int->integer.

                WHEN OTHERS.
                  lv_type = lcl_lisp=>type_integer.
                  res_int = lo_int->integer.
              ENDCASE.

            WHEN lcl_lisp=>type_real.
              lo_real ?= cell.

              CASE lv_type.
                WHEN lcl_lisp=>type_real.
                  res_real = res_real - lo_real->real.

                WHEN lcl_lisp=>type_rational.
                  res_real = res_nummer / res_denom - lo_real->real.
                  lv_type = lcl_lisp=>type_real.

                WHEN lcl_lisp=>type_integer.
                  res_real = res_int - lo_real->real.
                  lv_type = lcl_lisp=>type_real.

                WHEN OTHERS.
                  lv_type = lcl_lisp=>type_real.
                  res_real = lo_real->real.
              ENDCASE.

            WHEN lcl_lisp=>type_rational.
              lo_rat ?= cell.

              CASE lv_type.
                WHEN lcl_lisp=>type_real.
                  res_real = res_real - lo_rat->integer / lo_rat->denominator.
                  lv_type = lcl_lisp=>type_real.

                WHEN lcl_lisp=>type_rational.
                  res_nummer = res_nummer * lo_rat->denominator - ( lo_rat->integer * res_denom ).
                  res_denom = res_denom * lo_rat->denominator.
                  lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                    d = res_denom ).
                  res_nummer = res_nummer DIV lv_gcd.
                  res_denom = res_denom DIV lv_gcd.


                WHEN lcl_lisp=>type_integer.
                  res_nummer = ( res_int * lo_rat->denominator ) - lo_rat->integer.
                  res_denom = lo_rat->denominator.

                  lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                    d = res_denom ).
                  res_nummer = res_nummer DIV lv_gcd.
                  res_denom = res_denom DIV lv_gcd.
                  lv_type = lcl_lisp=>type_rational.

                WHEN OTHERS.
                  lv_type = lcl_lisp=>type_rational.
                  res_nummer = lo_rat->integer.
                  res_denom = lo_rat->denominator.
              ENDCASE.

*            WHEN lcl_lisp=>type_complex.
            WHEN OTHERS.
              throw( |{ cell->to_string( ) } is not a number in [-]| ).
          ENDCASE.

        ENDWHILE.
      ENDIF.

      "_result_arith `[-]`.
      CASE lv_type.
        WHEN lcl_lisp=>type_integer.
          result = lcl_lisp_new=>integer( res_int ).

        WHEN lcl_lisp=>type_rational.
          IF res_denom EQ 1.
            result = lcl_lisp_new=>integer( res_nummer ).
          ELSE.
            result = lcl_lisp_new=>rational( nummer = res_nummer
                                             denom = res_denom ).
          ENDIF.

        WHEN lcl_lisp=>type_real.
          result = lcl_lisp_new=>real( res_real ).

        WHEN OTHERS.
          throw( |Error in result of [-]| ).
      ENDCASE.
    ENDMETHOD.                    "proc_subtract

    METHOD proc_divide.
      DATA lv_type TYPE lcl_sexps=>tv_type.
      DATA res_int TYPE tv_int.
      DATA res_real TYPE tv_real.
      DATA res_nummer TYPE tv_int.
      DATA res_denom TYPE tv_int VALUE 1.
      DATA lv_gcd TYPE tv_int.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      DATA(iter) = list->new_iterator( ).
      IF iter->has_next( ) EQ abap_false.
        throw( |no number in [/]| ).
      ENDIF.
      cell = iter->next( ).
      "_cell_arith / `[/]`.
      CASE cell->type.
        WHEN lcl_lisp=>type_integer.
          lo_int ?= cell.

          CASE lv_type.
            WHEN lcl_lisp=>type_real.
              res_real = res_real / lo_int->integer.

            WHEN lcl_lisp=>type_rational.
              res_nummer = res_nummer / ( lo_int->integer * res_denom ).
              lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                d = res_denom ).
              res_nummer = res_nummer DIV lv_gcd.
              res_denom = res_denom DIV lv_gcd.

            WHEN lcl_lisp=>type_integer.
              res_int = res_int / lo_int->integer.

            WHEN OTHERS.
              lv_type = lcl_lisp=>type_integer.
              res_int = lo_int->integer.
          ENDCASE.

        WHEN lcl_lisp=>type_real.
          lo_real ?= cell.

          CASE lv_type.
            WHEN lcl_lisp=>type_real.
              res_real = res_real / lo_real->real.

            WHEN lcl_lisp=>type_rational.
              res_real = res_nummer / res_denom / lo_real->real.
              lv_type = lcl_lisp=>type_real.

            WHEN lcl_lisp=>type_integer.
              res_real = res_int / lo_real->real.
              lv_type = lcl_lisp=>type_real.

            WHEN OTHERS.
              lv_type = lcl_lisp=>type_real.
              res_real = lo_real->real.
          ENDCASE.

        WHEN lcl_lisp=>type_rational.
          lo_rat ?= cell.

          CASE lv_type.
            WHEN lcl_lisp=>type_real.
              res_real = res_real / lo_rat->integer / lo_rat->denominator.
              lv_type = lcl_lisp=>type_real.

            WHEN lcl_lisp=>type_rational.
              res_nummer = res_nummer * lo_rat->denominator / ( lo_rat->integer * res_denom ).
              res_denom = res_denom * lo_rat->denominator.
              lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                d = res_denom ).
              res_nummer = res_nummer DIV lv_gcd.
              res_denom = res_denom DIV lv_gcd.


            WHEN lcl_lisp=>type_integer.
              res_nummer = ( res_int * lo_rat->denominator ) / lo_rat->integer.
              res_denom = lo_rat->denominator.

              lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                d = res_denom ).
              res_nummer = res_nummer DIV lv_gcd.
              res_denom = res_denom DIV lv_gcd.
              lv_type = lcl_lisp=>type_rational.

            WHEN OTHERS.
              lv_type = lcl_lisp=>type_rational.
              res_nummer = lo_rat->integer.
              res_denom = lo_rat->denominator.
          ENDCASE.

*        WHEN lcl_lisp=>type_complex.
        WHEN OTHERS.
          throw( |{ cell->to_string( ) } is not a number in [/]| ).
      ENDCASE.

      TRY.
          IF iter->has_next( ) EQ abap_false.
            CASE lv_type.
              WHEN lcl_lisp=>type_integer.
                res_denom = res_int.
                res_nummer = 1.
                lv_type = lcl_lisp=>type_rational.

              WHEN lcl_lisp=>type_rational.
                DATA(lv_saved_nummer) = res_nummer.
                res_nummer = res_denom.
                res_denom = lv_saved_nummer.

              WHEN lcl_lisp=>type_real.
                res_real = 1 / res_real.
            ENDCASE.
          ELSE.
            IF lv_type EQ lcl_lisp=>type_integer.
              res_nummer = res_int.
              res_denom = 1.
              lv_type = lcl_lisp=>type_rational.
            ENDIF.

            WHILE iter->has_next( ).
              cell = iter->next( ).

              CASE cell->type.
                WHEN lcl_lisp=>type_integer.
                  lo_int ?= cell.

                  CASE lv_type.
                    WHEN lcl_lisp=>type_real.
                      res_real = res_real / lo_int->integer.

                    WHEN lcl_lisp=>type_rational.
                      res_denom = res_denom * lo_int->integer.
                      lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                        d = res_denom ).
                      res_nummer = res_nummer DIV lv_gcd.
                      res_denom = res_denom DIV lv_gcd.

                    WHEN lcl_lisp=>type_integer.
                      res_nummer = res_int.
                      res_denom = lo_int->integer.
                      lv_type = lcl_lisp=>type_rational.

                    WHEN OTHERS.
                      throw( 'internal error proc_divide( )' ).
                      lv_type = lcl_lisp=>type_integer.
                      res_int = lo_int->integer.
                  ENDCASE.

                WHEN lcl_lisp=>type_real.
                  lo_real ?= cell.

                  CASE lv_type.
                    WHEN lcl_lisp=>type_real.
                      res_real = res_real / lo_real->real.

                    WHEN lcl_lisp=>type_rational.
                      res_real = res_nummer / res_denom / lo_real->real.
                      lv_type = lcl_lisp=>type_real.

                    WHEN lcl_lisp=>type_integer.
                      res_real = res_int / lo_real->real.
                      lv_type = lcl_lisp=>type_real.

                    WHEN OTHERS.
                      lv_type = lcl_lisp=>type_real.
                      res_real = lo_real->real.
                  ENDCASE.

                WHEN lcl_lisp=>type_rational.
                  lo_rat ?= cell.

                  CASE lv_type.
                    WHEN lcl_lisp=>type_real.
                      res_real = res_real * lo_rat->denominator / lo_rat->integer.
                      lv_type = lcl_lisp=>type_real.

                    WHEN lcl_lisp=>type_rational.
                      res_nummer = res_nummer * lo_rat->denominator.
                      res_denom = res_denom * lo_rat->integer.
                      lv_gcd = lcl_lisp_rational=>gcd(  n = res_nummer
                                                        d = res_denom ).
                      res_nummer = res_nummer DIV lv_gcd.
                      res_denom = res_denom DIV lv_gcd.

                    WHEN lcl_lisp=>type_integer.
                      res_nummer = res_int * lo_rat->denominator.
                      res_denom = lo_rat->integer.

                      lv_type = lcl_lisp=>type_rational.

                    WHEN OTHERS.
                      lv_type = lcl_lisp=>type_rational.
                      res_nummer = lo_rat->integer.
                      res_denom = lo_rat->denominator.
                  ENDCASE.

*                WHEN lcl_lisp=>type_complex.
                WHEN OTHERS.
                  throw( |{ cell->to_string( ) } is not a number in [/]| ).
              ENDCASE.

            ENDWHILE.
          ENDIF.
        CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.

      "_result_arith `[/]`.
      CASE lv_type.
        WHEN lcl_lisp=>type_integer.
          result = lcl_lisp_new=>integer( res_int ).

        WHEN lcl_lisp=>type_rational.
          IF res_denom EQ 1.
            result = lcl_lisp_new=>integer( res_nummer ).
          ELSE.
            result = lcl_lisp_new=>rational( nummer = res_nummer
                                             denom = res_denom ).
          ENDIF.

        WHEN lcl_lisp=>type_real.
          result = lcl_lisp_new=>real( res_real ).

        WHEN OTHERS.
          throw( |Error in result of [/]| ).
      ENDCASE.
    ENDMETHOD.                    "proc_divide

**********************************************************************
    METHOD proc_gt.
      "_comparison <= '[>]'.
    DATA carry TYPE tv_real.
    DATA carry_int TYPE tv_int.
    DATA carry_is_int TYPE abap_boolean.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
   DATA lo_int TYPE REF TO lcl_lisp_integer.
   DATA lo_real TYPE REF TO lcl_lisp_real.
   DATA cell TYPE REF TO lcl_lisp.


    result = false.
    "_validate: list, list->car, list->cdr.
    IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
      throw( c_error_incorrect_input ).
    ENDIF.
    IF list->cdr->type NE lcl_lisp=>type_pair.
      throw( c_error_incorrect_input ).
    ENDIF.

    cell = list->car.
    carry_is_int = abap_false.
    CASE cell->type.
      WHEN lcl_lisp=>type_integer.
        carry_is_int = abap_true.
        carry_int = CAST lcl_lisp_integer( cell )->integer.
        carry = carry_int.

      WHEN lcl_lisp=>type_real.
        carry = CAST lcl_lisp_real( cell )->real.

      WHEN lcl_lisp=>type_rational.
        lo_rat ?= cell.
        carry = lo_rat->integer / lo_rat->denominator.
*      WHEN lcl_lisp=>type_complex.

      WHEN OTHERS.
        throw( |{ cell->to_string( ) } is not a number in [>]| ).
    ENDCASE.

    cell = list->cdr.
    WHILE cell->type EQ lcl_lisp=>type_pair.
      "_validate cell->car.
        IF cell->car IS NOT BOUND.
          throw( c_error_incorrect_input ).
        ENDIF.

      CASE cell->car->type.
        WHEN lcl_lisp=>type_integer.
          lo_int ?= cell->car.
          IF carry_is_int = abap_true.
            IF carry_int <= lo_int->integer.
              RETURN.
            ENDIF.
            carry_int = lo_int->integer.
          ELSE.
            IF carry <= lo_int->integer.
              RETURN.
            ENDIF.
          ENDIF.
          carry = lo_int->integer.

        WHEN lcl_lisp=>type_real.
          carry_is_int = abap_false.
          lo_real ?= cell->car.
          IF carry <= lo_real->real.
            RETURN.
          ENDIF.
          carry = lo_real->real.

        WHEN lcl_lisp=>type_rational.
          carry_is_int = abap_false.
          lo_rat ?= cell->car.
          IF carry * lo_rat->denominator <= lo_rat->integer.
            RETURN.
          ENDIF.
          carry = lo_rat->integer / lo_rat->denominator.

*               WHEN lcl_lisp=>type_complex.
        WHEN OTHERS.
          throw( |{ cell->car->to_string( ) } is not a number in [>]| ).
      ENDCASE.
      cell = cell->cdr.
    ENDWHILE.
    result = true.

    ENDMETHOD.                    "proc_gt

    METHOD proc_gte.
      "_comparison < '[>=]'.
    DATA carry TYPE tv_real.
    DATA carry_int TYPE tv_int.
    DATA carry_is_int TYPE abap_boolean.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
   DATA lo_int TYPE REF TO lcl_lisp_integer.
   DATA lo_real TYPE REF TO lcl_lisp_real.
   DATA cell TYPE REF TO lcl_lisp.


    result = false.
    "_validate: list, list->car, list->cdr.
    IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
      throw( c_error_incorrect_input ).
    ENDIF.
    IF list->cdr->type NE lcl_lisp=>type_pair.
      throw( c_error_incorrect_input ).
    ENDIF.

    cell = list->car.
    carry_is_int = abap_false.
    CASE cell->type.
      WHEN lcl_lisp=>type_integer.
        carry_is_int = abap_true.
        carry_int = CAST lcl_lisp_integer( cell )->integer.
        carry = carry_int.

      WHEN lcl_lisp=>type_real.
        carry = CAST lcl_lisp_real( cell )->real.

      WHEN lcl_lisp=>type_rational.
        lo_rat ?= cell.
        carry = lo_rat->integer / lo_rat->denominator.
*      WHEN lcl_lisp=>type_complex.

      WHEN OTHERS.
        throw( |{ cell->to_string( ) } is not a number in [>=]| ).
    ENDCASE.

    cell = list->cdr.
    WHILE cell->type EQ lcl_lisp=>type_pair.
      "_validate cell->car.
        IF cell->car IS NOT BOUND.
          throw( c_error_incorrect_input ).
        ENDIF.

      CASE cell->car->type.
        WHEN lcl_lisp=>type_integer.
          lo_int ?= cell->car.
          IF carry_is_int = abap_true.
            IF carry_int < lo_int->integer.
              RETURN.
            ENDIF.
            carry_int = lo_int->integer.
          ELSE.
            IF carry < lo_int->integer.
              RETURN.
            ENDIF.
          ENDIF.
          carry = lo_int->integer.

        WHEN lcl_lisp=>type_real.
          carry_is_int = abap_false.
          lo_real ?= cell->car.
          IF carry < lo_real->real.
            RETURN.
          ENDIF.
          carry = lo_real->real.

        WHEN lcl_lisp=>type_rational.
          carry_is_int = abap_false.
          lo_rat ?= cell->car.
          IF carry * lo_rat->denominator < lo_rat->integer.
            RETURN.
          ENDIF.
          carry = lo_rat->integer / lo_rat->denominator.

*               WHEN lcl_lisp=>type_complex.
        WHEN OTHERS.
          throw( |{ cell->car->to_string( ) } is not a number in [>=]| ).
      ENDCASE.
      cell = cell->cdr.
    ENDWHILE.
    result = true.

    ENDMETHOD.                    "proc_gte

    METHOD proc_lt.
      "_comparison >= '[<]'.
    DATA carry TYPE tv_real.
    DATA carry_int TYPE tv_int.
    DATA carry_is_int TYPE abap_boolean.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
   DATA lo_int TYPE REF TO lcl_lisp_integer.
   DATA lo_real TYPE REF TO lcl_lisp_real.
   DATA cell TYPE REF TO lcl_lisp.


    result = false.
    "_validate: list, list->car, list->cdr.
    IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
      throw( c_error_incorrect_input ).
    ENDIF.
    IF list->cdr->type NE lcl_lisp=>type_pair.
      throw( c_error_incorrect_input ).
    ENDIF.

    cell = list->car.
    carry_is_int = abap_false.
    CASE cell->type.
      WHEN lcl_lisp=>type_integer.
        carry_is_int = abap_true.
        carry_int = CAST lcl_lisp_integer( cell )->integer.
        carry = carry_int.

      WHEN lcl_lisp=>type_real.
        carry = CAST lcl_lisp_real( cell )->real.

      WHEN lcl_lisp=>type_rational.
        lo_rat ?= cell.
        carry = lo_rat->integer / lo_rat->denominator.
*      WHEN lcl_lisp=>type_complex.

      WHEN OTHERS.
        throw( |{ cell->to_string( ) } is not a number in [<]| ).
    ENDCASE.

    cell = list->cdr.
    WHILE cell->type EQ lcl_lisp=>type_pair.
      "_validate cell->car.
        IF cell->car IS NOT BOUND.
          throw( c_error_incorrect_input ).
        ENDIF.

      CASE cell->car->type.
        WHEN lcl_lisp=>type_integer.
          lo_int ?= cell->car.
          IF carry_is_int = abap_true.
            IF carry_int >= lo_int->integer.
              RETURN.
            ENDIF.
            carry_int = lo_int->integer.
          ELSE.
            IF carry >= lo_int->integer.
              RETURN.
            ENDIF.
          ENDIF.
          carry = lo_int->integer.

        WHEN lcl_lisp=>type_real.
          carry_is_int = abap_false.
          lo_real ?= cell->car.
          IF carry >= lo_real->real.
            RETURN.
          ENDIF.
          carry = lo_real->real.

        WHEN lcl_lisp=>type_rational.
          carry_is_int = abap_false.
          lo_rat ?= cell->car.
          IF carry * lo_rat->denominator >= lo_rat->integer.
            RETURN.
          ENDIF.
          carry = lo_rat->integer / lo_rat->denominator.

*               WHEN lcl_lisp=>type_complex.
        WHEN OTHERS.
          throw( |{ cell->car->to_string( ) } is not a number in [<]| ).
      ENDCASE.
      cell = cell->cdr.
    ENDWHILE.
    result = true.

    ENDMETHOD.                    "proc_lt

    METHOD proc_lte.
      "_comparison > '[<=]'.
    DATA carry TYPE tv_real.
    DATA carry_int TYPE tv_int.
    DATA carry_is_int TYPE abap_boolean.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
   DATA lo_int TYPE REF TO lcl_lisp_integer.
   DATA lo_real TYPE REF TO lcl_lisp_real.
   DATA cell TYPE REF TO lcl_lisp.


    result = false.
    "_validate: list, list->car, list->cdr.
    IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
      throw( c_error_incorrect_input ).
    ENDIF.
    IF list->cdr->type NE lcl_lisp=>type_pair.
      throw( c_error_incorrect_input ).
    ENDIF.

    cell = list->car.
    carry_is_int = abap_false.
    CASE cell->type.
      WHEN lcl_lisp=>type_integer.
        carry_is_int = abap_true.
        carry_int = CAST lcl_lisp_integer( cell )->integer.
        carry = carry_int.

      WHEN lcl_lisp=>type_real.
        carry = CAST lcl_lisp_real( cell )->real.

      WHEN lcl_lisp=>type_rational.
        lo_rat ?= cell.
        carry = lo_rat->integer / lo_rat->denominator.
*      WHEN lcl_lisp=>type_complex.

      WHEN OTHERS.
        throw( |{ cell->to_string( ) } is not a number in [<=]| ).
    ENDCASE.

    cell = list->cdr.
    WHILE cell->type EQ lcl_lisp=>type_pair.
      "_validate cell->car.
        IF cell->car IS NOT BOUND.
          throw( c_error_incorrect_input ).
        ENDIF.

      CASE cell->car->type.
        WHEN lcl_lisp=>type_integer.
          lo_int ?= cell->car.
          IF carry_is_int = abap_true.
            IF carry_int > lo_int->integer.
              RETURN.
            ENDIF.
            carry_int = lo_int->integer.
          ELSE.
            IF carry > lo_int->integer.
              RETURN.
            ENDIF.
          ENDIF.
          carry = lo_int->integer.

        WHEN lcl_lisp=>type_real.
          carry_is_int = abap_false.
          lo_real ?= cell->car.
          IF carry > lo_real->real.
            RETURN.
          ENDIF.
          carry = lo_real->real.

        WHEN lcl_lisp=>type_rational.
          carry_is_int = abap_false.
          lo_rat ?= cell->car.
          IF carry * lo_rat->denominator > lo_rat->integer.
            RETURN.
          ENDIF.
          carry = lo_rat->integer / lo_rat->denominator.

*               WHEN lcl_lisp=>type_complex.
        WHEN OTHERS.
          throw( |{ cell->car->to_string( ) } is not a number in [<=]| ).
      ENDCASE.
      cell = cell->cdr.
    ENDWHILE.
    result = true.

    ENDMETHOD.                    "proc_lte

    METHOD proc_is_zero.
      "_sign 0 '[zero?]'.
    DATA carry TYPE tv_real.
    DATA cell TYPE REF TO lcl_lisp.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
    DATA lo_int TYPE REF TO lcl_lisp_integer.
    DATA lo_real TYPE REF TO lcl_lisp_real.

    result = false.
    IF list IS NOT BOUND.
      lcl_lisp=>throw( c_error_incorrect_input ).
    ENDIF.

    "_get_number carry list->car &2.
    IF list->car IS NOT BOUND.
      lcl_lisp=>throw( c_error_incorrect_input ).
    ENDIF.

    cell = list->car.
    CASE cell->type.
      WHEN lcl_lisp=>type_integer.
        carry = CAST lcl_lisp_integer( cell )->integer.
      WHEN lcl_lisp=>type_real.
        carry = CAST lcl_lisp_real( cell )->real.
      WHEN lcl_lisp=>type_rational.
        lo_rat ?= cell.
        carry = lo_rat->integer / lo_rat->denominator.
*      WHEN lcl_lisp=>type_complex.
      WHEN OTHERS.
        throw( |{ cell->to_string( ) } is not a number in [zero?]| ).
    ENDCASE.

    IF sign( carry ) NE 0.
      RETURN.
    ENDIF.
    result = true.
    ENDMETHOD.                    "proc_gt

    METHOD proc_is_positive.
      "_sign 1 '[positive?]'.
    DATA carry TYPE tv_real.
    DATA cell TYPE REF TO lcl_lisp.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
    DATA lo_int TYPE REF TO lcl_lisp_integer.
    DATA lo_real TYPE REF TO lcl_lisp_real.

    result = false.
    IF list IS NOT BOUND.
      lcl_lisp=>throw( c_error_incorrect_input ).
    ENDIF.

    "_get_number carry list->car &2.
    IF list->car IS NOT BOUND.
      lcl_lisp=>throw( c_error_incorrect_input ).
    ENDIF.

    cell = list->car.
    CASE cell->type.
      WHEN lcl_lisp=>type_integer.
        carry = CAST lcl_lisp_integer( cell )->integer.
      WHEN lcl_lisp=>type_real.
        carry = CAST lcl_lisp_real( cell )->real.
      WHEN lcl_lisp=>type_rational.
        lo_rat ?= cell.
        carry = lo_rat->integer / lo_rat->denominator.
*      WHEN lcl_lisp=>type_complex.
      WHEN OTHERS.
        throw( |{ cell->to_string( ) } is not a number in [positive?]| ).
    ENDCASE.

    IF sign( carry ) NE 1.
      RETURN.
    ENDIF.
    result = true.
    ENDMETHOD.                    "proc_gte

    METHOD proc_is_negative.
      "_sign -1 '[negative?]'.
    DATA carry TYPE tv_real.
    DATA cell TYPE REF TO lcl_lisp.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
    DATA lo_int TYPE REF TO lcl_lisp_integer.
    DATA lo_real TYPE REF TO lcl_lisp_real.

    result = false.
    IF list IS NOT BOUND.
      lcl_lisp=>throw( c_error_incorrect_input ).
    ENDIF.

    "_get_number carry list->car &2.
    IF list->car IS NOT BOUND.
      lcl_lisp=>throw( c_error_incorrect_input ).
    ENDIF.

    cell = list->car.
    CASE cell->type.
      WHEN lcl_lisp=>type_integer.
        carry = CAST lcl_lisp_integer( cell )->integer.
      WHEN lcl_lisp=>type_real.
        carry = CAST lcl_lisp_real( cell )->real.
      WHEN lcl_lisp=>type_rational.
        lo_rat ?= cell.
        carry = lo_rat->integer / lo_rat->denominator.
*      WHEN lcl_lisp=>type_complex.
      WHEN OTHERS.
        throw( |{ cell->to_string( ) } is not a number in [negative?]| ).
    ENDCASE.

    IF sign( carry ) NE -1.
      RETURN.
    ENDIF.
    result = true.
    ENDMETHOD.                    "proc_lt

    METHOD proc_is_odd.
      result = false.
      "_validate list.
       IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      "_validate_integer list->car '[odd?]'.
       IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in [odd?]` ) ##NO_TEXT.
        ENDIF.

      CHECK CAST lcl_lisp_integer( list->car )->integer MOD 2 NE 0.
      result = true.
    ENDMETHOD.                    "proc_lte

    METHOD proc_is_even.
      result = false.
      "_validate: list.
       IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.

      "_validate_integer list->car '[even?]'.
       IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
       ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in [even?]` ) ##NO_TEXT.
        ENDIF.

      CHECK CAST lcl_lisp_integer( list->car )->integer MOD 2 EQ 0.
      result = true.
    ENDMETHOD.                    "proc_lte

**********************************************************************

    METHOD proc_eql.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.
      DATA lo_rat_2 TYPE REF TO lcl_lisp_rational.
      DATA lv_int TYPE tv_int.
      DATA lv_real TYPE tv_real.

      "_validate: list, list->car, list->cdr.
        IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      result = false.
      DATA(lo_ptr) = list.
      IF lo_ptr->cdr->type NE lcl_lisp=>type_pair.
        throw( c_error_incorrect_input ).
      ENDIF.

      WHILE lo_ptr->cdr NE nil.
        "_validate_number lo_ptr->car '[=]',
        IF lo_ptr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        CASE lo_ptr->car->type.
          WHEN lcl_lisp=>type_integer
            OR lcl_lisp=>type_real
            OR lcl_lisp=>type_rational
            OR lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ lo_ptr->car->to_string( ) } is not a number in [=]| ) ##NO_TEXT.
        ENDCASE.
        "_validate_number lo_ptr->cdr->car '[=]'.
        IF lo_ptr->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        CASE lo_ptr->car->type.
          WHEN lcl_lisp=>type_integer
            OR lcl_lisp=>type_real
            OR lcl_lisp=>type_rational
            OR lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ lo_ptr->cdr->car->to_string( ) } is not a number in [=]| ) ##NO_TEXT.
        ENDCASE.

        CASE lo_ptr->car->type.
          WHEN lcl_lisp=>type_integer.
            lv_int = CAST lcl_lisp_integer( lo_ptr->car )->integer.
            CASE lo_ptr->cdr->car->type.
              WHEN lcl_lisp=>type_integer.
                IF lv_int = CAST lcl_lisp_integer( lo_ptr->cdr->car )->integer.
                  result = true.
                ELSE.
                  result = false.
                  EXIT.
                ENDIF.

              WHEN lcl_lisp=>type_real.
                lv_real = CAST lcl_lisp_real( lo_ptr->cdr->car )->real.
                IF lv_int = trunc( lv_real ) AND frac( lv_real ) EQ 0.
                  result = true.
                ELSE.
                  result = false.
                  EXIT.
                ENDIF.

              WHEN lcl_lisp=>type_rational.
                lo_rat ?= lo_ptr->cdr->car.
                IF lv_int = lo_rat->integer AND lo_rat->denominator EQ 1.
                  result = true.
                ELSE.
                  result = false.
                  EXIT.
                ENDIF.

*              WHEN lcl_lisp=>type_complex.
            ENDCASE.

          WHEN lcl_lisp=>type_real.
            lv_real = CAST lcl_lisp_real( lo_ptr->car )->real.
            CASE lo_ptr->cdr->car->type.
              WHEN lcl_lisp=>type_integer.
                IF trunc( lv_real ) = CAST lcl_lisp_integer( lo_ptr->cdr->car )->integer AND frac( lv_real ) EQ 0.
                  result = true.
                ELSE.
                  result = false.
                  EXIT.
                ENDIF.

              WHEN lcl_lisp=>type_real.
                IF CAST lcl_lisp_real( lo_ptr->cdr->car )->float_eq( lv_real ).
                  result = true.
                ELSE.
                  result = false.
                  EXIT.
                ENDIF.

              WHEN lcl_lisp=>type_rational.
                lo_rat ?= lo_ptr->cdr->car.
                lv_real = lv_real * lo_rat->denominator.

                IF trunc( lv_real ) = lo_rat->integer AND frac( lv_real ) EQ 0.
                  result = true.
                ELSE.
                  result = false.
                  EXIT.
                ENDIF.

*              WHEN lcl_lisp=>type_complex.
            ENDCASE.

          WHEN lcl_lisp=>type_rational.
            lo_rat = CAST lcl_lisp_rational( lo_ptr->car ).
            CASE lo_ptr->cdr->car->type.
              WHEN lcl_lisp=>type_integer.
                IF lo_rat->integer = CAST lcl_lisp_integer( lo_ptr->cdr->car )->integer
                  AND lo_rat->denominator EQ 1.
                  result = true.
                ELSE.
                  result = false.
                  EXIT.
                ENDIF.

              WHEN lcl_lisp=>type_real.
                lv_real = CAST lcl_lisp_real( lo_ptr->cdr->car )->real * lo_rat->denominator.

                IF lo_rat->integer = trunc( lv_real ) AND frac( lv_real ) EQ 0.
                  result = true.
                ELSE.
                  result = false.
                  EXIT.
                ENDIF.

              WHEN lcl_lisp=>type_rational.
                lo_rat_2 ?= lo_ptr->cdr->car.
                IF lo_rat->integer = lo_rat_2->integer
                  AND lo_rat->denominator EQ lo_rat_2->denominator.
                  result = true.
                ELSE.
                  result = false.
                  EXIT.
                ENDIF.

*              WHEN lcl_lisp=>type_complex.
            ENDCASE.

*          WHEN lcl_lisp=>type_complex.
        ENDCASE.

        lo_ptr = lo_ptr->cdr.
      ENDWHILE.
    ENDMETHOD.                    "proc_eql

    METHOD proc_eq.
      "_validate: list, list->car, list->cdr.
      IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = nil.
      DATA(lo_ptr) = list.
      DATA(lo_ref) = lo_ptr->car.
      IF lo_ptr->cdr NE nil.
        IF lo_ref->type NE lo_ptr->cdr->car->type.
          result = false.
          RETURN.
        ENDIF.
        CASE lo_ptr->car->type.
          WHEN lcl_lisp=>type_integer.
            IF CAST lcl_lisp_integer( lo_ref )->integer = CAST lcl_lisp_integer( lo_ptr->cdr->car )->integer.
              result = true.
            ELSE.
              result = false.
              RETURN.
            ENDIF.

          WHEN lcl_lisp=>type_rational.
            DATA(lo_ref_rat) = CAST lcl_lisp_rational( lo_ref ).
            DATA(lo_target_rat) = CAST lcl_lisp_rational( lo_ptr->cdr->car ).
            IF lo_ref_rat->integer = lo_target_rat->integer AND lo_ref_rat->denominator = lo_target_rat->denominator.
              result = true.
            ELSE.
              result = false.
              RETURN.
            ENDIF.

          WHEN lcl_lisp=>type_real.
            IF CAST lcl_lisp_real( lo_ref )->float_eq( CAST lcl_lisp_real( lo_ptr->cdr->car )->real ).
              result = true.
            ELSE.
              result = false.
              RETURN.
            ENDIF.

          WHEN lcl_lisp=>type_string.
            IF CAST lcl_lisp_string( lo_ref )->value = CAST lcl_lisp_string( lo_ptr->cdr->car )->value.
              result = true.
            ELSE.
              result = false.
              RETURN.
            ENDIF.

          WHEN lcl_lisp=>type_symbol.
            DATA(lo_symbol) = CAST lcl_lisp_symbol( lo_ref ).
            DATA(lo_s_car) = CAST lcl_lisp_symbol( lo_ptr->cdr->car ).
            IF lo_symbol->value = lo_s_car->value
              AND lo_symbol->index = lo_s_car->index.  " for uninterned symbols
              result = true.
            ELSE.
              result = false.
              RETURN.
            ENDIF.

          WHEN OTHERS.
            IF lo_ref = lo_ptr->cdr->car.
              result = true.
            ELSE.
              result = false.
              RETURN.
            ENDIF.
        ENDCASE.

        lo_ptr = lo_ptr->cdr.
      ENDIF.
    ENDMETHOD.                    "proc_eq

    METHOD proc_equal.
* equal? returns the same as eqv? when applied to booleans, symbols, numbers, characters, ports,
* procedures, and the empty list. If two objects are eqv?, they must be equal? as well.
* In all other cases, equal? may return either #t or #f.
* Even if its arguments are circular data structures, equal? must always terminate.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        throw( c_error_incorrect_input ).
      ENDIF.
      result = false.
      DATA(lo_ptr) = list.
      DATA(lo_slow) = list.

      WHILE lo_ptr->cdr NE nil.
        DATA(lo_next) = lo_ptr->cdr->car.
        "_validate lo_next.
          IF lo_next IS NOT BOUND.
            throw( c_error_incorrect_input ).
          ENDIF.

        result = lo_next->is_equal( lo_ptr->car ).
        IF result EQ false.
          RETURN.
        ENDIF.
        lo_ptr = lo_ptr->cdr.
        lo_slow = lo_slow->cdr.

        CHECK lo_ptr->cdr NE nil.
        lo_next = lo_ptr->cdr->car.
        "_validate lo_next.
          IF lo_next IS NOT BOUND.
            throw( c_error_incorrect_input ).
          ENDIF.

        result = lo_next->is_equal( lo_ptr->car ).
        IF result EQ false.
          RETURN.
        ENDIF.
        lo_ptr = lo_ptr->cdr.
        CHECK lo_ptr EQ lo_slow.
*       Circular list
        RETURN.
      ENDWHILE.

    ENDMETHOD.                    "proc_equal

    METHOD proc_eqv. " eqv?
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.

      DATA(lo_ptr) = list.
      WHILE lo_ptr->cdr NE nil.
        DATA(lo_next) = lo_ptr->cdr->car.
        "_validate lo_next.
          IF lo_next IS NOT BOUND.
            lcl_lisp=>throw( c_error_incorrect_input ).
          ENDIF.

        result = lo_next->is_equivalent( lo_ptr->car ).
        IF result EQ false.
          RETURN.
        ENDIF.
        lo_ptr = lo_ptr->cdr.
      ENDWHILE.

    ENDMETHOD.

*--------------------------------------------------------------------*
*   Hash-related functions
    METHOD proc_make_hash.
      result = lcl_lisp_new=>hash( list ).
    ENDMETHOD.                    "proc_make_hash

*   Get an element from a hash
    METHOD proc_hash_get.
      result = lcl_lisp_hash=>from_list( list = list
                                         msg = 'HASH-GET' )->get( list->cdr ).
    ENDMETHOD.                    "proc_hash_get

*   Insert an element into a hash
    METHOD proc_hash_insert.
      result = lcl_lisp_hash=>from_list( list = list
                                         msg = 'HASH-INSERT' )->insert( list->cdr ).
    ENDMETHOD.                    "proc_hash_insert

*   Remove an element from a hash
    METHOD proc_hash_remove.
      result = lcl_lisp_hash=>from_list( list = list
                                         msg = 'HASH-REMOVE' )->delete( list->cdr ).
    ENDMETHOD.                    "proc_hash_delete

*   Return the keys of a hash
    METHOD proc_hash_keys.
      result = lcl_lisp_hash=>from_list( list = list
                                         msg = 'HASH-KEYS' )->get_hash_keys( ).
    ENDMETHOD.                    "proc_hash_keys

    METHOD proc_is_string.
      "_is_type string.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        result = false.
        CHECK list->car IS BOUND.
        IF list->car->type EQ lcl_lisp=>type_string.
          result = true.
        ENDIF.
    ENDMETHOD.                    "proc_is_string

    METHOD proc_is_char.
      "_is_type char.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        result = false.
        CHECK list->car IS BOUND.
        IF list->car->type EQ lcl_lisp=>type_char.
          result = true.
        ENDIF.

    ENDMETHOD.                    "proc_is_char

    METHOD proc_is_hash.
      "_is_type hash.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        result = false.
        CHECK list->car IS BOUND.
        IF list->car->type EQ lcl_lisp=>type_hash.
          result = true.
        ENDIF.
    ENDMETHOD.                    "proc_is_hash

    METHOD proc_is_number. " argument in list->car
      result = false.
      CHECK list IS BOUND AND list->car IS BOUND.
      result = list->car->is_number( ).
    ENDMETHOD.                    "proc_is_number

    METHOD proc_is_complex.
      result = false.
      CHECK list IS BOUND AND list->car IS BOUND.
      result = list->car->is_number( ).
*      _is_type complex.
    ENDMETHOD.

    METHOD proc_is_real.
*     If z is a complex number, then (real? z) is true if and only if (zero? (imag-part z)) is true.
      result = false.
      CHECK list IS BOUND AND list->car IS BOUND.
      CASE list->car->type.
        WHEN lcl_lisp=>type_real
          OR lcl_lisp=>type_rational
          OR lcl_lisp=>type_integer.
          result = true.
      ENDCASE.
    ENDMETHOD.

    METHOD proc_is_rational.
      result = false.
      CHECK list IS BOUND AND list->car IS BOUND.
      CASE list->car->type.
        WHEN lcl_lisp=>type_rational
          OR lcl_lisp=>type_integer.
          result = true.
      ENDCASE.
    ENDMETHOD.

    METHOD proc_is_exact_integer.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      DATA lo_rat TYPE REF TO lcl_lisp_rational.
*     (exact-integer? z) procedure
*     Returns #t if z is both exact and an integer; otherwise returns #f.
      result = false.
      CHECK list->car IS BOUND.
      CASE list->car->type.
        WHEN lcl_lisp=>type_integer.
          result = true.
        WHEN lcl_lisp=>type_rational.
          lo_rat ?= list->car.
          CHECK lo_rat->denominator EQ 1.
          result = true.
      ENDCASE.
    ENDMETHOD.

    METHOD proc_is_integer.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

*     If x is an inexact real number, then (integer? x) is true if and only if (= x (round x)).
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_real TYPE REF TO lcl_lisp_real.
      DATA lv_real TYPE tv_real.

      result = false.
      CHECK list->car IS BOUND.
      CASE list->car->type.
        WHEN lcl_lisp=>type_integer.
          result = true.
        WHEN lcl_lisp=>type_rational.
          lo_rat ?= list->car.
          CHECK lo_rat->denominator EQ 1.
          result = true.
        WHEN lcl_lisp=>type_real.
          lv_real = CAST lcl_lisp_real( list->car )->real.
          CHECK trunc( lv_real ) EQ lv_real.
          result = true.
      ENDCASE.
    ENDMETHOD.                    "proc_is_integer

    METHOD proc_is_symbol.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_is_type symbol.
        result = false.
        CHECK list->car IS BOUND.
        IF list->car->type EQ lcl_lisp=>type_symbol.
          result = true.
        ENDIF.

    ENDMETHOD.

    METHOD proc_is_pair. " argument in list->car
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_is_type pair.
        result = false.
        CHECK list->car IS BOUND.
        IF list->car->type EQ lcl_lisp=>type_pair.
          result = true.
        ENDIF.
    ENDMETHOD.                    "proc_is_pair

    METHOD proc_is_boolean. " argument in list->car
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_is_type boolean.
        result = false.
        CHECK list->car IS BOUND.
        IF list->car->type EQ lcl_lisp=>type_boolean.
          result = true.
        ENDIF.
    ENDMETHOD.

    METHOD proc_is_vector.  " argument in list->car
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_is_type vector.
        result = false.
        CHECK list->car IS BOUND.
        IF list->car->type EQ lcl_lisp=>type_vector.
          result = true.
        ENDIF.
    ENDMETHOD.

    METHOD proc_is_list.  " argument in list->car
      "_validate: list, list->car, list->cdr.
      IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->cdr NE nil.
        throw( |list? takes only one argument| ).
      ENDIF.

      result = false.

      DATA(lo_ptr) = list->car.
      DATA(lo_slow) = lo_ptr.
*     Iterate over list
      WHILE lo_ptr->type EQ lcl_lisp=>type_pair.
        lo_ptr = lo_ptr->cdr.
        lo_slow = lo_slow->cdr.
        CHECK lo_ptr->type EQ lcl_lisp=>type_pair.
*       fast pointer takes 2 steps while slow pointer takes one
        lo_ptr = lo_ptr->cdr.
        CHECK lo_ptr = lo_slow.
*       If fast pointer eventually equals slow pointer, then we must be stuck in a circular list.
*       By deﬁnition, all lists have ﬁnite length and are terminated by the empty list,
*       so a circular list is not a list
        RETURN.
      ENDWHILE.

      CHECK lo_ptr EQ nil.
*     the last element of a list must be nil
      result = true.
    ENDMETHOD.                    "proc_is_list

    METHOD proc_boolean_list_is_equal.
      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_boolean.
        lo_test = lo_arg->car.
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil.
        throw( |boolean=? missing boolean argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_boolean.
        IF lo_arg->car NE lo_test.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |boolean=? wrong argument { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.                    "proc_is_boolean

    METHOD proc_is_procedure.
      result = false.
      CHECK list IS BOUND        " paramater (car) must not be valid
        AND list->car IS BOUND.  " Body
      result = list->car->is_procedure( ).
    ENDMETHOD.

    METHOD proc_is_alist. " not in standard?
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.

      DATA(lo_arg) = list->car.
      WHILE lo_arg->type = lcl_lisp=>type_pair.
        IF lo_arg->car->type = lcl_lisp=>type_pair.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      CHECK lo_arg EQ nil.
      result = true.
    ENDMETHOD.                    "proc_is_alist

    METHOD proc_abs.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      result = nil.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_is_last_param list.
        IF list->cdr NE nil.
          throw( |{ list->to_string( ) } Parameter mismatch| ).
        ENDIF.

      TRY.
          "_validate list->car.
            IF list->car IS NOT BOUND.
              throw( c_error_incorrect_input ).
            ENDIF.

          CASE list->car->type.
            WHEN lcl_lisp=>type_integer.
              lo_int ?= list->car.
              result = lcl_lisp_new=>integer( abs( lo_int->integer ) ).
            WHEN lcl_lisp=>type_real.
              lo_real ?= list->car.
              result = lcl_lisp_new=>integer( abs( lo_real->real ) ).
            WHEN lcl_lisp=>type_rational.
              lo_rat ?= list->car.
              result = lcl_lisp_new=>rational( nummer = abs( lo_rat->integer )
                                               denom = lo_rat->denominator ).
*            WHEN lcl_lisp=>type_complex.
            WHEN OTHERS.
              throw( |{ list->car->to_string( ) } is not a number in [abs]| ).
          ENDCASE.

        CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.
    ENDMETHOD.                    "proc_abs

    METHOD proc_sin.
      "_trigonometric sin '[sin]'.
        DATA carry TYPE f.
        DATA cell TYPE REF TO lcl_lisp.
        DATA lo_rat TYPE REF TO lcl_lisp_rational.
        DATA lo_int TYPE REF TO lcl_lisp_integer.
        DATA lo_real TYPE REF TO lcl_lisp_real.

        result = nil.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        TRY.
            "_get_number carry list->car `[sin]`.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = list->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*                  WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [sin]| ).
            ENDCASE.

            IF list->cdr NE nil.
              throw( |{ list->to_string( ) } Parameter mismatch| ).
            ENDIF.
            result = lcl_lisp_new=>real( sin( carry ) ).
          CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
            throw( lx_error->get_text( ) ).
        ENDTRY.
    ENDMETHOD.                    "proc_sin

    METHOD proc_cos.
      "_trigonometric cos '[cos]'.
        DATA carry TYPE f.
        DATA cell TYPE REF TO lcl_lisp.
        DATA lo_rat TYPE REF TO lcl_lisp_rational.
        DATA lo_int TYPE REF TO lcl_lisp_integer.
        DATA lo_real TYPE REF TO lcl_lisp_real.

        result = nil.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        TRY.
            "_get_number carry list->car `[cos]`.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = list->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*                  WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [cos]| ).
            ENDCASE.

            IF list->cdr NE nil.
              throw( |{ list->to_string( ) } Parameter mismatch| ).
            ENDIF.
            result = lcl_lisp_new=>real( cos( carry ) ).
          CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
            throw( lx_error->get_text( ) ).
        ENDTRY.
    ENDMETHOD.                    "proc_cos

    METHOD proc_tan.
      "_trigonometric tan '[tan]'.
        DATA carry TYPE f.
        DATA cell TYPE REF TO lcl_lisp.
        DATA lo_rat TYPE REF TO lcl_lisp_rational.
        DATA lo_int TYPE REF TO lcl_lisp_integer.
        DATA lo_real TYPE REF TO lcl_lisp_real.

        result = nil.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        TRY.
            "_get_number carry list->car `[tan]`.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = list->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*                  WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [tan]| ).
            ENDCASE.

            IF list->cdr NE nil.
              throw( |{ list->to_string( ) } Parameter mismatch| ).
            ENDIF.
            result = lcl_lisp_new=>real( tan( carry ) ).
          CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
            throw( lx_error->get_text( ) ).
        ENDTRY.
    ENDMETHOD.                    "proc_tan

    METHOD proc_asin.
      "_trigonometric asin '[asin]'.
        DATA carry TYPE f.
        DATA cell TYPE REF TO lcl_lisp.
        DATA lo_rat TYPE REF TO lcl_lisp_rational.
        DATA lo_int TYPE REF TO lcl_lisp_integer.
        DATA lo_real TYPE REF TO lcl_lisp_real.

        result = nil.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        TRY.
            "_get_number carry list->car `[asin]`.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = list->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*                  WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [asin]| ).
            ENDCASE.

            IF list->cdr NE nil.
              throw( |{ list->to_string( ) } Parameter mismatch| ).
            ENDIF.
            result = lcl_lisp_new=>real( asin( carry ) ).
          CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
            throw( lx_error->get_text( ) ).
        ENDTRY.
    ENDMETHOD.                    "proc_asin

    METHOD proc_acos.
      "_trigonometric acos '[acos]'.
        DATA carry TYPE f.
        DATA cell TYPE REF TO lcl_lisp.
        DATA lo_rat TYPE REF TO lcl_lisp_rational.
        DATA lo_int TYPE REF TO lcl_lisp_integer.
        DATA lo_real TYPE REF TO lcl_lisp_real.

        result = nil.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        TRY.
            "_get_number carry list->car `[acos]`.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = list->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*                  WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [acos]| ).
            ENDCASE.

            IF list->cdr NE nil.
              throw( |{ list->to_string( ) } Parameter mismatch| ).
            ENDIF.
            result = lcl_lisp_new=>real( acos( carry ) ).
          CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
            throw( lx_error->get_text( ) ).
        ENDTRY.
    ENDMETHOD.                    "proc_acos

    METHOD proc_atan.
      "_trigonometric atan '[atan]'.
        DATA carry TYPE f.
        DATA cell TYPE REF TO lcl_lisp.
        DATA lo_rat TYPE REF TO lcl_lisp_rational.
        DATA lo_int TYPE REF TO lcl_lisp_integer.
        DATA lo_real TYPE REF TO lcl_lisp_real.

        result = nil.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        TRY.
            "_get_number carry list->car `[atan]`.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = list->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*                  WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [atan]| ).
            ENDCASE.

            IF list->cdr NE nil.
              throw( |{ list->to_string( ) } Parameter mismatch| ).
            ENDIF.
            result = lcl_lisp_new=>real( atan( carry ) ).
          CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
            throw( lx_error->get_text( ) ).
        ENDTRY.
    ENDMETHOD.                    "proc_atan

    METHOD proc_sinh.
      "_trigonometric sinh '[sinh]'.
        DATA carry TYPE f.
        DATA cell TYPE REF TO lcl_lisp.
        DATA lo_rat TYPE REF TO lcl_lisp_rational.
        DATA lo_int TYPE REF TO lcl_lisp_integer.
        DATA lo_real TYPE REF TO lcl_lisp_real.

        result = nil.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        TRY.
            "_get_number carry list->car `[sinh]`.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = list->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*                  WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [sinh]| ).
            ENDCASE.

            IF list->cdr NE nil.
              throw( |{ list->to_string( ) } Parameter mismatch| ).
            ENDIF.
            result = lcl_lisp_new=>real( sinh( carry ) ).
          CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
            throw( lx_error->get_text( ) ).
        ENDTRY.
    ENDMETHOD.                    "proc_sinh

    METHOD proc_cosh.
      "_trigonometric cosh '[cosh]'.
        DATA carry TYPE f.
        DATA cell TYPE REF TO lcl_lisp.
        DATA lo_rat TYPE REF TO lcl_lisp_rational.
        DATA lo_int TYPE REF TO lcl_lisp_integer.
        DATA lo_real TYPE REF TO lcl_lisp_real.

        result = nil.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        TRY.
            "_get_number carry list->car `[cosh]`.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = list->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*                  WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [cosh]| ).
            ENDCASE.

            IF list->cdr NE nil.
              throw( |{ list->to_string( ) } Parameter mismatch| ).
            ENDIF.
            result = lcl_lisp_new=>real( cosh( carry ) ).
          CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
            throw( lx_error->get_text( ) ).
        ENDTRY.
    ENDMETHOD.                    "proc_cosh

    METHOD proc_tanh.
      "_trigonometric tanh '[tanh]'.
        DATA carry TYPE f.
        DATA cell TYPE REF TO lcl_lisp.
        DATA lo_rat TYPE REF TO lcl_lisp_rational.
        DATA lo_int TYPE REF TO lcl_lisp_integer.
        DATA lo_real TYPE REF TO lcl_lisp_real.

        result = nil.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

        TRY.
            "_get_number carry list->car `[tanh]`.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = list->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*                  WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [tanh]| ).
            ENDCASE.

            IF list->cdr NE nil.
              throw( |{ list->to_string( ) } Parameter mismatch| ).
            ENDIF.
            result = lcl_lisp_new=>real( tanh( carry ) ).
          CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
            throw( lx_error->get_text( ) ).
        ENDTRY.
    ENDMETHOD.                    "proc_tanh

    METHOD proc_asinh.
      DATA carry TYPE f.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      result = nil.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      TRY.
          "_get_number carry list->car '[asinh]'.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = list->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                 carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                 carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*              WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [asinh]| ).
            ENDCASE.

          "_is_last_param list.
            IF list->cdr NE nil.
              throw( |{ list->to_string( ) } Parameter mismatch| ).
            ENDIF.
          result = lcl_lisp_new=>real( log( carry + sqrt( carry ** 2 + 1 ) ) ).
        CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.
    ENDMETHOD.                    "proc_asinh

    METHOD proc_acosh.
      DATA carry TYPE f.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      result = nil.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      TRY.
          "_get_number carry list->car '[acosh]'.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = list->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                 carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                 carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*              WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [acosh]| ).
            ENDCASE.
          "_is_last_param list.
            IF list->cdr NE nil.
              throw( |{ list->to_string( ) } Parameter mismatch| ).
            ENDIF.
          result = lcl_lisp_new=>real( log( carry + sqrt( carry ** 2 - 1 ) ) ).
        CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.
    ENDMETHOD.                    "proc_acosh

    METHOD proc_atanh.
      DATA carry TYPE f.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      result = nil.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      TRY.
          "_get_number carry list->car '[atanh]'.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = list->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                 carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                 carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*              WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [atanh]| ).
            ENDCASE.
          "_is_last_param list.
            IF list->cdr NE nil.
              throw( |{ list->to_string( ) } Parameter mismatch| ).
            ENDIF.

          result = lcl_lisp_new=>real( ( log( 1 + carry ) - log( 1 - carry ) ) / 2 ).
        CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.
    ENDMETHOD.                    "proc_atanh

    METHOD proc_expt.
      DATA base1 TYPE tv_real.
      DATA exp1 TYPE tv_real.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      result = nil.
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_is_last_param list->cdr.
        IF list->cdr->cdr NE nil.
          throw( |{ list->cdr->to_string( ) } Parameter mismatch| ).
        ENDIF.

      "_get_number base1 list->car '[expt]'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
             base1 = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
             base1 = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            base1 = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [expt]| ).
        ENDCASE.
      TRY.
*          _get_number exp1 list->cdr->car '[expt]'.
          "_validate list->cdr->car.
          IF list->cdr->car IS NOT BOUND.
            lcl_lisp=>throw( c_error_incorrect_input ).
          ENDIF.

          cell = list->cdr->car.
          CASE cell->type.
            WHEN lcl_lisp=>type_integer.
              exp1 = CAST lcl_lisp_integer( cell )->integer.
              result = lcl_lisp_new=>number( ipow( base = base1  exp = exp1 ) ).
            WHEN lcl_lisp=>type_real.
              exp1 = CAST lcl_lisp_real( cell )->real.
              result = lcl_lisp_new=>number( base1 ** exp1 ).
            WHEN lcl_lisp=>type_rational.
              lo_rat ?= cell.
              exp1 = lo_rat->integer / lo_rat->denominator.
              result = lcl_lisp_new=>number( base1 ** exp1 ).
*            WHEN lcl_lisp=>type_complex.
            WHEN OTHERS.
              throw( |{ cell->to_string( ) } is not a number in [expt]| ).
          ENDCASE.

        CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.
    ENDMETHOD.                    "proc_expt

    METHOD proc_exp.
      "_math exp '[exp]' real.
          DATA carry TYPE tv_real.
    DATA cell TYPE REF TO lcl_lisp.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
    DATA lo_int TYPE REF TO lcl_lisp_integer.
    DATA lo_real TYPE REF TO lcl_lisp_real.

    result = nil.
    IF list IS NOT BOUND.
      lcl_lisp=>throw( c_error_incorrect_input ).
    ENDIF.
    TRY.
        "_get_number carry list->car &2.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
            carry = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
            carry = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            carry = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [exp]| ).
        ENDCASE.
         IF list->cdr NE nil.
           throw( |{ list->to_string( ) } Parameter mismatch| ).
         ENDIF.
        result = lcl_lisp_new=>real( exp( carry ) ).
    CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
      throw( lx_error->get_text( ) ).
    ENDTRY.
    ENDMETHOD.                    "proc_exp

    METHOD proc_log.
      "_math log '[log]' real.
          DATA carry TYPE tv_real.
    DATA cell TYPE REF TO lcl_lisp.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
    DATA lo_int TYPE REF TO lcl_lisp_integer.
    DATA lo_real TYPE REF TO lcl_lisp_real.

    result = nil.
    IF list IS NOT BOUND.
      lcl_lisp=>throw( c_error_incorrect_input ).
    ENDIF.
    TRY.
        "_get_number carry list->car &2.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
            carry = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
            carry = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            carry = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [log]| ).
        ENDCASE.
         IF list->cdr NE nil.
           throw( |{ list->to_string( ) } Parameter mismatch| ).
         ENDIF.
        result = lcl_lisp_new=>real( log( carry ) ).
    CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
      throw( lx_error->get_text( ) ).
    ENDTRY.
    ENDMETHOD.                    "proc_log

    METHOD proc_sqrt.
      "_math sqrt '[sqrt]' real.
          DATA carry TYPE tv_real.
    DATA cell TYPE REF TO lcl_lisp.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
    DATA lo_int TYPE REF TO lcl_lisp_integer.
    DATA lo_real TYPE REF TO lcl_lisp_real.

    result = nil.
    IF list IS NOT BOUND.
      lcl_lisp=>throw( c_error_incorrect_input ).
    ENDIF.
    TRY.
        "_get_number carry list->car &2.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
            carry = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
            carry = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            carry = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [sqrt]| ).
        ENDCASE.
         IF list->cdr NE nil.
           throw( |{ list->to_string( ) } Parameter mismatch| ).
         ENDIF.
        result = lcl_lisp_new=>real( sqrt( carry ) ).
    CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
      throw( lx_error->get_text( ) ).
    ENDTRY.
    ENDMETHOD.                    "proc_sqrt

    METHOD proc_floor.
      "_math floor '[floor]' number.
          DATA carry TYPE tv_real.
    DATA cell TYPE REF TO lcl_lisp.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
    DATA lo_int TYPE REF TO lcl_lisp_integer.
    DATA lo_real TYPE REF TO lcl_lisp_real.

    result = nil.
    IF list IS NOT BOUND.
      lcl_lisp=>throw( c_error_incorrect_input ).
    ENDIF.
    TRY.
        "_get_number carry list->car &2.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
            carry = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
            carry = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            carry = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [floor]| ).
        ENDCASE.
         IF list->cdr NE nil.
           throw( |{ list->to_string( ) } Parameter mismatch| ).
         ENDIF.
        result = lcl_lisp_new=>number( floor( carry ) ).
    CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
      throw( lx_error->get_text( ) ).
    ENDTRY.
    ENDMETHOD.                    "proc_floor

    METHOD proc_ceiling.
      "_math ceil '[ceil]' number.
          DATA carry TYPE tv_real.
    DATA cell TYPE REF TO lcl_lisp.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
    DATA lo_int TYPE REF TO lcl_lisp_integer.
    DATA lo_real TYPE REF TO lcl_lisp_real.

    result = nil.
    IF list IS NOT BOUND.
      lcl_lisp=>throw( c_error_incorrect_input ).
    ENDIF.
    TRY.
        "_get_number carry list->car &2.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
            carry = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
            carry = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            carry = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [ceil]| ).
        ENDCASE.
         IF list->cdr NE nil.
           throw( |{ list->to_string( ) } Parameter mismatch| ).
         ENDIF.
        result = lcl_lisp_new=>number( ceil( carry ) ).
    CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
      throw( lx_error->get_text( ) ).
    ENDTRY.
    ENDMETHOD.                    "proc_ceiling

    METHOD proc_truncate.
      "_math trunc '[truncate]' number.
          DATA carry TYPE tv_real.
    DATA cell TYPE REF TO lcl_lisp.
    DATA lo_rat TYPE REF TO lcl_lisp_rational.
    DATA lo_int TYPE REF TO lcl_lisp_integer.
    DATA lo_real TYPE REF TO lcl_lisp_real.

    result = nil.
    IF list IS NOT BOUND.
      lcl_lisp=>throw( c_error_incorrect_input ).
    ENDIF.
    TRY.
        "_get_number carry list->car &2.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
            carry = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
            carry = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            carry = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [truncate]| ).
        ENDCASE.

        "_is_last_param list.
         IF list->cdr NE nil.
           throw( |{ list->to_string( ) } Parameter mismatch| ).
         ENDIF.
        result = lcl_lisp_new=>number( trunc( carry ) ).
    CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
      throw( lx_error->get_text( ) ).
    ENDTRY.
    ENDMETHOD.                    "proc_truncate

    METHOD proc_round.
      DATA carry TYPE tv_real.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      result = nil.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_get_number carry list->car '[round]'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
             carry = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
             carry = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            carry = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [round]| ).
        ENDCASE.
      "_is_last_param list.
        IF list->cdr NE nil.
          throw( |{ list->to_string( ) } Parameter mismatch| ).
        ENDIF.

      TRY.
          result = lcl_lisp_new=>number( round( val = carry dec = 0 ) ).
        CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.
    ENDMETHOD.                    "proc_round

    METHOD proc_numerator.
      DATA lv_num TYPE tv_real.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_is_last_param list.
        IF list->cdr NE nil.
          throw( |{ list->to_string( ) } Parameter mismatch| ).
        ENDIF.

      cell = list->car.
      CASE cell->type.
        WHEN lcl_lisp=>type_integer.
          result = cell.

        WHEN lcl_lisp=>type_real.
          TRY.
              lv_num = CAST lcl_lisp_real( cell )->real.
              result = lcl_lisp_new=>number( lcl_lisp_real=>gcd( n = lv_num
                                                                 d = 1 ) * lv_num ).
            CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
              throw( lx_error->get_text( ) ).
          ENDTRY.

        WHEN lcl_lisp=>type_rational.
          lo_rat ?= cell.
          result = lcl_lisp_new=>integer( lo_rat->integer ).
*        WHEN lcl_lisp=>type_complex.
        WHEN OTHERS.
          throw( |{ cell->to_string( ) } is not a number in [numerator]| ).
      ENDCASE.
    ENDMETHOD.

    METHOD proc_denominator.
      DATA lo_frac TYPE REF TO lcl_lisp_real.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_is_last_param list.
        IF list->cdr NE nil.
          throw( |{ list->to_string( ) } Parameter mismatch| ).
        ENDIF.

      cell = list->car.
      CASE cell->type.
        WHEN lcl_lisp=>type_integer.
          result = lcl_lisp_new=>integer( 1 ).

        WHEN lcl_lisp=>type_real.
          TRY.
              lo_real ?= cell.
              lo_frac = lcl_lisp_new=>real( frac( lo_real->real ) ).
              IF lo_frac->float_eq( 0 ).
                result = lcl_lisp_new=>integer( 1 ).
              ELSE.
                result = lcl_lisp_new=>real( 1 / lo_frac->real ).
              ENDIF.
            CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
              throw( lx_error->get_text( ) ).
          ENDTRY.

        WHEN lcl_lisp=>type_rational.
          lo_rat ?= cell.
          result = lcl_lisp_new=>integer( lo_rat->denominator ).
*        WHEN lcl_lisp=>type_complex.
        WHEN OTHERS.
          throw( |{ cell->to_string( ) } is not a number in [denominator]| ).
      ENDCASE.
    ENDMETHOD.

    METHOD proc_remainder.
      DATA numerator TYPE tv_real.
      DATA denominator TYPE tv_real.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      result = nil.
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_get_number numerator list->car '[remainder]'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
             numerator = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
             numerator = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            numerator = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [remainder]| ).
        ENDCASE.
      "_get_number denominator list->cdr->car '[remainder]'.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->cdr->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
             denominator = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
             denominator = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            denominator = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [remainder]| ).
        ENDCASE.

      "_is_last_param list->cdr.
        IF list->cdr->cdr NE nil.
          throw( |{ list->cdr->to_string( ) } Parameter mismatch| ).
        ENDIF.

      TRY.
          result = lcl_lisp_new=>number( numerator - denominator * trunc( numerator / denominator ) ).
        CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.
    ENDMETHOD.                    "proc_remainder

    METHOD proc_quotient.
      DATA numerator TYPE tv_real.
      DATA denominator TYPE tv_real.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      result = nil.
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_get_number numerator list->car '[quotient]'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
             numerator = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
             numerator = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            numerator = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [quotient]| ).
        ENDCASE.

      "_get_number denominator list->cdr->car '[quotient]'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
             denominator = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
             denominator = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            denominator = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [quotient]| ).
        ENDCASE.

      "_is_last_param list->cdr.
        IF list->cdr->cdr NE nil.
          throw( |{ list->cdr->to_string( ) } Parameter mismatch| ).
        ENDIF.

      TRY.
          result = lcl_lisp_new=>number( trunc( numerator / denominator ) ).
        CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.
    ENDMETHOD.                    "proc_quotient

    METHOD proc_modulo.
      DATA numerator TYPE tv_real.
      DATA base TYPE tv_real.
      DATA mod TYPE tv_real.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      result = nil.
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_get_number numerator list->car '[modulo]'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
            numerator = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
            numerator = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            numerator = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [modulo]| ).
        ENDCASE.

      "_get_number base list->cdr->car '[modulo]'.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->cdr->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
            base = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
            base = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            base = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [modulo]| ).
        ENDCASE.

      "_is_last_param list->cdr.
        IF list->cdr->cdr NE nil.
          throw( |{ list->cdr->to_string( ) } Parameter mismatch| ).
        ENDIF.

      TRY.
          mod = numerator MOD base.
          IF sign( base ) LE 0 AND mod NE 0.
            mod = mod + base.
          ENDIF.
          result = lcl_lisp_new=>number( mod ).
        CATCH cx_sy_arithmetic_error cx_sy_conversion_no_number INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.
    ENDMETHOD.                    "proc_modulo

    METHOD proc_random.
      DATA lv_high TYPE i.

      result = nil.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_integer list->car '[random]'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in [random]` ) ##NO_TEXT.
        ENDIF.

      "_is_last_param list.
        IF list->cdr NE nil.
          throw( |{ list->to_string( ) } Parameter mismatch| ).
        ENDIF.
      TRY.
          DATA(lo_rnd) = cl_abap_random=>create( cl_abap_random=>seed( ) ).
          lv_high = CAST lcl_lisp_integer( list->car )->integer.
          result = lcl_lisp_new=>number( lo_rnd->intinrange( high = lv_high ) ).
        CATCH cx_dynamic_check INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.
    ENDMETHOD.                    "proc_random

    METHOD proc_is_exact.
      DATA lo_number TYPE REF TO lcl_lisp_number.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_number list->car `exact?`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
         ENDIF.
        CASE list->car->type.
          WHEN lcl_lisp=>type_integer
            OR lcl_lisp=>type_real
            OR lcl_lisp=>type_rational
            OR lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ list->car->to_string( ) } is not a number in exact?| ) ##NO_TEXT.
        ENDCASE.

      lo_number ?= list->car.
      result = lo_number->is_exact( ).
    ENDMETHOD.

    METHOD proc_is_inexact.
      DATA lo_number TYPE REF TO lcl_lisp_number.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_number list->car `inexact?`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
         ENDIF.
        CASE list->car->type.
          WHEN lcl_lisp=>type_integer
            OR lcl_lisp=>type_real
            OR lcl_lisp=>type_rational
            OR lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ list->car->to_string( ) } is not a number in inexact?| ) ##NO_TEXT.
        ENDCASE.
      lo_number ?= list->car.
      result = lo_number->is_inexact( ).
    ENDMETHOD.

    METHOD proc_to_exact.
      DATA lo_number TYPE REF TO lcl_lisp_number.
      DATA lo_real TYPE REF TO lcl_lisp_real.
      DATA lv_denom TYPE tv_int.
      DATA lv_nummer TYPE tv_int.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_number list->car `exact`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
         ENDIF.
        CASE list->car->type.
          WHEN lcl_lisp=>type_integer
            OR lcl_lisp=>type_real
            OR lcl_lisp=>type_rational
            OR lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ list->car->to_string( ) } is not a number in exact| ) ##NO_TEXT.
        ENDCASE.

      lo_number ?= list->car.
      IF lo_number->exact EQ abap_true.
        result = lo_number.
      ELSE.
        CASE lo_number->type.
          WHEN lcl_lisp=>type_real.
            lo_real ?= lo_number.
            IF abs( lo_real->real ) GT 1.
              lv_denom = trunc( cl_abap_math=>max_int4 / lo_real->real ).
              lv_nummer = round( val = lo_real->real * lv_denom dec = 0 ).
            ELSE.
              lv_nummer = trunc( cl_abap_math=>max_int4 * lo_real->real ).
              lv_denom = round( val = lv_nummer / lo_real->real dec = 0 ).
            ENDIF.

            result = lcl_lisp_new=>rational( nummer = lv_nummer
                                             denom = lv_denom ).
          WHEN OTHERS.
            throw( |no exact representation of { lo_number->to_string( ) }| ).
        ENDCASE.
      ENDIF.
    ENDMETHOD.

    METHOD proc_to_inexact.
      DATA lo_number TYPE REF TO lcl_lisp_number.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lv_real TYPE tv_real.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_number list->car `inexact`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
         ENDIF.
        CASE list->car->type.
          WHEN lcl_lisp=>type_integer
            OR lcl_lisp=>type_real
            OR lcl_lisp=>type_rational
            OR lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ list->car->to_string( ) } is not a number in inexact| ) ##NO_TEXT.
        ENDCASE.

      lo_number ?= list->car.
      IF lo_number->exact EQ abap_true.
        CASE lo_number->type.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= lo_number.
            lv_real = lo_rat->integer / lo_rat->denominator.
            result = lcl_lisp_new=>real( lv_real ).
          WHEN lcl_lisp=>type_integer.
            lo_int ?= lo_number.
            lv_real = lo_int->integer.
            result = lcl_lisp_new=>real( lv_real ).
          WHEN OTHERS.
            throw( |no inexact representation of { lo_number->to_string( ) }| ).
        ENDCASE.
      ELSE.
        result = lo_number.
      ENDIF.
    ENDMETHOD.

    METHOD proc_num_to_string.
      DATA lv_radix TYPE i VALUE 10.
      DATA lv_radix_error TYPE abap_boolean VALUE abap_false.
      DATA lv_text TYPE string.
      DATA lv_int TYPE tv_int.
      DATA lv_real TYPE tv_real.
      DATA lv_digit TYPE i.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_validate_number list->car `number->string`.
      IF list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
*     Optional radix
      IF list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      IF list->cdr NE nil.
        "_validate_integer list->cdr->car `number->string`.
          IF list->cdr->car IS NOT BOUND.
            lcl_lisp=>throw( c_error_incorrect_input ).
          ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in number->string` ) ##NO_TEXT.
        ENDIF.

        lv_radix = CAST lcl_lisp_integer( list->cdr->car )->integer.
      ENDIF.

      CASE list->car->type.
        WHEN lcl_lisp=>type_integer.
          lv_int = CAST lcl_lisp_integer( list->car )->integer.
          CASE lv_radix.
            WHEN 10.
              lv_text = lv_int.
              result = lcl_lisp_new=>string( condense( lv_text ) ).

            WHEN 2 OR 8 OR 16.
              CLEAR lv_text.
              WHILE lv_int GT 0.
                lv_digit = lv_int MOD lv_radix.
                lv_int = lv_int DIV lv_radix.
                lv_text = c_hex_digits+lv_digit(1) && lv_text.
              ENDWHILE.
              result = lcl_lisp_new=>string( lv_text ).

            WHEN OTHERS.
              lv_radix_error = abap_true.
          ENDCASE.

        WHEN lcl_lisp=>type_real.
          lv_radix_error = xsdbool( lv_radix NE 10 ).
          lv_real = CAST lcl_lisp_real( list->car )->real.
          lv_text = lv_real.
          result = lcl_lisp_new=>string( condense( lv_text ) ).

        WHEN lcl_lisp=>type_rational.
          lv_radix_error = xsdbool( lv_radix NE 10 ).
          lv_text = list->car->to_string( ).
          result = lcl_lisp_new=>string( lv_text ).

        WHEN OTHERS.
          throw( |{ list->car->to_string( ) } is not a number in number->string| ) ##NO_TEXT.
      ENDCASE.
      IF lv_radix_error EQ abap_true.
        throw( |{ list->car->to_string( ) } radix { lv_radix } not supported in number->string| ) ##NO_TEXT.
      ENDIF.

    ENDMETHOD.

    METHOD string_to_number.
      DATA lv_radix_error TYPE abap_boolean VALUE abap_false.

      result = false.
      CHECK iv_text NE space.
      TRY.
          CASE iv_radix.
            WHEN 2.
              result = lcl_lisp_new=>binary( iv_text ).
            WHEN 8.
              result = lcl_lisp_new=>octal( iv_text ).
            WHEN 10.
              result = lcl_lisp_new=>number( iv_text ).
            WHEN 16.
              result = lcl_lisp_new=>hex( iv_text ).
            WHEN OTHERS.
              lv_radix_error = abap_true.
          ENDCASE.
        CATCH lcx_lisp_exception cx_sy_conversion_error ##NO_HANDLER.
      ENDTRY.
      CHECK lv_radix_error EQ abap_true.
      throw( |radix ({ iv_radix }) must be 2, 8, 10 or 16 in string->number| ).
    ENDMETHOD.

    METHOD proc_string_to_num.
      DATA lv_radix TYPE i VALUE 10.

      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_validate_string list->car `string->number`.
        IF list->car->type NE lcl_lisp=>type_string.
          throw( list->car->to_string( ) && ` is not a string in string->number` ) ##NO_TEXT.
        ENDIF.

*     Optional radix
      "_validate list->cdr.
      IF list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->cdr NE nil.
        "_validate_integer list->cdr->car `string->number`.
          IF list->cdr->car IS NOT BOUND.
            lcl_lisp=>throw( c_error_incorrect_input ).
          ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in string->number` ) ##NO_TEXT.
        ENDIF.

        lv_radix = CAST lcl_lisp_integer( list->cdr->car )->integer.
      ENDIF.

      result = string_to_number( iv_text = list->car->value
                                 iv_radix = lv_radix ).
    ENDMETHOD.

    METHOD proc_newline.
      result = write( io_elem = lcl_lisp=>new_line
                      io_arg = list ).
    ENDMETHOD.

    METHOD proc_write.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND. .
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      result = write( io_elem = list->car
                      io_arg = list->cdr ).
    ENDMETHOD.

    METHOD proc_write_string.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND. .
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_validate_string list->car `write-string`.
        IF list->car->type NE lcl_lisp=>type_string.
          throw( list->car->to_string( ) && ` is not a string in write-string` ) ##NO_TEXT.
        ENDIF.

      result = write( io_elem = list->car
                      io_arg = list->cdr ).
    ENDMETHOD.

    METHOD proc_write_char.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_validate_char list->car `write-char`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_char.
          throw( list->car->to_string( ) && ` is not a char in write-char` ) ##NO_TEXT.
        ENDIF.

      result = write( io_elem = list->car
                      io_arg = list->cdr ).
    ENDMETHOD.

    METHOD proc_display.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      result = display( io_elem = list->car
                        io_arg = list->cdr ).
    ENDMETHOD.

    METHOD proc_read.
      result = read( io_arg = list ).
    ENDMETHOD.

    METHOD proc_read_char.
      result = read_char( io_arg = list ).
    ENDMETHOD.

    METHOD proc_read_string.
      result = read_string( io_arg = list ).
    ENDMETHOD.

    METHOD proc_peek_char.
      "_optional_port list input `peek-char`.
      DATA li_port TYPE REF TO lif_input_port.

      TRY.
          IF list->type EQ lcl_lisp=>type_pair.
            "_validate_port list->car `peek-char`.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            IF list->car->type NE lcl_lisp=>type_port.
              throw( list->car->to_string( ) && ` is not a port in peek-char` ) ##NO_TEXT.
            ENDIF.

            li_port ?= list->car.
          ELSE.
            li_port ?= proc_current_input_port( nil ).
          ENDIF.
        CATCH cx_root INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.
      result = lcl_lisp_new=>char( li_port->peek_char( ) ).
    ENDMETHOD.

    METHOD proc_is_char_ready.
      "_optional_port list input `char-ready?`.
      DATA li_port TYPE REF TO lif_input_port.

      TRY.
          IF list->type EQ lcl_lisp=>type_pair.
            "_validate_port list->car `char-ready?`.
            IF list->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            IF list->car->type NE lcl_lisp=>type_port.
              throw( list->car->to_string( ) && ` is not a port in char-ready?` ) ##NO_TEXT.
            ENDIF.

            li_port ?= list->car.
          ELSE.
            li_port ?= proc_current_input_port( nil ).
          ENDIF.
        CATCH cx_root INTO DATA(lx_error).
          throw( lx_error->get_text( ) ).
      ENDTRY.

      result = false.
      CHECK li_port->is_char_ready( ).
      result = true.
    ENDMETHOD.

    METHOD proc_string.
      DATA lo_ptr TYPE REF TO lcl_lisp.
      DATA lv_text TYPE string.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      lo_ptr = list.
      WHILE lo_ptr->type EQ lcl_lisp=>type_pair AND lo_ptr->car->type EQ lcl_lisp=>type_char.
        lv_text = lv_text && lo_ptr->car->value+0(1).
        lo_ptr = lo_ptr->cdr.
      ENDWHILE.
      IF lo_ptr NE nil.
        throw( |{ lo_ptr->to_string( ) } is not a list of char | ).
      ENDIF.

      result = lcl_lisp_new=>string( lv_text ).
    ENDMETHOD.

    METHOD proc_make_string.
      DATA lv_len TYPE tv_index.
      DATA lv_char TYPE tv_char.
      DATA lv_text TYPE string.

      "_validate list.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      "_validate_integer list->car 'make-string'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in make-string` ) ##NO_TEXT.
        ENDIF.

      lv_len = CAST lcl_lisp_integer( list->car )->integer.

      IF list->cdr NE nil.
        DATA(lo_char) = list->cdr->car.
        "_validate_char lo_char 'make-string'.
        IF lo_char IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF lo_char->type NE lcl_lisp=>type_char.
          throw( lo_char->to_string( ) && ` is not a char in make-string` ) ##NO_TEXT.
        ENDIF.

        lv_char = lo_char->value+0(1).
      ENDIF.

      DO lv_len TIMES.
        CONCATENATE lv_text lv_char INTO lv_text RESPECTING BLANKS.
      ENDDO.
      result = lcl_lisp_new=>string( lv_text ).
    ENDMETHOD.

    METHOD proc_string_to_list.
      DATA lv_char TYPE c LENGTH 1.
      DATA lv_start TYPE tv_index.
      DATA lv_len TYPE tv_index.
      DATA lv_len_1 TYPE tv_index.
      DATA lv_text TYPE string.
      DATA lo_int TYPE REF TO lcl_lisp_integer.

      "_validate: list, list->car, list->cdr.
        IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      IF list->cdr NE nil.
        "_validate_integer list->cdr->car 'string->list start'.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in string->list start` ) ##NO_TEXT.
        ENDIF.

        lv_start = CAST lcl_lisp_integer( list->cdr->car )->integer.

        "_validate list->cdr->cdr.
        IF list->cdr->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->cdr NE nil.
          "_validate_integer list->cdr->cdr->car 'string->list end'.
            IF list->cdr->cdr->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            IF list->cdr->cdr->car->type NE lcl_lisp=>type_integer.
              throw( list->cdr->cdr->car->to_string( ) && ` is not an integer in string->list end` ) ##NO_TEXT.
            ENDIF.

          lv_len = CAST lcl_lisp_integer( list->cdr->cdr->car )->integer.
          lv_len = lv_len - lv_start.
          lv_text = list->car->value+lv_start(lv_len).
        ELSE.
          lv_text = list->car->value+lv_start.
        ENDIF.

      ELSE.
        lv_text = list->car->value.
      ENDIF.

      result = nil.
      CHECK lv_text IS NOT INITIAL.

      lv_char = lv_text+0(1).
      result = lcl_lisp_new=>cons( io_car = lcl_lisp_new=>char( lv_char ) ).
      lv_len_1 = strlen( lv_text ) - 1.
      DATA(lo_ptr) = result.

      DO lv_len_1 TIMES.
        lv_char = lv_text+sy-index.
        lo_ptr = lo_ptr->cdr = lcl_lisp_new=>cons( io_car = lcl_lisp_new=>char( lv_char ) ).
      ENDDO.
    ENDMETHOD.

    METHOD proc_string_length.
      "_validate list.
        IF list IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
      "_validate_string list->car 'string-length'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_string.
          throw( list->car->to_string( ) && ` is not a string in string-length` ) ##NO_TEXT.
        ENDIF.

      result = lcl_lisp_new=>integer( strlen( list->car->value ) ).
    ENDMETHOD.

    METHOD proc_string_copy.
      DATA lv_start TYPE tv_index.
      DATA lv_len TYPE tv_index.

      DATA lv_text TYPE string.
      DATA lo_int TYPE REF TO lcl_lisp_integer.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_string list->car 'string-copy'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_string.
          throw( list->car->to_string( ) && ` is not a string in string-copy` ) ##NO_TEXT.
        ENDIF.

      "_validate list->cdr.
        IF list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

*     lv_text = substring( val = list->car->value off = lv_start len = lv_len ).
      IF list->cdr EQ nil.
        lv_text = list->car->value.
      ELSE.
        "_validate_integer list->cdr->car 'string-copy start'.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in string-copy start` ) ##NO_TEXT.
        ENDIF.

        lv_start = CAST lcl_lisp_integer( list->cdr->car )->integer.

        "_validate list->cdr->cdr.
        IF list->cdr->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->cdr NE nil.
          "_validate_integer list->cdr->cdr->car 'string-copy end'.
            IF list->cdr->cdr->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            IF list->cdr->cdr->car->type NE lcl_lisp=>type_integer.
              throw( list->cdr->cdr->car->to_string( ) && ` is not an integer in string-copy end` ) ##NO_TEXT.
            ENDIF.

          lv_len = CAST lcl_lisp_integer( list->cdr->cdr->car )->integer.
          lv_len = lv_len - lv_start.
          lv_text = list->car->value+lv_start(lv_len).
        ELSE.
          lv_text = list->car->value+lv_start.
        ENDIF.
      ENDIF.

      result = lcl_lisp_new=>string( lv_text ).
    ENDMETHOD.

    METHOD proc_string_ref.
      DATA lv_index TYPE tv_index.
      DATA lv_char TYPE c LENGTH 1.
      DATA lo_int TYPE REF TO lcl_lisp_integer.

      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_validate_string list->car 'string-ref'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_string.
          throw( list->car->to_string( ) && ` is not a string in string-ref` ) ##NO_TEXT.
        ENDIF.

      "_validate_index list->cdr->car 'string-ref'.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in string-ref` ) ##NO_TEXT.
        ENDIF.
        IF CAST lcl_lisp_integer( list->cdr->car )->integer LT 0.
          throw( list->cdr->car->to_string( ) && ` must be non-negative in string-ref` ) ##NO_TEXT.
        ENDIF.

      lv_index = CAST lcl_lisp_integer( list->cdr->car )->integer.
      lv_char = list->car->value+lv_index(1).

      result = lcl_lisp_new=>char( lv_char ).
    ENDMETHOD.

    METHOD proc_string_set.
      DATA lv_index TYPE tv_index.
      DATA lv_char TYPE c LENGTH 1.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_char TYPE REF TO lcl_lisp_char.
      DATA lo_string TYPE REF TO lcl_lisp_string.

      DATA lv_len TYPE tv_index.
      DATA lv_text TYPE string.

      "_validate: list, list->cdr, list->cdr->cdr.
        IF list IS NOT BOUND OR list->cdr IS NOT BOUND OR list->cdr->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
      "_validate_string list->car 'string-set!'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_string.
          throw( list->car->to_string( ) && ` is not a string in string-set!` ) ##NO_TEXT.
        ENDIF.

      "_validate_index list->cdr->car 'string-set!'.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in string-set!` ) ##NO_TEXT.
        ENDIF.
        IF CAST lcl_lisp_integer( list->cdr->car )->integer LT 0.
          throw( list->cdr->car->to_string( ) && ` must be non-negative in string-set!` ) ##NO_TEXT.
        ENDIF.

      "_validate_char list->cdr->cdr->car 'string-set!'.
        IF list->cdr->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->cdr->car->type NE lcl_lisp=>type_char.
          throw( list->cdr->cdr->car->to_string( ) && ` is not a char in string-set!` ) ##NO_TEXT.
        ENDIF.

      lo_char ?= list->cdr->cdr->car.
      lv_char = lo_char->value(1).

      lv_index = CAST lcl_lisp_integer( list->cdr->car )->integer.

      lo_string ?= list->car.
      "_validate_mutable lo_string `in string-set!`.
        IF lo_string IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF lo_string->mutable EQ abap_false.
          throw( |constant list in string-set! cannot be changed| ) ##NO_TEXT.
        ENDIF.
*     lo_string->value+lv_index(1) = lv_char.  "Not allowed so split in (left, new char, right)

*     left part
      IF lv_index GT 0.
        lv_len = lv_index.
        lv_text = lo_string->value+0(lv_len).
      ENDIF.
*     compose with new char and right part
      lv_index = lv_index + 1.
      lv_text = lv_text && lv_char && lo_string->value+lv_index.

      lo_string->value = lv_text.
      result = lo_string.
    ENDMETHOD.

    METHOD proc_list_to_string.
      DATA lv_text TYPE string.
      DATA lo_ptr TYPE REF TO lcl_lisp.

      "_validate: list, list->car.
        IF list IS NOT BOUND OR list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      lo_ptr = list->car.
      WHILE lo_ptr->type = lcl_lisp=>type_pair AND lo_ptr->car->type EQ lcl_lisp=>type_char.
        lv_text = lv_text && lo_ptr->car->value+0(1).
        lo_ptr = lo_ptr->cdr.
      ENDWHILE.
      IF lo_ptr NE nil.
        throw( |{ lo_ptr->to_string( ) } is not a list of char| ).
      ENDIF.
      result = lcl_lisp_new=>string( lv_text ).
    ENDMETHOD.

    METHOD proc_symbol_to_string.
      "_validate: list, list->car.
        IF list IS NOT BOUND OR list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      IF list->car->type = lcl_lisp=>type_symbol.
        result = lcl_lisp_new=>string( value = list->car->value
                                       iv_mutable = abap_false ).
      ELSE.
        throw( |{ list->car->to_string( ) } is not a symbol| ).
      ENDIF.
    ENDMETHOD.

    METHOD proc_string_to_symbol.
      "_validate: list, list->car.
        IF list IS NOT BOUND OR list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      IF list->car->type = lcl_lisp=>type_string.
        result = lcl_lisp_new=>symbol( list->car->value ).
      ELSE.
        throw( |{ list->car->to_string( ) } is not a string| ).
      ENDIF.
    ENDMETHOD.

    METHOD proc_string_append.
      DATA lv_text TYPE string.
      DATA lo_ptr TYPE REF TO lcl_lisp.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      lo_ptr = list.
      WHILE lo_ptr->type = lcl_lisp=>type_pair AND lo_ptr->car->type EQ lcl_lisp=>type_string.
        lv_text = lv_text && lo_ptr->car->value.
        lo_ptr = lo_ptr->cdr.
      ENDWHILE.
      IF lo_ptr NE nil.
        throw( |{ lo_ptr->car->to_string( ) } is not a string| ).
      ENDIF.
      result = lcl_lisp_new=>string( lv_text ).
    ENDMETHOD.

    METHOD proc_max.
      DATA lo_ptr TYPE REF TO lcl_lisp.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      DATA carry TYPE tv_real.
      DATA lv_max TYPE tv_real.

      "_validate: list, list->cdr.
        IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      "_get_number lv_max list->car '[max]'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
             lv_max = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
             lv_max = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            lv_max = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [max]| ).
        ENDCASE.

      lo_ptr = list->cdr.
      WHILE lo_ptr->type EQ lcl_lisp=>type_pair.
        "_get_number carry lo_ptr->car '[max]'.
        IF lo_ptr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = lo_ptr->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
             carry = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
             carry = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            carry = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [max]| ).
        ENDCASE.

        lv_max = nmax( val1 = carry val2 = lv_max ).
        lo_ptr = lo_ptr->cdr.
      ENDWHILE.
      result = lcl_lisp_new=>number( lv_max ).
    ENDMETHOD.

    METHOD proc_min.
      DATA lo_ptr TYPE REF TO lcl_lisp.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      DATA carry TYPE tv_real.
      DATA lv_min TYPE tv_real.

      "_validate: list, list->cdr.
        IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
      "_get_number lv_min list->car '[min]'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
            lv_min = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
            lv_min = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            lv_min = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [min]| ).
        ENDCASE.

      lo_ptr = list->cdr.
      WHILE lo_ptr->type EQ lcl_lisp=>type_pair.
        "_get_number carry lo_ptr->car '[min]'.
        IF lo_ptr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = lo_ptr->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
             carry = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
             carry = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            carry = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [min]| ).
        ENDCASE.

        lv_min = nmin( val1 = carry val2 = lv_min ).
        lo_ptr = lo_ptr->cdr.
      ENDWHILE.
      result = lcl_lisp_new=>number( lv_min ).
    ENDMETHOD.

    METHOD proc_gcd.
*     non-negative greatest common divisor of the arguments
      DATA lo_ptr TYPE REF TO lcl_lisp.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.
      DATA carry TYPE tv_real.
      DATA lv_gcd TYPE tv_real VALUE 0.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list NE nil.

        "_get_number lv_gcd list->car '[gcd]'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
             lv_gcd = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
             lv_gcd = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            lv_gcd = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [gcd]| ).
        ENDCASE.


        lo_ptr = list->cdr.
        WHILE lo_ptr->type EQ lcl_lisp=>type_pair.
          "_get_number carry lo_ptr->car '[gcd]'.
            IF lo_ptr->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = lo_ptr->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                 carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                 carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*              WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [gcd]| ).
            ENDCASE.

          lv_gcd = lcl_lisp_rational=>gcd( n = carry d = lv_gcd ).
          lo_ptr = lo_ptr->cdr.
        ENDWHILE.
      ENDIF.
      result = lcl_lisp_new=>number( lv_gcd ).
    ENDMETHOD.

    METHOD proc_lcm.
*     non-negative least common multiple of the arguments
      DATA lo_ptr TYPE REF TO lcl_lisp.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      DATA carry TYPE tv_real.
      DATA lv_lcm TYPE tv_real VALUE 1.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list NE nil.

        "_get_number lv_lcm list->car '[lcm]'.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        cell = list->car.
        CASE cell->type.
          WHEN lcl_lisp=>type_integer.
             lv_lcm = CAST lcl_lisp_integer( cell )->integer.
          WHEN lcl_lisp=>type_real.
             lv_lcm = CAST lcl_lisp_real( cell )->real.
          WHEN lcl_lisp=>type_rational.
            lo_rat ?= cell.
            lv_lcm = lo_rat->integer / lo_rat->denominator.
*          WHEN lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ cell->to_string( ) } is not a number in [lcm]| ).
        ENDCASE.

        lo_ptr = list->cdr.
        WHILE lo_ptr->type EQ lcl_lisp=>type_pair.
          "_get_number carry lo_ptr->car '[lcm]'.
            IF lo_ptr->car IS NOT BOUND.
              lcl_lisp=>throw( c_error_incorrect_input ).
            ENDIF.
            cell = lo_ptr->car.
            CASE cell->type.
              WHEN lcl_lisp=>type_integer.
                 carry = CAST lcl_lisp_integer( cell )->integer.
              WHEN lcl_lisp=>type_real.
                 carry = CAST lcl_lisp_real( cell )->real.
              WHEN lcl_lisp=>type_rational.
                lo_rat ?= cell.
                carry = lo_rat->integer / lo_rat->denominator.
*              WHEN lcl_lisp=>type_complex.
              WHEN OTHERS.
                throw( |{ cell->to_string( ) } is not a number in [lcm]| ).
            ENDCASE.

          lv_lcm = lv_lcm * carry / lcl_lisp_rational=>gcd( n = carry d = lv_lcm ).
          lo_ptr = lo_ptr->cdr.
        ENDWHILE.
      ENDIF.
      result = lcl_lisp_new=>number( abs( lv_lcm ) ).
    ENDMETHOD.

    METHOD proc_is_textual_port.
      DATA lo_port TYPE REF TO lcl_lisp_port.

      "_validate: list, list->car.
        IF list IS NOT BOUND OR list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.

      result = false.
      CHECK list->car->type EQ lcl_lisp=>type_port.
      lo_port ?= list->car.
      CHECK lo_port->port_type EQ lcl_lisp_port=>c_port_textual.
      result = true.
    ENDMETHOD.

    METHOD proc_is_binary_port.
      DATA lo_port TYPE REF TO lcl_lisp_port.

      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      CHECK list->car->type EQ lcl_lisp=>type_port.
      lo_port ?= list->car.
      CHECK lo_port->port_type EQ lcl_lisp_port=>c_port_binary.
      result = true.
    ENDMETHOD.

    METHOD proc_is_port.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      CHECK list->car->type EQ lcl_lisp=>type_port.
      result = true.
    ENDMETHOD.

    METHOD proc_is_input_port.
      DATA lo_port TYPE REF TO lcl_lisp_port.

      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      CHECK list->car->type EQ lcl_lisp=>type_port.
      lo_port ?= list->car.
      CHECK lo_port->input EQ abap_true.
      result = true.
    ENDMETHOD.

    METHOD proc_is_output_port.
      DATA lo_port TYPE REF TO lcl_lisp_port.

      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      CHECK list->car->type EQ lcl_lisp=>type_port.
      lo_port ?= list->car.
      CHECK lo_port->output EQ abap_true.
      result = true.
    ENDMETHOD.

    METHOD proc_is_open_input_port.
      result = false.
      CHECK proc_is_input_port( list ) EQ true.
      result = true.
    ENDMETHOD.

    METHOD proc_is_open_output_port.
      result = false.
      CHECK proc_is_output_port( list ) EQ true.
      result = true.
    ENDMETHOD.

    METHOD proc_current_output_port.
      result = eval( element = lcl_lisp_new=>cons( io_car = go_output_port )  " no parameters
                     environment = env ).
    ENDMETHOD.

    METHOD proc_current_input_port.
      result = eval( element = lcl_lisp_new=>cons( io_car = go_input_port )
                     environment = env ).
    ENDMETHOD.

    METHOD proc_current_error_port.
      result = eval( element = lcl_lisp_new=>cons( io_car = go_error_port )
                     environment = env ).
    ENDMETHOD.

    METHOD proc_close_output_port.
      DATA lo_port TYPE REF TO lcl_lisp_port.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_port list->car `close-output-port`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_port.
          throw( list->car->to_string( ) && ` is not a port in close-output-port` ) ##NO_TEXT.
        ENDIF.

      lo_port ?= list->car.
      lo_port->close_output( ).
      result = nil.
    ENDMETHOD.

    METHOD proc_close_input_port.
      DATA lo_port TYPE REF TO lcl_lisp_port.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_port list->car `close-input-port`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_port.
          throw( list->car->to_string( ) && ` is not a port in close-input-port` ) ##NO_TEXT.
        ENDIF.

      lo_port ?= list->car.
      lo_port->close_input( ).
      result = nil.
    ENDMETHOD.

    METHOD proc_close_port.
      DATA lo_port TYPE REF TO lcl_lisp_port.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_port list->car `close-port`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_port.
          throw( list->car->to_string( ) && ` is not a port in close-port` ) ##NO_TEXT.
        ENDIF.

      lo_port ?= list->car.
      lo_port->close( ).
      result = nil.
    ENDMETHOD.

    METHOD proc_open_output_string.
      result = lcl_lisp_new=>port( iv_port_type = lcl_lisp_port=>c_port_textual
                                   iv_output = abap_true
                                   iv_input = abap_false
                                   iv_error = abap_false
                                   iv_buffered = abap_true
                                   io_out = go_out ).
    ENDMETHOD.

    METHOD proc_open_input_string.
      DATA lo_port TYPE REF TO lcl_lisp_port.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_string list->car `open-input-string`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_string.
          throw( list->car->to_string( ) && ` is not a string in open-input-string` ) ##NO_TEXT.
        ENDIF.

      lo_port = lcl_lisp_new=>port( iv_port_type = lcl_lisp_port=>c_port_textual
                                    iv_output = abap_false
                                    iv_input = abap_true
                                    iv_error = abap_false
                                    iv_buffered = abap_true   " only buffered input, but currently needed for peek_char
                                    iv_string = abap_true
                                    io_out = go_out ).
      lo_port->set_input_string( list->car->value ).
      result = lo_port.
    ENDMETHOD.

    METHOD proc_get_output_string.
      DATA lo_port TYPE REF TO lcl_lisp_buffered_port.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_port list->car `get-output-string`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_port.
          throw( list->car->to_string( ) && ` is not a port in get-output-string` ) ##NO_TEXT.
        ENDIF.

      lo_port ?= list->car.
      result = lcl_lisp_new=>string( lo_port->flush( ) ).
    ENDMETHOD.

    METHOD proc_eof_object.
      result = lcl_lisp=>eof_object. " cannot be read using (read), must not be unique
    ENDMETHOD.

    METHOD proc_is_eof_object.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate list->car.
      IF list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      CHECK list->car EQ lcl_lisp=>eof_object.
      result = true.
    ENDMETHOD.

    METHOD proc_make_parameter.
* (make-parameter init) procedure
* (make-parameter init converter) procedure
*  Returns a newly allocated parameter object, which is a procedure that accepts zero arguments
*    and returns the value associated with the parameter object. Initially, this value is the
*    value of (converter init), or of init if the conversion procedure converter is not specified.
*  The associated value can be temporarily changed using parameterize, which is described below.
*  The effect of passing arguments to a parameter object is implementation-dependent.

* The following implementation of make-parameter and parameterize is suitable for an implementation with
* no threads. Parameter objects are implemented here as procedures, using two arbitrary unique objects
* <param-set!> and <param-convert>:
*(define (make-parameter init . o)
*  (let* ((converter
*           (if (pair? o) (car o) (lambda (x) x)))
*           (value (converter init)))
*    (lambda args (cond ((null? args)
*                          value)
*                       ((eq? (car args) <param-set!>)
*                         (set! value (cadr args)))
*                       ((eq? (car args) <param-convert>)
*                         converter)
*                       (else (error "bad parameter syntax"))))))

      DATA lo_converter TYPE REF TO lcl_lisp.
      DATA lo_init TYPE REF TO lcl_lisp.
      DATA lo_value TYPE REF TO lcl_lisp.
      DATA lo_env TYPE REF TO lcl_lisp_environment.

      "_validate: list, list->car, list->cdr.
      IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      lo_init = list->car.

      DATA(lo_ptr) = list->cdr.
      IF lo_ptr NE nil.
        "_validate lo_ptr->car.
          IF lo_ptr->car IS NOT BOUND.
            lcl_lisp=>throw( c_error_incorrect_input ).
          ENDIF.

        IF lo_ptr->cdr NE nil.
          throw( |unexpected parameter { lo_ptr->cdr->to_string( ) } in make-parameter| ).
        ENDIF.

        lo_converter = lo_ptr->car.
        IF NOT lo_converter->is_procedure( ).
          throw( |{ lo_converter->to_string( ) } is not a procedure in make-parameter| ).
        ENDIF.

        lo_value = eval( element = lcl_lisp_new=>box( io_proc = lo_converter
                                                      io_elem = lo_init )
                         environment = env ).
      ELSE.
        lo_value = lo_init.
      ENDIF.
      result = lcl_lisp_new=>lambda( io_car = nil
                                     io_cdr = lcl_lisp_new=>cons( io_car = lo_value )
                                     io_env = env
                                     iv_parameter_object = abap_true ).
    ENDMETHOD.

    METHOD proc_parameterize.
      result = nil.
    ENDMETHOD.

    METHOD proc_is_char_alphabetic.
      CONSTANTS c_abcde TYPE string VALUE `ABCDEFGHIJKLMNOPQRSTUVWXYZ`. " sy-abcde
      DATA lv_char TYPE tv_char.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_char list->car `char-alphabetic?`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_char.
          throw( list->car->to_string( ) && ` is not a char in char-alphabetic?` ) ##NO_TEXT.
        ENDIF.

      result = false.
      lv_char = list->car->value.
      CHECK lv_char NE space AND to_upper( lv_char ) CO c_abcde.
      result = true.
    ENDMETHOD.

    METHOD proc_is_char_numeric.
      DATA lv_char TYPE tv_char.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_char list->car `char-numeric?`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_char.
          throw( list->car->to_string( ) && ` is not a char in char-numeric?` ) ##NO_TEXT.
        ENDIF.
      lv_char = list->car->value.

      IF unicode_to_digit( lv_char ) BETWEEN 0 AND 9.
        result = true.
      ELSE.
        result = false.
      ENDIF.
    ENDMETHOD.

    METHOD unicode_to_digit.
      FIELD-SYMBOLS <lv_hex> TYPE x.
      FIELD-SYMBOLS <lv_int> TYPE x.
      DATA ls_digit TYPE ts_digit.
      DATA lv_xdigit TYPE ts_digit-zero.
      DATA lv_zero TYPE i.
      DATA lv_index TYPE tv_int.
      DATA lv_int TYPE tv_int.

      rv_digit = -1.

      ASSIGN iv_char TO <lv_hex> CASTING.
      ASSIGN lv_int TO <lv_int> CASTING.
      <lv_int> = <lv_hex>. " conversion
      lv_xdigit = lv_int.

      READ TABLE mt_zero INTO ls_digit WITH TABLE KEY zero = lv_xdigit.
      CASE sy-subrc.
        WHEN 0.

        WHEN 4.
          lv_index = sy-tabix - 1.
          IF lv_index LT 1.
            lv_index = 1.
          ENDIF.
          READ TABLE mt_zero INDEX lv_index INTO ls_digit.
          IF sy-subrc NE 0.
            RETURN.
          ENDIF.

        WHEN OTHERS.
          RETURN.
      ENDCASE.
      lv_zero = ls_digit-zero.
      rv_digit = lv_int - lv_zero.
    ENDMETHOD.

    METHOD proc_digit_value.
      DATA lv_char TYPE tv_char.
      DATA lv_int TYPE tv_int.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_char list->car `digit-value`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_char.
          throw( list->car->to_string( ) && ` is not a char in digit-value` ) ##NO_TEXT.
        ENDIF.
      lv_char = list->car->value.

      lv_int = unicode_to_digit( lv_char ).
      IF lv_int BETWEEN 0 AND 9.
        result = lcl_lisp_new=>integer( lv_int ).
      ELSE.
        result = false.
      ENDIF.
    ENDMETHOD.

    METHOD unicode_digit_zero.
*     https://www.fileformat.info/info/unicode/category/Nd/list.htm
      rt_zero = VALUE #(
         ( zero = '000030' )       " Default
         ( zero = '000660' )       " ARABIC-INDIC DIGIT ZERO
         ( zero = '0006F0' )       " EXTENDED ARABIC-INDIC DIGIT ZERO
         ( zero = '0007C0' )       " NKO DIGIT ZERO
         ( zero = '000966' )       " DEVANAGARI DIGIT ZERO
         ( zero = '0009E6' )       " BENGALI DIGIT ZERO
         ( zero = '000A66' )       " GURMUKHI DIGIT ZERO
         ( zero = '000AE6' )       " GUJARATI DIGIT ZERO
         ( zero = '000B66' )       " ORIYA DIGIT ZERO
         ( zero = '000BE6' )       " TAMIL DIGIT ZERO
         ( zero = '000C66' )       " TELUGU DIGIT ZERO
         ( zero = '000CE6' )       " KANNADA DIGIT ZERO
         ( zero = '000D66' )       " MALAYALAM DIGIT ZERO
         ( zero = '000DE6' )       " SINHALA LITH DIGIT ZERO
         ( zero = '000E50' )       " THAI DIGIT ZERO
         ( zero = '000ED0' )       " LAO DIGIT ZERO
         ( zero = '000F20' )       " TIBETAN DIGIT ZERO
         ( zero = '001040' )       " MYANMAR DIGIT ZERO
         ( zero = '001090' )       " MYANMAR SHAN DIGIT ZERO
         ( zero = '0017E0' )       " KHMER DIGIT ZERO
         ( zero = '001810' )       " MONGOLIAN DIGIT ZERO
         ( zero = '001946' )       " LIMBU DIGIT ZERO
         ( zero = '0019D0' )       " NEW TAI LUE DIGIT ZERO
         ( zero = '001A80' )       " TAI THAM HORA DIGIT ZERO
         ( zero = '001A90' )       " TAI THAM THAM DIGIT ZERO
         ( zero = '001B50' )       " BALINESE DIGIT ZERO
         ( zero = '001BB0' )       " SUNDANESE DIGIT ZERO
         ( zero = '001C40' )       " LEPCHA DIGIT ZERO
         ( zero = '001C50' )       " OL CHIKI DIGIT ZERO
         ( zero = '00A620' )       " VAI DIGIT ZERO
         ( zero = '00A8D0' )       " SAURASHTRA DIGIT ZERO
         ( zero = '00A900' )       " KAYAH LI DIGIT ZERO
         ( zero = '00A9D0' )       " JAVANESE DIGIT ZERO
         ( zero = '00A9F0' )       " MYANMAR TAI LAING DIGIT ZERO
         ( zero = '00AA50' )       " CHAM DIGIT ZERO
         ( zero = '00ABF0' )       " MEETEI MAYEK DIGIT ZERO
         ( zero = '00FF10' )       " FULLWIDTH DIGIT ZERO
         ( zero = '0104A0' )       " OSMANYA DIGIT ZERO
         ( zero = '011066' )       " BRAHMI DIGIT ZERO
         ( zero = '0110F0' )       " SORA SOMPENG DIGIT ZERO
         ( zero = '011136' )       " CHAKMA DIGIT ZERO
         ( zero = '0111D0' )       " SHARADA DIGIT ZERO
         ( zero = '0112F0' )       " KHUDAWADI DIGIT ZERO
         ( zero = '011450' )       " NEWA DIGIT ZERO
         ( zero = '0114D0' )       " TIRHUTA DIGIT ZERO
         ( zero = '011650' )       " MODI DIGIT ZERO
         ( zero = '0116C0' )       " TAKRI DIGIT ZERO
         ( zero = '011730' )       " AHOM DIGIT ZERO
         ( zero = '0118E0' )       " WARANG CITI DIGIT ZERO
         ( zero = '011C50' )       " BHAIKSUKI DIGIT ZERO
         ( zero = '011D50' )       " MASARAM GONDI DIGIT ZERO
         ( zero = '016A60' )       " MRO DIGIT ZERO
         ( zero = '016B50' )       " PAHAWH HMONG DIGIT ZERO
         ( zero = '01D7CE' )       " MATHEMATICAL BOLD DIGIT ZERO
         ( zero = '01D7D8' )       " MATHEMATICAL DOUBLE-STRUCK DIGIT ZERO
         ( zero = '01D7E2' )       " MATHEMATICAL SANS-SERIF DIGIT ZERO
         ( zero = '01D7EC' )       " MATHEMATICAL SANS-SERIF BOLD DIGIT ZERO
         ( zero = '01D7F6' )       " MATHEMATICAL MONOSPACE DIGIT ZERO
         ( zero = '01E950' ) ).    " ADLAM DIGIT ZERO
    ENDMETHOD.

    METHOD proc_is_char_whitespace.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_char list->car `char-whitespace?`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_char.
          throw( list->car->to_string( ) && ` is not a char in char-whitespace?` ) ##NO_TEXT.
        ENDIF.

      CASE list->car.
        WHEN lcl_lisp=>char_space OR lcl_lisp=>char_tab OR lcl_lisp=>char_newline.
          result = true.
        WHEN OTHERS.
          result = false.
      ENDCASE.
    ENDMETHOD.

    METHOD proc_is_char_upper_case.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_char list->car `char-upper-case?`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_char.
          throw( list->car->to_string( ) && ` is not a char in char-upper-case?` ) ##NO_TEXT.
        ENDIF.
      result = false.
      CHECK list->car->value NE to_lower( list->car->value ).
      result = true.
    ENDMETHOD.

    METHOD proc_is_char_lower_case.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_char list->car `char-lower-case?`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_char.
          throw( list->car->to_string( ) && ` is not a char in char-lower-case?` ) ##NO_TEXT.
        ENDIF.

      result = false.
      CHECK list->car->value NE to_upper( list->car->value ).
      result = true.
    ENDMETHOD.

    METHOD fold_case.
      rv_string = to_upper( element->value ).
    ENDMETHOD.

    METHOD char_case_identity.
      rv_string = element->value.
    ENDMETHOD.

    METHOD char_to_integer.
      FIELD-SYMBOLS <xword> TYPE x.
      FIELD-SYMBOLS <xint> TYPE x.
      DATA lv_int TYPE int2.
      DATA lv_char TYPE tv_char.

      lv_char = io_char->value+0(1).
      "_char01_to_integer lv_char rv_int.
      ASSIGN lv_char TO <xword> CASTING.
      ASSIGN lv_int TO <xint> CASTING.
      <xint> = <xword>.
      rv_int = lv_int.
    ENDMETHOD.

    METHOD char_fold_case_to_integer.
      FIELD-SYMBOLS <xword> TYPE x.
      FIELD-SYMBOLS <xint> TYPE x.
      DATA lv_int TYPE int2.
      DATA lv_char TYPE tv_char.

      lv_char = to_upper( element->value+0(1) ).
      "_char01_to_integer lv_char rv_int.
      ASSIGN lv_char TO <xword> CASTING.
      ASSIGN lv_int TO <xint> CASTING.
      <xint> = <xword>.
      rv_int = lv_int.
    ENDMETHOD.

*----- Char
    METHOD proc_char_list_is_eq.
      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE tv_int.
      DATA lv_test TYPE tv_int.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lo_test = lo_arg->car.
        lv_ref = char_to_integer( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `char=?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lv_test = char_to_integer( lo_arg->car ).
        IF lv_ref = lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `char=?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.

    ENDMETHOD.

    METHOD proc_char_list_is_lt.
      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE tv_int.
      DATA lv_test TYPE tv_int.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lo_test = lo_arg->car.
        lv_ref = char_to_integer( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `char<?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lv_test = char_to_integer( lo_arg->car ).
        IF lv_ref < lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `char<?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.

    ENDMETHOD.

    METHOD proc_char_list_is_gt.
      "_proc_char_list_compare `char>?` >.
      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE tv_int.
      DATA lv_test TYPE tv_int.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lo_test = lo_arg->car.
        lv_ref = char_to_integer( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `char>?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lv_test = char_to_integer( lo_arg->car ).
        IF lv_ref > lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `char>?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_char_list_is_le.
      "_proc_char_list_compare `char<=?` <=.
      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE tv_int.
      DATA lv_test TYPE tv_int.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lo_test = lo_arg->car.
        lv_ref = char_to_integer( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `char<=?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lv_test = char_to_integer( lo_arg->car ).
        IF lv_ref <= lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `char<=?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.

    ENDMETHOD.

    METHOD proc_char_list_is_ge.
      "_proc_char_list_compare `char>=?` >=.
      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE tv_int.
      DATA lv_test TYPE tv_int.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lo_test = lo_arg->car.
        lv_ref = char_to_integer( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `char>=?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lv_test = char_to_integer( lo_arg->car ).
        IF lv_ref >= lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `char>=?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_char_ci_list_is_eq.
      "_proc_char_ci_list_compare `char-ci=?` =.
      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE tv_int.
      DATA lv_test TYPE tv_int.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lo_test = lo_arg->car.
        lv_ref = char_fold_case_to_integer( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `char-ci=?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lv_test = char_fold_case_to_integer( lo_arg->car ).
        IF lv_ref  = lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `char-ci=?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_char_ci_list_is_lt.
      "_proc_char_ci_list_compare `char-ci<?` <.
      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE tv_int.
      DATA lv_test TYPE tv_int.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lo_test = lo_arg->car.
        lv_ref = char_fold_case_to_integer( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `char-ci<?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lv_test = char_fold_case_to_integer( lo_arg->car ).
        IF lv_ref < lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `char-ci<?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_char_ci_list_is_gt.
      "_proc_char_ci_list_compare `char-ci>?` >.

      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE tv_int.
      DATA lv_test TYPE tv_int.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lo_test = lo_arg->car.
        lv_ref = char_fold_case_to_integer( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `char-ci>?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lv_test = char_fold_case_to_integer( lo_arg->car ).
        IF lv_ref > lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `char-ci>?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_char_ci_list_is_le.
      "_proc_char_ci_list_compare `char-ci<=?` <=.
      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE tv_int.
      DATA lv_test TYPE tv_int.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lo_test = lo_arg->car.
        lv_ref = char_fold_case_to_integer( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `char-ci<=?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lv_test = char_fold_case_to_integer( lo_arg->car ).
        IF lv_ref <= lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `char-ci<=?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_char_ci_list_is_ge.
      "_proc_char_ci_list_compare `char-ci>=?` >=.

      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE tv_int.
      DATA lv_test TYPE tv_int.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lo_test = lo_arg->car.
        lv_ref = char_fold_case_to_integer( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `char-ci>=?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_char.
        lv_test = char_fold_case_to_integer( lo_arg->car ).
        IF lv_ref >= lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `char-ci>=?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

*----- String
    METHOD proc_string_list_is_eq.
      "_proc_string_list_compare `string=?` =.

      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE string.
      DATA lv_test TYPE string.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lo_test = lo_arg->car.
        lv_ref = char_case_identity( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `string=?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lv_test = char_case_identity( lo_arg->car ).
        IF lv_ref = lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `string=?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_string_list_is_lt.
      "_proc_string_list_compare `string<?` <.

      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE string.
      DATA lv_test TYPE string.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lo_test = lo_arg->car.
        lv_ref = char_case_identity( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `string<?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lv_test = char_case_identity( lo_arg->car ).
        IF lv_ref < lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `string<?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_string_list_is_gt.
      "_proc_string_list_compare `string>?` >.

      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE string.
      DATA lv_test TYPE string.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lo_test = lo_arg->car.
        lv_ref = char_case_identity( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `string>?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lv_test = char_case_identity( lo_arg->car ).
        IF lv_ref > lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `string>?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_string_list_is_le.
      "_proc_string_list_compare `string<=?` <=.

      "_proc_list_compare &1 &2 char_case_identity string type_string.
      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE string.
      DATA lv_test TYPE string.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lo_test = lo_arg->car.
        lv_ref = char_case_identity( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `string<=?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lv_test = char_case_identity( lo_arg->car ).
        IF lv_ref <= lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `string<=?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_string_list_is_ge.
      "_proc_string_list_compare `string>=?` >=.

      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE string.
      DATA lv_test TYPE string.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lo_test = lo_arg->car.
        lv_ref = char_case_identity( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `string>=?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lv_test = char_case_identity( lo_arg->car ).
        IF lv_ref >= lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `string>=?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

*----- String CI

    METHOD proc_string_ci_list_is_eq.
      "_proc_string_ci_list_compare `string-ci=?` =.

      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE string.
      DATA lv_test TYPE string.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lo_test = lo_arg->car.
        lv_ref = fold_case( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `string-ci=?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lv_test = fold_case( lo_arg->car ).
        IF lv_ref = lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `string-ci=?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_string_ci_list_is_lt.
      "_proc_string_ci_list_compare `string-ci<?` <.

      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE string.
      DATA lv_test TYPE string.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lo_test = lo_arg->car.
        lv_ref = fold_case( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `string-ci<?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lv_test = fold_case( lo_arg->car ).
        IF lv_ref < lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `string-ci<?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_string_ci_list_is_gt.
      "_proc_string_ci_list_compare `string-ci>?` >.

      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE string.
      DATA lv_test TYPE string.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lo_test = lo_arg->car.
        lv_ref = fold_case( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `string-ci>?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lv_test = fold_case( lo_arg->car ).
        IF lv_ref > lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `string-ci>?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_string_ci_list_is_le.
      "_proc_string_ci_list_compare `string-ci<=?` <=.

      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE string.
      DATA lv_test TYPE string.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lo_test = lo_arg->car.
        lv_ref = fold_case( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `string-ci<=?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lv_test = fold_case( lo_arg->car ).
        IF lv_ref <= lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `string-ci<=?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

    METHOD proc_string_ci_list_is_ge.
      "_proc_string_ci_list_compare `string-ci>=?` >=.

      DATA lo_test TYPE REF TO lcl_lisp.
      DATA lo_arg TYPE REF TO lcl_lisp.
      DATA lv_ref TYPE string.
      DATA lv_test TYPE string.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = false.
      lo_arg = list.

      lo_test = nil.
      IF lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lo_test = lo_arg->car.
        lv_ref = fold_case( lo_test ).
        lo_arg = lo_arg->cdr.
      ENDIF.
      IF lo_test EQ nil OR lo_arg EQ nil.
        throw( |{ `string-ci>=?` } missing argument| ).
      ENDIF.

      WHILE lo_arg->type EQ lcl_lisp=>type_pair AND lo_arg->car->type EQ lcl_lisp=>type_string.
        lv_test = fold_case( lo_arg->car ).
        IF lv_ref >= lv_test.
          lv_ref = lv_test.
        ELSE.
          RETURN.
        ENDIF.
        lo_arg = lo_arg->cdr.
      ENDWHILE.

      IF lo_arg NE nil.
        throw( |{ `string-ci>=?` } wrong argument in { lo_arg->car->to_string( ) }| ).
      ENDIF.
      CHECK lo_arg = nil.
      result = true.
    ENDMETHOD.

*--- End string

    METHOD proc_char_to_integer.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_char list->car `char->integer`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_char.
          throw( list->car->to_string( ) && ` is not a char in char->integer` ) ##NO_TEXT.
        ENDIF.

      result = lcl_lisp_new=>integer( char_to_integer( list->car ) ).
    ENDMETHOD.

    METHOD proc_integer_to_char.
      DATA lv_char TYPE tv_char.
      FIELD-SYMBOLS <xchar> TYPE x.
      FIELD-SYMBOLS <xint> TYPE x.
      DATA lv_int TYPE int2.
      DATA lo_int TYPE REF TO lcl_lisp_integer.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_validate_integer list->car `integer->char`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in integer->char` ) ##NO_TEXT.
        ENDIF.

      lv_int = CAST lcl_lisp_integer( list->car )->integer.

      ASSIGN lv_int TO <xint> CASTING.
      ASSIGN lv_char TO <xchar> CASTING.
      <xchar> = <xint>.

      result = lcl_lisp_new=>char( lv_char ).
    ENDMETHOD.

    METHOD proc_char_upcase.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_validate_char list->car `char-upcase`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_char.
          throw( list->car->to_string( ) && ` is not a char in char-upcase` ) ##NO_TEXT.
        ENDIF.

      result = lcl_lisp_new=>char( to_upper( list->car->value ) ).
    ENDMETHOD.

    METHOD proc_char_downcase.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_char list->car `char-downcase`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_char.
          throw( list->car->to_string( ) && ` is not a char in char-downcase` ) ##NO_TEXT.
        ENDIF.

      result = lcl_lisp_new=>char( to_lower( list->car->value ) ).
    ENDMETHOD.

    METHOD proc_error.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      throw( list->to_string( ) ).
    ENDMETHOD.

    METHOD proc_raise.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      throw( list->car->to_string( ) ).
    ENDMETHOD.

    METHOD proc_call_cc.
* A continuation denotes a suspended computation that is awaiting a value

* http://www.ccs.neu.edu/home/dherman/browse/projects/vm/implementation-strategies2.pdf
* Implementation Strategies for First-Class Continuations
* by William D. Clinger Anne H. Hartheimer Eric M. Ost
* Higher-Order and Symbolic Computation. April 1999, Volume 12, Issue 1, pp 7–45
*(define (call-with-current-continuation f)
*  (let ((k (creg-get)))
*    (f (lambda (v)
*      (creg-set! k)
*      v))))

*implementation in terms of low-level procedures creg-get and creg-set!
* A)creg-get - capture procedure - converts the implicit continuation passed to
*             call-with-current-continuationinto some kind of Scheme object with unlimited extent
*B) creg-set! - throw procedure - takes such an object and installs it as the continuation
*      for the currently executing procedure overriding the previous implicit continuation.
* f is called an escape procedure, because a call to the escape procedure will allow control
*   to bypass the implicit continuation.

*simplest implementation strategy: allocate storage for each continuation frame (activation record)
*  on a heap and reclaim that storage through garbage collection or reference counting [23].
*  With this strategy, which we call the gc strategy, creg-get can just return the contents of a
*  continuation register (which is often called the dynamic link, stack pointer, or frame pointer),
*  and creg-set! can just store its argument into that register.

      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      result = nil.
      throw( `call/cc not implemented yet` ).
    ENDMETHOD.

**********************************************************************
*       _                   _           _ _ _        _
*  __ _| |__   __ _ _ __   | |__  _   _(_) | |_     (_)_ __  ___
* / _` | '_ \ / _` | '_ \  | '_ \| | | | | | __|____| | '_ \/ __|
*| (_| | |_) | (_| | |_) | | |_) | |_| | | | ||_____| | | | \__ \
* \__,_|_.__/ \__,_| .__/  |_.__/ \__,_|_|_|\__|    |_|_| |_|___/
*                  |_|
**********************************************************************

    METHOD proc_abap_data.
      DATA lo_result TYPE REF TO lcl_lisp_data.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->car = nil OR ( list->car->type NE lcl_lisp=>type_string
                            AND list->car->type NE lcl_lisp=>type_symbol ).
        throw( |ab-data: String or symbol required as name of type| ).
      ENDIF.

      cl_abap_typedescr=>describe_by_name( EXPORTING p_name = list->car->value
                                           RECEIVING p_descr_ref = DATA(lr_desc)
                                           EXCEPTIONS OTHERS = 1 ).
      IF sy-subrc NE 0.
        throw( |ab-data: type { list->car->value } not found | ).
      ENDIF.

      CASE lr_desc->kind.
        WHEN cl_abap_typedescr=>kind_table.
          result = lcl_lisp_new=>table( ).
        WHEN cl_abap_typedescr=>kind_elem OR cl_abap_typedescr=>kind_struct.
          result = lcl_lisp_new=>data( ).
        WHEN OTHERS.
          throw( |ab-data: type kind { lr_desc->kind } not supported yet| ).
      ENDCASE.
*     Create data as given type
      lo_result ?= result.
      CREATE DATA lo_result->data TYPE (list->car->value).
*     Set value if supplied as second parameter
      IF list->cdr NE nil.
        FIELD-SYMBOLS <data> TYPE any.
        ASSIGN lo_result->data->* TO <data>.
        element_to_data(
          EXPORTING
            element = list->cdr->car
          CHANGING
            data    = <data> ).
      ENDIF.
    ENDMETHOD.                    "proc_abap_data

**********************************************************************
*    METHOD proc_abap_function.
*      result = lcl_lisp_new=>function( list ).
*    ENDMETHOD.                    "proc_abap_function
*
*    METHOD proc_abap_function_param.
*      result = lcl_lisp=>nil.
*    ENDMETHOD.

    METHOD proc_abap_table. "Create a table data
      DATA lo_result TYPE REF TO lcl_lisp_table.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

*     First input: name of data type, second input: value
      result = lo_result = lcl_lisp_new=>table( ).
      CREATE DATA lo_result->data TYPE TABLE OF (list->car->value).
*     Set value if supplied as second parameter
      IF list->cdr NE nil.
        FIELD-SYMBOLS <data> TYPE any.
        ASSIGN lo_result->data->* TO <data>.
        element_to_data( EXPORTING element = list->cdr->car
                         CHANGING data    = <data> ).
      ENDIF.
    ENDMETHOD.                    "proc_abap_table

**********************************************************************
    METHOD proc_abap_append_row.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      DATA(lo_ref) = list->car.
      IF lo_ref->type NE lcl_lisp=>type_abap_table.
        throw( |ab-append-row requires ABAP table as parameter| ).
      ENDIF.
      throw( `ab-append-row not implemented yet` ).
    ENDMETHOD.                    "proc_abap_append_row

    METHOD proc_abap_delete_row.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      DATA(lo_ref) = list->car.
      IF lo_ref->type NE lcl_lisp=>type_abap_table.
        throw( |ab-delete-row requires ABAP table as parameter| ).
      ENDIF.
      throw( `ab-delete-row not implemented yet` ).
    ENDMETHOD.                    "proc_abap_delete_row

    METHOD proc_abap_get_row.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      DATA(lo_ref) = list->car.
      IF lo_ref->type NE lcl_lisp=>type_abap_table.
        throw( |ab-get-row requires ABAP table as parameter| ).
      ENDIF.
      throw( `ab-get-row not implemented yet` ).
    ENDMETHOD.                    "proc_abap_get_row

**********************************************************************
    METHOD proc_abap_get_value. "Convert ABAP to Lisp data
      DATA lo_ref TYPE REF TO lcl_lisp_data.
      FIELD-SYMBOLS <data> TYPE any.

      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      IF list->car->type NE lcl_lisp=>type_abap_data AND
         list->car->type NE lcl_lisp=>type_abap_table.
        throw( |ab-get-value requires ABAP data or table as parameter| ).
      ENDIF.
      lo_ref ?= list->car.
      TRY.
          ASSIGN lo_ref->data->* TO <data>.
          result = data_to_element( <data> ).
        CATCH cx_root INTO DATA(lx_root).
          throw( |Mapping error: { lx_root->get_text( ) }| ).
      ENDTRY.
    ENDMETHOD.                    "proc_abap_get_value

    METHOD proc_abap_set_value. "Convert Lisp to ABAP data
      DATA lo_ref TYPE REF TO lcl_lisp_data.
      FIELD-SYMBOLS <data> TYPE any.

      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->car->type NE lcl_lisp=>type_abap_data AND
         list->car->type NE lcl_lisp=>type_abap_table.
        throw( |ab-set-value requires ABAP data or table as first parameter| ).
      ENDIF.
      lo_ref ?= list->car.
      TRY.
          ASSIGN lo_ref->data->* TO <data>.
          element_to_data(
            EXPORTING
              element = list->cdr->car
            CHANGING
              data    = <data> ).
        CATCH cx_root INTO DATA(lx_root).
          throw( |Mapping error: { lx_root->get_text( ) }| ).
      ENDTRY.
      result = nil. "TODO: What should we return here?
    ENDMETHOD.                    "proc_abap_set_value

*    METHOD proc_abap_function_call. "Called internally only for execution of function module
*      DATA lo_func TYPE REF TO lcl_lisp_abapfunction.
*      "_validate: list, list->car.
*      IF list IS NOT BOUND OR list->car IS NOT BOUND.
*        lcl_lisp=>throw( c_error_incorrect_input ).
*      ENDIF.
*
**     The first parameter must be a function module instance
*      IF list->car->type NE lcl_lisp=>type_abap_function.
*        throw( |{ list->car->value } is not a function module reference| ).
*      ENDIF.
*
*      TRY.
*          lo_func ?= list->car.
*          result = lo_func->call( list->car ).
*        CATCH cx_root INTO DATA(lx_root).
*          throw( |Function call error: { lx_root->get_text( ) }| ).
*      ENDTRY.
*    ENDMETHOD.                    "proc_abap_function_call

    METHOD create_element_from_data.
*     Perform RTTI on determined data and generate appropriate response
      DATA(lv_kind) = cl_abap_typedescr=>describe_by_data_ref( ir_data )->kind.
      CASE lv_kind.
        WHEN cl_abap_typedescr=>kind_table.
          result = lcl_lisp_new=>table( ir_data ).
        WHEN cl_abap_typedescr=>kind_struct.
          result = lcl_lisp_new=>data( ir_data ).
        WHEN cl_abap_typedescr=>kind_elem.
*         Give back immediate value
          FIELD-SYMBOLS <value> TYPE any.

          ASSIGN ir_data->* TO <value>.
          result = data_to_element( <value> ).
        WHEN OTHERS.
          throw( |ab-get: type kind { lv_kind } not supported yet| ). "Can do AB-TAB-WHERE some other time
      ENDCASE.
    ENDMETHOD.                    "create_element_from_data

    METHOD proc_abap_get.
      DATA lo_ref TYPE REF TO lcl_lisp_data.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

*     Ensure a valid first parameter is passed
      IF list->car->type NE lcl_lisp=>type_abap_data
        AND list->car->type NE lcl_lisp=>type_abap_function
        AND list->car->type NE lcl_lisp=>type_abap_table.
        throw( |ab-get: First parameter must be ABAP data or table or a function| ).
      ENDIF.
      lo_ref ?= list->car.

*     Determine whether the data is elementary or not to decide if we need to get the element by identifier
      IF lo_ref->data IS NOT INITIAL AND
        cl_abap_typedescr=>describe_by_data_ref( lo_ref->data )->kind = cl_abap_typedescr=>kind_elem.
*       Elementary type; can return the value without mapping
        DATA(lr_data) = lo_ref->data.
      ELSEIF list->cdr = nil.
*       Could short-cut here and provide the value right away
        throw( |ab-get: Complex type requires identifier for lookup| ).
      ELSE.
        lr_data = get_element( list ).
      ENDIF.

      result = create_element_from_data( lr_data ).

    ENDMETHOD. "proc_abap_get

    METHOD proc_abap_set.
      DATA lo_ref TYPE REF TO lcl_lisp_data.
      DATA lo_source TYPE REF TO lcl_lisp.
      DATA lr_target TYPE REF TO data.
      FIELD-SYMBOLS <target> TYPE any.
      FIELD-SYMBOLS <source> TYPE any.

      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

*     Ensure a valid first parameter is passed
      IF list->car->type NE lcl_lisp=>type_abap_data
        AND list->car->type NE lcl_lisp=>type_abap_function
        AND list->car->type NE lcl_lisp=>type_abap_table.
        throw( |ab-set: First parameter must be ABAP data or table or a function| ).
      ENDIF.
      lo_ref ?= list->car.

*     Determine whether the data is elementary or not to decide if we need to get the element by identifier
      IF lo_ref->data IS NOT INITIAL AND
        cl_abap_typedescr=>describe_by_data_ref( lo_ref->data )->kind = cl_abap_typedescr=>kind_elem.
*       Elementary type; can return the value without mapping
        lr_target = lo_ref->data.
        lo_source = list->cdr->car.  "Value to set is data ref from second argument
      ELSEIF list->cdr = nil.
        throw( |ab-set: Complex type requires identifier for lookup| ).
      ELSE.
        lr_target = get_element( list ).
        lo_source = list->cdr->cdr->car.  "Value to set is data ref from third argument
      ENDIF.

*     Do we just assign the reference now?
*     Probably should dereference source value and copy the value...
*     Perform RTTI on determined data and generate appropriate response
      ASSIGN lr_target->* TO <target>.

*     For elementary types, set value from second parameter, otherwise third
      IF cl_abap_typedescr=>describe_by_data( <target> )->kind = cl_abap_typedescr=>kind_elem.
*       For now, we will support setting data from a number, string or symbol
        CASE lo_source->type.
          WHEN lcl_lisp=>type_string OR lcl_lisp=>type_symbol.
            <target> = lo_source->value.
          WHEN lcl_lisp=>type_integer.
            <target> = CAST lcl_lisp_integer( lo_source )->integer.
          WHEN lcl_lisp=>type_real.
            <target> = CAST lcl_lisp_real( lo_source )->real.
        ENDCASE.
      ELSE.
*       Complex types will just copy the whole value across
        lo_ref ?= lo_source.
        ASSIGN lo_ref->data->* TO <source>.
        <target> = <source>.                        "Set the value
      ENDIF.

      result = nil.

    ENDMETHOD. "proc_abap_set

    METHOD structure_to_element.
      FIELD-SYMBOLS <field> TYPE any.

      element = nil.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE struct TO <field>.
        IF sy-subrc NE 0.
          RETURN.
        ENDIF.
        IF sy-index EQ 1.
          element = lcl_lisp_new=>cons( io_car = data_to_element( <field> ) ).
          DATA(lo_ptr) = element.
        ELSE.          "Move pointer only from second field onward
          lo_ptr = lo_ptr->cdr = lcl_lisp_new=>cons( io_car = data_to_element( <field> ) ).
        ENDIF.
      ENDDO.
    ENDMETHOD.                    "structure_to_element

    METHOD table_to_element.
*     map ABAP Data to Lisp element
      FIELD-SYMBOLS <table> TYPE ANY TABLE.          " ABAP-side (source)
      DATA line TYPE REF TO data.
*     Table type
      FIELD-SYMBOLS <line> TYPE any.

      ASSIGN data TO <table>.
      CREATE DATA line LIKE LINE OF <table>.
      ASSIGN line->* TO <line>.

      element = nil.
*     Create list with cell for each row AND Set pointer to start of list
      LOOP AT <table> INTO <line>.
        IF sy-tabix EQ 1.
          element = lcl_lisp_new=>cons( io_car = data_to_element( <line> ) ). "recursive call
          DATA(lo_ptr) = element.
        ELSE.   "Move pointer only from second line onward
          lo_ptr = lo_ptr->cdr = lcl_lisp_new=>cons( io_car = data_to_element( <line> ) ).
        ENDIF.
      ENDLOOP.
    ENDMETHOD.

    METHOD data_to_element.
*     Determine type of the ABAP value
      DATA(lr_ddesc) = cl_abap_typedescr=>describe_by_data( data ).
      CASE lr_ddesc->kind.

        WHEN cl_abap_typedescr=>kind_table.
          element = table_to_element( data ).

        WHEN cl_abap_typedescr=>kind_struct.
          element = structure_to_element( data ).

        WHEN cl_abap_typedescr=>kind_elem.
*         Elementary type
          element = SWITCH #( lr_ddesc->type_kind
                       WHEN cl_abap_typedescr=>typekind_numeric OR cl_abap_typedescr=>typekind_num
                       THEN lcl_lisp_new=>number( data )
                       ELSE lcl_lisp_new=>string( data ) ).
      ENDCASE.
    ENDMETHOD.                    "data_to_element

*   Map Lisp element to ABAP Data
    METHOD element_to_data.
*     ABAP-side (target) mapping:
      FIELD-SYMBOLS <field> TYPE any.
      FIELD-SYMBOLS <line> TYPE any.
      FIELD-SYMBOLS <table> TYPE ANY TABLE.
      FIELD-SYMBOLS <sotab> TYPE SORTED TABLE.
      FIELD-SYMBOLS <sttab> TYPE STANDARD TABLE.

      DATA line TYPE REF TO data.
      DATA table TYPE REF TO data.

*     Determine type of the ABAP value
      DATA(lr_ddesc) = cl_abap_typedescr=>describe_by_data( data ).
      CASE lr_ddesc->kind.
*       Table type
        WHEN cl_abap_typedescr=>kind_table.
*         For this mapping to happen, the element must be a cons cell
          IF element->type NE lcl_lisp=>type_pair.
            throw( |Mapping failed: Non-cell to table| ).
          ENDIF.
*         Provide reference to table and line
          table = REF #( data ).
          ASSIGN table->* TO <table>.
          CASE CAST cl_abap_tabledescr( lr_ddesc )->table_kind.
            WHEN cl_abap_tabledescr=>tablekind_sorted OR cl_abap_tabledescr=>tablekind_hashed.
              ASSIGN table->* TO <sotab>. "Sorted table type
              CREATE DATA line LIKE LINE OF <sotab>.
            WHEN OTHERS.
              ASSIGN table->* TO <sttab>. "Standard table type
              CREATE DATA line LIKE LINE OF <sttab>.
          ENDCASE.
          ASSIGN line->* TO <line>.

          DATA(lr_conscell) = element. "Set pointer to start of list
          WHILE lr_conscell NE nil.
            element_to_data( EXPORTING element = lr_conscell->car
                             CHANGING data    = <line> ).
*            Append or insert, depending on table type (what is assigned)
            IF <sotab> IS ASSIGNED.
              INSERT <line> INTO TABLE <sotab>.
            ELSE.
              APPEND <line> TO <sttab>.
            ENDIF.
            CLEAR <line>.
            lr_conscell = lr_conscell->cdr.
          ENDWHILE.

        WHEN cl_abap_typedescr=>kind_struct.
*         Structure
          IF element->type NE lcl_lisp=>type_pair.
            throw( |Mapping failed: Non-cell to structure| ).
          ENDIF.

          lr_conscell = element. "Set pointer to start of list
          ASSIGN data TO <line>.
          DO.
            ASSIGN COMPONENT sy-index OF STRUCTURE <line> TO <field>.
            IF sy-subrc NE 0.
              EXIT.
            ENDIF.

            IF sy-index > 1. "Move cons cell pointer only from second element on
              lr_conscell = lr_conscell->cdr.
            ENDIF.
*           Don't map nil values
            CHECK lr_conscell->car NE nil.

            element_to_data( EXPORTING element = lr_conscell->car
                             CHANGING data    = <field> ).
          ENDDO.

        WHEN cl_abap_typedescr=>kind_elem.
*         Elementary type
          ASSIGN data TO <field>.
          CASE element->type.
            WHEN lcl_lisp=>type_integer.
              <field> = CAST lcl_lisp_integer( element )->integer.
            WHEN lcl_lisp=>type_real.
              <field> = CAST lcl_lisp_real( element )->real.
            WHEN OTHERS.
              <field> = element->value.
          ENDCASE.
        WHEN OTHERS.
*          Not supported yet
          throw( |Mapping failed: unsupported type| ).
      ENDCASE.
    ENDMETHOD.                    "element_to_data

    METHOD get_structure_field.
      FIELD-SYMBOLS <value> TYPE any.
      FIELD-SYMBOLS <struct> TYPE any.

      IF identifier = nil OR
        ( identifier->type NE lcl_lisp=>type_string AND identifier->type NE lcl_lisp=>type_symbol ).
        throw( `ab-get: String or symbol required to access structure field` ).
      ENDIF.

      ASSIGN element->data->* TO <struct>.
      ASSIGN COMPONENT identifier->value OF STRUCTURE <struct> TO <value>.
      IF sy-subrc NE 0.
        throw( |ab-get: Structure has no component { identifier->value }| ).
      ENDIF.
      rdata = REF #( <value> ).
    ENDMETHOD.                    "get_structure_field

    METHOD get_index_table_row.
*     Second input for reading an index table must be a number (row index)
      FIELD-SYMBOLS <idxtab> TYPE INDEX TABLE.
      DATA lo_int TYPE REF TO lcl_lisp_integer.

      "_validate_integer identifier `ab-get`.
        IF identifier IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF identifier->type NE lcl_lisp=>type_integer.
          throw( identifier->to_string( ) && ` is not an integer in ab-get` ) ##NO_TEXT.
        ENDIF.

      ASSIGN element->data->* TO <idxtab>.

      lo_int ?= identifier.
      READ TABLE <idxtab> REFERENCE INTO rdata INDEX lo_int->integer.
      IF sy-subrc NE 0.
        throw( |ab-get: No entry at index { lo_int->integer }| ). "Can do AB-TAB-WHERE some other time
      ENDIF.
    ENDMETHOD.                    "get_index_table_row

    METHOD get_table_row_with_key.
*      Read with key, which is a bit more effort
*      FIELD-SYMBOLS <wa> TYPE any.
*      FIELD-SYMBOLS <tab> TYPE table.
*      DATA line TYPE REF TO data.


      rdata = get_index_table_row( element = element
                                   identifier = identifier ).
*       IF identifier = nil.
*         throw( |AB-GET: Key required to read table| ).
*       ENDIF.

*       ASSIGN element->data->* TO <tab>.
*       CREATE DATA line LIKE LINE OF <tab>.
*       ASSIGN line->* TO <wa>.
*
*       READ TABLE <tab> FROM <wa> REFERENCE INTO rdata
*  example:
*        WITH TABLE KEY ('CARRID') = 'SQ'
*                       ('CONNID') = '0002'
*                       ('FLDATE') = '20170915'
*                       ('BOOKID') = '00000002'.
*
*       CHECK sy-subrc NE 0.
*       throw( |AB-GET: No entry at key| ).
    ENDMETHOD.                    "get_table_row_with_key

    METHOD get_element.
      DATA element TYPE REF TO lcl_lisp_data.
*     RDATA <- Data reference to value pointed to
      element ?= list->car.         " Lisp element containing an ABAP value (data, table or function)
      DATA(identifier) = list->cdr->car. " Lisp element, string or symbol or index, to identify subcomponent of value

      IF element->type = lcl_lisp=>type_abap_function.
*       Get function parameter by name
        "rdata = CAST lcl_lisp_abapfunction( element )->get_function_parameter( identifier ).
        throw( `function not supported in the SAP Cloud ABAP environment` ).
      ELSE.
*       First parameter is not function, but table or other data; examine the data
        DATA(lo_ddesc) = cl_abap_typedescr=>describe_by_data_ref( element->data ).

        CASE lo_ddesc->kind.
          WHEN cl_abap_typedescr=>kind_struct.
*           Structure: Use second parameter as field name
            rdata = get_structure_field( element = element
                                         identifier = identifier ).
          WHEN cl_abap_typedescr=>kind_elem.
*           Elementary data: No qualifier / second parameter required
            rdata = element->data.

          WHEN cl_abap_typedescr=>kind_table.
*           Table: Second parameter is index (std table) or key (sorted table)
            CASE CAST cl_abap_tabledescr( lo_ddesc )->table_kind.
              WHEN cl_abap_tabledescr=>tablekind_sorted
                OR cl_abap_tabledescr=>tablekind_hashed.
                rdata = get_table_row_with_key( element = element
                                                identifier = identifier ).
              WHEN cl_abap_tabledescr=>tablekind_std.
                "OR cl_abap_tabledescr=>tablekind_index.  - No Test data for this case yet
                rdata = get_index_table_row( element = element
                                             identifier = identifier ).
            ENDCASE.

        ENDCASE.

      ENDIF.
    ENDMETHOD. "get_element

*    METHOD proc_sql_prepare.
**     define-query
*      DATA lo_string TYPE REF TO lcl_lisp_string.
*      "_validate: list, list->car.
*      IF list IS NOT BOUND OR list->car IS NOT BOUND.
*        lcl_lisp=>throw( c_error_incorrect_input ).
*      ENDIF.
*
*      lo_string ?= list->car.
*
*      result = lcl_lisp_new=>query( value = lo_string->value ).
*    ENDMETHOD.

*    METHOD proc_sql_query.
*      DATA lo_sql TYPE REF TO lcl_lisp_query.
*      DATA lo_string TYPE REF TO lcl_lisp_string.
**     sql-query
*      "_validate: list, list->cdr.
*      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
*        lcl_lisp=>throw( c_error_incorrect_input ).
*      ENDIF.
*
*      TRY.
*          lo_string ?= list->car.
*          lo_sql ?= lcl_lisp_new=>query( value = lo_string->value ).
*          result = lo_sql->execute( lo_string->value ).
*        CATCH cx_sql_exception INTO DATA(lx_error).
*          throw( |SQL query { lx_error->get_text( ) }| ).
*      ENDTRY.
*    ENDMETHOD.

" Turtle library
    METHOD proc_turtle_new. "turtles
*    (turtles width
*          height
*        [  init-x
*         init-y
*         init-angle])    →   turtles?
*      width : real?
*      height : real?
*      init-x : real? = (/ width 2)
*      init-y : real? = (/ height 2)
*      init-angle : real? = 0
      DATA lo_width TYPE REF TO lcl_lisp_integer.
      DATA lo_next TYPE REF TO lcl_lisp.
      DATA lo_height TYPE REF TO lcl_lisp_integer.
      DATA lo_init_x TYPE REF TO lcl_lisp_integer.
      DATA lo_init_y TYPE REF TO lcl_lisp_integer.
      DATA lo_init_angle TYPE REF TO lcl_lisp_real.
      DATA cell TYPE REF TO lcl_lisp.
      DATA lo_rat TYPE REF TO lcl_lisp_rational.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "_validate_integer list->car `turtles`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in turtles` ) ##NO_TEXT.
        ENDIF.

      lo_width ?= list->car.
      "_validate_integer list->cdr->car `turtles`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in turtles` ) ##NO_TEXT.
        ENDIF.

      lo_height ?= list->cdr->car.

      lo_next = list->cdr->cdr.

      IF lo_next->car IS BOUND.
        IF lo_next->car->type EQ lcl_lisp=>type_integer.
          lo_init_x ?= lo_next->car.

          lo_next = lo_next->cdr.
          IF lo_next->car IS BOUND.
            IF lo_next->car->type EQ lcl_lisp=>type_integer.
              lo_init_y ?= lo_next->car.

              lo_next = lo_next->cdr.
              IF lo_next->car IS BOUND.
                DATA lv_real TYPE tv_real.

                "_get_number lv_real lo_next->car `turtles`.
                IF lo_next->car IS NOT BOUND.
                  lcl_lisp=>throw( c_error_incorrect_input ).
                ENDIF.
                cell = lo_next->car.
                CASE cell->type.
                  WHEN lcl_lisp=>type_integer.
                     lv_real = CAST lcl_lisp_integer( cell )->integer.
                  WHEN lcl_lisp=>type_real.
                     lv_real = CAST lcl_lisp_real( cell )->real.
                  WHEN lcl_lisp=>type_rational.
                    lo_rat ?= cell.
                    lv_real = lo_rat->integer / lo_rat->denominator.
*                  WHEN lcl_lisp=>type_complex.
                  WHEN OTHERS.
                    throw( |{ cell->to_string( ) } is not a number in turtles| ).
                ENDCASE.
                lo_init_angle = lcl_lisp_new=>real( lv_real ).
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lo_init_x IS NOT BOUND.
        lo_init_x = lcl_lisp_new=>integer( lo_width->integer div 2 ).
      ENDIF.

      IF lo_init_y IS NOT BOUND.
        lo_init_y = lcl_lisp_new=>integer( lo_height->integer div 2 ).
      ENDIF.

      IF lo_init_angle IS NOT BOUND.
        lo_init_angle = lcl_lisp_new=>real( 0 ).
      ENDIF.

      result = lcl_lisp_new=>turtles( width = lo_width
                                      height = lo_height
                                      init_x = lo_init_x
                                      init_y = lo_init_y
                                      init_angle = lo_init_angle
                                      out = go_out ).
    ENDMETHOD.

    METHOD proc_turtle_merge.
      DATA lo_width TYPE REF TO lcl_lisp_integer.
      DATA lo_height TYPE REF TO lcl_lisp_integer.
      DATA lo_init_x TYPE REF TO lcl_lisp_integer.
      DATA lo_init_y TYPE REF TO lcl_lisp_integer.
      DATA lo_init_angle TYPE REF TO lcl_lisp_real.
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
*    (merge turtles1 turtles2) → turtles?
*      turtles1 : turtles?
*      turtles2 : turtles?
      "_validate_turtle list->car `merge`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->car->to_string( ) && ` is not a turtle in merge` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtle1 TYPE REF TO lcl_lisp_turtle.
      lo_turtle1 ?= list->car.
      "_validate_turtle list->cdr->car `merge`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->cdr->car->to_string( ) && ` is not a turtle in merge` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtle2 TYPE REF TO lcl_lisp_turtle.
      lo_turtle2 ?= list->cdr->car.

      DATA(lo_turtles) = lcl_turtle=>compose( VALUE #( ( lo_turtle1->turtle ) ( lo_turtle2->turtle ) ) ).

      lo_width = lcl_lisp_new=>integer( nmax( val1 = lo_turtle1->turtle->width
                                              val2 = lo_turtle2->turtle->width ) ).
      lo_height = lcl_lisp_new=>integer( nmax( val1 = lo_turtle1->turtle->height
                                               val2 = lo_turtle2->turtle->height ) ).

      lo_init_x = lcl_lisp_new=>integer( lo_width->integer div 2 ).
      lo_init_y = lcl_lisp_new=>integer( lo_height->integer div 2 ).
      lo_init_angle = lcl_lisp_new=>real( 0 ).
      result = lcl_lisp_new=>turtles( width = lo_width
                                      height = lo_height
                                      init_x = lo_init_x
                                      init_y = lo_init_y
                                      init_angle = lo_init_angle
                                      out = go_out ).
    ENDMETHOD.

    METHOD proc_turtle_exist. "turtles?
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      "(turtles? v) → boolean?
      IF list->car->type EQ lcl_lisp=>type_abap_turtle.
        result = true.
      ELSE.
        result = false.
      ENDIF.
    ENDMETHOD.

    METHOD proc_turtle_move. "move
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
*    (move n turtles) → turtles?
*      n : real?  (integer)
*      turtles : turtles?
      DATA lo_dist_n TYPE REF TO lcl_lisp_integer.
      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.

      "_validate_integer list->car `turtles move n`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in turtles move n` ) ##NO_TEXT.
        ENDIF.

      "_validate_turtle list->cdr->car `turtles move`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->cdr->car->to_string( ) && ` is not a turtle in turtles move` ) ##NO_TEXT.
        ENDIF.

      lo_dist_n ?= list->car.
      lo_turtles ?= list->cdr->car.
      result = lo_turtles.

      lo_turtles->turtle->pen_up( ).
      lo_turtles->turtle->forward( lo_dist_n->integer ).
    ENDMETHOD.

    METHOD proc_turtle_draw. "draw
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

*    (draw n turtles) → turtles?
*      n : real? (integer)
*      turtles : turtles?
      DATA lo_dist_n TYPE REF TO lcl_lisp_integer.
      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.

      "_validate_integer list->car `turtles draw n`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in turtles draw n` ) ##NO_TEXT.
        ENDIF.

      "_validate_turtle list->cdr->car `turtles draw`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->cdr->car->to_string( ) && ` is not a turtle in turtles draw` ) ##NO_TEXT.
        ENDIF.

      lo_dist_n ?= list->car.
      lo_turtles ?= list->cdr->car.
      result = lo_turtles.

      lo_turtles->turtle->pen_down( ).
      lo_turtles->turtle->forward( lo_dist_n->integer ).
    ENDMETHOD.

    METHOD proc_turtle_erase.
      "_validate: list, list->cdr.
        IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
*    (erase n turtles) → turtles?
*
*      n : real?
*      turtles : turtles?
      DATA lo_dist_n TYPE REF TO lcl_lisp_integer.
      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.

      "_validate_integer list->car `turtles erase n`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in turtles erase n` ) ##NO_TEXT.
        ENDIF.

      "_validate_turtle list->cdr->car `turtles erase`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->cdr->car->to_string( ) && ` is not a turtle in turtles erase` ) ##NO_TEXT.
        ENDIF.

      lo_dist_n ?= list->car.
      lo_turtles ?= list->cdr->car.
      result = lo_turtles.

      lo_turtles->turtle->pen_down( ).
      lo_turtles->turtle->forward( lo_dist_n->integer ).
    ENDMETHOD.

    METHOD proc_turtle_move_offset.
     "_validate: list, list->cdr, list->cdr->cdr.
     IF list IS NOT BOUND OR list->cdr IS NOT BOUND OR list->cdr->cdr IS NOT BOUND.
       lcl_lisp=>throw( c_error_incorrect_input ).
     ENDIF.
*    (move-offset h v turtles) → turtles?
*      h : real? (integer)
*      v : real? (integer)
*      turtles : turtles?
      DATA lo_off_h TYPE REF TO lcl_lisp_integer.
      DATA lo_off_v TYPE REF TO lcl_lisp_integer.
      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.

      "_validate_integer list->car `turtles move-offset h`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in turtles move-offset h` ) ##NO_TEXT.
        ENDIF.

      "_validate_integer list->cdr->car `turtles move-offset v`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in turtles move-offset v` ) ##NO_TEXT.
        ENDIF.

      "_validate_turtle list->cdr->cdr->car `move-offset`.
        IF list->cdr->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->cdr->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->cdr->cdr->car->to_string( ) && ` is not a turtle in move-offset` ) ##NO_TEXT.
        ENDIF.

      lo_off_h ?= list->car.
      lo_off_v ?= list->cdr->car.
      lo_turtles ?= list->cdr->cdr->car.
      result = lo_turtles.

      lo_turtles->turtle->pen_up( ).
      lo_turtles->turtle->to_offset( delta_x = lo_off_h->integer
                                     delta_y = lo_off_v->integer ).
    ENDMETHOD.

    METHOD proc_turtle_draw_offset.
      "_validate: list, list->cdr, list->cdr->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND OR list->cdr->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

*    (draw-offset h v turtles) → turtles?
*      h : real? (integer)
*      v : real? (integer)
*      turtles : turtles?
      DATA lo_off_h TYPE REF TO lcl_lisp_integer.
      DATA lo_off_v TYPE REF TO lcl_lisp_integer.
      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.

      "_validate_integer list->car `turtles draw-offset h`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in turtles draw-offset h`  ) ##NO_TEXT.
        ENDIF.

      "_validate_integer list->cdr->car `turtles draw-offset v`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in draw-offset v` ) ##NO_TEXT.
        ENDIF.

      "_validate_turtle list->cdr->cdr->car `draw-offset`.
        IF list->cdr->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->cdr->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->cdr->cdr->car->to_string( ) && ` is not a turtle in draw-offset` ) ##NO_TEXT.
        ENDIF.

      lo_off_h ?= list->car.
      lo_off_v ?= list->cdr->car.
      lo_turtles ?= list->cdr->cdr->car.

      lo_turtles->turtle->pen_down( ).
      lo_turtles->turtle->to_offset( delta_x = lo_off_h->integer
                                     delta_y = lo_off_v->integer ).
    ENDMETHOD.

    METHOD proc_turtle_erase_offset.
      "_validate: list, list->cdr, list->cdr->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND OR list->cdr->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
*    (erase-offset n turtles) → turtles?
*      n : real?
*      turtles : turtles?
      DATA lo_off_h TYPE REF TO lcl_lisp_integer.
      DATA lo_off_v TYPE REF TO lcl_lisp_integer.
      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.

      "_validate_integer list->car `turtles erase-offset h`.
      IF list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      IF list->car->type NE lcl_lisp=>type_integer.
        throw( list->car->to_string( ) && ` is not an integer in turtles erase-offset h` ) ##NO_TEXT.
      ENDIF.

      "_validate_integer list->cdr->car `turtles erase-offset v`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in turtles erase-offset v` ) ##NO_TEXT.
        ENDIF.

      "_validate_turtle list->cdr->cdr->car `erase-offset`.
        IF list->cdr->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->cdr->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->cdr->cdr->car->to_string( ) && ` is not a turtle in erase-offset` ) ##NO_TEXT.
        ENDIF.

      lo_off_h ?= list->car.
      lo_off_v ?= list->cdr->car.
      lo_turtles ?= list->cdr->cdr->car.

      lo_turtles->turtle->pen_down( ).
      lo_turtles->turtle->to_offset( delta_x = lo_off_h->integer
                                     delta_y = lo_off_v->integer ).
    ENDMETHOD.

    METHOD proc_turtle_turn_degrees. "turn
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
*      (turn theta turtles) → turtles?
*        theta : real?
*        turtles : turtles?
      "_validate_number list->car `turtles turn`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        CASE list->car->type.
          WHEN lcl_lisp=>type_integer
            OR lcl_lisp=>type_real
            OR lcl_lisp=>type_rational
            OR lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ list->car->to_string( ) } is not a number in [turtles turn]| ) ##NO_TEXT.
        ENDCASE.

      DATA lo_theta TYPE REF TO lcl_lisp_real.
      lo_theta ?= list->car.

      "_validate_turtle list->cdr->car `turn`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->cdr->car->to_string( ) && ` is not a turtle in turn` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.
      lo_turtles ?= list->cdr->car.

      DATA(angle) = ( lo_turtles->turtle->position-angle + lo_theta->real ) MOD 360.
      lo_turtles->turtle->set_position( VALUE #( x = lo_turtles->turtle->position-x
                                                 y = lo_turtles->turtle->position-y
                                                 angle = angle ) ).
      result = lo_turtles.
    ENDMETHOD.

    METHOD proc_turtle_turn_radians. "turn/radians
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

*      (turn/radians theta turtles) → turtles?
*        theta : real?
*        turtles : turtles?
      "_validate_number list->car `turn/radians theta`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        CASE list->car->type.
          WHEN lcl_lisp=>type_integer
            OR lcl_lisp=>type_real
            OR lcl_lisp=>type_rational
            OR lcl_lisp=>type_complex.
          WHEN OTHERS.
            throw( |{ list->car->to_string( ) } is not a number in [turn/radians theta]| ) ##NO_TEXT.
        ENDCASE.

      DATA lo_theta TYPE REF TO lcl_lisp_real.
      lo_theta ?= list->car.

      "_validate_turtle list->cdr->car `turn/radians`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->cdr->car->to_string( ) && ` is not a turtle in turn/radians` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.
      lo_turtles ?= list->cdr->car.

      DATA(angle) = lcl_turtle_convert=>degrees_to_radians( lo_turtles->turtle->position-angle MOD 360 ) + lo_theta->real.
      angle = lcl_turtle_convert=>radians_to_degrees( angle ) MOD 360.

      lo_turtles->turtle->set_position( VALUE #( x = lo_turtles->turtle->position-x
                                                 y = lo_turtles->turtle->position-y
                                                 angle = angle ) ).
      result = lo_turtles.
    ENDMETHOD.

    METHOD proc_turtle_set_pen_width. "set-pen-width
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
*      (set-pen-width turtles width) → turtles?
*        turtles : turtles?
*        width : (real-in 0 255)
      "_validate_turtle list->car `set-pen-width`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->car->to_string( ) && ` is not a turtle in set-pen-width` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.
      lo_turtles ?= list->car.

      "_validate_index list->cdr->car `set-pen-width`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF CAST lcl_lisp_integer( list->cdr->car )->integer LT 0.
          throw( list->cdr->car->to_string( ) && ` must be non-negative in set-pen-width` ) ##NO_TEXT.
        ENDIF.
      DATA lo_width TYPE REF TO lcl_lisp_integer.
      lo_width ?= list->cdr->car.

      lo_turtles->turtle->set_pen( VALUE #( BASE lo_turtles->turtle->pen
                                            stroke_width = lo_width->integer ) ).
      result = lo_turtles.
    ENDMETHOD.

    METHOD proc_turtle_set_pen_color. "set-pen-color
      "_validate: list, list->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
*    (set-pen-color turtles color) → turtles?
*      turtles : turtles?
*      color : (or/c string? (is-a?/c color%))
      "_validate_turtle list->car `set-pen-color`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->car->to_string( ) && ` is not a turtle in set-pen-color` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.
      lo_turtles ?= list->car.

      "_validate_string list->cdr->car `set-pen-color`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_string.
          throw( list->cdr->car->to_string( ) && ` is not a string in set-pen-color` ) ##NO_TEXT.
        ENDIF.
      DATA lo_color TYPE REF TO lcl_lisp_string.
      lo_color ?= list->cdr->car.

      lo_turtles->turtle->set_pen( VALUE #( BASE lo_turtles->turtle->pen
                                            stroke_color = lo_color->value ) ).
      result = lo_turtles.
    ENDMETHOD.

    METHOD proc_turtle_state.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

*    (turtle-state turtles) → (listof (vector/c real? real? real?)
      "_validate_turtle list->car `turtle-state`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->car->to_string( ) && ` is not a turtle in turtle-state` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.
      lo_turtles ?= list->car.
      DATA(position) = lo_turtles->turtle->get_position( ).

      result = lcl_lisp_new=>cons( io_car = lcl_lisp_new=>vector(
                  it_vector = VALUE tt_lisp( ( lcl_lisp_new=>integer( position-x ) )
                                             ( lcl_lisp_new=>integer( position-y ) )
                                             ( lcl_lisp_new=>real( position-angle ) )  )
                  iv_mutable = abap_false ) ).
    ENDMETHOD.

    METHOD proc_turtle_clean.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

*    (clean turtles) → turtles?
*      turtles : turtles?
      "_validate_turtle list->car `clean`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->car->to_string( ) && ` is not a turtle in clean` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.
      lo_turtles ?= list->car.
      throw( `turtle clean not implemented yet` ).
      result = lo_turtles.
    ENDMETHOD.

    METHOD proc_turtle_width.
*    (turtles-width turtles) → (and/c real? positive?)
*      turtles : turtles?
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_turtle list->car `turtles-width`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->car->to_string( ) && ` is not a turtle in turtles-width` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.
      lo_turtles ?= list->car.

      result = lcl_lisp_new=>integer( lo_turtles->turtle->width ).
    ENDMETHOD.

    METHOD proc_turtle_height.
*    (turtles-height turtles) → (and/c real? positive?)
*      turtles : turtles?
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_turtle list->car `turtles-height`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->car->to_string( ) && ` is not a turtle in turtles-height` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.
      lo_turtles ?= list->car.

      result = lcl_lisp_new=>integer( lo_turtles->turtle->height ).
    ENDMETHOD.

    METHOD proc_turtle_pen_width.
*      (turtles-pen-width turtles) → (real-in 0 255)
*        turtles : turtles?
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_turtle list->car `turtles-pen-width`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->car->to_string( ) && ` is not a turtle in turtles-pen-width` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.
      lo_turtles ?= list->car.

      result = lcl_lisp_new=>integer( lo_turtles->turtle->pen-stroke_width ).
    ENDMETHOD.

    METHOD proc_turtle_pen_color.
*     (turtles-pen-color turtles) → (is-a?/c color%)
*       turtles : turtles?
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      "_validate_turtle list->car `turtles-pen-color`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->car->to_string( ) && ` is not a turtle in turtles-pen-color` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.
      lo_turtles ?= list->car.

      result = lcl_lisp_new=>string( lo_turtles->turtle->pen-stroke_color ).
    ENDMETHOD.

    METHOD proc_turtle_regular_poly.
      "_validate: list, list->cdr, list->cdr->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND OR list->cdr->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
*      (regular-poly sides radius turtles) → turtles?
*        sides : exact-nonnegative-integer?
*        radius : real?
*        turtles : turtles?
      "_validate_index list->car `regular-poly sides`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF CAST lcl_lisp_integer( list->car )->integer LT 0.
          throw( list->car->to_string( ) && ` must be non-negative in regular-poly sides` ) ##NO_TEXT.
        ENDIF.
      DATA lo_sides TYPE REF TO lcl_lisp_integer.
      lo_sides ?= list->car.

      "_validate_integer list->cdr->car `regular-poly radius`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in regular-poly radius` ) ##NO_TEXT.
        ENDIF.

      DATA lo_radius TYPE REF TO lcl_lisp_integer.
      lo_radius ?= list->cdr->car.

      "_validate_turtle list->cdr->cdr->car `regular-poly`.
        IF list->cdr->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->cdr->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->cdr->cdr->car->to_string( ) && ` is not a turtle in regular-poly` ) ##NO_TEXT.
        ENDIF.
      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.
      lo_turtles ?= list->cdr->cdr->car.

      lo_turtles->turtle->regular_polygon( num_sides = lo_sides->integer
                                           side_length = lo_radius->integer ).
      result = lo_turtles.
    ENDMETHOD.

    METHOD proc_turtle_regular_polys.
      "_validate: list, list->cdr, list->cdr->cdr.
      IF list IS NOT BOUND OR list->cdr IS NOT BOUND OR list->cdr->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
*      Draws n regular polys each with n sides centered at the turtle.
*      (regular-polys n s turtles) → turtles?
*        n : exact-nonnegative-integer?
*        s : any/c
*        turtles : turtles?
      "_validate_integer list->car `regular-polys n`.
        IF list->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->car->type NE lcl_lisp=>type_integer.
          throw( list->car->to_string( ) && ` is not an integer in regular-polys n` ) ##NO_TEXT.
        ENDIF.

      DATA lo_n TYPE REF TO lcl_lisp_integer.
      lo_n ?= list->car.

      "_validate_index list->cdr->car `regular-polys s`.
        IF list->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->car->type NE lcl_lisp=>type_integer.
          throw( list->cdr->car->to_string( ) && ` is not an integer in regular-polys s` ) ##NO_TEXT.
        ENDIF.
        IF CAST lcl_lisp_integer( list->cdr->car )->integer LT 0.
          throw( list->cdr->car->to_string( ) && ` must be non-negative in regular-polys s` ) ##NO_TEXT.
        ENDIF.

      DATA lo_side TYPE REF TO lcl_lisp_integer.
      lo_side ?= list->cdr->car.

      "_validate_turtle list->cdr->cdr->car `regular-polys`.
        IF list->cdr->cdr->car IS NOT BOUND.
          lcl_lisp=>throw( c_error_incorrect_input ).
        ENDIF.
        IF list->cdr->cdr->car->type NE lcl_lisp=>type_abap_turtle.
          throw( list->cdr->cdr->car->to_string( ) && ` is not a turtle in regular-polys` ) ##NO_TEXT.
        ENDIF.

      DATA lo_turtles TYPE REF TO lcl_lisp_turtle.
      lo_turtles ?= list->cdr->cdr->car.

      lo_turtles->turtle->polygon_flower( number_of_polygons = lo_n->integer
                                          polygon_sides = lo_n->integer
                                          side_length = lo_side->integer ).
      result = lo_turtles.
    ENDMETHOD.

  ENDCLASS.                    "lcl_lisp_interpreter IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_lisp_abapfunction IMPLEMENTATION
*----------------------------------------------------------------------*
*  CLASS lcl_lisp_abapfunction IMPLEMENTATION.
*
*    METHOD read_interface.
**      Determine the parameters of the function module to populate parameter table
**  TODO: At the moment, we do not support reference types in function module interfaces
*      function_name = iv_name.          "Name of function module
*      parameters_generated = abap_false.
*
**     Read the function module interface
*      CALL FUNCTION 'FUNCTION_IMPORT_INTERFACE'
*        EXPORTING
*          funcname           = function_name  " Name of the function module
*          with_enhancements  = 'X'            " X = Enhancement Parameters Will Be Provided
**         ignore_switches    = SPACE           " X = Switches Are Ignored
*        IMPORTING
*          remote_call        = interface-remote_call
*          update_task        = interface-update_task
*        TABLES
*          exception_list     = interface-exc
*          export_parameter   = interface-exp
*          import_parameter   = interface-imp
*          changing_parameter = interface-cha
*          tables_parameter   = interface-tbl
*          enha_exp_parameter = interface-enh_exp
*          enha_imp_parameter = interface-enh_imp
*          enha_cha_parameter = interface-enh_cha
*          enha_tbl_parameter = interface-enh_tbl
*        EXCEPTIONS
*          error_message      = 1
*          function_not_found = 2
*          invalid_name       = 3
*          OTHERS             = 4.
*      IF sy-subrc <> 0.
*        throw( |Function { function_name }: { error_message( ) }| ).
*      ENDIF.
*    ENDMETHOD.                    "read_interface
*
**(define bapi-userdetail (ab-function "BAPI_USER_GET_DETAIL"))  ;; Assign interface of BAPI_USER_GET_DETAIL to a symbol
**(ab-set bapi-userdetail "USERNAME" (ab-get ab-sy "UNAME"))     ;; Set parameter "USERNAME" to current user
*
*    METHOD call.
*      create_parameters( ).
**TODO: Map given list to parameters of function module
*
**     First parameter: Name of function to call;
**     second parameter: data to pass to interface
*      CALL FUNCTION list->value
*        PARAMETER-TABLE param_active
*        EXCEPTION-TABLE exceptions.
*
*      IF sy-subrc EQ c_error_message.
*        throw( |Call { list->value }: { error_message( ) }| ).
*      ENDIF.
*
**     Map output parameters to new list
*      ro_elem = list.      "Function reference is updated with values after call
*    ENDMETHOD.                    "call
*
*    METHOD error_message.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*         INTO rv_message.
*    ENDMETHOD.
*
*    METHOD get_function_parameter.
**     Get function parameter by name
**     IDENTIFIER -> Lisp element, string or symbol or index, to identify subcomponent of value
*      IF identifier = nil OR
*        ( identifier->type NE type_string AND identifier->type NE type_symbol ).
*        throw( `ab-get: String or symbol required to access function parameter` ).
*      ENDIF.
*
*      create_parameters( ).
*
*      TRY.
*          DATA(lv_parmname) = CONV abap_parmname( identifier->value ).
*          rdata = VALUE #( param_active[ name = lv_parmname ]-value
*                      DEFAULT parameters[ name = lv_parmname ]-value ). "#EC CI_SORTSEQ
*        CATCH cx_sy_itab_line_not_found.
*          throw( |ab-get: No parameter { lv_parmname } in function| ).
*      ENDTRY.
*    ENDMETHOD.                    "get_function_parameter
*
*    METHOD create_table_params.
**     Create structures in parameter - TABLES
*      LOOP AT it_table INTO DATA(ls_table).
*        DATA(ls_par) = VALUE abap_func_parmbind( kind = abap_func_tables
*                                                 name = ls_table-parameter ).
*
*        DATA(lv_type) = COND rs38l_typ( WHEN ls_table-typ IS INITIAL THEN ls_table-dbstruct ELSE ls_table-typ ).
*        CREATE DATA ls_par-value TYPE TABLE OF (lv_type).
*        CREATE DATA ls_par-tables_wa TYPE (lv_type).
*
*        INSERT ls_par INTO TABLE: parameters,
*                                  param_active.
*      ENDLOOP.
*    ENDMETHOD.
*
*    METHOD create_params.
*      TYPES: BEGIN OF ts_params,
*               parameter TYPE c LENGTH 30,
*               dbfield   TYPE c LENGTH 26,  " reference field/structure for parameter
*               typ       TYPE c LENGTH 132, " reference type
*
*               default   TYPE c LENGTH 21,  " default value for import parameter
*               optional  TYPE c LENGTH 1,
*             END OF ts_params.
*
*      DATA(ls_par) = VALUE abap_func_parmbind( kind = iv_kind ).
*      LOOP AT it_table ASSIGNING FIELD-SYMBOL(<row>).
*        DATA(ls_params) = CORRESPONDING ts_params( <row> ).
*
*        DATA(lv_type) = COND rs38l_typ( WHEN ls_params-dbfield IS NOT INITIAL THEN ls_params-dbfield
*                                        WHEN ls_params-typ IS NOT INITIAL THEN ls_params-typ
*                                        ELSE 'TEXT100' ).   "Fallback for untyped parameters
*        CREATE DATA ls_par-value TYPE (lv_type).
*
*        ls_par-name = ls_params-parameter.
*        INSERT ls_par INTO TABLE: parameters,
*                                  param_active.
*      ENDLOOP.
*    ENDMETHOD.
*
*    METHOD create_parameters.
*      CHECK parameters_generated EQ abap_false.
*
*      create_exceptions( ).
**     Tables
*      create_table_params( interface-tbl ).         "    input TABLES parameter
*      create_table_params( interface-enh_tbl ).
**     Import
*      create_params( it_table = interface-imp
*                     iv_kind = abap_func_exporting ).
*      create_params( it_table = interface-enh_imp
*                     iv_kind = abap_func_exporting ).
**     Export
*      create_params( it_table = interface-exp
*                     iv_kind = abap_func_importing ).
*      create_params( it_table = interface-enh_exp
*                     iv_kind = abap_func_importing ).
**     Changing
*      create_params( it_table = interface-cha
*                     iv_kind = abap_func_changing ).
*      create_params( it_table = interface-enh_cha
*                     iv_kind = abap_func_changing ).
*
*      parameters_generated = abap_true.
*    ENDMETHOD.
*
*    METHOD create_exceptions.
*      exceptions = VALUE #( ( name = 'OTHERS'        value = 10 )
*                            ( name = 'error_message' value = c_error_message ) ).
*    ENDMETHOD.
*
*  ENDCLASS.                    "lcl_lisp_abapfunction IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_lisp_environment IMPLEMENTATION
*----------------------------------------------------------------------*
  CLASS lcl_lisp_environment IMPLEMENTATION.

    METHOD scope_of.
*     find the environment where the symbol is defined
      env = me.
      WHILE env IS BOUND.
        IF line_exists( env->map[ symbol = symbol ] ).
          RETURN.                      " found
        ENDIF.
        env = env->outer.
      ENDWHILE.
      unbound_symbol( symbol ).
    ENDMETHOD.

    METHOD get.
**     Clever but probably expensive TRY / CATCH. This logic is called often
*      TRY.
*          cell = VALUE #( map[ symbol = symbol ]-value DEFAULT outer->get( symbol ) ).
*        CATCH cx_root.
*          unbound_symbol( symbol ).
*      ENDTRY.
      DATA ls_map LIKE LINE OF map.
      DATA lo_env TYPE REF TO lcl_lisp_environment.
*     takes a symbol key and uses the find logic to locate the environment with the key,
*     then returns the matching value.
      lo_env = me.
      WHILE lo_env IS BOUND.
        READ TABLE lo_env->map INTO ls_map WITH KEY symbol = symbol.
        IF sy-subrc EQ 0.
          cell = ls_map-value.
          RETURN.
        ENDIF.
        lo_env = lo_env->outer.
      ENDWHILE.
*     raises an "unbound" error if key is not found
      unbound_symbol( symbol ).
    ENDMETHOD.

    METHOD unbound_symbol.
*     symbol not found in the environment chain
      RAISE EXCEPTION TYPE lcx_lisp_exception
        EXPORTING
          message = |Symbol { symbol } is unbound|
          area    = c_area_eval.
    ENDMETHOD.

    METHOD define_value.
      element = lcl_lisp_new=>elem( type = type
                                    value = value ).
      set( symbol = symbol
           element = element ).
    ENDMETHOD.                    "define_cell

    METHOD set.
*     Add a value to the (local) environment
      DATA(ls_map) = VALUE ts_map( symbol = symbol
                                   value = element ).
      INSERT ls_map INTO TABLE map.
      CHECK sy-subrc = 4.
      IF once EQ abap_true.
*       The value must not exist yet in scope
*       It is an error for a <variable> to appear more than once in the list of variables.
        lcl_lisp=>throw( |variable { symbol } appears more than once| ).
      ELSE.
        MODIFY TABLE map FROM ls_map.         " overwrite existing defined values
      ENDIF.
    ENDMETHOD.

    METHOD parameters_to_symbols.
*     The lambda receives its own local environment in which to execute, where parameters
*     become symbols that are mapped to the corresponding arguments
*     Assign each argument to its corresponding symbol in the newly created environment
      DATA lv_count TYPE i.

      CASE io_pars->type.
        WHEN lcl_lisp=>type_pair.   "Do we have a proper list?

          DATA(lo_var) = io_pars.                " Pointer to formal parameters
          DATA(lo_arg) = io_args.                " Pointer to arguments
*         local environment used to detect duplicate variable usage (invalid)
          DATA(local) = lcl_lisp_env_factory=>clone( me ).

          WHILE lo_var NE lcl_lisp=>nil.         " Nil would mean no parameters to map

            IF lo_var->type EQ lcl_lisp=>type_symbol.
*             dotted pair after fixed number of parameters, to be bound to a variable number of arguments

*             1) Read the next parameter, bind to the (rest) list of arguments
              local->set( symbol = lo_var->value
                          element = lcl_lisp=>nil
                          once = abap_true ).
              set( symbol = lo_var->value
                   element = lo_arg ).
*             2) Exit
              RETURN.
            ENDIF.

*           Part of the list with fixed number of parameters

            IF lo_arg = lcl_lisp=>nil.           " Premature end of arguments
              lcl_lisp=>throw( |Missing parameter(s) { lo_var->to_string( ) }| ).
            ENDIF.

            lv_count += 1.

*           NOTE: Each element of the argument list is evaluated before being defined in the environment
            local->set( symbol = lo_var->car->value
                        element = lcl_lisp=>nil
                        once = abap_true ).
            set( symbol = lo_var->car->value
                 element = lo_arg->car ).

            lo_var = lo_var->cdr.
            lo_arg = lo_arg->cdr.
            CHECK lo_arg IS NOT BOUND.
            lo_arg = lcl_lisp=>nil.
          ENDWHILE.

          IF lo_arg NE lcl_lisp=>nil.  " Excessive number of arguments
            lcl_lisp=>throw( |Expected { lv_count } parameter(s), found { io_args->to_string( ) }| ).
          ENDIF.

        WHEN lcl_lisp=>type_symbol.
*         args is a symbol to be bound to a variable number of parameters
          set( symbol = io_pars->value
               element = io_args ).

      ENDCASE.

    ENDMETHOD.                    "parameters_to_symbols

    METHOD prepare.
*     Create symbols for nil, true and false values
      set( symbol = 'nil' element = lcl_lisp=>nil ).
      set( symbol = '#f' element = lcl_lisp=>true ).
      set( symbol = '#t' element = lcl_lisp=>false ).

*     Add primitive functions to environment
      define_value( symbol = 'define'          type = lcl_lisp=>type_syntax value   = 'define' ).
      define_value( symbol = 'lambda'          type = lcl_lisp=>type_syntax value   = 'lambda' ).
      define_value( symbol = 'if'              type = lcl_lisp=>type_syntax value   = 'if' ).
      define_value( symbol = c_eval_quote      type = lcl_lisp=>type_syntax value   = `'` ).
      define_value( symbol = c_eval_quasiquote type = lcl_lisp=>type_syntax value   = '`' ).
      define_value( symbol = 'set!'            type = lcl_lisp=>type_syntax value   = 'set!' ).

      define_value( symbol = 'define-macro'    type = lcl_lisp=>type_syntax value   = 'define-macro' ).
      define_value( symbol = 'define-syntax'   type = lcl_lisp=>type_syntax value   = 'define-syntax' ).
      define_value( symbol = 'macroexpand'     type = lcl_lisp=>type_syntax value   = 'macroexpand' ).
      define_value( symbol = 'gensym'          type = lcl_lisp=>type_syntax value   = 'gensym' ).
      define_value( symbol = 'case-lambda'     type = lcl_lisp=>type_syntax value   = 'case-lambda' ).
      define_value( symbol = 'parameterize'    type = lcl_lisp=>type_syntax value   = 'parameterize' ).

      define_value( symbol = 'and'      type = lcl_lisp=>type_syntax value   = 'and' ).
      define_value( symbol = 'or'       type = lcl_lisp=>type_syntax value   = 'or' ).
      define_value( symbol = 'cond'     type = lcl_lisp=>type_syntax value   = 'cond' ).
      define_value( symbol = 'unless'   type = lcl_lisp=>type_syntax value   = 'unless' ).
      define_value( symbol = 'when'     type = lcl_lisp=>type_syntax value   = 'when' ).
      define_value( symbol = 'begin'    type = lcl_lisp=>type_syntax value   = 'begin' ).
      define_value( symbol = 'let'      type = lcl_lisp=>type_syntax value   = 'let' ).
      define_value( symbol = 'let*'     type = lcl_lisp=>type_syntax value   = 'let*' ).
      define_value( symbol = 'letrec'   type = lcl_lisp=>type_syntax value   = 'letrec' ).
      define_value( symbol = 'letrec*'  type = lcl_lisp=>type_syntax value   = 'letrec*' ).
      define_value( symbol = 'do'       type = lcl_lisp=>type_syntax value   = 'do' ).
      define_value( symbol = 'case'     type = lcl_lisp=>type_syntax value   = 'case' ).

      define_value( symbol = c_eval_unquote          type = lcl_lisp=>type_syntax value   = ',' ).
      define_value( symbol = c_eval_unquote_splicing type = lcl_lisp=>type_syntax value   = ',@' ).

*     Procedures
      define_value( symbol = 'apply'        type = lcl_lisp=>type_primitive value   = 'apply' ).
      define_value( symbol = 'for-each'     type = lcl_lisp=>type_primitive value   = 'for-each' ).
      define_value( symbol = 'map'          type = lcl_lisp=>type_primitive value   = 'map' ).

*     Add native functions to environment
      define_value( symbol = '+'        type = lcl_lisp=>type_native value   = 'PROC_ADD' ).
      define_value( symbol = '-'        type = lcl_lisp=>type_native value   = 'PROC_SUBTRACT' ).
      define_value( symbol = '*'        type = lcl_lisp=>type_native value   = 'PROC_MULTIPLY' ).
      define_value( symbol = '/'        type = lcl_lisp=>type_native value   = 'PROC_DIVIDE' ).
      define_value( symbol = c_eval_append type = lcl_lisp=>type_native value   = 'PROC_APPEND' ).
      define_value( symbol = 'append!'     type = lcl_lisp=>type_native value   = 'PROC_APPEND_UNSAFE' ).
      define_value( symbol = 'list'     type = lcl_lisp=>type_native value   = 'PROC_LIST' ).
      define_value( symbol = 'length'   type = lcl_lisp=>type_native value   = 'PROC_LENGTH' ).
      define_value( symbol = 'reverse'  type = lcl_lisp=>type_native value   = 'PROC_REVERSE' ).
      define_value( symbol = 'not'      type = lcl_lisp=>type_native value   = 'PROC_NOT' ).

      define_value( symbol = 'make-list'    type = lcl_lisp=>type_native value   = 'PROC_MAKE_LIST' ).
      define_value( symbol = 'list-tail'    type = lcl_lisp=>type_native value   = 'PROC_LIST_TAIL' ).
      define_value( symbol = 'list-ref'     type = lcl_lisp=>type_native value   = 'PROC_LIST_REF' ).
      define_value( symbol = 'list-copy'    type = lcl_lisp=>type_native value   = 'PROC_LIST_COPY' ).
      define_value( symbol = 'list->vector' type = lcl_lisp=>type_native value   = 'PROC_LIST_TO_VECTOR' ).
      define_value( symbol = 'iota'         type = lcl_lisp=>type_native value   = 'PROC_IOTA' ).

      define_value( symbol = 'memq'    type = lcl_lisp=>type_native value   = 'PROC_MEMQ' ).
      define_value( symbol = 'memv'    type = lcl_lisp=>type_native value   = 'PROC_MEMV' ).
      define_value( symbol = 'member'  type = lcl_lisp=>type_native value   = 'PROC_MEMBER' ).

      define_value( symbol = 'assq'    type = lcl_lisp=>type_native value   = 'PROC_ASSQ' ).
      define_value( symbol = 'assv'    type = lcl_lisp=>type_native value   = 'PROC_ASSV' ).
      define_value( symbol = 'assoc'   type = lcl_lisp=>type_native value   = 'PROC_ASSOC' ).

      define_value( symbol = 'car'     type = lcl_lisp=>type_native value   = 'PROC_CAR' ).
      define_value( symbol = 'cdr'     type = lcl_lisp=>type_native value   = 'PROC_CDR' ).
      define_value( symbol = c_eval_cons    type = lcl_lisp=>type_native value   = 'PROC_CONS' ).
      define_value( symbol = 'nil?'    type = lcl_lisp=>type_native value   = 'PROC_NILP' ).
      define_value( symbol = 'null?'   type = lcl_lisp=>type_native value   = 'PROC_NILP' ).

      define_value( symbol = '>'       type = lcl_lisp=>type_native value   = 'PROC_GT' ).
      define_value( symbol = '>='      type = lcl_lisp=>type_native value   = 'PROC_GTE' ).
      define_value( symbol = '<'       type = lcl_lisp=>type_native value   = 'PROC_LT' ).
      define_value( symbol = '<='      type = lcl_lisp=>type_native value   = 'PROC_LTE' ).
      define_value( symbol = '='       type = lcl_lisp=>type_native value   = 'PROC_EQL' ). "Math equal
      define_value( symbol = 'eq?'     type = lcl_lisp=>type_native value   = 'PROC_EQ' ).
      define_value( symbol = 'eqv?'    type = lcl_lisp=>type_native value   = 'PROC_EQV' ).
      define_value( symbol = 'equal?'  type = lcl_lisp=>type_native value   = 'PROC_EQUAL' ).

      define_value( symbol = 'set-car!' type = lcl_lisp=>type_native value   = 'PROC_SET_CAR' ).
      define_value( symbol = 'set-cdr!' type = lcl_lisp=>type_native value   = 'PROC_SET_CDR' ).

      define_value( symbol = 'caar'     type = lcl_lisp=>type_native value   = 'PROC_CAAR' ).
      define_value( symbol = 'cadr'     type = lcl_lisp=>type_native value   = 'PROC_CADR' ).
      define_value( symbol = 'cdar'     type = lcl_lisp=>type_native value   = 'PROC_CDAR' ).
      define_value( symbol = 'cddr'     type = lcl_lisp=>type_native value   = 'PROC_CDDR' ).
      define_value( symbol = 'caaar'    type = lcl_lisp=>type_native value   = 'PROC_CAAAR' ).
      define_value( symbol = 'cdaar'    type = lcl_lisp=>type_native value   = 'PROC_CDAAR' ).
      define_value( symbol = 'caadr'    type = lcl_lisp=>type_native value   = 'PROC_CAADR' ).
      define_value( symbol = 'cdadr'    type = lcl_lisp=>type_native value   = 'PROC_CDADR' ).
      define_value( symbol = 'cadar'    type = lcl_lisp=>type_native value   = 'PROC_CADAR' ).
      define_value( symbol = 'cddar'    type = lcl_lisp=>type_native value   = 'PROC_CDDAR' ).
      define_value( symbol = 'caddr'    type = lcl_lisp=>type_native value   = 'PROC_CADDR' ).
      define_value( symbol = 'cdddr'    type = lcl_lisp=>type_native value   = 'PROC_CDDDR' ).

      define_value( symbol = 'caaaar'    type = lcl_lisp=>type_native value   = 'PROC_CAAAAR' ).
      define_value( symbol = 'cdaaar'    type = lcl_lisp=>type_native value   = 'PROC_CDAAAR' ).
      define_value( symbol = 'cadaar'    type = lcl_lisp=>type_native value   = 'PROC_CADAAR' ).
      define_value( symbol = 'cddaar'    type = lcl_lisp=>type_native value   = 'PROC_CDDAAR' ).
      define_value( symbol = 'caaadr'    type = lcl_lisp=>type_native value   = 'PROC_CAAADR' ).
      define_value( symbol = 'cdaadr'    type = lcl_lisp=>type_native value   = 'PROC_CDAADR' ).
      define_value( symbol = 'cadadr'    type = lcl_lisp=>type_native value   = 'PROC_CADADR' ).
      define_value( symbol = 'cddadr'    type = lcl_lisp=>type_native value   = 'PROC_CDDADR' ).
      define_value( symbol = 'caadar'    type = lcl_lisp=>type_native value   = 'PROC_CAADAR' ).
      define_value( symbol = 'cdadar'    type = lcl_lisp=>type_native value   = 'PROC_CDADAR' ).
      define_value( symbol = 'caddar'    type = lcl_lisp=>type_native value   = 'PROC_CADDAR' ).
      define_value( symbol = 'cdddar'    type = lcl_lisp=>type_native value   = 'PROC_CDDDAR' ).
      define_value( symbol = 'caaddr'    type = lcl_lisp=>type_native value   = 'PROC_CAADDR' ).
      define_value( symbol = 'caaddr'    type = lcl_lisp=>type_native value   = 'PROC_CAADDR' ).
      define_value( symbol = 'cadddr'    type = lcl_lisp=>type_native value   = 'PROC_CADDDR' ).
      define_value( symbol = 'cddddr'    type = lcl_lisp=>type_native value   = 'PROC_CDDDDR' ).


      define_value( symbol = 'make-parameter'    type = lcl_lisp=>type_native value = 'PROC_MAKE_PARAMETER' ).

      define_value( symbol = 'current-input-port'  type = lcl_lisp=>type_native value = 'PROC_CURRENT_INPUT_PORT' ).
      define_value( symbol = 'current-output-port' type = lcl_lisp=>type_native value = 'PROC_CURRENT_OUTPUT_PORT' ).
      define_value( symbol = 'current-error-port'  type = lcl_lisp=>type_native value = 'PROC_CURRENT_ERROR_PORT' ).

      define_value( symbol = 'close-input-port'  type = lcl_lisp=>type_native value = 'PROC_CLOSE_INPUT_PORT' ).
      define_value( symbol = 'close-output-port' type = lcl_lisp=>type_native value = 'PROC_CLOSE_OUTPUT_PORT' ).
      define_value( symbol = 'close-port'        type = lcl_lisp=>type_native value = 'PROC_CLOSE_PORT' ).

*     vector-related functions
      define_value( symbol = 'vector'        type = lcl_lisp=>type_native value   = 'PROC_VECTOR' ).
      define_value( symbol = 'vector-length' type = lcl_lisp=>type_native value   = 'PROC_VECTOR_LENGTH' ).
      define_value( symbol = 'vector-set!'   type = lcl_lisp=>type_native value   = 'PROC_VECTOR_SET' ).
      define_value( symbol = 'vector-fill!'  type = lcl_lisp=>type_native value   = 'PROC_VECTOR_FILL' ).
      define_value( symbol = 'vector-ref'    type = lcl_lisp=>type_native value   = 'PROC_VECTOR_REF' ).
      define_value( symbol = 'vector->list'  type = lcl_lisp=>type_native value   = 'PROC_VECTOR_TO_LIST' ).
      define_value( symbol = 'make-vector'   type = lcl_lisp=>type_native value   = 'PROC_MAKE_VECTOR' ).

*     Hash-related functions
      define_value( symbol = 'make-hash'   type = lcl_lisp=>type_native value   = 'PROC_MAKE_HASH' ).
      define_value( symbol = 'hash-get'    type = lcl_lisp=>type_native value   = 'PROC_HASH_GET' ).
      define_value( symbol = 'hash-insert' type = lcl_lisp=>type_native value   = 'PROC_HASH_INSERT' ).
      define_value( symbol = 'hash-remove' type = lcl_lisp=>type_native value   = 'PROC_HASH_REMOVE' ).
      define_value( symbol = 'hash-keys'   type = lcl_lisp=>type_native value   = 'PROC_HASH_KEYS' ).
*     Functions for type:
      define_value( symbol = 'string?'     type = lcl_lisp=>type_native value = 'PROC_IS_STRING' ).
      define_value( symbol = 'char?'       type = lcl_lisp=>type_native value = 'PROC_IS_CHAR' ).
      define_value( symbol = 'hash?'       type = lcl_lisp=>type_native value = 'PROC_IS_HASH' ).
      define_value( symbol = 'number?'     type = lcl_lisp=>type_native value = 'PROC_IS_NUMBER' ).
      define_value( symbol = 'exact-integer?'    type = lcl_lisp=>type_native value = 'PROC_IS_EXACT_INTEGER' ).
      define_value( symbol = 'integer?'    type = lcl_lisp=>type_native value = 'PROC_IS_INTEGER' ).
      define_value( symbol = 'complex?'    type = lcl_lisp=>type_native value = 'PROC_IS_COMPLEX' ).
      define_value( symbol = 'real?'       type = lcl_lisp=>type_native value = 'PROC_IS_REAL' ).
      define_value( symbol = 'rational?'   type = lcl_lisp=>type_native value = 'PROC_IS_RATIONAL' ).
      define_value( symbol = 'list?'       type = lcl_lisp=>type_native value = 'PROC_IS_LIST' ).
      define_value( symbol = 'pair?'       type = lcl_lisp=>type_native value = 'PROC_IS_PAIR' ).
      define_value( symbol = 'vector?'     type = lcl_lisp=>type_native value = 'PROC_IS_VECTOR' ).
      define_value( symbol = 'boolean?'    type = lcl_lisp=>type_native value = 'PROC_IS_BOOLEAN' ).
      define_value( symbol = 'alist?'      type = lcl_lisp=>type_native value = 'PROC_IS_ALIST' ).
      define_value( symbol = 'procedure?'  type = lcl_lisp=>type_native value = 'PROC_IS_PROCEDURE' ).
      define_value( symbol = 'symbol?'     type = lcl_lisp=>type_native value = 'PROC_IS_SYMBOL' ).
      define_value( symbol = 'port?'       type = lcl_lisp=>type_native value = 'PROC_IS_PORT' ).
      define_value( symbol = 'boolean=?'   type = lcl_lisp=>type_native value = 'PROC_BOOLEAN_LIST_IS_EQUAL' ).
      define_value( symbol = 'exact?'      type = lcl_lisp=>type_native value = 'PROC_IS_EXACT' ).
      define_value( symbol = 'inexact?'    type = lcl_lisp=>type_native value = 'PROC_IS_INEXACT' ).

*     Format
      define_value( symbol = 'newline'     type = lcl_lisp=>type_native value = 'PROC_NEWLINE' ).
      define_value( symbol = 'write'       type = lcl_lisp=>type_native value = 'PROC_WRITE' ).
      define_value( symbol = 'display'     type = lcl_lisp=>type_native value = 'PROC_DISPLAY' ).

      define_value( symbol = 'read'         type = lcl_lisp=>type_native value = 'PROC_READ' ).
      define_value( symbol = 'write-string' type = lcl_lisp=>type_native value = 'PROC_WRITE_STRING' ).
      define_value( symbol = 'write-char'   type = lcl_lisp=>type_native value = 'PROC_WRITE_CHAR' ).
      define_value( symbol = 'read-char'    type = lcl_lisp=>type_native value = 'PROC_READ_CHAR' ).
      define_value( symbol = 'read-string'  type = lcl_lisp=>type_native value = 'PROC_READ_STRING' ).
      define_value( symbol = 'char-ready?'  type = lcl_lisp=>type_native value = 'PROC_IS_CHAR_READY' ).
      define_value( symbol = 'peek-char'    type = lcl_lisp=>type_native value = 'PROC_PEEK_CHAR' ).

      define_value( symbol = 'exact'          type = lcl_lisp=>type_native value = 'PROC_TO_EXACT' ).
      define_value( symbol = 'inexact'        type = lcl_lisp=>type_native value = 'PROC_TO_INEXACT' ).

      define_value( symbol = 'number->string' type = lcl_lisp=>type_native value = 'PROC_NUM_TO_STRING' ).
      define_value( symbol = 'string->number' type = lcl_lisp=>type_native value = 'PROC_STRING_TO_NUM' ).
      define_value( symbol = 'make-string'    type = lcl_lisp=>type_native value = 'PROC_MAKE_STRING' ).
      define_value( symbol = 'string'         type = lcl_lisp=>type_native value = 'PROC_STRING' ).
      define_value( symbol = 'string->list'   type = lcl_lisp=>type_native value = 'PROC_STRING_TO_LIST' ).
      define_value( symbol = 'list->string'   type = lcl_lisp=>type_native value = 'PROC_LIST_TO_STRING' ).
      define_value( symbol = 'symbol->string' type = lcl_lisp=>type_native value = 'PROC_SYMBOL_TO_STRING' ).
      define_value( symbol = 'string->symbol' type = lcl_lisp=>type_native value = 'PROC_STRING_TO_SYMBOL' ).
      define_value( symbol = 'string-append'  type = lcl_lisp=>type_native value = 'PROC_STRING_APPEND' ).
      define_value( symbol = 'string-length'  type = lcl_lisp=>type_native value = 'PROC_STRING_LENGTH' ).
      define_value( symbol = 'string-copy'    type = lcl_lisp=>type_native value = 'PROC_STRING_COPY' ).
      define_value( symbol = 'substring'      type = lcl_lisp=>type_native value = 'PROC_STRING_COPY' ).
      define_value( symbol = 'string-ref'     type = lcl_lisp=>type_native value = 'PROC_STRING_REF' ).
      define_value( symbol = 'string-set!'    type = lcl_lisp=>type_native value = 'PROC_STRING_SET' ).

      define_value( symbol = 'string=?'     type = lcl_lisp=>type_native value   = 'PROC_STRING_LIST_IS_EQ' ).
      define_value( symbol = 'string<?'     type = lcl_lisp=>type_native value   = 'PROC_STRING_LIST_IS_LT' ).
      define_value( symbol = 'string>?'     type = lcl_lisp=>type_native value   = 'PROC_STRING_LIST_IS_GT' ).
      define_value( symbol = 'string<=?'    type = lcl_lisp=>type_native value   = 'PROC_STRING_LIST_IS_LE' ).
      define_value( symbol = 'string>=?'    type = lcl_lisp=>type_native value   = 'PROC_STRING_LIST_IS_GE' ).

      define_value( symbol = 'string-ci=?'     type = lcl_lisp=>type_native value   = 'PROC_STRING_CI_LIST_IS_EQ' ).
      define_value( symbol = 'string-ci<?'     type = lcl_lisp=>type_native value   = 'PROC_STRING_CI_LIST_IS_LT' ).
      define_value( symbol = 'string-ci>?'     type = lcl_lisp=>type_native value   = 'PROC_STRING_CI_LIST_IS_GT' ).
      define_value( symbol = 'string-ci<=?'    type = lcl_lisp=>type_native value   = 'PROC_STRING_CI_LIST_IS_LE' ).
      define_value( symbol = 'string-ci>=?'    type = lcl_lisp=>type_native value   = 'PROC_STRING_CI_LIST_IS_GE' ).

*     Math
      define_value( symbol = 'abs'   type = lcl_lisp=>type_native value = 'PROC_ABS' ).
      define_value( symbol = 'sin'   type = lcl_lisp=>type_native value = 'PROC_SIN' ).
      define_value( symbol = 'cos'   type = lcl_lisp=>type_native value = 'PROC_COS' ).
      define_value( symbol = 'tan'   type = lcl_lisp=>type_native value = 'PROC_TAN' ).
      define_value( symbol = 'asin'  type = lcl_lisp=>type_native value = 'PROC_ASIN' ).
      define_value( symbol = 'acos'  type = lcl_lisp=>type_native value = 'PROC_ACOS' ).
      define_value( symbol = 'atan'  type = lcl_lisp=>type_native value = 'PROC_ATAN' ).
      define_value( symbol = 'sinh'  type = lcl_lisp=>type_native value = 'PROC_SINH' ).
      define_value( symbol = 'cosh'  type = lcl_lisp=>type_native value = 'PROC_COSH' ).
      define_value( symbol = 'tanh'  type = lcl_lisp=>type_native value = 'PROC_TANH' ).
      define_value( symbol = 'asinh' type = lcl_lisp=>type_native value = 'PROC_ASINH' ).
      define_value( symbol = 'acosh' type = lcl_lisp=>type_native value = 'PROC_ACOSH' ).
      define_value( symbol = 'atanh' type = lcl_lisp=>type_native value = 'PROC_ATANH' ).
      define_value( symbol = 'expt'  type = lcl_lisp=>type_native value = 'PROC_EXPT' ).
      define_value( symbol = 'exp'   type = lcl_lisp=>type_native value = 'PROC_EXP' ).
      define_value( symbol = 'log'   type = lcl_lisp=>type_native value = 'PROC_LOG' ).
      define_value( symbol = 'sqrt'  type = lcl_lisp=>type_native value = 'PROC_SQRT' ).

      define_value( symbol = 'floor'    type = lcl_lisp=>type_native value = 'PROC_FLOOR' ).
      define_value( symbol = 'ceiling'  type = lcl_lisp=>type_native value = 'PROC_CEILING' ).
      define_value( symbol = 'truncate' type = lcl_lisp=>type_native value = 'PROC_TRUNCATE' ).
      define_value( symbol = 'round'    type = lcl_lisp=>type_native value = 'PROC_ROUND' ).

      define_value( symbol = 'numerator'   type = lcl_lisp=>type_native value = 'PROC_NUMERATOR' ).
      define_value( symbol = 'denominator' type = lcl_lisp=>type_native value = 'PROC_DENOMINATOR' ).
      define_value( symbol = 'remainder' type = lcl_lisp=>type_native value = 'PROC_REMAINDER' ).
      define_value( symbol = 'modulo'    type = lcl_lisp=>type_native value = 'PROC_MODULO' ).
      define_value( symbol = 'quotient'  type = lcl_lisp=>type_native value = 'PROC_QUOTIENT' ).
      define_value( symbol = 'random'    type = lcl_lisp=>type_native value = 'PROC_RANDOM' ).
      define_value( symbol = 'max'       type = lcl_lisp=>type_native value = 'PROC_MAX' ).
      define_value( symbol = 'min'       type = lcl_lisp=>type_native value = 'PROC_MIN' ).
      define_value( symbol = 'gcd'       type = lcl_lisp=>type_native value = 'PROC_GCD' ).
      define_value( symbol = 'lcm'       type = lcl_lisp=>type_native value = 'PROC_LCM' ).

      define_value( symbol = 'zero?'     type = lcl_lisp=>type_native value = 'PROC_IS_ZERO' ).
      define_value( symbol = 'positive?' type = lcl_lisp=>type_native value = 'PROC_IS_POSITIVE' ).
      define_value( symbol = 'negative?' type = lcl_lisp=>type_native value = 'PROC_IS_NEGATIVE' ).
      define_value( symbol = 'odd?'      type = lcl_lisp=>type_native value = 'PROC_IS_ODD' ).
      define_value( symbol = 'even?'     type = lcl_lisp=>type_native value = 'PROC_IS_EVEN' ).
*     Continuation
      define_value( symbol = 'call-with-current-continuation' type = lcl_lisp=>type_native value = 'PROC_CALL_CC' ).
      define_value( symbol = 'call/cc'                        type = lcl_lisp=>type_native value = 'PROC_CALL_CC' ).

*     Native functions for ABAP integration
      define_value( symbol = 'ab-data'       type = lcl_lisp=>type_native value   = 'PROC_ABAP_DATA' ).
      define_value( symbol = 'ab-function'   type = lcl_lisp=>type_native value   = 'PROC_ABAP_FUNCTION' ).
      define_value( symbol = 'ab-func-param' type = lcl_lisp=>type_native value   = 'PROC_ABAP_FUNCTION_PARAM' ).
      define_value( symbol = 'ab-table'      type = lcl_lisp=>type_native value   = 'PROC_ABAP_TABLE' ).
      define_value( symbol = 'ab-append-row' type = lcl_lisp=>type_native value   = 'PROC_ABAP_APPEND_ROW' ).
      define_value( symbol = 'ab-delete-row' type = lcl_lisp=>type_native value   = 'PROC_ABAP_DELETE_ROW' ).
      define_value( symbol = 'ab-get-row'    type = lcl_lisp=>type_native value   = 'PROC_ABAP_GET_ROW' ).
      define_value( symbol = 'ab-get-value'  type = lcl_lisp=>type_native value   = 'PROC_ABAP_GET_VALUE' ).
      define_value( symbol = 'ab-set-value'  type = lcl_lisp=>type_native value   = 'PROC_ABAP_SET_VALUE' ).

      define_value( symbol = 'ab-get' type = lcl_lisp=>type_native value = 'PROC_ABAP_GET' ).
      define_value( symbol = 'ab-set' type = lcl_lisp=>type_native value = 'PROC_ABAP_SET' ).

*     Compatibility
      define_value( symbol = 'empty?'  type = lcl_lisp=>type_native value   = 'PROC_NILP' ).
      define_value( symbol = 'first'   type = lcl_lisp=>type_native value   = 'PROC_CAR' ).
      define_value( symbol = 'rest'    type = lcl_lisp=>type_native value   = 'PROC_CDR' ).

*     Errors
      define_value( symbol = 'raise'   type = lcl_lisp=>type_native value   = 'PROC_RAISE' ).
      define_value( symbol = 'error'   type = lcl_lisp=>type_native value   = 'PROC_ERROR' ).

*     Ports
      define_value( symbol = 'input-port?'         type = lcl_lisp=>type_native value   = 'PROC_IS_INPUT_PORT' ).
      define_value( symbol = 'output-port?'        type = lcl_lisp=>type_native value   = 'PROC_IS_OUTPUT_PORT' ).
      define_value( symbol = 'textual-port?'       type = lcl_lisp=>type_native value   = 'PROC_IS_TEXTUAL_PORT' ).
      define_value( symbol = 'binary-port?'        type = lcl_lisp=>type_native value   = 'PROC_IS_BINARY_PORT' ).
      define_value( symbol = 'input-port-open?'    type = lcl_lisp=>type_native value   = 'PROC_IS_OPEN_INPUT_PORT' ).
      define_value( symbol = 'output-port-open?'   type = lcl_lisp=>type_native value   = 'PROC_IS_OPEN_OUTPUT_PORT' ).
      define_value( symbol = 'eof-object?'         type = lcl_lisp=>type_native value   = 'PROC_IS_EOF_OBJECT' ).
      define_value( symbol = 'open-output-string'  type = lcl_lisp=>type_native value   = 'PROC_OPEN_OUTPUT_STRING' ).
      define_value( symbol = 'open-input-string'   type = lcl_lisp=>type_native value   = 'PROC_OPEN_INPUT_STRING' ).
      define_value( symbol = 'get-output-string'   type = lcl_lisp=>type_native value   = 'PROC_GET_OUTPUT_STRING' ).
      define_value( symbol = 'eof-object'          type = lcl_lisp=>type_native value   = 'PROC_EOF_OBJECT' ).

      define_value( symbol = 'char-alphabetic?'  type = lcl_lisp=>type_native value   = 'PROC_IS_CHAR_ALPHABETIC' ).
      define_value( symbol = 'char-numeric?'     type = lcl_lisp=>type_native value   = 'PROC_IS_CHAR_NUMERIC' ).
      define_value( symbol = 'char-whitespace?'  type = lcl_lisp=>type_native value   = 'PROC_IS_CHAR_WHITESPACE' ).
      define_value( symbol = 'char-upper-case?'  type = lcl_lisp=>type_native value   = 'PROC_IS_CHAR_UPPER_CASE' ).
      define_value( symbol = 'char-lower-case?'  type = lcl_lisp=>type_native value   = 'PROC_IS_CHAR_LOWER_CASE' ).

      define_value( symbol = 'digit-value'       type = lcl_lisp=>type_native value   = 'PROC_DIGIT_VALUE' ).
      define_value( symbol = 'char->integer'     type = lcl_lisp=>type_native value   = 'PROC_CHAR_TO_INTEGER' ).
      define_value( symbol = 'integer->char'     type = lcl_lisp=>type_native value   = 'PROC_INTEGER_TO_CHAR' ).
      define_value( symbol = 'char-upcase'       type = lcl_lisp=>type_native value   = 'PROC_CHAR_UPCASE' ).
      define_value( symbol = 'char-downcase'     type = lcl_lisp=>type_native value   = 'PROC_CHAR_DOWNCASE' ).

      define_value( symbol = 'char=?'     type = lcl_lisp=>type_native value   = 'PROC_CHAR_LIST_IS_EQ' ).
      define_value( symbol = 'char<?'     type = lcl_lisp=>type_native value   = 'PROC_CHAR_LIST_IS_LT' ).
      define_value( symbol = 'char>?'     type = lcl_lisp=>type_native value   = 'PROC_CHAR_LIST_IS_GT' ).
      define_value( symbol = 'char<=?'    type = lcl_lisp=>type_native value   = 'PROC_CHAR_LIST_IS_LE' ).
      define_value( symbol = 'char>=?'    type = lcl_lisp=>type_native value   = 'PROC_CHAR_LIST_IS_GE' ).

      define_value( symbol = 'char-ci=?'     type = lcl_lisp=>type_native value   = 'PROC_CHAR_CI_LIST_IS_EQ' ).
      define_value( symbol = 'char-ci<?'     type = lcl_lisp=>type_native value   = 'PROC_CHAR_CI_LIST_IS_LT' ).
      define_value( symbol = 'char-ci>?'     type = lcl_lisp=>type_native value   = 'PROC_CHAR_CI_LIST_IS_GT' ).
      define_value( symbol = 'char-ci<=?'    type = lcl_lisp=>type_native value   = 'PROC_CHAR_CI_LIST_IS_LE' ).
      define_value( symbol = 'char-ci>=?'    type = lcl_lisp=>type_native value   = 'PROC_CHAR_CI_LIST_IS_GE' ).

      define_value( symbol = 'sql-query'         type = lcl_lisp=>type_native value   = 'PROC_SQL_QUERY' ).
      define_value( symbol = 'define-query'      type = lcl_lisp=>type_native value   = 'PROC_SQL_PREPARE' ).

      define_value( symbol = 'turtles'       type = lcl_lisp=>type_native value   = 'PROC_TURTLE_NEW' ).
      define_value( symbol = 'turtles?'      type = lcl_lisp=>type_native value   = 'PROC_TURTLE_EXIST' ).
      define_value( symbol = 'move'          type = lcl_lisp=>type_native value   = 'PROC_TURTLE_MOVE' ).
      define_value( symbol = 'draw'          type = lcl_lisp=>type_native value   = 'PROC_TURTLE_DRAW' ).
      define_value( symbol = 'erase'         type = lcl_lisp=>type_native value   = 'PROC_TURTLE_ERASE' ).
      define_value( symbol = 'move-offset'   type = lcl_lisp=>type_native value   = 'PROC_TURTLE_MOVE_OFFSET' ).
      define_value( symbol = 'draw-offset'   type = lcl_lisp=>type_native value   = 'PROC_TURTLE_DRAW_OFFSET' ).
      define_value( symbol = 'erase-offset'  type = lcl_lisp=>type_native value   = 'PROC_TURTLE_ERASE_OFFSET' ).
      define_value( symbol = 'turn'          type = lcl_lisp=>type_native value   = 'PROC_TURTLE_TURN_DEGREES' ).
      define_value( symbol = 'turn/radians'  type = lcl_lisp=>type_native value   = 'PROC_TURTLE_TURN_RADIANS' ).
      define_value( symbol = 'set-pen-width' type = lcl_lisp=>type_native value   = 'PROC_TURTLE_SET_PEN_WIDTH' ).
      define_value( symbol = 'set-pen-color' type = lcl_lisp=>type_native value   = 'PROC_TURTLE_SET_PEN_COLOR' ).

      define_value( symbol = 'merge'             type = lcl_lisp=>type_native value = 'PROC_TURTLE_MERGE' ).
      define_value( symbol = 'clean'             type = lcl_lisp=>type_native value = 'PROC_TURTLE_CLEAN' ).
      define_value( symbol = 'turtle-state'      type = lcl_lisp=>type_native value = 'PROC_TURTLE_STATE' ).
      define_value( symbol = 'turtles-height'    type = lcl_lisp=>type_native value = 'PROC_TURTLE_HEIGHT' ).
      define_value( symbol = 'turtles-width'     type = lcl_lisp=>type_native value = 'PROC_TURTLE_WIDTH' ).
      define_value( symbol = 'turtles-pen-color' type = lcl_lisp=>type_native value = 'PROC_TURTLE_PEN_COLOR' ).
      define_value( symbol = 'turtles-pen-width' type = lcl_lisp=>type_native value = 'PROC_TURTLE_PEN_WIDTH' ).
      define_value( symbol = 'regular-poly'      type = lcl_lisp=>type_native value = 'PROC_TURTLE_REGULAR_POLY' ).
      define_value( symbol = 'regular-polys'     type = lcl_lisp=>type_native value = 'PROC_TURTLE_REGULAR_POLYS' ).

*     Define a value in the environment for SYST
      " set( symbol = 'ab-sy' element = lcl_lisp_new=>data( REF #( syst ) ) ).
      " obsolete, use class CL_ABAP_SYST
    ENDMETHOD.

  ENDCLASS.                    "lcl_lisp_environment IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_lisp_profiler DEFINITION
*----------------------------------------------------------------------*
  CLASS lcl_lisp_profiler DEFINITION INHERITING FROM lcl_lisp_interpreter.
    PUBLIC SECTION.
      METHODS eval_repl REDEFINITION.
      DATA runtime TYPE i READ-ONLY.
  ENDCLASS.                    "lcl_lisp_profiler DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_lisp_profiler IMPLEMENTATION
*----------------------------------------------------------------------*
  CLASS lcl_lisp_profiler IMPLEMENTATION.

    METHOD eval_repl.
*      DATA(timer) = cl_abap_runtime=>create_hr_timer( ).
*
*      DATA(lv_start) = timer->get_runtime( ).         " Start timer
      response = super->eval_repl( EXPORTING code = code
                                   IMPORTING output = output ).       " Evaluate given code
*      runtime = timer->get_runtime( ) - lv_start.
    ENDMETHOD.                    "eval_repl

  ENDCLASS.                    "lcl_lisp_profiler IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_lisp IMPLEMENTATION
*----------------------------------------------------------------------*
  CLASS lcl_lisp IMPLEMENTATION.

    METHOD class_constructor.
      nil = lcl_lisp_new=>null( ).
      false = lcl_lisp_new=>boolean( '#f' ).
      true = lcl_lisp_new=>boolean( '#t' ).
      undefined = lcl_lisp_new=>undefined( ).

      quote = lcl_lisp_new=>symbol( c_eval_quote ).
      quasiquote = lcl_lisp_new=>symbol( c_eval_quasiquote ).
      unquote = lcl_lisp_new=>symbol( c_eval_unquote ).
      unquote_splicing = lcl_lisp_new=>symbol( c_eval_unquote_splicing ).
      append = lcl_lisp_new=>symbol( c_eval_append ).
      cons = lcl_lisp_new=>symbol( c_eval_cons ).
      list = lcl_lisp_new=>symbol( c_eval_list ).

      char_alarm = lcl_lisp_new=>charx( '0007' ).
      char_backspace = lcl_lisp_new=>charx( '0008' ).
      char_delete = lcl_lisp_new=>charx( '007F' ).
      char_escape = lcl_lisp_new=>charx( '001B' ).
      char_newline = lcl_lisp_new=>charx( '000A' ).
      char_null = lcl_lisp_new=>charx( '0000' ).
      char_return = lcl_lisp_new=>charx( '000D' ).
      char_space = lcl_lisp_new=>char( ` ` ).
      char_tab = lcl_lisp_new=>charx( '0009' ).

      new_line = lcl_lisp_new=>string( |\n| ).
      eof_object = lcl_lisp_new=>char( c_lisp_eof ).
    ENDMETHOD.

    METHOD is_equivalent. "eqv?
      "_validate io_elem.
      IF io_elem IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      DATA lo_int TYPE REF TO lcl_lisp_integer.
      DATA lo_real TYPE REF TO lcl_lisp_real.

      result = false.

      DATA(b) = io_elem.
*     Object a and Object b are both #t or both #f or both the empty list.
      IF ( me EQ true AND b EQ true )
        OR ( me EQ false AND b EQ false )
        OR ( me EQ nil AND b EQ nil ).
        result = true.
        RETURN.
      ENDIF.

      CHECK type EQ b->type.

      CASE type.
        WHEN lcl_lisp=>type_integer.
* obj1 and obj2 are both exact numbers and are numerically equal (in the sense of =).
          lo_int ?= b.
          CHECK CAST lcl_lisp_integer( me )->integer = lo_int->integer.

        WHEN lcl_lisp=>type_real.
*obj1 and obj2 are both inexact numbers such that they are numerically equal (in the sense of =)
*and they yield the same results (in the sense of eqv?) when passed as arguments to any other
*procedure that can be defined as a finite composition of Scheme’s standard arithmetic procedures,
*provided it does not result in a NaN value.
          lo_real ?= b.
          CHECK CAST lcl_lisp_real( me )->float_eq( lo_real->real ).

        WHEN lcl_lisp=>type_symbol.
* obj1 and obj2 are both symbols and are the same symbol according to the symbol=? procedure (section 6.5).
          DATA(lo_symbol) = CAST lcl_lisp_symbol( me ).
          DATA(lo_s_b) = CAST lcl_lisp_symbol( b ).
          CHECK lo_symbol->value = lo_s_b->value
              AND lo_symbol->index = lo_s_b->index.  " for uninterned symbols

        WHEN lcl_lisp=>type_string.
* obj1 and obj2 are both characters and are the same character according to the char=? procedure (section 6.6).
          DATA(lo_string) = CAST lcl_lisp_string( me ).
          DATA(lo_str_b) = CAST lcl_lisp_string( b ).
          CHECK lo_string->value = lo_str_b->value.

        WHEN lcl_lisp=>type_pair.
* obj1 and obj2 are procedures whose location tags are equal (section 4.1.4).
          DATA(lo_pair) = CAST lcl_lisp_pair( me ).
          DATA(lo_p_b) = CAST lcl_lisp_pair( b ).
          CHECK lo_pair->car EQ lo_p_b->car AND lo_pair->cdr EQ lo_p_b->cdr.

        WHEN lcl_lisp=>type_lambda OR lcl_lisp=>type_case_lambda .
* obj1 and obj2 are procedures whose location tags are equal (section 4.1.4).
          DATA(lo_lambda) = CAST lcl_lisp_lambda( me ).
          DATA(lo_l_b) = CAST lcl_lisp_lambda( b ).
          CHECK lo_lambda->car EQ lo_l_b->car AND lo_lambda->cdr EQ lo_l_b->cdr
            AND lo_lambda->macro EQ lo_l_b->macro AND lo_lambda->environment = b->environment.

        WHEN OTHERS.
* obj1 and obj2 are pairs, vectors, bytevectors, records, or strings that denote the same location in the store (section 3.4).

          CHECK me = b.
      ENDCASE.
      result = true.
    ENDMETHOD.

    METHOD is_equal. "equal?
* The equal? procedure, when applied to pairs, vectors, strings and bytevectors, recursively compares them,
* returning #t when the unfoldings of its arguments into (possibly infinite) trees are equal (in the sense
* of equal?) as ordered trees, and #f otherwise.
* equal? returns the same as eqv? when applied to booleans, symbols, numbers, characters, ports, procedures,
* and the empty list. If two objects are eqv?, they must be equal? as well.
* In all other cases, equal? may return either #t or #f.
* Even if its arguments are circular data structures, equal? must always terminate.
      "_validate io_elem.
      IF io_elem IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF comp NE nil.
        DATA(lo_lambda) = comp->car.
        DATA(lo_env) = lo_lambda->environment.
        IF lo_env IS NOT BOUND.
          lo_env = environment.
        ENDIF.
        DATA(lo_head) = lcl_lisp_new=>list3( io_first = lo_lambda
                                             io_second = lcl_lisp_new=>quote( me )
                                             io_third = lcl_lisp_new=>quote( io_elem ) ).

        result = interpreter->eval( element = lo_head
                                    environment = lo_env ).
        RETURN.
      ENDIF.

      result = false.

      CHECK type EQ io_elem->type.

      CASE type.

        WHEN lcl_lisp=>type_pair.
          DATA(lo_a) = me.
          DATA(lo_slow_a) = me.

          DATA(lo_b) = io_elem.
          DATA(lo_slow_b) = io_elem.

          WHILE lo_a->type EQ lcl_lisp=>type_pair AND lo_b->type EQ lcl_lisp=>type_pair.
            IF lo_a->car EQ lo_a AND lo_b->car EQ lo_b.
*             Circular list
              result = true.
              RETURN.
            ELSEIF lo_a->car->is_equal( lo_b->car ) EQ false.
              RETURN.
            ENDIF.
            lo_slow_a = lo_slow_a->cdr.
            lo_a = lo_a->cdr.
            lo_slow_b = lo_slow_b->cdr.
            lo_b = lo_b->cdr.
            CHECK lo_a->type EQ lcl_lisp=>type_pair AND lo_b->type EQ lcl_lisp=>type_pair.
            IF lo_a->car->is_equal( lo_b->car ) EQ false.
              RETURN.
            ENDIF.
            lo_a = lo_a->cdr.
            lo_b = lo_b->cdr.
            CHECK lo_slow_a EQ lo_a AND lo_slow_b EQ lo_b.
*           Circular list
            result = true.
            RETURN.
          ENDWHILE.

          result = lo_a->is_equal( lo_b ).

        WHEN lcl_lisp=>type_vector.
          DATA lo_vec TYPE REF TO lcl_lisp_vector.
          DATA lo_elem_vec TYPE REF TO lcl_lisp_vector.
          lo_vec ?= me.
          lo_elem_vec ?= io_elem.
          result = lo_vec->to_list( )->is_equal( lo_elem_vec->to_list( ) ).

        WHEN lcl_lisp=>type_string.
          CHECK me->value EQ io_elem->value.
          result = true.

*        WHEN lcl_lisp=>type_bytevector.

        WHEN OTHERS.
          result = is_equivalent( io_elem ).

      ENDCASE.

    ENDMETHOD.

    METHOD new_iterator.
      ro_iter = NEW lcl_lisp_iterator( me ).
    ENDMETHOD.

    METHOD format_quasiquote.
*     Quasiquoting output (quasiquote x) is displayed as `x without parenthesis
      ev_skip = abap_false.
      CHECK io_elem->type EQ type_pair.

      IF io_elem->car->type EQ type_symbol OR io_elem->car->type EQ type_syntax.
        CASE io_elem->car->value.
          WHEN c_eval_quote OR `'`.
            ev_str = ev_str && `'`.
            ev_skip = abap_true.

          WHEN c_eval_quasiquote OR '`'.
            ev_str = ev_str && '`'.
            ev_skip = abap_true.

          WHEN c_eval_unquote OR ','.
            ev_str = ev_str && ','.
            ev_skip = abap_true.

          WHEN c_eval_unquote_splicing OR ',@'.
            ev_str = ev_str && ',@'.
            ev_skip = abap_true.

        ENDCASE.
      ENDIF.
    ENDMETHOD.

    METHOD set_shared_structure.
      DATA lo_ptr TYPE REF TO lcl_lisp.
      DATA lo_last_pair TYPE REF TO lcl_lisp.

      CHECK mv_label IS NOT INITIAL.

      CASE type.
        WHEN lcl_lisp=>type_pair.
          lo_last_pair = lo_ptr = me.
          WHILE lo_ptr->type EQ lcl_lisp=>type_pair.
            lo_last_pair = lo_ptr.
            lo_ptr = lo_ptr->cdr.
          ENDWHILE.
          IF lo_ptr->type = lcl_lisp=>type_symbol AND lo_ptr->value = mv_label.
            lo_last_pair->cdr = me.
          ENDIF.

        WHEN OTHERS.
          RETURN.
      ENDCASE.
    ENDMETHOD.

    METHOD list_to_string.
      DATA lv_str TYPE string.
      DATA lv_skip TYPE abap_boolean.
      DATA lv_parens TYPE abap_boolean.
      DATA lv_first TYPE abap_boolean VALUE abap_true.
      DATA lo_elem TYPE REF TO lcl_lisp.
      DATA lo_fast TYPE REF TO lcl_lisp.
      DATA lv_shared TYPE i VALUE -1.

      lo_elem = me.
      lo_fast = cdr.

      lv_parens = abap_true.
      WHILE lo_elem IS BOUND AND lo_elem NE nil.

*       Quasiquoting output (quasiquote x) is displayed as `x without parenthesis
        lv_skip = abap_false.
        IF lv_first EQ abap_true AND lo_elem->type EQ type_pair.
          lv_first = abap_false.

          format_quasiquote( EXPORTING io_elem = lo_elem
                             IMPORTING ev_skip = lv_skip
                                       ev_str = lv_str ).
          IF lv_skip EQ abap_true.
            lv_parens = abap_false.
          ENDIF.
        ENDIF.

        IF lo_fast IS BOUND AND lo_fast->type EQ type_pair.
          lo_fast = lo_fast->cdr.

          IF lo_fast IS BOUND AND lo_fast->type EQ type_pair AND lo_elem NE lo_fast.
            lo_fast = lo_fast->cdr.
          ENDIF.

          IF lo_elem = lo_fast.
*           Circular list
            lv_shared += 1.
            WHILE lo_elem->cdr NE lo_fast.
              lv_str = |{ lv_str } { lo_elem->car->to_string( ) }|.
              lo_elem = lo_elem->cdr.
            ENDWHILE.
            lv_str = |{ lv_str } { lo_elem->car->to_string( ) } . #{ lv_shared }#|.
            EXIT.
          ENDIF.

        ENDIF.

        IF lv_skip EQ abap_false.
          lv_str = lv_str && COND string( WHEN lo_elem->type NE type_pair     " If item is not a cons cell
                                          THEN | . { lo_elem->to_string( ) }|      " indicate with dot notation:
                                          ELSE | { lo_elem->car->to_string( ) }| ).
        ENDIF.

        lo_elem = lo_elem->cdr.

      ENDWHILE.

      IF lv_parens EQ abap_true.
        str = |{ lcl_parser=>c_open_paren }{ lv_str } { lcl_parser=>c_close_paren }|.
      ELSE.
*       Quasiquoting output
        str = lv_str.
      ENDIF.

      IF lv_shared GE 0.
        str = |#{ lv_shared } = { str }|.
      ENDIF.

    ENDMETHOD.                    "list_to_string

    METHOD to_string.
      CASE type.
        WHEN type_lambda.
          str = |<lambda> { car->list_to_string( ) }|.
        WHEN type_null.
          str = c_lisp_nil.

        WHEN type_syntax
          OR type_primitive
          OR type_symbol
          OR type_boolean.
          str = value.

        WHEN type_undefined.
          str = c_undefined.

        WHEN type_string.
          IF me EQ lcl_lisp=>new_line.
            str = |\n|.
          ELSE.
*           give back the string as a quoted string
            str = |"{ escape( val = value format = cl_abap_format=>e_html_js ) }"|.
          ENDIF.

        WHEN type_char.
          CASE me.
            WHEN lcl_lisp=>new_line.
              str = |\n|.
            WHEN lcl_lisp=>eof_object.
              str = '<eof>'.
            WHEN OTHERS.
              str = |"{ escape( val = value format = cl_abap_format=>e_html_js ) }"|.
          ENDCASE.

        WHEN type_integer.
          DATA lv_real TYPE tv_real.
          DATA lo_int TYPE REF TO lcl_lisp_integer.

          lo_int ?= me.
          lv_real = lo_int->integer.
          str = lv_real.
          str = condense( str ).

        WHEN type_real.
          DATA lo_real TYPE REF TO lcl_lisp_real.
          lo_real ?= me.
          str = condense( CAST lcl_lisp_real( me )->real ).
          "str = condense( CONV #( lo_real->real ) ).
*        WHEN type_rational.

*        WHEN type_complex.
*          str = ?.

        WHEN type_native.
          str = |<native> { to_lower( value ) }|.
        WHEN type_pair.
          str = list_to_string( ).
        WHEN type_hash.
          str = '<hash>'.
        WHEN type_vector.
          DATA lo_vec TYPE REF TO lcl_lisp_vector.
          lo_vec ?= me.
          str = |#{ lo_vec->to_list( )->to_string( ) }|.
        WHEN type_port.
          str = '<port>'.
*--------------------------------------------------------------------*
*        Additions for ABAP Types:
        WHEN type_abap_function.
          str = |<ABAP function module { value }>|.
*          TODO
*        WHEN type_abap_class.
*          str = |<ABAP class { value }>|.
*        WHEN type_abap_method.
*          str = |<ABAP method { car->value }->{ cdr->value }( ) >|.
        WHEN type_abap_data.
          str = |<ABAP Data>|.
        WHEN type_abap_table.
          str = |<ABAP Table>|.
        WHEN type_abap_query.
          str = |<ABAP Query>|.
        WHEN type_abap_sql_set.
          str = |<ABAP Query Result Set>|.

        WHEN type_abap_turtle.
          str = |<ABAP turtle>|.
      ENDCASE.
    ENDMETHOD.                    "to_string

    METHOD to_text.
      CASE type.
        WHEN type_string OR type_char.
          CASE me.
            WHEN lcl_lisp=>new_line.
              str = |\n|.
            WHEN lcl_lisp=>eof_object.
              str = space.
            WHEN OTHERS.
              str = value.
          ENDCASE.
        WHEN type_null OR type_undefined.
          str = space.
        WHEN OTHERS.
          str = to_string( ).
      ENDCASE.
    ENDMETHOD.

    METHOD error_not_a_pair.
      throw( context && to_string( ) && ` is not a pair` ).
    ENDMETHOD.

    METHOD throw.
      RAISE EXCEPTION TYPE lcx_lisp_exception
        EXPORTING
          message = message
          area    = c_area_eval.
    ENDMETHOD.                    "eval_err

    METHOD is_procedure.
      CASE type.
        WHEN type_lambda
          OR type_native
          OR type_primitive
          OR type_abap_function.  " really?
          result = true.
        WHEN OTHERS.
          result = false.
      ENDCASE.
    ENDMETHOD.

    METHOD is_number.
      CASE type.
        WHEN type_integer
          OR type_rational
          OR type_real
          OR type_complex.
          result = true.
        WHEN OTHERS.
          result = false.
      ENDCASE.
    ENDMETHOD.

  ENDCLASS.                    "lcl_lisp IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_lisp_iterator IMPLEMENTATION
*----------------------------------------------------------------------*
  CLASS lcl_lisp_iterator IMPLEMENTATION.

    METHOD constructor.
      elem = io_elem.
      first = abap_true.
    ENDMETHOD.

    METHOD has_next.
*     if the last element in the list is not a cons cell, we cannot append
      rv_flag = xsdbool( elem NE lcl_lisp=>nil AND
               ( first EQ abap_true OR ( elem->cdr IS BOUND AND elem->cdr NE lcl_lisp=>nil ) ) ).
    ENDMETHOD.                    "has_next

    METHOD next.
      IF first EQ abap_true.
        first = abap_false.
      ELSE.
        IF elem->cdr->type NE lcl_lisp=>type_pair.
          lcl_lisp=>throw( |{ elem->to_string( ) } is not a proper list| ).
        ENDIF.
        elem = elem->cdr.
      ENDIF.
      ro_elem = elem->car.
    ENDMETHOD.                    "next

  ENDCLASS.                    "lcl_lisp_iterator IMPLEMENTATION

  CLASS lcl_lisp_new IMPLEMENTATION.

    METHOD elem.
      CASE type.
        WHEN lcl_lisp=>type_integer.
          ro_elem = integer( value ).

        WHEN lcl_lisp=>type_real.
          ro_elem = real( value ).

        WHEN lcl_lisp=>type_string.
          ro_elem = string( value ).

        WHEN lcl_lisp=>type_char.
          ro_elem = char( value ).

        WHEN lcl_lisp=>type_boolean.
          ro_elem = boolean( value ).

        WHEN lcl_lisp=>type_abap_data.
          ro_elem = data( value ).

        WHEN lcl_lisp=>type_abap_table.
          ro_elem = table( value ).

        WHEN OTHERS.
          CREATE OBJECT ro_elem.
          ro_elem->type = type.
          ro_elem->value = value.

      ENDCASE.
    ENDMETHOD.

    METHOD atom.
      CASE value.
        WHEN space.
          ro_elem = lcl_lisp=>nil.  " or EOF_OBJECT?

        WHEN lcl_lisp=>true->value.
          ro_elem = lcl_lisp=>true.

        WHEN lcl_lisp=>false->value.
          ro_elem = lcl_lisp=>false.

        WHEN OTHERS.
          TRY.
              ro_elem = number( value ).
            CATCH cx_sy_conversion_no_number.
*             otherwise treat it as a symbol
              ro_elem = symbol( value ).
          ENDTRY.
      ENDCASE.
    ENDMETHOD.                    "new_atom

    METHOD string.
      ro_elem = NEW lcl_lisp_string( value = value
                                     iv_mutable = iv_mutable ).
    ENDMETHOD.

    METHOD char.
      ro_elem = lcl_lisp_char=>new( value ).
    ENDMETHOD.

    METHOD charx.
      DATA lv_char TYPE tv_char.
      FIELD-SYMBOLS <xword> TYPE x.
      FIELD-SYMBOLS <xchar> TYPE x.
      DATA xword TYPE tv_xword.
      DATA lv_int TYPE int2.

      xword = value.
      lv_int = xword.
      ASSIGN lv_int TO <xword> CASTING.
      ASSIGN lv_char TO <xchar> CASTING.
      <xchar> = <xword>.
      ro_elem = char( lv_char ).
    ENDMETHOD.

    METHOD symbol.
      ro_elem = NEW lcl_lisp_symbol( value = value
                                     index = index ).
    ENDMETHOD.

    METHOD boolean.
      ro_elem = NEW lcl_lisp_boolean( value ).
    ENDMETHOD.

    METHOD null.
      ro_elem = NEW lcl_lisp_null( ).
      ro_elem->type = lcl_lisp=>type_null.
      ro_elem->value = c_lisp_nil.
    ENDMETHOD.

    METHOD undefined.
      ro_elem = NEW lcl_lisp( ).
      ro_elem->type = lcl_lisp=>type_undefined.
    ENDMETHOD.

    METHOD integer.
      ro_elem = NEW lcl_lisp_integer( value ).
    ENDMETHOD.

    METHOD real.
      ro_elem = NEW lcl_lisp_real( value ).
    ENDMETHOD.

    METHOD number.
      CONSTANTS c_lisp_slash TYPE tv_char VALUE '/'.
      DATA lv_nummer_str TYPE string.
      DATA lv_denom_str TYPE string.
      DATA lv_denom TYPE tv_int.
      DATA lv_int TYPE tv_int.
      DATA lv_real TYPE tv_real.

      TRY.
*         Check whether the token can be converted to a float,
*         to cover all manner of number formats, including scientific
          lv_real = value.

          IF iv_exact IS SUPPLIED AND iv_exact EQ abap_false.
            ro_elem = real( lv_real ).
            RETURN.
          ENDIF.

          TRY.
              lv_nummer_str = value.
              IF NOT contains( val = lv_nummer_str sub = '.' ) OR iv_exact EQ abap_true.
                lv_int = EXACT tv_int( value ).
                ro_elem = integer( lv_int ).
                RETURN.
              ENDIF.
            CATCH cx_sy_conversion_error ##NO_HANDLER.
          ENDTRY.

          IF contains( val = lv_nummer_str sub = '.' ) AND iv_exact EQ abap_true.
            DATA lv_int_str TYPE string.
            DATA lv_dec_str TYPE string.
            SPLIT lv_nummer_str AT lcl_parser=>c_lisp_dot INTO lv_int_str lv_dec_str.
            lv_int_str = lv_int_str && lv_dec_str.
            lv_int = lv_int_str.
            lv_denom = ipow( base = 10 exp = strlen( lv_dec_str ) ).
            ro_elem = rational( nummer = lv_int
                                denom = lv_denom ).
            RETURN.
          ENDIF.

          ro_elem = real( lv_real ).
          RETURN.

        CATCH cx_sy_conversion_error.

          SPLIT value AT c_lisp_slash INTO lv_nummer_str lv_denom_str.
          IF sy-subrc EQ 0 AND lv_denom_str IS NOT INITIAL.
            lv_int = EXACT tv_int( lv_nummer_str ).
            lv_denom = EXACT tv_int( lv_denom_str ).
            ro_elem = rational( nummer = lv_int
                                denom = lv_denom ).
            RETURN.
          ENDIF.

      ENDTRY.

      RAISE EXCEPTION TYPE cx_sy_conversion_no_number
        EXPORTING
          value = value.

    ENDMETHOD.

    METHOD hex_integer.
      DATA lv_text TYPE string VALUE '0000000000000000'. " 2x8 = 16
      DATA lv_len TYPE tv_int.
      DATA lv_hex TYPE x LENGTH 8.

      lv_len = 16 - strlen( value ).
      IF lv_len GT 0.
        lv_text = lv_text+0(lv_len) && value.
      ELSE.
        lv_text = value.
      ENDIF.
      IF lv_text CA 'abcdef'.
        lv_text = to_upper( lv_text ).
      ENDIF.
      IF lv_text CO c_hex_digits.
        lv_hex = lv_text.
        rv_int = lv_hex.
      ELSE.
        "_throw_radix `Invalid hexadecimal number`.
          RAISE EXCEPTION TYPE lcx_lisp_exception
            EXPORTING
              message = `Invalid hexadecimal number`
              area    = 'Radix' ##NO_TEXT.
      ENDIF.
    ENDMETHOD.

    METHOD hex.
      DATA lv_text TYPE string.

      DATA lv_trunc_str TYPE string.
      DATA lv_decimal_str TYPE string.
      DATA lv_int TYPE tv_int.
      DATA lv_exp TYPE tv_int.
      DATA lv_dec TYPE tv_int.
      DATA lv_real TYPE tv_real.

      lv_text = value.
      SPLIT lv_text AT lcl_parser=>c_lisp_dot INTO lv_trunc_str lv_decimal_str.

      lv_int = hex_integer( lv_trunc_str ).
      IF lv_decimal_str IS INITIAL.
        ro_elem = integer( lv_int ).
      ELSE.
        lv_dec = hex_integer( lv_decimal_str ).
        lv_real = lv_int.
        IF lv_dec EQ 0.
          ro_elem = real( lv_real ).
        ELSE.
          lv_exp = strlen( lv_decimal_str ).
          ro_elem = real( lv_real + lv_dec / ipow( base = 16 exp = lv_exp ) ).
        ENDIF.
      ENDIF.
    ENDMETHOD.

    METHOD octal_integer.
      DATA lv_text TYPE string.
      DATA lv_index TYPE tv_int.
      DATA lv_size TYPE tv_int.
      DATA lv_char TYPE tv_char.
      DATA lv_radix TYPE i VALUE 1.

      CLEAR rv_int.
      lv_text = value.
      IF lv_text CN '01234567'.
        "_throw_radix `Invalid octal number`.
          RAISE EXCEPTION TYPE lcx_lisp_exception
            EXPORTING
              message = `Invalid octal number`
              area    = 'Radix' ##NO_TEXT.
      ENDIF.

      lv_index = lv_size = strlen( lv_text ).
      DO lv_size TIMES.
        lv_index -= 1.
        lv_char = lv_text+lv_index(1).

        rv_int = rv_int + lv_char * lv_radix.
        lv_radix = lv_radix * 8.
      ENDDO.
    ENDMETHOD.

    METHOD octal.
      DATA lv_text TYPE string.

      DATA lv_trunc_str TYPE string.
      DATA lv_decimal_str TYPE string.
      DATA lv_int TYPE tv_int.
      DATA lv_exp TYPE tv_int.
      DATA lv_real TYPE tv_real.
      DATA lv_dec TYPE tv_int.

      lv_text = value.
      SPLIT lv_text AT lcl_parser=>c_lisp_dot INTO lv_trunc_str lv_decimal_str.

      lv_int = octal_integer( lv_trunc_str ).
      IF lv_decimal_str IS INITIAL.
        ro_elem = integer( lv_int ).
      ELSE.
        lv_dec = octal_integer( lv_decimal_str ).
        lv_real = lv_int.
        IF lv_dec EQ 0.
          ro_elem = real( lv_real ).
        ELSE.
          lv_exp = strlen( lv_decimal_str ).
          ro_elem = real( lv_real + lv_dec / ipow( base = 8 exp = lv_exp ) ).
        ENDIF.
      ENDIF.
    ENDMETHOD.

    METHOD binary_integer.
      DATA lv_text TYPE string.
      DATA lv_index TYPE tv_int.
      DATA lv_size TYPE tv_int.
      DATA lv_radix TYPE i VALUE 1.

      lv_text = value.
      IF lv_text CN '01'.
        "_throw_radix `Invalid binary number`.
          RAISE EXCEPTION TYPE lcx_lisp_exception
            EXPORTING
              message = `Invalid binary number`
              area    = 'Radix' ##NO_TEXT.
      ENDIF.

      lv_index = lv_size = strlen( lv_text ).
      DO lv_size TIMES.
        lv_index -= 1.

        IF lv_text+lv_index(1) EQ '1'.
          rv_int = rv_int + lv_radix.
        ENDIF.
        lv_radix = lv_radix * 2.
      ENDDO.
    ENDMETHOD.

    METHOD binary.
      DATA lv_text TYPE string.

      DATA lv_trunc_str TYPE string.
      DATA lv_decimal_str TYPE string.
      DATA lv_int TYPE tv_int.
      DATA lv_exp TYPE tv_int.
      DATA lv_real TYPE tv_real.
      DATA lv_dec TYPE tv_int.

      lv_text = value.
      SPLIT lv_text AT lcl_parser=>c_lisp_dot INTO lv_trunc_str lv_decimal_str.

      lv_int = binary_integer( lv_trunc_str ).
      IF lv_decimal_str IS INITIAL.
        ro_elem = integer( lv_int ).
      ELSE.
        lv_dec = binary_integer( lv_decimal_str ).
        lv_real = lv_int.
        IF lv_dec EQ 0.
          ro_elem = real( lv_real ).
        ELSE.
          lv_exp = strlen( lv_decimal_str ).
          ro_elem = real( lv_real + lv_dec / ipow( base = 2 exp = lv_exp ) ).
        ENDIF.
      ENDIF.
    ENDMETHOD.

    METHOD port.
      IF iv_buffered EQ abap_true.
        CREATE OBJECT ro_port TYPE lcl_lisp_buffered_port
          EXPORTING
            iv_port_type = iv_port_type
            iv_input     = iv_input
            iv_output    = iv_output
            iv_error     = iv_error
            iv_separator = iv_separator
            iv_string    = iv_string
            out          = io_out.
      ELSE.
        CREATE OBJECT ro_port
          EXPORTING
            iv_port_type = iv_port_type
            iv_input     = iv_input
            iv_output    = iv_output
            iv_error     = iv_error
            out          = io_out.
      ENDIF.
    ENDMETHOD.

    METHOD rational.
      ro_elem = lcl_lisp_rational=>new( nummer = nummer
                                        denom = denom ).
    ENDMETHOD.

    METHOD data.
      ro_elem = NEW lcl_lisp_data( ).
      ro_elem->type = lcl_lisp=>type_abap_data.
      ro_elem->data = ref.
    ENDMETHOD.                    "new_data

    METHOD table.
      ro_elem = NEW lcl_lisp_table( ).
      ro_elem->type = lcl_lisp=>type_abap_table.
      ro_elem->data = ref.
    ENDMETHOD.                    "new_table

*    METHOD query.
*      TRY.
*          ro_elem = NEW lcl_lisp_query( ).
*        CATCH cx_sql_exception.
*          ro_elem = lcl_lisp=>nil.
*      ENDTRY.
*    ENDMETHOD.

    METHOD cons.
      ro_cons = NEW lcl_lisp_pair( ).
      ro_cons->type = lcl_lisp=>type_pair.
      ro_cons->car = io_car.
      ro_cons->cdr = io_cdr.
    ENDMETHOD.                    "new_cons

    METHOD box.
      ro_elem = cons( io_car = io_proc
                      io_cdr = cons( io_car = io_elem )  ).
    ENDMETHOD.

    METHOD list3.
      ro_cons = cons( io_car = io_first
                      io_cdr = box( io_proc = io_second
                                    io_elem = io_third ) ).
    ENDMETHOD.

    METHOD vector.
      ro_vec = NEW lcl_lisp_vector( ).
      ro_vec->type = lcl_lisp=>type_vector.
      ro_vec->vector = it_vector.
      ro_vec->mutable = iv_mutable.
      ro_vec->mo_length = number( lines( it_vector ) ).
    ENDMETHOD.

    METHOD turtles.
      ro_turtle = NEW lcl_lisp_turtle( width = width
                                       height = height
                                       init_x = init_x
                                       init_y = init_y
                                       init_angle = init_angle
                                       out = out ).
    ENDMETHOD.

    METHOD lambda.
*     The lambda is a special cell that stores a pointer to a list of parameters
*     and a pointer to a list which is the body to be evaluated later on
      DATA(lo_lambda) = NEW lcl_lisp_lambda( ).
      lo_lambda->type = lcl_lisp=>type_lambda.
      lo_lambda->car = io_car.               " List of parameters
      lo_lambda->cdr = io_cdr.               " Body
      lo_lambda->macro = iv_macro.
      lo_lambda->parameter_object = iv_parameter_object.

*     Store the reference to the environment in which the lambda was created (lexical scope)
*     e.g. if the lambda is created inside another lambda we want that environment to be present
*     when we evaluate the new lambda
      lo_lambda->environment = io_env.
      ro_lambda = lo_lambda.
    ENDMETHOD.                    "new_lambda

    METHOD case_lambda.
      IF it_clauses IS INITIAL.
        ro_lambda = lcl_lisp=>nil.
      ELSE.
        DATA(lo_lambda) = NEW lcl_lisp_case_lambda( ).
        lo_lambda->type = lcl_lisp=>type_case_lambda.
        lo_lambda->clauses = it_clauses.
        ro_lambda = lo_lambda.
      ENDIF.
    ENDMETHOD.

    METHOD hash.
      "_validate io_list.
      IF io_list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      ro_hash = NEW lcl_lisp_hash( ).
      ro_hash->type = lcl_lisp=>type_hash.
      ro_hash->fill( io_list->car ).
    ENDMETHOD.

    METHOD quote.
      ro_elem = box( io_proc = lcl_lisp=>quote
                     io_elem = io_elem ).
      ro_elem->cdr->mutable = abap_false.
    ENDMETHOD.

    METHOD box_quote.
*     quote to avoid double eval
      ro_elem = cons( io_car = quote( io_elem ) ).
      ro_elem->cdr->mutable = abap_false.
    ENDMETHOD.

    METHOD unquote.
      ro_elem = box( io_proc = lcl_lisp=>unquote
                     io_elem = io_elem ).
      ro_elem->cdr->mutable = abap_true.
    ENDMETHOD.

    METHOD splice_unquote.
      ro_elem = box( io_proc = lcl_lisp=>unquote_splicing
                     io_elem = io_elem ).
      ro_elem->cdr->mutable = abap_false.  " true?
    ENDMETHOD.

    METHOD quasiquote.
      ro_elem = box( io_proc = lcl_lisp=>quasiquote
                     io_elem = io_elem ).
      ro_elem->cdr->mutable = abap_false.
    ENDMETHOD.

*    METHOD function.
*      "_validate: io_list, io_list->car.
*      IF io_list IS NOT BOUND OR io_list->car IS NOT BOUND.
*        lcl_lisp=>throw( c_error_incorrect_input ).
*      ENDIF.
*
*      ro_func = NEW lcl_lisp_abapfunction( ).
*      ro_func->type = lcl_lisp=>type_abap_function.
**     Determine the parameters of the function module to populate parameter table
*      ro_func->value = ro_func->read_interface( io_list->car->value ).
*    ENDMETHOD.

  ENDCLASS.

*----------------------------------------------------------------------*
*       CLASS lcl_lisp_hash IMPLEMENTATION
*----------------------------------------------------------------------*
  CLASS lcl_lisp_hash IMPLEMENTATION.

    METHOD eval.
      result = NEW lcl_lisp_hash( ).
      result->type = lcl_lisp=>type_hash.

      LOOP AT hash INTO DATA(ls_entry).
        INSERT VALUE #( key = ls_entry-key
                        element = interpreter->eval( element = ls_entry-element
                                                     environment = environment ) ) INTO TABLE result->hash.
      ENDLOOP.

    ENDMETHOD.

    METHOD fill.
      "_validate list.
      IF list IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      DATA(lo_head) = list.
      CHECK lo_head->type = type_pair.

*     Can accept a parameter which should be a list of alternating symbols/strings and elements
      DATA(lo_iter) = lo_head->new_iterator( ).
      WHILE lo_iter->has_next( ).
        DATA(lo_key) = lo_iter->next( ).
        IF lo_key->type NE type_symbol AND lo_key->type NE type_string.
          throw( |make-hash: Use only symbol or string as a key| ).
        ENDIF.
        CHECK lo_iter->has_next( ).
        INSERT VALUE #( key = lo_key->value
                        element = lo_iter->next( ) ) INTO TABLE hash.
      ENDWHILE.
    ENDMETHOD.                    "new_hash

    METHOD get.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.

      IF list->car = nil.
        throw( |hash-get requires a key to access an element| ).
      ENDIF.

*      TODO: Additional check for key type
      result = VALUE #( hash[ key = list->car->value ]-element DEFAULT nil ).
    ENDMETHOD.                    "get

    METHOD insert.
      "_validate: list, list->car, list->cdr.
      IF list IS NOT BOUND OR list->car IS NOT BOUND OR list->cdr IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
* TODO: Check number and type of parameters
      INSERT VALUE #( key = list->car->value
                      element = list->cdr->car ) INTO TABLE hash.
* TODO: Should we overwrite existing keys?
      result = nil.
    ENDMETHOD.                    "insert

    METHOD delete.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
* TODO: Check number and type of parameters
      DELETE hash WHERE key = list->car->value.
      result = nil.
    ENDMETHOD.                    "delete

    METHOD get_hash_keys.
      DATA lo_ptr TYPE REF TO lcl_lisp.

      result = nil.
      LOOP AT hash INTO DATA(ls_entry).
        DATA(lo_last) = lcl_lisp_new=>cons( io_car = lcl_lisp_new=>symbol( ls_entry-key ) ).

        IF result EQ nil.
          result = lo_ptr = lo_last.
        ELSE.
          lo_ptr = lo_ptr->cdr = lo_last.
        ENDIF.
      ENDLOOP.
    ENDMETHOD.                    "get_hash_keys

    METHOD from_list.
      "_validate: list, list->car.
      IF list IS NOT BOUND OR list->car IS NOT BOUND.
        lcl_lisp=>throw( c_error_incorrect_input ).
      ENDIF.
      IF list->car->type NE type_hash.
        throw( |{ msg } only works on hashes| ).
      ENDIF.
      ro_hash = CAST #( list->car ).
    ENDMETHOD.                    "from_list

  ENDCLASS.                    "lcl_lisp_hash IMPLEMENTATION

  CLASS lcl_lisp_vector IMPLEMENTATION.

    METHOD init.
      DATA(lt_vector) = VALUE tt_lisp( FOR idx = 0 UNTIL idx = size ( io_fill )  ).
      ro_vector = lcl_lisp_new=>vector( it_vector = lt_vector
                                        iv_mutable = iv_mutable ).
    ENDMETHOD.

    METHOD from_list.
      DATA(lt_vector) = VALUE tt_lisp( ).
      DATA(lo_ptr) = io_list.
      WHILE lo_ptr NE nil.
        APPEND lo_ptr->car TO lt_vector.
        lo_ptr = lo_ptr->cdr.
      ENDWHILE.
      ro_vector = lcl_lisp_new=>vector( it_vector = lt_vector
                                        iv_mutable = iv_mutable ).
    ENDMETHOD.

    METHOD to_list.
      ro_elem = nil.
      ASSIGN vector[ 1 ] TO  FIELD-SYMBOL(<vec>).
      IF sy-subrc EQ 0.
        ro_elem = lcl_lisp_new=>cons( io_car = <vec> ).
        DATA(lo_ptr) = ro_elem.
      ENDIF.
      LOOP AT vector FROM 2 ASSIGNING <vec>.
        lo_ptr = lo_ptr->cdr = lcl_lisp_new=>cons( io_car = <vec> ).
      ENDLOOP.
    ENDMETHOD.

    METHOD get_list.
      DATA lv_end TYPE tv_index.

      DATA(lv_start) = from + 1.         " start is Inclusive

      IF to IS SUPPLIED.
        lv_end = to.                     " end is Exclusive
      ELSE.
        lv_end = lines( vector ).        " End of vector
      ENDIF.

      IF lv_end LT 1 OR lv_start GT lv_end.
        throw( |vector-ref: out-of-bound range| ).
      ENDIF.

      ro_elem = nil.
      CHECK lv_start BETWEEN 1 AND lv_end.

      ro_elem = lcl_lisp_new=>cons( io_car = vector[ lv_start ] ).

      DATA(lo_ptr) = ro_elem.
      LOOP AT vector FROM lv_start + 1 TO lv_end ASSIGNING FIELD-SYMBOL(<vec>).
        lo_ptr = lo_ptr->cdr = lcl_lisp_new=>cons( io_car = <vec> ).
      ENDLOOP.
    ENDMETHOD.

    METHOD get.
      DATA(lv_start) = index + 1.

      IF lv_start BETWEEN 1 AND lines( vector ).
        ro_elem = vector[ lv_start ].
      ELSE.
        throw( |vector-ref: out-of-bound position { index }| ).
      ENDIF.
    ENDMETHOD.

    METHOD set.
      "_validate_mutable me `vector`.
        "_validate me. " cannot  fail here
        IF me->mutable EQ abap_false.
          throw( |constant list in vector cannot be changed| ) ##NO_TEXT.
        ENDIF.

      DATA(lv_start) = index + 1.

      IF lv_start BETWEEN 1 AND lines( vector ).
        vector[ lv_start ] = io_elem.
      ELSE.
        throw( |vector-set!: out-of-bound position { index }| ).
      ENDIF.
    ENDMETHOD.

    METHOD fill.
      DATA lv_end TYPE tv_index.
      "_validate_mutable me `vector`.
        "_validate me. cannot fail here
        IF me->mutable EQ abap_false.
          throw( |constant list in vector cannot be changed| ) ##NO_TEXT.
        ENDIF.

      ro_elem = me.

      DATA(lv_start) = from + 1.         " start is Inclusive
      DATA(lv_size) = lines( vector ).
      IF to IS SUPPLIED.
        lv_end = to.                     " end is Exclusive
      ELSE.
        lv_end = lv_size.        " End of vector
      ENDIF.

      IF lv_end LT 1 OR lv_end GT lv_size OR lv_start GT lv_end.
        throw( |vector-fill!: out-of-bound range| ).
      ENDIF.

      LOOP AT vector FROM lv_start TO lv_end ASSIGNING FIELD-SYMBOL(<vec>).
        <vec> = elem.
      ENDLOOP.
    ENDMETHOD.

    METHOD length.
      ro_length = mo_length.
    ENDMETHOD.

    METHOD to_string.
      DATA(lo_list) = to_list( ).
      IF lo_list EQ nil.
        str = |#()|.
      ELSE.
        str = |#{ lo_list->to_string( ) }|.
      ENDIF.
    ENDMETHOD.

    METHOD is_equal.
      DATA lo_vec TYPE REF TO lcl_lisp_vector.
      DATA lo_ptr TYPE REF TO lcl_lisp.

      result = false.
      CHECK io_elem->type EQ type_vector.

      lo_vec ?= io_elem.
      CHECK lines( vector ) = lines( lo_vec->vector ).

      LOOP AT lo_vec->vector INTO DATA(lo_elem).
        lo_ptr = vector[ sy-tabix ].
        CHECK lo_ptr->is_equal( io_elem = lo_elem
                                comp = comp
                                interpreter = interpreter ) EQ false.
        RETURN.
      ENDLOOP.
      result = true.
    ENDMETHOD.

    METHOD eval.
      result = lcl_lisp_new=>vector( it_vector = VALUE tt_lisp( FOR lo_elem IN vector
                                                    ( interpreter->eval( element = lo_elem
                                                                         environment = environment ) ) )
                                     iv_mutable = abap_true ).
    ENDMETHOD.

    METHOD set_shared_structure.
      FIELD-SYMBOLS <lo_elem> TYPE REF TO lcl_lisp.

      CHECK mv_label IS NOT INITIAL.

      CASE type.
        WHEN lcl_lisp=>type_vector.
          LOOP AT vector ASSIGNING <lo_elem> WHERE table_line->type = type_symbol
                                               AND table_line->value = mv_label.
            <lo_elem> = me.
            RETURN.
          ENDLOOP.

        WHEN OTHERS.
          super->set_shared_structure( ).
      ENDCASE.
    ENDMETHOD.

  ENDCLASS.

*  CLASS lcl_lisp_query IMPLEMENTATION.
*
*    METHOD constructor.
*      super->constructor( ).
*      type = type_abap_query.
*      sql_query = osql.
*      connection = cl_sql_connection=>get_connection( ).
*      IF value IS INITIAL.
*        statement = connection->create_statement( ).
*      ELSE.
*        statement = connection->prepare_statement( sql_query ).
*      ENDIF.
*      mv_hold_cursor = abap_false.
*    ENDMETHOD.
*
*    METHOD execute.
**     Development not completed yet
*      DATA lo_set TYPE REF TO cl_sql_result_set.
*      IF sql_query IS NOT INITIAL.
**       prepared statement
**       statement->set_param( dref1 ).
*        lo_set = statement->execute_query( hold_cursor = mv_hold_cursor ).
*      ELSEIF query IS NOT INITIAL.
*        lo_set = statement->execute_query( statement = query
*                                           hold_cursor = mv_hold_cursor ).
**     ELSE ? which query to execute
*      ENDIF.
*      result = NEW lcl_lisp_sql_result( lo_set ).
*    ENDMETHOD.
*
*  ENDCLASS.
*
*  CLASS lcl_lisp_sql_result IMPLEMENTATION.
*
*    METHOD constructor.
*      super->constructor( ).
*      type = type_abap_sql_set.
*      result_set = io_result.
*    ENDMETHOD.
*
*    METHOD clear.
*      CHECK result_set IS BOUND.
*      result_set->clear_parameters( ).
*    ENDMETHOD.
*
*    METHOD close.
*      CHECK result_set IS BOUND.
*      result_set->close( ).
*      CLEAR result_set.
*    ENDMETHOD.
*  ENDCLASS.

  CLASS lcl_lisp_turtle IMPLEMENTATION.

    METHOD constructor.
      super->constructor( ).
      type = type_abap_turtle.
      turtle = lcl_turtle=>new( height = height->integer
                                width = width->integer
                                title = `SchemeTurtle`
                                out = out ).
      turtle->set_position( VALUE #( x = init_x->integer
                                     y = init_y->integer
                                     angle = init_angle->real ) ).
    ENDMETHOD.

  ENDCLASS.