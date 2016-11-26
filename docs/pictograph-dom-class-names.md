
NB this is out of date and not really needed any more ...

- The outer svg gets a class name of `pictograph-outer-svg`, as well as a unique id and class per pictograph. The unique can be provided via the `table-id` parameter, or it is auto generated to be `pictograph-N` - for example the first pictograph will have an id of `pictograph-0` and a class of `pictograph-0`

- Every cell in the table gets a class `table-cell` and `.cell-N-N` for example the 2nd row 3rd column would get `.cell-1-2` (0-based numbering!)

- The cell type is also added as a class, currently either `.graphic` or `.label`

- Inside each graphic cell the following classes are always used:

    - `.node`
    - `.node-I`
    - `.node-xy-X-Y`
    - `.text-header`
    - `.text-footer`
    - `.text-overlay`
    - `.background-rect`
    - `.base-img`
    - `.variable-img`

- Inside each label cell each subsequent label is given a class of `.text-label-N`, for example the second label is `.text-label-0`
