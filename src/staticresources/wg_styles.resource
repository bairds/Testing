body {
font-family: Arial, Helvetica, sans-serif;
}

.section_header {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12pt;
	font-weight: bold;
	color: #black;
	padding: 5;
}

.page_header {
	font-family: Arial, Helvetica, sans-serif;
	font-size: xx-large;
	font-weight: bold;
	color: #black;
	padding: 5;
}

.gen_text
	font-family: Arial, Helvetica, sans-serif;
	font-size: 10pt;
	color: #black;
	padding: 5;
}

.header {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 10pt;
	font-weight: bold;
	color: #green;
}

.TwoCol1 {
width: 320px;
}

.TwoCol2 {
width: 320px;
}

.label_text
{
font-family: Arial, Helvetica, sans-serif;
font-size: 8pt;
font-weight: bold;
color: #4B4B4B;
padding: 0 0 5 0;
}

.warning
{
font-family: Arial, Helvetica, sans-serif;
font-size: 10pt;
font-weight: bold;
color: #red;
}

.thanks
{
font-family: Arial, Helvetica, sans-serif;
font-size: 10pt;
font-weight: bold;
color: #000000;
}

.val_text
{
font-family: Arial, Helvetica, sans-serif;
font-size: 8pt;
font-weight: bold;
color: #000000;
padding: 0 0 5 0;
}


hr.green {
	border-top-width: 1px;
	border-top-style: solid;
	border-right-style: none;
	border-bottom-style: none;
	border-left-style: none;
	border-top-color: #green;
	border-right-color: #green;
	border-bottom-color: #green;
	border-left-color: #green;
	}

#container
{
width: 660px;
padding-left: 10px;
margin: 10px auto;
background-color: #fff;
float: left;
align: left;
text-align: left;
}

.row {
width: 660px;
height: 100%;
padding: 10px;
clear: both;
}

.labels
{
font-family: Arial, Helvetica, sans-serif;
font-size: 8pt;
font-weight: bold;
float: left;
text-align: left;
width: 250px;
clear: left;
padding: 0 0 10 0;
}

.inputs
{
text-align: left;
margin-left: 250px;
width: 410px;
height: 100%;
clear: right;
padding: 0 10 10 0;
}

.topsection {
margin-bottom: 10px;
}

.newsection {
margin-top: 10px;
margin-bottom: 10px;
}

.footer{
    text-align: center;
    font-size: 18pt
    }

/*
  GTRLC Form Styles
  ---

  Notes:
    - float:left with display: inline is for IE6
    - zoom:1 for hasLayout where necessary
*/


html, body {
  background: $fff;
  font: 13px/20px ITC Franklin Gothic, Helvetica Neue, Arial, Helvetica, sans-serif;
  color: #696A6D;
  margin: 0;
  padding: 0;
}

td {
  font: 13px/20px ITC Franklin Gothic, Helvetica Neue, Arial, Helvetica, sans-serif;
  color: #696A6D;
}

a {
  color: #00704A;
  text-decoration: underline;
}
a:hover { color: #69331F; }
a img { border: 0; }
h1, h2, h3, h4, h5, h6 {
  font: normal 36px/41px Chaparral Pro, Palatino Linotype, Palatino, Times New Roman, sans-serif;
  margin: 12px 0;
  padding: 0;
}
  h1.entry-title { margin-top: 0; }
  h2.entry-subtitle { margin-top: -12px; color: #69331F; }
  h2 { font-size: 24px; line-height: 29px; }
  h3 { font-size: 18px; line-height: 23px; }
  h4 { font-size: 16px; line-height: 21px; }
  h5, h6 {
    font-size: 13px;
    line-height: 20px;
    text-transform: uppercase;
  }
blockquote, p, ol, ul {
  margin: 12px 0;
}
ol, ul { padding: 0 0 0 24px; }


/*
 * General
 */

.data-header {
  font: normal 13px/20px Chaparral Pro, Palatino Linotype, Palatino, Times New Roman, sans-serif;
}
.data-list .content h4,
.data-columns-featured .content h4 {
  font: 13px/20px ITC Franklin Gothic, Helvetica Neue, Arial, Helvetica, sans-serif;
}

form {
  margin: 0;
  padding: 0;
  zoom: 1; /* <3 you IE */
}
form:after { /* clear fix for the rest of us */
  clear: both;
  content: ".";
  display: block;
  height: 0;
  visibility: hidden;
}


    .gtrlcEvent {
	vertical-align: top;
    }


    .gtrlcLabel {
      line-height: 30px;
      padding: 0 15px 3px 0;
      text-align: right;
      width: 244px;
    }



  .fields-wrapper { }
    .fields-wrapper input,
    .fields-wrapper label,
    .fields-wrapper select,
    .fields-wrapper textarea {
      float: left;
      margin: 0;
    }
    .fields-wrapper label {
      line-height: 30px;
      padding: 0 15px 3px 0;
      text-align: right;
      width: 244px;
    }
    .fields-wrapper input,
    .fields-wrapper textarea {
      border: 1px solid #696A6D;
      padding: 6px;
      width: 240px;
    }
    .fields-wrapper textarea {
      height: 120px;
      width: 300px;
    }
    .fields-wrapper select {
      /* we want to touch these as little as possible */
      margin: 3px 0 0;
    }
    .fields-wrapper br { clear: both; }
  .button-wrapper {
    clear: both;
    padding: 20px 0 0;
  }
      input.submit, button.submit,
      input.return-to-events-list, button.return-to-events-list,
      input.pay-online, button.pay-online,
      input.pay-by-check, button.pay-by-check {
          background: url('http://www.gtrlc.org/resources/sprites-forms-embed.png') no-repeat;
          border: 0 none;
          cursor: pointer;
          height: 39px;
          line-height: 39px;
          margin: 0;
          overflow: hidden;
          padding: 0;
          text-indent: 140px;
          width: 140px;
      }

      input.submit,        button.submit { }
      input.submit:hover,  button.submit:hover  { background-position: 0 -40px; }
      input.submit:active, button.submit:active { background-position: 0 -80px; }

      input.submit.single { margin-left: 250px; }

      input.return-to-events-list, button.return-to-events-list {
          background-position: -160px 0;
          text-indent: 250px;
          width: 250px;
      }
      input.return-to-events-list:hover,  button.return-to-events-list:hover  { background-position: -160px -40px; }
      input.return-to-events-list:active, button.return-to-events-list:active { background-position: -160px -80px; }

      input.pay-online,        button.pay-online        { background-position: -430px     0; }
      input.pay-online:hover,  button.pay-online:hover  { background-position: -430px -40px; }
      input.pay-online:active, button.pay-online:active { background-position: -430px -80px; }

      input.pay-by-check,        button.pay-by-check        { background-position: -590px     0; }
      input.pay-by-check:hover,  button.pay-by-check:hover  { background-position: -590px -40px; }
      input.pay-by-check:active, button.pay-by-check:active { background-position: -590px -80px; }