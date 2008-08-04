<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:include href="../common/page.xsl" />
  <xsl:include href="../common/source-cookies.xsl" />
  
  <xsl:output indent="no" omit-xml-declaration="yes" method="xml"
       doctype-public="-//W3C//DTD XHTML 1.1//EN"
       doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
       media-type="text/html" encoding="utf-8" />

  <xsl:strip-space elements="*"/>

  <xsl:template match="/page" mode="js">
    <!-- JavaScripts -->
    <xsl:apply-templates select="/page/asset-urls/js-urls/js-url" />
  
    <script type="text/javascript">
      <xsl:if test="string-length(/page/request/@query) > 0">
<!-- AJAX loading of documents -->
$(document).ready(function() {
  $.get($.unescape("<xsl:value-of select="$documents-url" disable-output-escaping="no" />"), {}, function(data) {
    $("#documents-panel").prepend(data);
    $("#documents-panel").trigger("carrot2.documents.loaded");
  });

<!-- AJAX loading of groups -->
<xsl:if test="/page/request/@view != 'visu'">
  $.get($.unescape("<xsl:value-of select="$clusters-url" disable-output-escaping="no" />"), {}, function(data) {
    $("#clusters-panel").prepend(data);
    $("#clusters-panel").trigger("carrot2.clusters.loaded");
  });
</xsl:if>  

<!-- Visualization -->
<xsl:if test="/page/request/@view = 'visu'">
var flashvars = {
  data_sourceURL: "<xsl:value-of select="$xml-url-encoded" />",
  callback_onGroupClick: "groupClicked"
};
var params = {};
var attributes = {};

swfobject.embedSWF("<xsl:value-of select="$skin-path" />/common-dynamic/swf/org.carrotsearch.vis.circles.swf", "clusters-visu", "100%", "100%", "9.0.0", "<xsl:value-of select="$skin-path" />/common/swf/expressInstall.swf",
    flashvars, params, attributes);
</xsl:if>
});

function groupClicked(clusterId, docList) {
  var documentIndexes = docList.split(",");
  $.documents.select(documentIndexes);
}  
      </xsl:if>

<!-- Common initialization -->
$(document).ready(function() {
  setTimeout(function() { 
    $("#query").focus();
  }, 200);
  $("#loading").fadeOut(1000);
  $("div.disabled-ui").removeClass("disabled-ui");

  $("body").trigger("carrot2.loaded");
});      
    </script>
  </xsl:template>

  <xsl:template match="page" mode="results">
    <xsl:apply-templates select=".." mode="results.area" />
  </xsl:template>
  
  <xsl:template match="page" mode="results.area">
    <div id="results-area" class="{/page/request/@view}">
      <xsl:if test="/page/request/@view != 'visu'">
        <div id="loading-clusters">Loading...</div>
      </xsl:if>
      <div id="loading-documents">Loading...</div>
      
      <ul id="views">
        <xsl:if test="/page/request/@view = /page/config/views/view[1]/@id">
          <xsl:attribute name="class">first-active</xsl:attribute>        
        </xsl:if>
        <xsl:apply-templates select="/page/config/views/view" />
      </ul>
      
      <div id="clusters-panel">
        <xsl:comment></xsl:comment>
        <xsl:if test="/page/request/@view = 'visu'">
          <div id="clusters-visu"><xsl:comment></xsl:comment></div>
        </xsl:if>
      </div>

      <div id="split-panel"><xsl:comment></xsl:comment></div>
      
      <div id="documents-panel"><xsl:comment></xsl:comment></div>

      <div id="status-bar">
        Query: <b><xsl:value-of select="/page/request/@query" /></b> 
        -- 
        Source: <b><xsl:value-of select="/page/config/components/sources/source[@id = /page/request/@source]/label" /></b>
        <span class="hide"> (<span id="document-count"><xsl:comment></xsl:comment></span> results, <span id="source-time"><xsl:comment></xsl:comment></span> ms)</span>
        --
        Clusterer: <b><xsl:value-of select="/page/config/components/algorithms/algorithm[@id = /page/request/@algorithm]/label" /></b> 
        <span class="hide"> (<span id="algorithm-time"><xsl:comment></xsl:comment></span> ms)</span>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="view">
    <xsl:variable name="view-pos" select="position()" />
    <li>
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="@id = /page/request/@view">active <xsl:choose>
              <xsl:when test="$view-pos = count(/page/config/views/view)">active-last</xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>passive <xsl:choose>
              <xsl:when test="$view-pos = count(/page/config/views/view)">passive-last</xsl:when>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      
        <xsl:if test="/page/request/@view = /page/config/views/view[$view-pos + 1]/@id"> before-active</xsl:if>
        <xsl:if test="$view-pos = 1"> first</xsl:if>
      </xsl:attribute>
      
      <xsl:variable name="view-url">
        <xsl:call-template name="replace-in-url">
          <xsl:with-param name="url" select="$request-url" />
          <xsl:with-param name="param" select="$view-param" />
          <xsl:with-param name="value" select="@id" />
        </xsl:call-template>
      </xsl:variable>
      <a href="{$view-url}"><xsl:value-of select="label" /></a>
      <span class="right"><xsl:comment></xsl:comment></span>
    </li>
  </xsl:template>
</xsl:stylesheet>
