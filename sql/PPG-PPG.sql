SELECT
  materialname "Item"
  --, mat.info1 Description
  ,
  SUM(quantitycurrent) - isnull(
  (
    SELECT
      SUM(quantity)
    FROM
      [powerpick_bimba].[dbo].[masterorderline] AS mo
    WHERE
      materialreference = materialname
  )
  ,0) --open mo
  "Quantity"
  --, locationname
FROM
  [powerpick_bimba].[dbo].[LocContent]   AS lc ,
  [powerpick_bimba].[dbo].[Location]     AS loc ,
  [powerpick_bimba].[dbo].[materialbase] AS mat
WHERE
  1=1
  -- and materialname = 'D-74
AND loc.locationid = lc.locationid
AND locationname LIKE 'Rem%'
AND lc.materialid = mat.materialid
GROUP BY
  materialname
