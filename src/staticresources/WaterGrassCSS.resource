/* WaterGrassCSS */
/*COLORS*/

:root {
    --primary-color: #DBE8F6;
    --secondary-color: #DEF6DE;
    --primary-bgcolor: #406B8C;
    --secondary-bgcolor: #2C6636;
}

.bcb { background-color: #DBE8F6; }
.bcb2 { background-color: var(--primary-color); }
.bcbl { background-color: black; }
.bcg { background-color: var(--primary-bgcolor); }
.bcg2 { background-color: var(--secondary-color); }
.bco { background-color: #EDE9D6; }
.bco2 { background-color: #A69343; }
.bcp { background-color: #D2D2EB; }
.bcp2 { background-color: #222666; }
.bcr { background-color: #F6E8EC;}
.bcw { background-color: #F2F6F2; }
.bcw2 { background-color: #FfFfFf; }

.bb { border: 1px solid var(--primary-color); }
.bg { border: 1px solid var(--secondary-bgcolor); }
.bgr { border: 1px solid #CECECE; }
.bo { border: 1px solid #A69343; }
.bp { border: 1px solid #F2F6F2; }
.br { border: 1px solid red; }
.by { border: 1px solid yellow; }

.bbg { border-bottom: 1px solid #CECECE; }

.br2 { border-radius: 2px; }
.br3 { border-radius: 3px; }
.br6 { border-radius: 6px; }

.cb { color: var(--primary-bgcolor); }
.cg { color: var(--secondary-bgcolor); }
.co { color: #A69343; }
.cp { color: #222666; }

.df { display: flex; }
.dib { display: inline-block; }
.dn { display: none; }
.dt { display: table; }
.dtc { display: table-cell; }
.dtr { display: table-row; }

.f1 { flex: 1; }

.fdc { flex-direction: column; }

.fg1 { flex-grow: 1; }

.fs0 { flex-shrink: 0; }

.fs11 {	font-size: 11pt; }
.fs12 {	font-size: 12pt; }
.fs13 {	font-size: 13pt; }
.fs16 {	font-size: 16pt; }
.fs22 {	font-size: 22pt; }
.fs266 { font-size: 2.66vw; }
.fs366 { font-size: 3.66vw; }

.fwb { font-weight: bold; }

.h100 { height: 100%; }

.m11 { margin: 11px; }

.ma { margin: auto; }

.mh222 { max-height: 222px; }

.miw100 { min-width: 100%; }

.ml6 { margin-left: 6px; }
.ml11 { margin-left: 11px; }
.ml22 { margin-left: 22px; }

.mt11 { margin-top: 11px; }

.mw222 { max-width: 222px; }
.mw388 { max-width: 388px; }
.mw422 { max-width: 422px; }
.mw33 { max-width: 33%; }

.oi { opacity: initial; }
.o66 { opacity: .66; }
.o88 { opacity: .88; }

.oh { overflow: hidden; }

.p6 { padding: 6px; }
.p11 { padding: 11px; }
.p22 { padding: 22px; }

.pa { position: absolute; }
.pr { position: relative; }

.r0 { right: 0; }
.t0 { top: 0; }

.tac { text-align: center; }
.tal { text-align: left; }
.tar { text-align: right; }

.ttl { text-transform: lowercase; }

.vam { vertical-align: middle; }
.vat { vertical-align: top; }

.wsn { white-space: nowrap; }

.w22 { width: 22%; }
.w44 { width: 44%; }
.w66 { width: 66%; }
.w88 { width: 88%; }
.w100 { width: 100%; }
.wi { width: initial; }

/*STYLES*/
table { border-collapse: collapse }


.alignleft {
    text-align: left;
}

body div.bPageBlock {
    margin: initial;
    border: initial;
}

.box-centerside {
    float: left;
    min-height: 100px;
}

.bPageblock[color="SectionColor"]{
    background-color: var(--secondary-bgcolor);
    border: 1px solid var(--secondary-bgcolor);
    color: var(--primary-bgcolor);
}

.btn{
    width: 166px;
    font-size: large;
}
.btn[color="SectionColor"]{
    background-color: var(--secondary-bgcolor);
}

.checkboxlarger{
    zoom:1.5;
}

.col-md-4 {
    vertical-align; middle;
    border-style: none;
}

.col-xs-6 {
    font-weight: bold;
    line-height: 25px;
}

.container {
    max-width: 1200px;
    margins: auto;
}

div[color] div[color="green"] div.title,
div[color="green"] div.title,
div[color="green"] div.buttons,
div[color] div[color="green"] div.buttons {
    background-color: var(--primary-bgcolor);
    color: var(--secondary-bgcolor);
}

div.container {
    border-radius: 2px;
    display: block;
    overflow: hidden;
    max-width: 1200px;
    margin: auto;
}

div.container div.title {
    text-align: center;
    font-weight: bold;
    /*font-size: 16pt;*/
}

div.container div.title div.text {
    flex: 1;
    display: flex;
    flex-direction: column;
}

div.container div.title div.text div.date {
    padding: 3px 6px;
    border-radius: 0px 0px 0px 6px;
    /*font-size: 3.66vw;*/
    display: inline-block;
}

div.container div.title div.text div.name {
    padding: 6px;
    height: 100%;
    display: flex;
}

.mobile div.container div.title div.text div.name {
    font-size: 4.44vw;
}

div.container div.buttons {
    padding: 6px;
    text-align: center;
    /*opacity: .88;*/
}

body div.container div.control {
    display: flex;
    padding: 6px;
    align-items: center;
}

body div.container div.control input {
    padding: 6px;
    width: 100%;
    margin-left: 6px;
}

body .mobile div.container div.control input {
    padding: 1.22vw 2.22vw;
    /*font-size: 2.11vw;*/
}

div.container div.buttons > input {
    background: initial;
    font-weight: bold;
    margin-right: 6px;
    width: initial;
    /*font-size: 12pt;*/
    padding: 3px 6px;
}

.mobile div.container div.buttons > input {
    /*font-size: 3.66vw;*/
    padding: 0.66vw 6.66vw;
}

div.table {
    border-radius: 3px;
    overflow: hidden;
    width: 100%;
}

div.table > div.title {
    font-weight: bold;
    text-align: center;
    opacity: .88;
    padding: 6px;
}

.mobile div.table > div.title { font-size: 3.66vw; }

div.highlight {
    font-weight: bold;
    font-size: 12pt;
    text-align: center;
    padding: 11px;
}

div.scrollable_box {
    font-size: 2.22vw;
    text-align: left;
    padding: 1.22vw;
    overflow: scroll;
    border: 1px solid #ECECEC;
    overflow-x: hidden;
}

.input table,
.output table {
    width: 100%;
}

.flex-container {
    display: flex;
    flex-flow: row wrap;
    justify-content: left;
    max-width: 1000px;
    margin: auto;
}

.flex-container > div {
    line-height: 25px;
    font-size: large;
}

.flex-container > div > table {
    background-color: white;
}

.infolabel {
    display: block;
    margin-left: auto;
    margin-right: auto;
}

.input div.td { display: table-cell; }

.legaldoc{
    font-size:large;
    padding:10px;
}

.logo-image{
    background-color: #ffffff;
    padding: 0% 0% 0% 0%;
    margin: 0px auto;
}

.output td {
    text-align: left;
    padding: 11px 22px;
}

.repeatrow{
    padding-bottom: 100px;
    /*text-indent: -999px;*/
}

.row {
    padding-bottom:10px;
    border-top: 0; }

.row[color=olive]{
    background-color: #F3EFE9;
    color: #A69343;
}

.row[color=red]{
    background-color: #F6E8EC;
}

.row[color=TitleColor]{
    background-color: #DBE8F6;
    color: var(--primary-bgcolor);
}

.row.match-my-cols {
    overflow: hidden;
}

.row.match-my-cols [class*="col-"]{
    margin-bottom: -99999px;
    padding-bottom: 99999px;
}

.selectlabel {
    font-weight: bold;
    padding: 1px;
    line-height: 25px;
    font-size: large;
    text-align: left;
}

.td {
    text-align: left;
    padding: 10px;
    font-weight: bold;
}

.tdlabel {
    font-weight: bold;
    padding: 1px;
    line-height: 25px;
    font-size: large;
}
.tdlabel:first-child{
    text-align:right;
}

.tdlabel[color=red]{
    color:red;
}


tr { border-bottom: 1px solid #CECECE; }
.input div.td,
.input td,
.output td {
    background-color: white;
    padding: 11px;
    text-align: center;
    vertical-align: middle;
    /*font-size: 11pt;*/
}

tr.col-header > td,
.input div:first-child,
.input td:first-child,
.output div:first-child,
.output div.label,
.input div.label {
    border-right: 1px solid #CECECE;
    font-weight: bold;
    text-align: right;
    width: initial;
}

.WGPageTitle{
    padding-top: 8px;
    text-align: center;
    font-weight: bold;
    font-size: xx-large;
    vertical-align: middle;
    height: auto !important;
}

.WGPageTitle[color=SectionColor]{
    background-color: var(--secondary-bgcolor);
    color: var(--secondary-color);
}
.WGPageTitle[color=TitleColor]{
    background-color: var(--primary-bgcolor);
    color: #DBE8F6;
}
.WGPageTitle[color=AlertColor]{
    color: #F6E8EC;
    background-color: #DE2C58;
}

/*MOBILE NOT SURE IF THIS IS USEFUL NOW*/
.mobile .input div.td,
.mobile .input td,
.mobile .output td {
    width: 62%;
    font-size: 2.88vw;
}


.mobile tr.col-header > td,
.mobile .input div.td:first-child,
.mobile .input td:first-child,
.mobile .output td:first-child,
.mobile .output td.label {
    font-size: 2.66vw;
    width: 36%;
}

.mobile .input div.checkbox div.td,
.mobile .input table.checkbox td {
    width: initial;
    padding: 1.22vw 1.66vw;
    font-size: initial;
}

.mobile .input div.checkbox div.td:first-child,
.mobile .input table.checkbox td:first-child {
    font-size: 2.88vw;
}

tr.row > td,
.output tr.row > td,
.output tr.col-header > td,
tr.col-header > td {
    text-align: center;
    width: initial;
    padding: 6px;
    text-transform: initial;
}

.mobile tr.row > td,
.mobile tr.col-header > td {
    padding: 1.11vw 1.44vw;
    font-size: 1.88vw;
}

tr.row { border-bottom: none; }

tr.row > td,
div[color] > div.table table.table tr.row > td {
    background-color: white;
    color: #222;
}

.input div.autocomplete {
    font-size: 11pt;
    width: 100%;
    text-align: center;
}

.mobile .input div.autocomplete { font-size: 2.11vw; }
.input .small div.autocomplete { width: 184px; }

body .input input,
body .input select,
body .input textarea {
    border: 1px solid #CECECE;
    border-radius: 3px;
    padding: 6px 9px;
    /*font-size: 11pt;*/
    width: 244px;
}

body .mobile .input input,
body .mobile .input select,
body .mobile .input textarea {
    font-size: 2.66vw;
    padding: 1.22vw;
    width: 92%;
}

body .mobile .input input[type="checkbox"],
body .mobile .input input[type="radio"]
{
    width: 3.66vw;
    height: 3.66vw;
}

select optgroup {
    background-color: #EDE9D6;
    text-align: center;
}

select option {
    background-color: white;
    padding: 3px;
    text-align: left;
}

select option:before { content: initial; }

.input span.dateInput input,
.input input.date {
    width: 122px;
}

.mobile .input span.dateInput input,
.mobile .input input.date {
    width: 69%;
}

.multiSelectPicklistTable select {
    height: 111px;
    max-width: 102px;
    min-width: 102px;
}

div[color] .input .selectcheckboxes > tbody > tr > td:first-child,
.input .selectcheckboxes > tbody > tr > td:first-child,
.input .selectcheckboxes > tbody > tr > td,
.input .selectcheckboxes > tbody > tr,
.input .multiSelectPicklistTable > tbody > tr > td:first-child,
.input .multiSelectPicklistTable > tbody > tr > td,
.input .multiSelectPicklistTable > tbody > tr {
    text-align: initial;
    background-color: initial;
    color: initial;
    font-weight: initial;
    border: initial;
    padding: initial;
    width: initial;
    /*text-transform: initial;*/
    font-size: initial;
}

div[color] .input .horizontal .selectcheckboxes > tbody > tr > td:first-child,
.input .horizontal .selectcheckboxes > tbody > tr > td  {
    text-align: center;
}

.input .multiSelectPicklistTable td.multiSelectPicklistCell {
    padding: 0px 6px;
}

.mobile div[color] .input .selectcheckboxes > tbody > tr > td {
    font-size: 2.22vw;
}

.input .selectcheckboxes > tbody > tr > td > input,
.input .selectcheckboxes > tbody > tr > td > label,
.input input.checkbox {
    width: 16px;
    height: 16px;
    display: inline-block;
    vertical-align: middle;
}

.input .buttons .selectcheckboxes > tbody > tr > td > label {
    font-weight: bold;
}

.input .selectcheckboxes > tbody > tr > td > label {
    width: initial;
    margin-right: 6px;
}

.mobile .input .selectcheckboxes > tbody > tr > td > label {
    height: initial;
}

/*.input .small input.btn { width: 166px; }*/

div.button-container {
    padding: 6px;
    background-color: #F2F6F2;
    border: 1px solid #CECECE;
    border-radius: 2px;
    display: flex;
    flex: 1;
    align-items: center;
    margin-left: 6px;
}

.mobile div.button-container { padding: .88vw; }
div.button-container:first-child { margin-left: initial; }

div.button-container > * {
    width: 100%;
    margin: auto;
}

div.full-popup {
    position: fixed;
    display: none;
    background-color: #C8DEF6;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    background: rgba(200, 222, 246, .66);
}

div.full-popup > div {
    margin: auto;
    width: 80%;
    background-color: white;
    padding: 22px;
    border-radius: 2px;
    font-size: 18pt;
    border: 4px solid var(--primary-bgcolor);
    text-align: center;
}

div.full-popup > div > p:last-child { font-size: 11pt; }

div.full-popup > div > p:last-child > a {
    color: var(--primary-bgcolor);
    text-decoration: none;
}

div.emptyBox {
    border: 1px dotted #6D6D6D;
    height: 3.66vw;
    width: 3.66vw;
}

div.errors {
    padding: 11px;
    font-size: 12pt;
}

div[color="blue"] div.container,
div[color="blue"] div.table,
div[color] div[color="blue"] div.table {
    border: 1px solid var(--primary-bgcolor);
    background-color: #C8DEF6;
}

div[color] div[color="blue"] div.title,
div[color] div[color="blue"] div.buttons,
div[color="blue"] div.title,
div[color="blue"] div.buttons {
    background-color: var(--primary-bgcolor);
    color: #C8DEF6;
}

div[color="blue"] div.title div.highlight {
    background-color: #F2F6F2;
    color: var(--primary-bgcolor);
}

div[color] div[color="blue"] .output td:first-child,
div[color] div[color="blue"] .input td.label,
div[color] div[color="blue"] .output td.label,
div[color] div[color="blue"] .input td:first-child,
div[color="blue"] .input td:first-child,
div[color="blue"] .output td:first-child {
    background-color: #DBE8F6;
    color: var(--primary-bgcolor);
}

div[color] div[color="blue"] div.buttons > input,
div[color="blue"] div.buttons > input {
    background-color: #C8DEF6;
    color: var(--primary-bgcolor);
}

div[color] div.buttons > input:hover {
    background-color: #F2F6F2;
}

tr.highlight > td.purple:first-child,
div.purple {
    background-color: #D2D2EB;
    color: #222666;
}

div.blue2 {
    background-color: #F2F6F2;
    color: var(--primary-bgcolor);
}

div[color] div[color="green"] div.table,
div[color="green"] div.table {
    background-color: var(--secondary-bgcolor);
    border: 1px solid var(--secondary-bgcolor);
    color: var(--primary-bgcolor);
}

div[color] div[color="green"] div.title,
div[color="green"] div.title,
div[color="green"] div.buttons,
div[color] div[color="green"] div.buttons {
    background-color: var(--primary-bgcolor);
    color: var(--secondary-bgcolor);
}

div[color="green"] .input div.label,
div[color] div[color="green"] .output tr.col-header > td,
div[color] div[color="green"] .output tr.row > td,
div[color="green"] tr.col-header > td,
div[color] div[color="green"] .output td:first-child,
div[color] div[color="green"] .output td.label,
div[color] div[color="green"] .input td.label,
div[color] div[color="green"] .input td:first-child,
div[color="green"] .input td:first-child {
    background-color: #C9E2C9;
    color: var(--secondary-bgcolor);
}

div[color] div[color="green"] div.buttons > input,
div[color="green"] div.buttons > input {
    background-color: var(--primary-bgcolor);
    color: var(--secondary-bgcolor);
}

div[color] div[color="red"] div.table,
div[color="red"] div.table,
div[color="red"] div.errors {
    background-color: #F6E8EC;
    border: 1px solid #DE2C58;
    color: #DE2C58;
}

div[color] div[color="red"] div.title,
div[color] div[color="red"] div.buttons,
div[color="red"] div.title,
div[color="red"] div.buttons {
    background-color: #DE2C58;
    color: #F6E8EC;
}

div[color="red"] .input div.label,
div[color] div[color="red"] .output td:first-child,
div[color] div[color="red"] .output td.label,
div[color] div[color="red"] .input td.label,
div[color] div[color="red"] .input td:first-child,
div[color="red"] .input td:first-child {
    background-color: #F4D3DE;
    color: #DE2C58;
}

div[color="red"] div.buttons > input {
    background-color: #F6E8EC;
    color: #DE2C58;
}

div[color="olive"] div.container,
div[color="olive"] div.table {
    background-color: #EDE9D6;
    border: 1px solid #A69343;
    color: #A69343;
}

div[color="olive"] div.title,
div[color="olive"] div.buttons {
    background-color: #A69343;
    color: #EDE9D6;
}

div[color="olive"] .input div.label,
div[color="olive"] .output td:first-child,
div[color="olive"] .input td:first-child,
div[color="olive"] .output td.label,
div[color] div[color="olive"] .output td:first-child,
div[color] div[color="olive"] .output td.label,
div[color] div[color="olive"] .input td.label,
div[color] div[color="olive"] .input td:first-child {
    background-color: #F3EFE9;
    color: #A69343;
}

div[color="olive"] div.control > input,
div[color="olive"] div.buttons > input {
    background-color: #EDE9D6;
    color: #A69343;
}

div[color="olive"] .input .buttons .selectcheckboxes > tbody > tr > td > label {
    color: #EDE9D6;
}

div[color="blue2"] div.table {
    background-color: #F2F6F2;
    border: 1px solid var(--primary-bgcolor);
    color: var(--primary-bgcolor);
}

div[color="blue2"] div.title,
div[color="blue2"] div.buttons {
    background-color: var(--primary-bgcolor);
    color: #F2F6F2;
}

div[color="blue2"] .input div.label,
div[color="blue2"] tr.col-header > td,
div[color="blue2"] .input td:first-child {
    background-color: #60A8DF;
    color: #F2F6F2;
}

div.olive {
    background-color: #EDE9D6;
    color: #A69343;
}

.black {
    background-color: white;
    color: black;
}