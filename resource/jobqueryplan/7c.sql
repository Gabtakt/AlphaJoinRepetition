SELECT MIN(n.name) AS cast_member_name,
       MIN(pi.info) AS cast_member_info
FROM aka_name AS an,
     cast_info AS ci,
     info_type AS it,
     link_type AS lt,
     movie_link AS ml,
     name AS n,
     person_info AS pi,
     title AS t
WHERE an.name IS NOT NULL
  AND (an.name LIKE '%a%'
       OR an.name LIKE 'A%')
  AND it.info = 'mini biography'
  AND lt.link IN ('references',
                  'referenced in',
                  'features',
                  'featured in')
  AND n.name_pcode_cf BETWEEN 'A' AND 'F'
  AND ( n.gender = 'm'
       OR ( n.gender = 'f'
           AND n.name LIKE 'A%'))
  AND pi.note IS NOT NULL
  AND t.production_year BETWEEN 1980 AND 2010
  AND n.id = an.person_id
  AND n.id = pi.person_id
  AND ci.person_id = n.id
  AND t.id = ci.movie_id
  AND ml.linked_movie_id = t.id
  AND lt.id = ml.link_type_id
  AND it.id = pi.info_type_id
  AND pi.person_id = an.person_id
  AND pi.person_id = ci.person_id
  AND an.person_id = ci.person_id
  AND ci.movie_id = ml.linked_movie_id;



Aggregate  (cost=58055.04..58055.05 rows=1 width=64)
  ->  Nested Loop  (cost=2495.97..58055.01 rows=6 width=110)
        ->  Hash Join  (cost=2495.54..58050.44 rows=10 width=118)
              Hash Cond: (ml.link_type_id = lt.id)
              ->  Nested Loop  (cost=2494.22..58048.98 rows=45 width=122)
                    ->  Nested Loop  (cost=2493.93..57558.48 rows=1432 width=114)
                          ->  Nested Loop  (cost=2493.36..57294.18 rows=15 width=122)
                                ->  Nested Loop  (cost=2492.93..56121.64 rows=1435 width=103)
                                      ->  Nested Loop  (cost=2492.51..55268.15 rows=740 width=99)
                                            ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                  Filter: ((info)::text = 'mini biography'::text)
                                            ->  Bitmap Heap Scan on person_info pi  (cost=2492.51..55227.72 rows=3802 width=103)
                                                  Recheck Cond: (info_type_id = it.id)
                                                  Filter: (note IS NOT NULL)
                                                  ->  Bitmap Index Scan on info_type_id_person_info  (cost=0.00..2491.56 rows=134817 width=0)
                                                        Index Cond: (info_type_id = it.id)
                                      ->  Index Scan using person_id_aka_name on aka_name an  (cost=0.42..1.13 rows=2 width=4)
                                            Index Cond: (person_id = pi.person_id)
                                            Filter: ((name IS NOT NULL) AND (((name)::text ~~ '%a%'::text) OR ((name)::text ~~ 'A%'::text)))
                                ->  Index Scan using name_pkey on name n  (cost=0.43..0.82 rows=1 width=19)
                                      Index Cond: (id = an.person_id)
                                      Filter: (((name_pcode_cf)::text >= 'A'::text) AND ((name_pcode_cf)::text <= 'F'::text) AND (((gender)::text = 'm'::text) OR (((gender)::text = 'f'::text) AND ((name)::text ~~ 'A%'::text))))
                          ->  Index Scan using person_id_cast_info on cast_info ci  (cost=0.56..12.49 rows=513 width=8)
                                Index Cond: (person_id = n.id)
                    ->  Index Scan using linked_movie_id_movie_link on movie_link ml  (cost=0.29..0.32 rows=2 width=8)
                          Index Cond: (linked_movie_id = ci.movie_id)
              ->  Hash  (cost=1.27..1.27 rows=4 width=4)
                    ->  Seq Scan on link_type lt  (cost=0.00..1.27 rows=4 width=4)
                          Filter: ((link)::text = ANY ('{references,"referenced in",features,"featured in"}'::text[]))
        ->  Index Scan using title_pkey on title t  (cost=0.43..0.46 rows=1 width=4)
              Index Cond: (id = ci.movie_id)
              Filter: ((production_year >= 1980) AND (production_year <= 2010))
