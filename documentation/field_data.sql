SELECT DISTINCT
    tbl_stationoccupation.stationid,
    tbl_stationoccupation.occupationlatitude as latitude,
    tbl_stationoccupation.occupationlongitude as longitude,
    tbl_stationoccupation.occupationdepth as stationwaterdepth,
    tbl_stationoccupation.occupationdepthunits as stationwaterdepthunits,
    tbl_stationoccupation.occupationdate as samplecollectdate,
    field_assignment_table.areaweight,
    field_assignment_table.stratum
FROM
    field_assignment_table
    INNER JOIN tbl_stationoccupation ON field_assignment_table.stationid = tbl_stationoccupation.stationid
WHERE
    tbl_stationoccupation.collectiontype = 'Grab'
    AND tbl_stationoccupation.stationfail = 'None or No Failure'