<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:trj="http://bioinformatics.hochschule-stralsund.de/trajectory"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:math="http://www.w3.org/2005/xpath-functions/math">

    <xsl:output method="text" indent="no" omit-xml-declaration="yes"/>


    <xsl:template match="trj:trajectory">
        atom default radius 0.7 name DEF
        <xsl:for-each select="trj:configurations/trj:configuration[1]/trj:beads/trj:dnabead">
            <xsl:choose>
                <xsl:when test="/trj:trajectory/trj:configurations/trj:configuration[1]/trj:beads/trj:dnabead[1] = current()">
                    atom <xsl:value-of select="trj:id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text/>,<xsl:value-of select="trj:id"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="/trj:trajectory/trj:configurations/trj:configuration[1]/trj:beads/trj:dnabead[last()] = current()">
                <xsl:text> </xsl:text>radius 12 name DNA
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="trj:configurations/trj:configuration[1]/trj:beads/trj:nucleosomebead">
            <xsl:choose>
                <xsl:when test="/trj:trajectory/trj:configurations/trj:configuration[1]/trj:beads/trj:nucleosomebead[1] = current()">
                    atom <xsl:value-of select="trj:id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text/>,<xsl:value-of select="trj:id"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="/trj:trajectory/trj:configurations/trj:configuration[1]/trj:beads/trj:nucleosomebead[last()] = current()">
                <xsl:text> </xsl:text>radius 46.7 name NUCS
            </xsl:if>
        </xsl:for-each>


        <xsl:variable name="NumberNucs" select="count(trj:configurations/trj:configuration[1]//trj:nucleosomebead)"/>
        # Bonds
        bond 0::<xsl:value-of select="(trj:parameters/trj:parameter[1]/trj:value)-1"/>
        # set the unitcell
        unitcell <xsl:value-of select="ceiling(fn:max(//trj:position/trj:x))*10"/><xsl:text>.0 </xsl:text><xsl:value-of select="ceiling(fn:max(//trj:position/trj:y))*10"/><xsl:text>.0 </xsl:text> <xsl:value-of select="ceiling(fn:max(//trj:position/trj:z))*10"/>.0
        <xsl:for-each select="/trj:trajectory/trj:configurations/trj:configuration">
            timestep
            <xsl:text>
            </xsl:text>
            <xsl:for-each select="trj:beads/(trj:dnabead|trj:nucleosomebead)">
                <xsl:value-of select="trj:position/trj:x*10"/>
                <xsl:text>    </xsl:text>
                <xsl:value-of select="trj:position/trj:y*10"/>
                <xsl:text>    </xsl:text>
                <xsl:value-of select="trj:position/trj:z*10"/>
                <xsl:text>
                </xsl:text>
            </xsl:for-each>
            <xsl:text>
            </xsl:text>
        </xsl:for-each>
    </xsl:template>



</xsl:stylesheet>
