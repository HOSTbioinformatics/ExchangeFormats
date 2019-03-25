<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:trj="http://bioinformatics.fh-stralsund.de/trajectory"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://exslt.org/math"
>

  <!-- Transforming a chromatin fiber into a POV-Ray scene. -->
  <!-- http://bioinformatics.fh-stralsund.de -->

  <!-- @see http://www.w3.org/TR/xslt#output -->
  <xsl:output method="text" indent="yes" encoding="UTF-8" />

  <!-- The number of the configuration to be transformed. -->
  <xsl:param name="cfg" select="1" />

  <xsl:param name="aspect_ratio" as="xs:decimal*">
    <xsl:value-of select="4 div 3" />
  </xsl:param>

  <!-- The height of all nucleosomes which is stored in the trajectory parameter list. -->
  <!-- We store the half nucleosome height here to simplify further processing and avoid redundant calculation. -->
  <xsl:param name="half_nucleosome_height" as="xs:decimal*">
    <!-- WE ARE LOOKING IN THE TRAJECTORY PARAMETER LIST,
         BECAUSE WE EXPECT ONE COMMON HEIGHT FOR ALL NUCLEOSOMES.

         IF NUCLEOSOMES HAVE INDIVIDUAL HEIGHTS ONE DAY,
         THEN WE HAVE TO LOOK IN THE CONFIGURATION PARAMETER LIST INSTEAD. -->
    <xsl:for-each select="/trj:trajectory/trj:parameters/trj:parameter">
      <xsl:if test="trj:name='NucleosomeHeight'" >
        <xsl:value-of select="trj:value * 0.5" />
      </xsl:if>
    </xsl:for-each>
  </xsl:param>

  <!-- A nucleosome consists of a proteine surrounded by dna. -->
  <!-- That's why we subtract dna diameter from nucleosome radius to get proteine radius. -->
  <xsl:param name="proteine_radius" as="xs:decimal*">
    <!-- WE ARE LOOKING IN THE TRAJECTORY PARAMETER LIST,
         BECAUSE WE EXPECT ONE COMMON RADIUS FOR ALL NUCLEOSOMES.

         IF NUCLEOSOMES HAVE INDIVIDUAL RADII ONE DAY,
         THEN WE HAVE TO LOOK IN THE CONFIGURATION PARAMETER LIST INSTEAD. -->
    <xsl:for-each select="/trj:trajectory/trj:parameters/trj:parameter">
      <xsl:if test="trj:name='NucleosomeRadius'" >
        <xsl:value-of select="trj:value - 2 * $dna_radius" />
      </xsl:if>
    </xsl:for-each>
  </xsl:param>

  <!-- The radius of all DNA segments which is stored in the trajectory parameter list. -->
  <xsl:param name="dna_radius" as="xs:decimal*">
    <!-- WE ARE LOOKING IN THE TRAJECTORY PARAMETER LIST,
         BECAUSE WE EXPECT ONE COMMON RADIUS FOR ALL DNA SEGMENTS.

         IF DNA SEGMENTS HAVE INDIVIDUAL RADII ONE DAY,
         THEN WE HAVE TO LOOK IN THE CONFIGURATION PARAMETER LIST INSTEAD. -->
    <xsl:for-each select="/trj:trajectory/trj:parameters/trj:parameter">
      <xsl:if test="trj:name='RadiusDNA'">
        <xsl:value-of select="trj:value" />
      </xsl:if>
    </xsl:for-each>
  </xsl:param>

  <!-- Transforming the xml trajectory. -->
  <xsl:template match="/" >
    <xsl:apply-templates select="/trj:trajectory/trj:configurations/trj:configuration[$cfg]" />
  </xsl:template>

  <!-- Processing the selected configuration. -->
  <xsl:template match="trj:configuration">
<!--    <xsl:message>Adding includes to scene. </xsl:message> -->
#include "colors.inc"
#include "glass.inc"
#include "metals.inc"
#include "textures.inc"
<!--    <xsl:message>Adding global settings to scene. </xsl:message> -->
global_settings {
  radiosity { count 200 }
  assumed_gamma 1.0
}
<!--    <xsl:message>Adding background to scene. </xsl:message> -->
background {
  color rgb &#60; 1., 1., 1. &#62;
}
<!--    <xsl:message>Adding camera to scene. </xsl:message> -->
camera {
  perspective
  location &#60; 0, 0, 250 &#62;
  direction &#60; 0, 0, -1 &#62;
  up &#60; 0, 1, 0 &#62;
  right &#60; <xsl:value-of select="$aspect_ratio" />, 0, 0 &#62;
  angle 60
<!--  look_at  &#60; 0, 0, 0 &#62; -->
}
<!--    <xsl:message>Adding light source to scene. </xsl:message> -->
light_source {
  &#60; 1000.0, 1000.0, 1000.0 &#62;
  color rgb &#60; 1., 1., 1. &#62;
}
<!-- Comment a template to exclude dna or nucleosomes from the scene. -->
    <xsl:apply-templates select="trj:beads/trj:dnabead" />
    <xsl:apply-templates select="trj:beads/trj:nucleosomebead" />
  </xsl:template>

  <xsl:template match="trj:dnabead">
