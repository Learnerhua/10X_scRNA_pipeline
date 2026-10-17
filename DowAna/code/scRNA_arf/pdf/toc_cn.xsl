<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:outline="http://wkhtmltopdf.org/outline"
                xmlns="http://www.w3.org/1999/xhtml">
  <xsl:output doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
              indent="yes" />
  <xsl:template match="outline:outline">
    <html>
      <head>
        <title>Table of Contents</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <style>
          p {
            text-align: center;
            font-size: 25px;
            font-family:"Noto Sans CJK SC Medium", "Source Han Sans CN Medium";
	    text-indent: 0px;
	    color:#000000;
	    font-weight:bold;
          }
          div {border-bottom: 1px dashed rgb(200,200,200);}
          span {float: right;}
          li {list-style: none;}
          ul {
            font-size: 17px;
            font-family: "Noto Sans CJK SC Medium", "Source Han Sans CN Medium";
            color:#000000;
          }
          ul ul {font-size: 100%; }
          ul {padding-left: 0em;font-weight:bold;}
          ul ul {padding-left: 1.2em;padding-top:1em;padding-bottom:0.1em;font-weight:normal;font-size:15px;color:#000000;}
          a {text-decoration:none; color: #000000;}
        </style>
      </head>
      <body>
        <p>&#x76EE;&#160;&#160;&#160;&#160;&#x5F55;</p>
        <ul><xsl:apply-templates select="outline:item/outline:item"/></ul>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="outline:item">
    <li>
      <xsl:if test="@title!=''">
        <div>
          <a>
            <xsl:if test="@link">
              <xsl:attribute name="href"><xsl:value-of select="@link"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@backLink">
              <xsl:attribute name="name"><xsl:value-of select="@backLink"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="@title" /> 
          </a>
          <span> <xsl:value-of select="@page" /> </span>
        </div>
      </xsl:if>
      <ul>
        <xsl:comment>added to prevent self-closing tags in QtXmlPatterns</xsl:comment>
        <xsl:apply-templates select="outline:item"/>
      </ul>
    </li>
  </xsl:template>
</xsl:stylesheet>
