module namespace ds="http://www.marklogic.com/POC/display";

import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";

import module namespace sem="http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";

declare namespace wiki="http://marklogic.com/wikipedia";


(:#########################################
# header
#########################################:)

declare function header($params) {

		<div id="header">
				<h2><a href="default.xqy" id="home"><img src="old-skool-sm.png" border="0"/></a>
				Search and Semantics Demo</h2>
				<hr/>
			</div>
	
};

(:#########################################
# footer
#########################################:)

declare function footer(
	$params) 
as node() 
{
<div id="footer" style="padding-top: 50px;">
<a href="{xdmp:get-request-url()}&amp;facets=yes">F</a> - 
<a href="{xdmp:get-request-url()}&amp;sem=yes">S</a><hr/>
	<span style='align=left;'><img src="MLogic.gif" border="0"/></span>
	&nbsp;<span style='align=right;'>Mark Logic Corporation</span>
</div>
};



(:#########################################
# main menu
#########################################:)

declare function main-menu(
    $params as node())
{
    <div>
        <p>Welcome to the Old Skool Search and Semantics Demo!</p>
	<p>This demo shows the search features of the MarkLogic Enterprise NoSQL Database AND demonstrations some of the Semantics features of MarkLogic 7 EA2</p>
	<p>Enjoy!</p>
            <ul> 
                <li><a href="default.xqy?action=search"><h3>Click Me!</h3></a>
                </li>
	</ul>
    </div>

};




(:#########################################
# search
#########################################:)

declare function search(
    $params as node())
{

let $term := concat(string($params/search), " AND cat:oscars")
let $results := if ($params/search) then search:search($term, get-options()) else ()
return

<table cellspacing="10">
<tr><td><form>
Find What You're Looking For: <input name="search" size="60" value="{string($params/search)}"/>
<input type="hidden" value="search" name="action"/>
</form></td></tr>
<tr><td>
<table><td valign="top">
{if ($params/facets="yes") then facets($results, $params) else ()}
</td>
<td valign="top">{if ($params/search) then results($results, $params) else ()}</td>
<td valign="top">{if ($params/sem="yes") then semantics($results, $params) else ()}</td></table>
</td></tr>
</table>
};


(:#########################################
# semantics
#########################################:)

declare function semantics(
    $results as node(), $params as node())
{
(<h2>SEMANTICS!</h2>,
<div>
{
let $term := fn:string-join($results//cts:word-query/cts:text/text(), " ")
let $locations := 
	for $value in $results//search:facet[./@name = "primary"]/search:facet-value
	return
	$value
let $terms := (fn:string-join(fn:tokenize($term, " "), "_"),
		for $location in $locations
		return
		for $term in fn:tokenize($location, ",")
		return 
			fn:string-join(fn:tokenize($term, " "), "_")
		)

let $sems := 
	for $term in $terms
	let $query := fn:concat("PREFIX thing:<http://dbpedia.org/resource/> SELECT * WHERE {thing:",$term," ?x ?y}")
	return
		try {<super-result>
		<item>http://dbpedia.org/resource/{$term}</item>
		{sem:query-results-serialize(sem:sparql($query))}	
		</super-result>}
		catch ($e) {}

return	

for $result in $sems[.//*:result]
return
(<h3>{(fn:tokenize(fn:string($result/item), "/"))[fn:last()]}</h3>
,
<table>
{for $item in $result//*:result
return
<tr>{for $uri in $item//(*:uri|*:literal)
	return
	<td>{(fn:tokenize(fn:data($uri), "/"))[fn:last()]}</td>
}</tr>
}</table>

)
	
}</div>)
};



(:#########################################
# results
#########################################:)

declare function results(
    $results as node(), $params as node())
{

(<h2>RESULTS</h2>,
for $result in $results/search:result
let $uri := fn:data($result/@uri)
return
<div><h3>{
<a href="default.xqy?action=show&amp;uri={xdmp:url-encode($uri)}">
{fn:doc($uri)//wiki:name}
</a>

}</h3>
{$uri}<br/>
{for $snippet in $result/search:snippet
return
<span>{
fn:string($snippet)
}
...&nbsp;</span>
}
</div>
)
};


(:#########################################
# facets
#########################################:)

declare function facets(
    $results as node(), $params as node())
{
(<h2>FACETS!</h2>,
<div>
{
for $facet in $results//search:facet
return
<div>
<h3>{fn:data($facet/@name)}</h3>
{for $value in $facet/search:facet-value
let $facet-value := fn:concat('"', $value, '"')
return
<div>
<a href="default.xqy?action=search&amp;search={fn:string($params/search)}+AND+{fn:data($facet/@name)}:{xdmp:url-encode($facet-value)}&amp;facets=yes">
{$value} ({fn:data($value/@count)})
</a>
</div>
}</div>
}</div>)
};


(:#########################################
# return document
#########################################:)

declare function recursion($x, $options) {
	for $z in $x/node() return mapping($z, $options) 
};

declare function mapping($x, $options){
typeswitch ($x)
	case element() return process($x, $options) 
	case text() return output-text($x, $options)
	case attribute() return process($x, $options)
    case comment() return ()
    default return process($x, $options)
};

declare function process($x, $options) {
	if ($x/text() and $x/element()) then
		<table><tr><td colspan="2" bgcolor="grey" valign="top"><b>{fn:local-name($x)}</b></td></tr>
		<tr><td>&nbsp;</td><td><table>{recursion($x, $options)}</table></td></tr>
		</table>
	else if ($x/text()) then
		<tr><td bgcolor="grey" valign="top"><b>{fn:local-name($x)}</b></td><td>{recursion($x, $options)}</td></tr>
	else if ($x/element()) then 
		<table><tr><td colspan="2" bgcolor="grey" valign="top"><b>{fn:local-name($x)}</b></td></tr>
		<tr><td>&nbsp;</td><td><table>{recursion($x, $options)}</table></td></tr>
		</table>
	else <tr><td valign="top"><b>{fn:local-name($x)}</b></td><td>{fn:data($x)}</td></tr>

};

declare function output-text($x, $options) {
  if (fn:empty($x)) then () else text {$x}
};



(:#########################################
# get-options
#########################################:)

declare function get-options()
{
<search:options xmlns:search="http://marklogic.com/appservices/search">
	<search:quality-weight>0</search:quality-weight>
	<search:search-option>unfiltered</search:search-option>
	<search:page-length>10</search:page-length>
	<search:term apply="term">
	  <search:empty apply="all-results"/>
	  <search:term-option>punctuation-insensitive</search:term-option>
	</search:term>
	<search:grammar>
	  <search:quotation>"</search:quotation>
	  <search:implicit>
	    <cts:and-query strength="20" xmlns:cts="http://marklogic.com/cts"/>
	  </search:implicit>
	  <search:starter strength="30" apply="grouping" delimiter=")">(</search:starter>
	  <search:starter strength="40" apply="prefix" element="cts:not-query">-</search:starter>
	  <search:joiner strength="10" apply="infix" element="cts:or-query" tokenize="word">OR</search:joiner>
	  <search:joiner strength="20" apply="infix" element="cts:and-query" tokenize="word">AND</search:joiner>
	  <search:joiner strength="30" apply="infix" element="cts:near-query" tokenize="word">NEAR</search:joiner>
	  <search:joiner strength="30" apply="near2" consume="2" element="cts:near-query">NEAR/</search:joiner>
	  <search:joiner strength="35" apply="not-in" element="cts:not-in-query" tokenize="word">NOT_IN</search:joiner>
	  <search:joiner strength="50" apply="constraint">:</search:joiner>
	  <search:joiner strength="50" apply="constraint" compare="LT" tokenize="word">LT</search:joiner>
	  <search:joiner strength="50" apply="constraint" compare="LE" tokenize="word">LE</search:joiner>
	  <search:joiner strength="50" apply="constraint" compare="GT" tokenize="word">GT</search:joiner>
	  <search:joiner strength="50" apply="constraint" compare="GE" tokenize="word">GE</search:joiner>
	  <search:joiner strength="50" apply="constraint" compare="NE" tokenize="word">NE</search:joiner>
	</search:grammar>
	<search:constraint name="film-title">
	  <search:range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
	    <search:facet-option>frequency-order</search:facet-option>
	    <search:facet-option>descending</search:facet-option>
	    <search:facet-option>limit=10</search:facet-option>
	    <search:attribute ns="" name="film-title"/>
	    <search:element ns="http://marklogic.com/wikipedia" name="oscar"/>
	  </search:range>
	</search:constraint>
	<search:constraint name="primary">
	  <search:range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
	    <search:facet-option>frequency-order</search:facet-option>
	    <search:facet-option>descending</search:facet-option>
	    <search:facet-option>limit=10</search:facet-option>
	    <search:element ns="http://marklogic.com/wikipedia" name="primary"/>
	  </search:range>
	</search:constraint>
	<search:constraint name="year">
	  <search:range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
	    <search:facet-option>frequency-order</search:facet-option>
	    <search:facet-option>descending</search:facet-option>
	    <search:facet-option>limit=10</search:facet-option>
	    <search:attribute ns="" name="year"/>
	    <search:element ns="http://marklogic.com/wikipedia" name="oscar"/>
	  </search:range>
	</search:constraint>
	<search:constraint name="cat" facet="false">
		<search:collection/>
	</search:constraint>
	<search:operator name="sort">
	  <search:state name="relevance">
	    <search:sort-order>
	      <search:score/>
	    </search:sort-order>
	  </search:state>
	  <search:state name="film-title">
	    <search:sort-order direction="descending" type="xs:string" collation="http://marklogic.com/collation/">
	      <search:attribute ns="" name="film-title"/>
	      <search:element ns="http://marklogic.com/wikipedia" name="oscar"/>
	    </search:sort-order>
	    <search:sort-order>
	      <search:score/>
	    </search:sort-order>
	  </search:state>
	</search:operator>
	<search:transform-results apply="snippet">
	  <search:preferred-elements><search:element ns="http://www.w3.org/1999/xhtml" name="p"/><search:element ns="http://www.w3.org/1999/xhtml" name="a"/><search:element ns="http://www.w3.org/1999/xhtml" name="li"/><search:element ns="http://www.w3.org/1999/xhtml" name="span"/></search:preferred-elements>
	  <search:max-matches>2</search:max-matches>
	  <search:max-snippet-chars>150</search:max-snippet-chars>
	  <search:per-match-tokens>20</search:per-match-tokens>
	</search:transform-results>
	<search:return-query>1</search:return-query>
	<search:operator name="results">
	  <search:state name="compact">
	    <search:transform-results apply="snippet">
	      <search:preferred-elements><search:element ns="http://www.w3.org/1999/xhtml" name="p"/><search:element ns="http://www.w3.org/1999/xhtml" name="a"/><search:element ns="http://www.w3.org/1999/xhtml" name="li"/><search:element ns="http://www.w3.org/1999/xhtml" name="span"/></search:preferred-elements>
	      <search:max-matches>2</search:max-matches>
	      <search:max-snippet-chars>150</search:max-snippet-chars>
	      <search:per-match-tokens>20</search:per-match-tokens>
	    </search:transform-results>
	  </search:state>
	  <search:state name="detailed">
	    <search:transform-results apply="snippet">
	      <search:preferred-elements><search:element ns="http://www.w3.org/1999/xhtml" name="p"/><search:element ns="http://www.w3.org/1999/xhtml" name="a"/><search:element ns="http://www.w3.org/1999/xhtml" name="li"/><search:element ns="http://www.w3.org/1999/xhtml" name="span"/></search:preferred-elements>
	      <search:max-matches>2</search:max-matches>
	      <search:max-snippet-chars>400</search:max-snippet-chars>
	      <search:per-match-tokens>30</search:per-match-tokens>
	    </search:transform-results>
	  </search:state>
	</search:operator>
      </search:options>


};



