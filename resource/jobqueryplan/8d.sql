SELECT MIN(an.name) AS costume_designer_pseudo,
       MIN(t.title) AS movie_with_costumes
FROM aka_name AS an,
     cast_info AS ci,
     company_name AS cn,
     movie_companies AS mc,
     name AS n,
     role_type AS rt,
     title AS t
WHERE cn.country_code = '[us]'
  AND rt.role = 'costume designer'
  AND an.person_id = n.id
  AND n.id = ci.person_id
  AND ci.movie_id = t.id
  AND t.id = mc.movie_id
  AND mc.company_id = cn.id
  AND ci.role_id = rt.id
  AND an.person_id = ci.person_id
  AND ci.movie_id = mc.movie_id;



Finalize Aggregate  (cost=531282.04..531282.05 rows=1 width=64)
  ->  Gather  (cost=531281.82..531282.03 rows=2 width=64)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=530281.82..530281.83 rows=1 width=64)
              ->  Parallel Hash Join  (cost=484869.28..515595.44 rows=2937275 width=33)
                    Hash Cond: (an.person_id = n.id)
                    ->  Parallel Seq Scan on aka_name an  (cost=0.00..15151.60 rows=375560 width=20)
                    ->  Parallel Hash  (cost=460468.01..460468.01 rows=1261941 width=25)
                          ->  Parallel Hash Join  (cost=345155.78..460468.01 rows=1261941 width=25)
                                Hash Cond: (ci.person_id = n.id)
                                ->  Hash Join  (cost=243688.55..334114.19 rows=1261941 width=21)
                                      Hash Cond: (t.id = ci.movie_id)
                                      ->  Parallel Hash Join  (cost=44355.46..110377.49 rows=395501 width=25)
                                            Hash Cond: (t.id = mc.movie_id)
                                            ->  Parallel Seq Scan on title t  (cost=0.00..46532.63 rows=1053463 width=21)
                                            ->  Parallel Hash  (cost=37866.69..37866.69 rows=395501 width=4)
                                                  ->  Parallel Hash Join  (cost=5351.53..37866.69 rows=395501 width=4)
                                                        Hash Cond: (mc.company_id = cn.id)
                                                        ->  Parallel Seq Scan on movie_companies mc  (cost=0.00..29661.37 rows=1087137 width=8)
                                                        ->  Parallel Hash  (cost=4722.92..4722.92 rows=50289 width=4)
                                                              ->  Parallel Seq Scan on company_name cn  (cost=0.00..4722.92 rows=50289 width=4)
                                                                    Filter: ((country_code)::text = '[us]'::text)
                                      ->  Hash  (cost=149779.57..149779.57 rows=3020362 width=8)
                                            ->  Nested Loop  (cost=0.56..149779.57 rows=3020362 width=8)
                                                  ->  Seq Scan on role_type rt  (cost=0.00..1.15 rows=1 width=4)
                                                        Filter: ((role)::text = 'costume designer'::text)
                                                  ->  Index Scan using role_id_cast_info on cast_info ci  (cost=0.56..116829.02 rows=3294940 width=12)
                                                        Index Cond: (role_id = rt.id)
                                ->  Parallel Hash  (cost=72977.55..72977.55 rows=1736455 width=4)
                                      ->  Parallel Seq Scan on name n  (cost=0.00..72977.55 rows=1736455 width=4)
