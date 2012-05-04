<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--  To see the input used for this xslt, check the "Create source.xml file 
        when creating report" menu item under the "Reports" menu in FsComp.
        When checked a .source.xml file is created each time you create a report.
        It shows the actual xml input to the xslt processor.
        This is helpfull if you like to modify this file.
  -->

	<xsl:output method="html" encoding="utf-8" indent="yes" />

	<!--  Set the decimal separator to be used (. or ,) when decimal data is displayed.
        All decimal data in the source is with . and will be displayed with . unless
        formated otherwise using format-number() function.
  -->
	<xsl:variable name="decimal_separator" select="','"/>
	<xsl:decimal-format decimal-separator=',' grouping-separator=' ' />
	<!-- note! make sure both above use same, ie either . or ,!! -->

	<!--  All <xsl:param ... elements will show as a field in a report dialog in 
        FS when creating reports. This means you can define param elements here 
        with a default value and set the value from FS when creating report.
        Some is used simply to display text at the top of the report (ie status), 
        others is used to filter the results (ie women_only, nation, ...).
        If you add filter params you must of course also change the "filter"
        definition below so that the filter params is applied.
				20080518 FS 1.2.3: 
				Removed all "filter" params.
				Moved filtering inside FS so the xml input to the xslt is already filtered.
				the filter_info attribute of FsTaskResults element shows what filter(s) is applied.
  -->
	<xsl:param name="title"></xsl:param>
	<xsl:param name="status">Provisional</xsl:param>
	<!-- filter params -->
	<!--  No of best tasks to use the sum of for each pilot. 
        Default is 'all' which is normally used. -->
	<xsl:param name="top_x_tasks">all</xsl:param>

	<!--  The node-set that this variable returns is what is used 
        to create the result list.
        Here some of the params above is used.
  -->
	<xsl:variable name="filter" select="/Fs/FsCompetition[1]/FsCompetitionResults[@top=$top_x_tasks]/FsParticipant"/>
	<xsl:variable name="filter_info" select="/Fs/FsCompetition[1]/FsCompetitionResults[@top=$top_x_tasks]/@filter_info"/>

	<!--  Returns a ranking number based on the @points attribute in the element given by the item param.
        Will give same ranking to elements with equal points. 
        NOTE! does NOT work when called inside a sorted node-list!!!
				NOTE! Likly to give wrong rank for some pilots when applied to a filtered node-list.
  -->
	<xsl:template name="calc_rank_from_points" >
		<xsl:param name="item"/>
		<xsl:param name="points"/>
		<xsl:param name="sub" select="0"/>
		<xsl:variable name="found" select="boolean($item/preceding-sibling::node()[1]/@points = $points)"/>
		<xsl:choose>
			<xsl:when test="$found = true()">
				<xsl:call-template name="calc_rank_from_points">
					<xsl:with-param name="item" select="$item/preceding-sibling::node()[1]"/>
					<xsl:with-param name="points" select="$points"/>
					<xsl:with-param name="sub" select="$sub+1"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="position()-$sub"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- list of tasks -->
	<xsl:template name="FsTask_list">
		<table>
			<thead>
				<tr class="fs_res_res_row" onmouseover="this.className = 'hover'" onmouseout="this.className='fs_res_res_row'" >
					<th>Manga</th>
					<th>Fecha</th>
					<th>Dist.</th>
					<th>Tipo de manga</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="/Fs/FsCompetition/FsCompetitionResults[@top=$top_x_tasks]/FsParticipant[1]/FsTask">
					<xsl:variable name="task_id" select="@id"/>
					<xsl:variable name="es" select="/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/FsTaskDefinition/@es"/>
					<xsl:variable name="no_of_startgates" select="count(/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/FsTaskDefinition/FsStartGate)"/>
					<xsl:variable name="task_distance" select="/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/FsTaskScoreParams/@task_distance"/>
					<tr class="fs_res_res_row" onmouseover="this.className = 'hover'" onmouseout="this.className='fs_res_res_row'" >
						<td>
							M<xsl:value-of select="position()"/>
							<xsl:text>&#160;</xsl:text>
							<xsl:value-of select="/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/@name"/>
						</td>
						<td>
							<xsl:value-of select="translate(substring(/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/FsTaskDefinition/FsTurnpoint[1]/@open, 1, 16), 'T', ' ')"/>&#160;&#160;<xsl:value-of select="@name"/>
						</td>
						<td>
							<xsl:if test="$es">
								<xsl:text>&#160;</xsl:text>
								<xsl:value-of select="format-number($task_distance, concat('#0', $decimal_separator, '0'))"/>
								<xsl:text> km</xsl:text>
							</xsl:if>
						</td>
						<td>
							<xsl:choose>
								<xsl:when test="$es and $no_of_startgates > 0">
									<xsl:text>Carrera a Gol con </xsl:text>
									<xsl:value-of select="$no_of_startgates"/>
									<xsl:text> ventana(s)</xsl:text>
								</xsl:when>
								<xsl:when test="$es and $no_of_startgates = 0">
									<xsl:text>Tiempo transcurrido</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>Distancia libre</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<!-- record template, used for each pilot in the ranked list of pilots -->
	<xsl:template name="record">
		<xsl:variable name="pilot_id" select="@id"/>
		<tr class="fs_res_res_row" onmouseover="this.className = 'hover'" onmouseout="this.className='fs_res_res_row'" >
			<td align="right">
				<xsl:call-template name="calc_rank_from_points">
					<xsl:with-param name="item" select="."/>
					<xsl:with-param name="points" select="@points"/>
				</xsl:call-template>
			</td>
			<td>
        <span class="pilot_id"><xsl:value-of select="@id"/></span>
				<xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@name"/>
			</td>
			<td style="text-align: center">
				<xsl:choose>
					<xsl:when test="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@female=1">F</xsl:when>
					<xsl:otherwise>M</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@nat_code_3166_a3"/>
			</td>
			<td>
				<xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@glider"/>
			</td>
			<xsl:for-each select="FsTask">
				<xsl:variable name="task_id" select="@id"/>
				<xsl:choose>
					<xsl:when test="@counts='1'">
						<td style="text-align: right">
							<xsl:value-of select="/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/FsParticipants/FsParticipant[@id=$pilot_id]/FsResult/@points"/>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td style="text-align: right; text-decoration: line-through;">
							<xsl:value-of select="/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/FsParticipants/FsParticipant[@id=$pilot_id]/FsResult/@points"/>
						</td>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<td style="font-weight: bold; text-align: right">
				<xsl:value-of select="@points"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="/">---