<!--    <xsl:message>Adding a cylinder representing the current dna segment to scene. </xsl:message> -->
cylinder {
&#60; 
<!-- Setting base point of the POVRAY cylinder representing the current dna segment. -->
<!-- @see http://www.povray.org/documentation/view/3.6.1/278/ -->
    <xsl:value-of select="trj:position/trj:x" /> ,
    <xsl:value-of select="trj:position/trj:y" /> ,
    <xsl:value-of select="trj:position/trj:z" />
&#62; , &#60;
<!-- Setting cap point of the POVRAY cylinder representing the current dna segment. -->
<!-- @see http://www.povray.org/documentation/view/3.6.1/278/ -->
    <xsl:value-of select="trj:position/trj:x + trj:segment_vector/trj:x" /> ,
    <xsl:value-of select="trj:position/trj:y + trj:segment_vector/trj:y" /> ,
    <xsl:value-of select="trj:position/trj:z + trj:segment_vector/trj:z" />
&#62; , <xsl:value-of select="$dna_radius" />
  texture {
    pigment {
      color rgb &#60; 0.0, 0.0, 1.0 &#62;
    }
  }
  finish {
    ambient 0.5
    diffuse 0.9
    reflection { 0.3 metallic }
    specular 0.3
    roughness 0.9
    phong 0.9
  }
  normal {
    bumps 0.3
  }
}
  </xsl:template>

  <xsl:template match="trj:nucleosomebead">
<!--    <xsl:message>Adding a cylinder representing the current nucleosome to scene. </xsl:message> -->
<!-- Calculate length of center orientation vector 
     in order to normalize this vector 
     before adding a POVRAY cylinder to the scene. -->
<!-- @see http://mathworld.wolfram.com/NormalizedVector.html -->
  <xsl:param name="length_center_orientation_vector" as="xs:decimal*">
    <xsl:value-of select="math:sqrt(
    (trj:center_orientation_vector/trj:x * trj:center_orientation_vector/trj:x) +
    (trj:center_orientation_vector/trj:y * trj:center_orientation_vector/trj:y) +
    (trj:center_orientation_vector/trj:z * trj:center_orientation_vector/trj:z))" />
  </xsl:param>
cylinder {
&#60;
<!-- Setting base point of the POVRAY cylinder representing the current nucleosome. -->
<!-- @see http://www.povray.org/documentation/view/3.6.1/278/ -->
<!-- Normalization: trj:center_orientation_vector/trj:[x|y|z] div $length_center_orientation_vector -->
    <xsl:value-of select="trj:center/trj:x - (trj:center_orientation_vector/trj:x div $length_center_orientation_vector) * $half_nucleosome_height" /> , 
    <xsl:value-of select="trj:center/trj:y - (trj:center_orientation_vector/trj:y div $length_center_orientation_vector) * $half_nucleosome_height" /> , 
    <xsl:value-of select="trj:center/trj:z - (trj:center_orientation_vector/trj:z div $length_center_orientation_vector) * $half_nucleosome_height" /> 
&#62; , &#60;
<!-- Setting cap point of the POVRAY cylinder representing the current nucleosome. -->
<!-- @see http://www.povray.org/documentation/view/3.6.1/278/ -->
<!-- Normalization: trj:center_orientation_vector/trj:[x|y|z] div $length_center_orientation_vector -->
    <xsl:value-of select="trj:center/trj:x + (trj:center_orientation_vector/trj:x div $length_center_orientation_vector) * $half_nucleosome_height" /> , 
    <xsl:value-of select="trj:center/trj:y + (trj:center_orientation_vector/trj:y div $length_center_orientation_vector) * $half_nucleosome_height" /> , 
    <xsl:value-of select="trj:center/trj:z + (trj:center_orientation_vector/trj:z div $length_center_orientation_vector) * $half_nucleosome_height" /> 
&#62; , <xsl:value-of select="$proteine_radius" />
  texture {
    pigment {
      color Col_Glass_Ruby
      transmit 0.4
    }
  }
  finish {
    ambient 0.8
    diffuse 0.8
    reflection { 0.3 metallic }
    specular 0.4
    roughness 0.8
    phong 0.8
  }
  normal {
    bumps 0.1
  }
}
  </xsl:template>

</xsl:stylesheet>
