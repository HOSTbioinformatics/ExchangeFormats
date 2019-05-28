<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:trj="http://bioinformatics.hochschule-stralsund.de/trajectory"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:math="http://www.w3.org/2005/xpath-functions/math">
    <xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="trj:trajectory">
        <xsl:text>
        </xsl:text>
        <xsl:variable name="NumberNucs" select="count(trj:configurations/trj:configuration[1]//trj:nucleosomebead)"/>
        <xsl:value-of select="trj:parameters/trj:parameter[1]/trj:value"/> atoms
        <xsl:value-of select="$NumberNucs"/> ellipsoids
        2 atom types
        1 bond types

        <xsl:value-of select="ceiling(fn:min(//trj:position/trj:x))"/>
        <xsl:text>   </xsl:text><xsl:value-of select="ceiling(fn:max(//trj:position/trj:x))"/> <xsl:text>    </xsl:text>xlo xhi
        <xsl:value-of select="ceiling(fn:min(//trj:position/trj:y))"/>
        <xsl:text>   </xsl:text><xsl:value-of select="ceiling(fn:max(//trj:position/trj:y))"/> <xsl:text>    </xsl:text>ylo yhi
        <xsl:value-of select="ceiling(fn:min(//trj:position/trj:z))"/>
        <xsl:text>   </xsl:text><xsl:value-of select="ceiling(fn:max(//trj:position/trj:z))"/> <xsl:text>    </xsl:text>zlo zhi
        Masses

        1 5.0
        2 10.0


        Atoms
        <xsl:for-each select="trj:configurations/trj:configuration[last()]/trj:beads/(trj:dnabead|trj:nucleosomebead)">
                <xsl:text>
                </xsl:text>
            <xsl:value-of select="trj:id+1"/>
            <xsl:choose>
                <xsl:when test="name()='nucleosomebead'">
                    <xsl:text>   </xsl:text>1<xsl:text>  </xsl:text>1<xsl:text>  </xsl:text>2<xsl:text>    </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>   </xsl:text>1<xsl:text>    </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="trj:position/trj:x"/>
            <xsl:text>    </xsl:text>
            <xsl:value-of select="trj:position/trj:y"/>
            <xsl:text>    </xsl:text>
            <xsl:value-of select="trj:position/trj:z"/>
        </xsl:for-each>

        Ellipsoids
        <xsl:for-each select="trj:configurations/trj:configuration[last()]/trj:beads/trj:nucleosomebead">
                <xsl:text>
                </xsl:text>
            <xsl:value-of select="trj:id+1"/>
            <xsl:text>   </xsl:text>1<xsl:text>  </xsl:text>1.5<xsl:text>    </xsl:text>2<xsl:text> </xsl:text>
            <xsl:value-of select="math:cos(trj:intrinsic_twist/2)"/>
            <xsl:text>    </xsl:text>
            <xsl:value-of select="trj:bend_vector/trj:x*math:sin(trj:intrinsic_twist/2)"/>
            <xsl:text>    </xsl:text>
            <xsl:value-of select="trj:bend_vector/trj:y*math:sin(trj:intrinsic_twist/2)"/>
            <xsl:text>    </xsl:text>
            <xsl:value-of select="trj:bend_vector/trj:z*math:sin(trj:intrinsic_twist/2)"/>
        </xsl:for-each>

    </xsl:template>


</xsl:stylesheet>