layout: results
title: <xsl:value-of select="$title"/>
---
		<h2><xsl:value-of select="$title"/></h2>
		<div class="fs_res competition">
			<div class="report_date">
				<i>
					Informe generado el: <xsl:value-of select="/Fs/FsCompetition/FsCompetitionResults[@top=$top_x_tasks]/@ts"/>
				</i>
			</div>
			<xsl:choose>
				<xsl:when test="$top_x_tasks='all'">
					<h3>Resultados utilizando todas las mangas celebradas</h3>
				</xsl:when>
				<xsl:otherwise>
					<h3>Resultados utilizando las <xsl:value-of select="$top_x_tasks"/> mejores mangas de cada piloto
					</h3>
				</xsl:otherwise>
			</xsl:choose>
			<p>
				<xsl:value-of select="$status"/>
			</p>
			<xsl:if test="string-length($filter_info) > 0">
				<p>
					<b>
						Resultados de pilotos con <xsl:value-of select="$filter_info"/>
					</b>
				</p>
			</xsl:if>
			<xsl:if test="$top_x_tasks != 'all'">
				<p>
					<b>
						<xsl:choose>
							<xsl:when test="$top_x_tasks = 1">
								Only the score from the best task of each pilot is used for total score.
							</xsl:when>
							<xsl:otherwise>
								Only the scores from the best <xsl:value-of select="$top_x_tasks"/> tasks of each pilot is used for total score.
							</xsl:otherwise>
						</xsl:choose>
					</b>
				</p>
			</xsl:if>
			<xsl:call-template name="FsTask_list"></xsl:call-template>
			<br/>
			<table class="result_list">
				<thead>
					<tr class="fs_res_res_row" onmouseover="this.className = 'hover'" onmouseout="this.className='fs_res_res_row'" >
						<th>#</th>
						<th>Nombre</th>
						<th></th>
						<th>Nat</th>
						<th>Ala</th>
						<xsl:for-each select="/Fs/FsCompetition/FsCompetitionResults[@top=$top_x_tasks]/FsParticipant[1]/FsTask">
							<th>
								<xsl:text>M </xsl:text>
								<xsl:value-of select="position()"/>
							</th>
						</xsl:for-each>
						<th>Total</th>
					</tr>
				</thead>
				<xsl:for-each select="$filter">
					<!-- participant rows -->
					<xsl:call-template name="record"/>
				</xsl:for-each>
			</table>
		</div>
	</xsl:template>
</xsl:stylesheet>
