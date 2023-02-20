#!/bin/bash

echo "=========================================================================================="
echo "REQUIREMENT"
echo "1. Segment node hostname have to be composed of work type (prefix) + sequence number."
echo "2. Segment nodes have to be expanded in units of 4 units."
echo "3. Do not put empty values in all input fields."
echo "=========================================================================================="

## check user env
MAXCONTENT=`psql -Atc "select max(content)+1 from gp_segment_configuration;"`
SEGHOSTNM=`psql -Atc "select hostname from gp_segment_configuration where content=0 and preferred_role='p';"`
echo "Segment node hostname is configed prefix_name + number like this : " ${SEGHOSTNM}
read -p "(Input1)What is the segment node's prefix_name in your segment node? : " SEGPREFIX
read -p "(Input2)How many zeros are in the segment node hostname? [0/1/2] : " ZEROCNT
INSTNM=`psql -Atc "select datadir from gp_segment_configuration where content=0 and preferred_role='p';" | awk -F'/' '{print $4}'`
echo "Segment instance name is configed prefix_name + contnet like this : " ${INSTNM}
read -p "(Input3)What is the instance's prefix_name in your cluster? : " INSTPREFIX
read -p "(Input4)What is segment node number of the first expand nodes? : " SCNT
read -p "(Input5)What is segment node number of the last expand nodes? : " ECNT
SNUM=`expr ${SCNT} / 4`
ENUM=`expr \( ${ECNT} - 1 \) / 4`

## generate mirror map
psql -Atc "
WITH
primary_ AS
(
  SELECT   address,
           Count(1)::int AS cnt
  FROM     pg_catalog.gp_segment_configuration
  WHERE    content >= 0
  AND      content < ${MAXCONTENT}
  AND      role = 'p'
  GROUP BY 1),
info AS
(
  SELECT '${SEGPREFIX}'::text AS prefix_name,
         Count(DISTINCT(address))::int AS nodes,
         Max(cnt)::int                 AS instances
  FROM   primary_),
template_ AS
(
  SELECT sc.dbid::int,
         sc.content::int,
         sc.role,
         sc.preferred_role,
         sc.port,
         split_part(sc.hostname, prefix_name, 2)::int AS node_no,
         split_part(sc.datadir, '${INSTPREFIX}', 1)    AS location,
         io.prefix_name,
         io.nodes,
         io.instances
  FROM   pg_catalog.gp_segment_configuration AS sc,
         info                                AS io
  WHERE  sc.content >= 0
  AND    sc.content < ${MAXCONTENT} )

SELECT hostname || '|' || hostname || '|' || port::text || '|' || location || '|' || dbid || '|' || content || '|' || preferred_role AS text
FROM
(
  SELECT tm.dbid    + instances * nodes * 2 * i AS dbid,
         tm.content + instances * nodes * i     AS content,
         tm.role,
         tm.preferred_role,
         tm.port,
         CASE
         WHEN (${ZEROCNT} = 1) THEN
           CASE
           WHEN (tm.node_no + tm.nodes * i ) <= 9 THEN
             tm.prefix_name || '0' || (tm.node_no + tm.nodes * i )::text
           ELSE
             tm.prefix_name || (tm.node_no + tm.nodes * i )::text
           END
         WHEN (${ZEROCNT} = 2) THEN
           CASE
           WHEN (tm.node_no + tm.nodes * i ) <= 9 THEN
             tm.prefix_name || '00' || (tm.node_no + tm.nodes * i )::text
           WHEN (tm.node_no + tm.nodes * i ) >= 10 AND (tm.node_no + tm.nodes * i ) <= 99 THEN
             tm.prefix_name || '0' || (tm.node_no + tm.nodes * i )::text           ELSE
           ELSE
             tm.prefix_name || (tm.node_no + tm.nodes * i )::text
           END
         ELSE
           tm.prefix_name || (tm.node_no + tm.nodes * i )::text
         END AS hostname,
         --tm.prefix_name || (tm.node_no + tm.nodes * i )::text AS hostname,
         tm.location || '${INSTPREFIX}' || (tm.content + instances * nodes * i) AS location
  FROM   template_            AS tm,
         generate_series(${SNUM},${ENUM}) AS i
  ORDER BY 2, 1) AS lt ;
" > ./gen_mirror_map.out

echo ""
echo "=========================================================================================="
echo "Succes : result write in the ./gen_mirror_map.out file"
echo "=========================================================================================="
