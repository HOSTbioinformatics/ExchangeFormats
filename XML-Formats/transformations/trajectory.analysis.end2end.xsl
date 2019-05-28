<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://exslt.org/math"
	xmlns:trj="http://bioinformatics.hochschule-stralsund.de/trajectory">


	<!-- Computing end-to-end distances of all configurations. -->
	<!-- http://bioinformatics.fh-stralsund.de -->

	<!-- @see http://www.w3.org/TR/xslt#output -->
	<xsl:output method="text" indent="yes"/>

	<!-- Transforming the xml trajectory. -->
	<xsl:template match="/">
		<xsl:for-each
			select="/trj:trajectory/trj:configurations/trj:configuration">
			<xsl:for-each
				select="trj:beads/trj:dnabead|trj:beads/trj:nucleosomebead">
				<xsl:if test="position() = last()">
					<!-- Last bead found. -->
					<!-- Indices are 1-based, therefore 1st position is NOT 0. -->

					<!-- Get coordinates of end at first bead (position of first bead). -->
					<xsl:param name="first_bead_x"
						select="../trj:*[1]/trj:position/trj:x" />
					<xsl:param name="first_bead_y"
						select="../trj:*[1]/trj:position/trj:y" />
					<xsl:param name="first_bead_z"
						select="../trj:*[1]/trj:position/trj:z" />

					<!-- Get coordinates of end at last bead (position of last bead extended 
						by segment vector). -->
					<xsl:param name="last_bead_x"
						select="trj:position/trj:x + trj:segment_vector/trj:x" />
					<xsl:param name="last_bead_y"
						select="trj:position/trj:y + trj:segment_vector/trj:y" />
					<xsl:param name="last_bead_z"
						select="trj:position/trj:z + trj:segment_vector/trj:z" />

					<!-- Compute euclidean distance between both ends of chromatin fiber. -->
					<!-- @see http://mathworld.wolfram.com/Distance.html -->
					<!-- @see http://en.wikipedia.org/wiki/Pythagorean_theorem -->
					<xsl:value-of
						select="math:sqrt(
            math:power(
              ($first_bead_x - $last_bead_x), 2) + 
            math:power(
              ($first_bead_y - $last_bead_y), 2) + 
            math:power(
              ($first_bead_z - $last_bead_z), 2))" />
					<!-- Separate values by new line. -->
					<xsl:text>
</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
