
import module namespace ds="http://www.marklogic.com/POC/display" at "display.xqy";


xdmp:set-response-content-type("text/html; charset=utf-8"),

(: get all the form parameters :)
(: do some manipulation to get pagination :)

let $startno := xs:int(xdmp:get-request-field("startno", "1"))
let $page := xs:int(xdmp:get-request-field("page", "10"))
let $end := $startno + $page - 1
let $next := $startno + $page
let $prev := $startno - $page

let $params := 
	<params>
	  {for $i in xdmp:get-request-field-names()
	      return
	  	for $j in xdmp:get-request-field($i)
    	    return
		        if ($i ne "") then
        		    element {$i} { $j}
        		else ()
	   }
	           <start>{$startno}</start>
                <end>{$end}</end>
				<page>{$page}</page>
    </params>

return

<html>
	<head>
		<title>MarkLogic Server Demonstration</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<link rel="stylesheet" type="text/css" href="ml.css" media="screen"/>
    
   </head>

	<body>
		<div id="page">
			{ds:header($params)}
			<div id="main">
				<div id="body">
				
				<p>
					{
					if($params/action eq "search") then
						ds:search($params)
				      else if($params/action eq "show") then
						ds:mapping(fn:doc(fn:string($params/uri)), $params)
					else if($params/action) then
						"Coming Soon"
					else
						ds:main-menu($params)

					}
				</p>
				</div>
				<div class="clearing"></div>
			</div>
		</div>
		{ds:footer($params)}
    </body>
</html>
