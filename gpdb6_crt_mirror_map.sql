/* 
(1) 사용 설명
  - 최초 1/4 rack 노드의 primary and mirror 구성을 완료 하고, 아래 쿼리를 수행하면 generate_series 함수에 입력된 1/4 rack 갯수 만큼 확장한 맵이 생성됨
(2) 주의사항
  - segment hostname의 prefix를 지정하는 부분은 환경에 맞게 변경하여 사용할것
(3) config map file format : hostname|address|port|datadir|dbid|content|preferred_role
*/

WITH 
primary_ AS 
( 
         SELECT   address, 
                  Count(1) AS cnt 
         FROM     pg_catalog.gp_segment_configuration 
         WHERE    content >= 0 
         AND      content < 16 /* Number of primary instances in four segments (start 0, 16 = seg_nodes 4 * instances per seg_nodes 4) */
         AND      role = 'p' 
         GROUP BY 1), 
info AS 
( 
       SELECT 'gpsdw' AS prefix_name, /* segment node prefix name setting */ 
              Count(DISTINCT(address)) AS nodes, 
              Max(cnt)                 AS instances 
       FROM   primary_), 
template_ AS 
( 
       SELECT sc.dbid::int, 
              sc.content::int, 
              sc.role, 
              sc.preferred_role, 
              sc.port, 
              split_part(sc.hostname, prefix_name, 2)::int AS node_no, 
              split_part(sc.datadir, 'gpseg', 1)           AS location, /* segment instance prefix name setting */ 
              io.prefix_name, 
              io.nodes, 
              io.instances 
       FROM   pg_catalog.gp_segment_configuration AS sc, 
              info                                AS io 
       WHERE  sc.content >= 0 
       AND    sc.content < 16) /* Number of primary instances in four segments (start 0, 16 = seg_nodes 4 * instances per seg_nodes 4) */

SELECT hostname || '|' || hostname || '|' || port::text || '|' || location || '|' || dbid || '|' || content || '|' || preferred_role AS text 
FROM   ( 
                SELECT   tm.dbid    + instances * nodes * 2 * i AS dbid, 
                         tm.content + instances * nodes * i     AS content, 
                         tm.role, 
                         tm.preferred_role, 
                         tm.port, 
                         tm.prefix_name || (tm.node_no + tm.nodes * i )::text AS hostname, 
                         tm.location || 'gpseg' || (tm.content + instances * nodes * i) AS location /* segment instance prefix name setting */ 
                FROM     template_            AS tm, 
                         generate_series(1,3) AS i /* Number of quater groups to add (quater = 4 seg_nodes, start 0, if 2nd fullrack = (4,7) */
                ORDER BY 2, 1) AS lt ;