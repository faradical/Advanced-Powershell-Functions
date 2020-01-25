<#
Get-JulianDate
	-Summary: Returns the date in Julian format, yyddd. Useful in mainframe automation scripts.
	-Usage: Get-JulianDate
#>
Function Get-JulianDate
{ 
	$yy = (get-date -Format yy)
	$date = Get-Date
	$offset = (Get-Date 1/1/$yy).AddDays(-1)
	$jdays = $date - $offset
	$jday = $jdays.days
	$length = ($jday).tostring().length

	switch ($length) {
		"1" {$jdate = "$yy" + "00" + "$jday"}
		"2" {$jdate = "$yy" + "0" + "$jday"}
		"3" {$jdate = "$yy" + "$jday"}
	}
	return $jdate
}