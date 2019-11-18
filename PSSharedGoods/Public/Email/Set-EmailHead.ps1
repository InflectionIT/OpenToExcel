function Set-EmailHead {
    param(
        [System.Collections.IDictionary] $FormattingOptions
    )
    $head = @"
    <head>
        <style>
        BODY {
            background-color: white;
            font-family: $($FormattingOptions.FontFamily);
            font-size: $($FormattingOptions.FontSize);
        }

        TABLE {
            border-width: 1px;
            border-style: solid;
            border-color: black;
            border-collapse: collapse;
            font-family: $($FormattingOptions.FontTableDataFamily);
            font-size: $($FormattingOptions.FontTableDataSize);
        }

        TH {
            border-width: 1px;
            padding: 3px;
            border-style: solid;
            border-color: black;
            background-color: #00297A;
            color: white;
            font-family: $($FormattingOptions.FontTableHeadingFamily);
            font-size: $($FormattingOptions.FontTableHeadingSize);
        }
        TR {
            font-family: $($FormattingOptions.FontTableDataFamily);
            font-size: $($FormattingOptions.FontTableDataSize);
        }

        UL {
            font-family: $($FormattingOptions.FontFamily);
            font-size: $($FormattingOptions.FontSize);
        }

        LI {
            font-family: $($FormattingOptions.FontFamily);
            font-size: $($FormattingOptions.FontSize);
        }

        TD {
            border-width: 1px;
            padding-right: 2px;
            padding-left: 2px;
            padding-top: 0px;
            padding-bottom: 0px;
            border-style: solid;
            border-color: black;
            background-color: white;
            font-family: $($FormattingOptions.FontTableDataFamily);
            font-size: $($FormattingOptions.FontTableDataSize);
        }

        H2 {
            font-family: $($FormattingOptions.FontHeadingFamily);
            font-size: $($FormattingOptions.FontHeadingSize);
        }

        P {
            font-family: $($FormattingOptions.FontFamily);
            font-size: $($FormattingOptions.FontSize);
        }
    </style>
    </head>
"@
    return $Head
}