/*
THEME NAME:  Autumn Leaves
THEME URI: http://www.nonmom.com/autumn-leaves-theme/
DESCRIPTION: Clean white theme with touches of fall colors and a beautiful autumn leaves header image. Provided by a <a href="http://www.nonmom.com/">work at home mother</a>. Based on the Sandbox theme.
VERSION: 1.0
AUTHOR: Work at Home Mom
AUTHOR URI: http://www.nonmom.com/
TAGS: autumn, fall, leaves, white, clean, simple, header image, two columns, right sidebar, fixed width, sandbox, microformats, hcard, hatom, widget ready, gravatar support, valid XHTML, valid CSS, w3c, free
*/

body {
	font-family: Arial, Helvetica, Verdana, Sans-serif;
	font-size: 10pt;
	background-color: #fff;
}

body,h1#blog-title {
	margin: 0;
	padding: 0;
}

a {
	color: blue;
}

a:hover {
	color: #FF8C00;
}

a img {
	border: 0 none;
}

#wrapper {
	width: 930px;
	margin: 0 auto;
	background-color: #FFF;
	border-left: 1px solid #ccc;
	border-right: 1px solid #ccc;
}

#header {
	background-image: url(http://leadgreen.org/wordpress/wp-content/themes/autumn-leaves/images/marshgrass.png);
	height: 160px;
}

#inner-header {
	padding: 50px 1em 0;
}

h1#blog-title {
	font-size: 3em;
        background-color: #fff;
        opacity:0.8;
        filter:alpha(opacity=80);
        padding: 5px;
        width: 500px;
}

h1#blog-title a {
	color: #003264;
}

.entry-title a {
	color: #CD853F;
}

h1#blog-title a, .entry-title a, #footer a {
	text-decoration: none;
}

h1#blog-title a:hover, .entry-title a:hover, #footer a:hover {
	text-decoration: underline;
}

div.skip-link {
	display: none;
}

#menu {
	border-bottom: 1px solid #ccc;
}

#menu a {
	color: #000;
}

#menu a:hover {
	text-decoration: none;
	background-color: #FFFFBE;
        color: #003264;
}

#menu li.current_page_item a, #menu li.current_page_item a:hover {
	background-color: #003264;
        color: white;
	text-decoration: none;
}

#content {
	padding: 1em;
}

.entry-title {
	font-size: 1.5em;
	margin: 1em 0 0 0;
}

abbr.published {
	color: #666;
	border: 0 none;
}

.entry-meta, .entry-date {
	color: #666;
}

#comments-list .avatar {
	float: left;
	margin-right: 1em;
}

#comments-list .n {
	font-weight: bold;
}

.entry-meta, .comment-meta {
	font-style: italic;
}

#comments-list p {
	clear: left;
}

#primary {
	padding-left: 1em;
	font-size: 0.9em;
	border-left: 1px solid #ccc;
	border-bottom: 1px solid #ccc;
	background-color: #FFFFBE;
}

#footer {
	text-align: center;
	font-size: 0.8em;
	border-top: 1px solid #ccc;
	border-bottom: 1px solid #ccc;
	margin-bottom: 1em;	
	background-color: #FFFFBE;
}

#inner-footer {
	padding: 1em 0;
}

.entry-meta, .entry-meta a,
.comment-meta, .comment-meta a,
.sidebar, .sidebar a,
#footer, #footer a {
	color: #003264;
}

/*
LAYOUT: Two-Column (Right)
DESCRIPTION: Two-column fluid layout with one 

sidebars right of content
*/
div#container {
float:left;
margin:0 -200px 0 0;
width:100%;
}

div#content {
margin:0 200px 0 0;
}

div.sidebar {
float:right;
overflow:hidden;
width:180px;
}

div#secondary {
clear:right;
}

div#footer {
clear:both;
width:100%;
}

/* Just some example content */
div#menu {
height:2em;
width:100%;
}

div#menu ul,div#menu ul ul {
line-height:2em;
list-style:none;
margin:0;
padding:0;
}

div#menu ul a {
display:block;
margin-right:1em;
padding:0 0.5em;
text-decoration:none;
}

div#menu ul ul ul a {
font-style:italic;
}

div#menu ul li ul {
left:-999em;
position:absolute;
}

div#menu ul li:hover ul {
left:auto;
}

.entry-title,.entry-meta {
clear:both;
}

div#primary {
padding-top:2em;
}

form#commentform .form-label {
margin:1em 0 0;
}

form#commentform span.required {
background:#fff;
color:#c30;
}

form#commentform,form#commentform p {
padding:0;
}

input#author,input#email,input#url,textarea#comme

nt {
padding:0.2em;
}

div.comments ol li {
margin:0 0 3.5em;
}

textarea#comment {
height:13em;
margin:0 0 0.5em;
overflow:auto;
width:66%;
}

.alignright,img.alignright{
float:right;
margin:1em 0 0 1em;
}

.alignleft,img.alignleft{
float:left;
margin:1em 1em 0 0;
}

.aligncenter,img.aligncenter{
display:block;
margin:1em auto;
text-align:center;
}

div.gallery {
clear:both;
height:180px;
margin:1em 0;
width:100%;
}

p.wp-caption-text{
font-style:italic;
}

div.gallery dl{
margin:1em auto;
overflow:hidden;
text-align:center;
}

div.gallery dl.gallery-columns-1 {
width:100%;
}

div.gallery dl.gallery-columns-2 {
width:49%;
}

div.gallery dl.gallery-columns-3 {
width:33%;
}

div.gallery dl.gallery-columns-4 {
width:24%;
}

div.gallery dl.gallery-columns-5 {
width:19%;
}

div#nav-above {
margin-bottom:1em;
}

div#nav-below {
margin-top:1em;
}

div#nav-images {
height:150px;
margin:1em 0;
}

div.navigation {
height:1.25em;
}

div.navigation div.nav-next {
float:right;
text-align:right;
}

div.sidebar h3 {
font-size:1.2em;
}

div.sidebar input#s {
width:7em;
}

div.sidebar li {
list-style:none;
margin:0 0 2em;
}

div.sidebar li form {
margin:0.2em 0 0;
padding:0;
}

div.sidebar ul ul {
margin:0 0 0 2em;
}

div.sidebar ul ul li {
list-style:disc;
margin:0;
}

div.sidebar ul ul ul {
margin:0 0 0 0.5em;
}

div.sidebar ul ul ul li {
list-style:circle;
}

div#menu ul li,div.gallery dl,div.navigation 

div.nav-previous {
float:left;
}

input#author,input#email,input#url,div.navigation 

div {
width:50%;
}

div.gallery *,div.sidebar div,div.sidebar 

h3,div.sidebar ul {
margin:0;
padding:0;
}