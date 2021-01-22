       identification division.
       program-id. A1-ItemList.
       author. Jacky Yuan.
       date-written. 01/21/2021.

      *****************************************************************
      *   This program will demonstrate file reading, input and
      *   outputs as per the requirements of MAFD 4202 deliverable 1.
      ***************************************************************** 

       environment division.
       configuration section.
      *    
       input-output section.
       file-control.
      *
           select input-file
               assign to "../../../data/A2.dat"
               organization is line sequential.
      *
           select output-file
               assign to "../../../data/A2.out"
               organization is line sequential.

       data division.
       file section.
      *
      *Input and Output files and record definitions
      *
       fd input-file
           data record is input-line
           record contains 27 characters.
       01 input-line.
         05 il-item-number             pic x(4).
         05 il-product-class           pic x(1).
         05 il-description             pic x(13).
         05 il-quantity                pic zz9.
         05 il-unit-price              pic zzz9v99.

       fd output-file
           data record is output-line
           record contains 108 characters.

       01 output-line pic x(108).


       working-storage section.

       01 ws-report-heading.
         05 filler                     pic x(94) value spaces.
         05 ws-author-name             pic x(14) value "Jacky Yuan, A2".

       01 ws-column-heading-1.
         05 filler                     pic x(1) value spaces.
         05 filler                     pic x(4) value "ITEM".
         05 filler                     pic x(5) value spaces.
         05 filler                     pic x(4) value "ITEM".
         05 filler                     pic x(6) value spaces.
         05 filler                     pic x(3) value "QTY".
         05 filler                     pic x(5) value spaces.
         05 filler                     pic x(4) value "UNIT".
         05 filler                     pic x(7) value spaces.
         05 filler                     pic x(8) value "EXTENDED".
         05 filler                     pic x(7) value spaces.
         05 filler                     pic x(8) value "DISCOUNT".
         05 filler                     pic x(6) value spaces.
         05 filler                     pic x(9) value "NET PRICE".
         05 filler                     pic x(2) value spaces.
         05 filler                     pic x(5) value "CLASS".
         05 filler                     pic x(2) value spaces.
         05 filler                     pic x(5) value "TRANS".
         05 filler                     pic x(3) value spaces.
         05 filler                     pic x(14) value "TRANSPORTATION".

       01 ws-column-heading-2.
         05 filler                     pic x(2) value spaces.
         05 filler                     pic x(1) value "#".
         05 filler                     pic x(4) value spaces.
         05 filler                     pic x(11) value "DESCRIPTION".
         05 filler                     pic x(10) value spaces.
         05 filler                     pic x(5) value "PRICE".
         05 filler                     pic x(7) value spaces.
         05 filler                     pic x(5) value "PRICE".
         05 filler                     pic x(10) value spaces.
         05 filler                     pic x(6) value "AMOUNT".
         05 filler                     pic x(26) value spaces.
         05 filler                     pic x(1) value "%".
         05 filler                     pic x(10) value spaces.
         05 filler                     pic x(6) value "CHARGE".

       01 ws-detail-line.
         05 filler                     pic x(1) value spaces.
         05 ws-item-number             pic x(4).
         05 filler                     pic x(1) value spaces.
         05 ws-description             pic x(13).
         05 filler                     pic x(1) value spaces.
         05 ws-quantity-view           pic zz9.
         05 filler                     pic x(3) value spaces.
         05 ws-unit-price-view         pic zzz9.99.
         05 filler                     pic x(3) value spaces.
         05 ws-extended-price-view     pic z,zzz,zz9.99.
         05 filler                     pic x(3) value spaces.
         05 ws-discounted-price-view   pic zzz,zz9.99.
         05 filler                     pic x(4) value spaces.
         05 ws-net-price-view          pic z,zzz,zz9.99.
         05 filler                     pic x(4) value spaces.
         05 ws-product-class           pic x(1).
         05 filler                     pic x(5) value spaces.
         05 ws-trans-percent           pic z9.9.
         05 ws-symbol                  pic x.
         05 filler                     pic x(3) value spaces.
         05 ws-trans-cost-view         pic z,zzz,zz9.99.

       01 ws-totals.
         05 filler                     pic x(35) value spaces.
         05 ws-ep-total-view           pic $$$,$$$,$$9.99.
         05 filler                     pic x(14) value spaces.
         05 ws-np-total-view           pic $$$,$$$,$$9.99.
         05 filler                     pic x(16) value spaces.
         05 ws-tc-total-view           pic $$$,$$$,$$9.99.

       01 ws-non-discounted-summary.
         05 filler                     pic x(24)
                                       value "ITEMS WITHOUT DISCOUNT =".
         05 filler                     pic x value spaces.
         05 ws-non-discount-view       pic zz9.9.
         05 ws-symbol2                 pic x.

       01 ws-calcs.
         05 ws-quantity                pic 999.
         05 ws-unit-price              pic 9(4)v99.
         05 ws-extended-price          pic 9(7)v99.
         05 ws-discounted-price        pic 9(6)v99.
         05 ws-net-price               pic 9(7)v99.
         05 ws-trans-cost              pic 9(7)v99.
         05 ws-non-discount-percent    pic 999v999.
         
       01 ws-consts.
         05 ws-percent-sign            pic x value "%".
         05 ws-discount-percent-const  pic 9v99 value 0.05.
         05 ws-classa-cutoff-const     pic 999 value 100.
         05 ws-classf-cutoff-const     pic 99 value 50.
         05 ws-classb-cutoff-const     pic 9 value 5.
         05 ws-default-discount-const  pic 9v99 value 0.00.
         05 ws-classa-trans-const      pic 9v999 value 0.125.
         05 ws-classd-trans-const      pic 9v999 value 0.085.
         05 ws-classf-trans-const      pic 9v999 value 0.045.
         05 ws-low-qty-trans-const     pic 9v999 value 0.065.
         05 ws-high-qty-trans-const    pic 9v9 value 0.0.
         05 ws-low-qty-tans-cutoff     pic 999 value 101.
         05 ws-flat-trans-const        pic 99v99 value 45.

       01 ws-totals-calc.
         05 ws-ep-total                pic 9(8)v99.
         05 ws-np-total                pic 9(8)v99.
         05 ws-tc-total                pic 9(8)v99.

       01 ws-counters.
         05 ws-item-count              pic 999 value 0.
         05 ws-discount-count          pic 999 value 0.
         05 ws-non-discount-count      pic 999 value 0.

       01 ws-flags.
         05 ws-eof-flag                pic x value "n".
       
       01 ws-empty-line                pic x(1) value spaces.

       procedure division.
      *
       000-main.
      *  
      * Open files
      *
           open input input-file.
           open output output-file.

      *Write the report and column headings

           write output-line from ws-report-heading
             after advancing 1 line.

           write output-line from ws-column-heading-1
             after advancing 3 line.

           write output-line from ws-column-heading-2
             after advancing 1 line.

           write output-line from ws-empty-line
             after advancing 2 line.

      *
      * Initial read of input file
      *
           read input-file
               at end
               move "y" to ws-eof-flag.
      *
      *    Process each input record and read in next record
      *
           perform 100-process-file
             until ws-eof-flag equals "y".

      *    Summary report calculation and output
      *
           move ws-ep-total            to ws-ep-total-view.
           move ws-np-total            to ws-np-total-view.
           move ws-tc-total            to ws-tc-total-view.


           write output-line from ws-totals
             after advancing 3 line.

      *    Items without discount calculation and output
      *
           subtract ws-discount-count
             from ws-item-count
             giving ws-non-discount-count.

           divide ws-non-discount-count
             by ws-item-count
             giving ws-non-discount-percent rounded.

           multiply ws-non-discount-percent
             by 100
             giving ws-non-discount-view.

           move ws-percent-sign        to ws-symbol2.

           write output-line from ws-non-discounted-summary
             after advancing 2 lines.

      *
      *  Close files and end program
      *
           close input-file
             output-file.
      *
           goback.

       100-process-file.

      *   Clear the detail line
      *
           move spaces                 to ws-detail-line.

      *    Add one to items count
           add 1 to ws-item-count.

      *    Calculate the extended price
           move il-unit-price          to ws-unit-price.
           move il-quantity            to ws-quantity.

           multiply ws-unit-price
             by ws-quantity
             giving ws-extended-price rounded.

           add ws-extended-price
             to ws-ep-total.
      *
      *    Calculate the discounted prices
      *
           move il-product-class       to ws-product-class.

           move ws-default-discount-const to
             ws-discounted-price.

      *    Class A discount calculations
           if ws-product-class = "A" then

               if ws-extended-price > ws-classa-cutoff-const then

                   multiply ws-extended-price
                     by ws-discount-percent-const
                     giving ws-discounted-price rounded

                   add 1 to ws-discount-count

               end-if
           end-if.

      *    Class F discount calculations.
           if ws-product-class = "F" then

              if ws-extended-price > ws-classf-cutoff-const then

                   multiply ws-extended-price
                     by ws-discount-percent-const
                     giving ws-discounted-price rounded

                   add 1 to ws-discount-count

               end-if
           end-if.

      *    Class B discount calculations
           if ws-product-class = "B" then

               if ws-quantity > ws-classb-cutoff-const then

                   multiply ws-extended-price
                     by ws-discount-percent-const
                     giving ws-discounted-price rounded

                   add 1 to ws-discount-count

               end-if
           end-if.

      *
      *    Net price calculations
      *
           subtract ws-discounted-price
             from ws-extended-price
             giving ws-net-price.

           add ws-net-price
             to ws-np-total.
      *
      *    Determining the transport percentage and calculation
      *
           move ws-high-qty-trans-const  to ws-trans-percent.

           move ws-flat-trans-const      to ws-trans-cost.

      *    Transport percent for items with more than 100 quantity
           if ws-quantity < ws-low-qty-tans-cutoff then

               multiply ws-low-qty-trans-const
                 by 100
                 giving ws-trans-percent

               multiply ws-low-qty-trans-const
                 by ws-extended-price
                 giving ws-trans-cost rounded

           end-if.

      *    Class A transport percent calculation
           if ws-product-class = "A" then

               multiply ws-classa-trans-const 
                 by 100
                 giving ws-trans-percent

               multiply ws-classa-trans-const 
                 by ws-extended-price
                 giving ws-trans-cost rounded

           end-if.

      *    Class D transport percent calculation
           if ws-product-class = "D" then

               multiply ws-classd-trans-const
                 by 100
                 giving ws-trans-percent

               multiply ws-classd-trans-const
                 by ws-extended-price
                 giving ws-trans-cost rounded

           end-if.

      *    Class F transport percent calculation
           if ws-product-class = "F" then

               multiply ws-classf-trans-const
                 by 100
                 giving ws-trans-percent

               multiply ws-classf-trans-const
                 by ws-extended-price
                 giving ws-trans-cost rounded

           end-if.

           add ws-trans-cost
             to ws-tc-total.

      *
      *   Move input data to detail line and write to output file

           move il-item-number         to ws-item-number.
           move il-description         to ws-description.
           move ws-quantity            to ws-quantity-view.
           move il-unit-price          to ws-unit-price-view.
           move ws-unit-price          to ws-unit-price-view.
           move ws-extended-price      to ws-extended-price-view.
           move ws-discounted-price    to ws-discounted-price-view.
           move ws-net-price           to ws-net-price-view.
           move ws-trans-cost          to ws-trans-cost-view.
           move ws-percent-sign        to ws-symbol.

      *
           write output-line from ws-detail-line
             after advancing 2 lines.
      *
      *   Read next input record for the next iteration of perform loop
      *
           read input-file
               at end
               move "y" to ws-eof-flag.
      *
       end program A1-ItemList.