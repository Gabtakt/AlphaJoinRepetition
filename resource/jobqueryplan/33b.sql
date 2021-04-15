SELECT MIN(cn1.name) AS first_company,
       MIN(cn.name) AS second_company,
       MIN(mi_idx1.info) AS first_rating,
       MIN(mi_idx.info) AS second_rating,
       MIN(t1.title) AS first_movie,
       MIN(t.title) AS second_movie
FROM company_name AS cn1,
     company_name AS cn,
     info_type AS it1,
     info_type AS it,
     kind_type AS kt1,
     kind_type AS kt,
     link_type AS lt,
     movie_companies AS mc1,
     movie_companies AS mc,
     movie_info_idx AS mi_idx1,
     movie_info_idx AS mi_idx,
     movie_link AS ml,
     title AS t1,
     title AS t
WHERE cn1.country_code = '[nl]'
  AND it1.info = 'rating'
  AND it.info = 'rating'
  AND kt1.kind IN ('tv series')
  AND kt.kind IN ('tv series')
  AND lt.link LIKE '%follow%'
  AND mi_idx.info < '3.0'
  AND t.production_year = 2007
  AND lt.id = ml.link_type_id
  AND t1.id = ml.movie_id
  AND t.id = ml.linked_movie_id
  AND it1.id = mi_idx1.info_type_id
  AND t1.id = mi_idx1.movie_id
  AND kt1.id = t1.kind_id
  AND cn1.id = mc1.company_id
  AND t1.id = mc1.movie_id
  AND ml.movie_id = mi_idx1.movie_id
  AND ml.movie_id = mc1.movie_id
  AND mi_idx1.movie_id = mc1.movie_id
  AND it.id = mi_idx.info_type_id
  AND t.id = mi_idx.movie_id
  AND kt.id = t.kind_id
  AND cn.id = mc.company_id
  AND t.id = mc.movie_id
  AND ml.linked_movie_id = mi_idx.movie_id
  AND ml.linked_movie_id = mc.movie_id
  AND mi_idx.movie_id = mc.movie_id;



Aggregate  (cost=2708.96..2708.97 rows=1 width=192)
  ->  Nested Loop  (cost=340.63..2708.94 rows=1 width=82)
        Join Filter: ((t.id = mi_idx.movie_id) AND (it.id = mi_idx.info_type_id))
        ->  Nested Loop  (cost=340.20..2708.41 rows=1 width=93)
              ->  Nested Loop  (cost=340.07..2708.23 rows=1 width=97)
                    Join Filter: (ml.movie_id = t1.id)
                    ->  Nested Loop  (cost=339.64..2707.71 rows=1 width=88)
                          ->  Nested Loop  (cost=339.22..2707.26 rows=1 width=73)
                                ->  Nested Loop  (cost=338.79..2705.80 rows=1 width=65)
                                      ->  Nested Loop  (cost=338.66..2705.63 rows=1 width=69)
                                            ->  Nested Loop  (cost=338.23..2697.23 rows=2 width=44)
                                                  ->  Index Scan using info_type_pkey on info_type it  (cost=0.14..14.12 rows=1 width=4)
                                                        Filter: ((info)::text = 'rating'::text)
                                                  ->  Nested Loop  (cost=338.08..2683.09 rows=2 width=40)
                                                        ->  Nested Loop  (cost=337.66..2579.27 rows=233 width=25)
                                                              Join Filter: (ml.movie_id = mc1.movie_id)
                                                              ->  Hash Join  (cost=337.23..2548.48 rows=47 width=17)
                                                                    Hash Cond: (mi_idx1.info_type_id = it1.id)
                                                                    ->  Merge Join  (cost=334.81..2531.49 rows=5350 width=21)
                                                                          Merge Cond: (mi_idx1.movie_id = ml.movie_id)
                                                                          ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx1  (cost=0.43..43814.65 rows=1380035 width=13)
                                                                          ->  Sort  (cost=334.38..338.55 rows=1666 width=8)
                                                                                Sort Key: ml.movie_id
                                                                                ->  Nested Loop  (cost=38.82..245.23 rows=1666 width=8)
                                                                                      ->  Seq Scan on link_type lt  (cost=0.00..1.23 rows=1 width=4)
                                                                                            Filter: ((link)::text ~~ '%follow%'::text)
                                                                                      ->  Bitmap Heap Scan on movie_link ml  (cost=38.82..225.26 rows=1875 width=12)
                                                                                            Recheck Cond: (link_type_id = lt.id)
                                                                                            ->  Bitmap Index Scan on link_type_id_movie_link  (cost=0.00..38.35 rows=1875 width=0)
                                                                                                  Index Cond: (link_type_id = lt.id)
                                                                    ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                                                          ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
                                                                                Filter: ((info)::text = 'rating'::text)
                                                              ->  Index Scan using movie_id_movie_companies on movie_companies mc1  (cost=0.43..0.59 rows=5 width=8)
                                                                    Index Cond: (movie_id = mi_idx1.movie_id)
                                                        ->  Index Scan using company_name_pkey on company_name cn1  (cost=0.42..0.45 rows=1 width=23)
                                                              Index Cond: (id = mc1.company_id)
                                                              Filter: ((country_code)::text = '[nl]'::text)
                                            ->  Index Scan using title_pkey on title t  (cost=0.43..4.20 rows=1 width=25)
                                                  Index Cond: (id = ml.linked_movie_id)
                                                  Filter: (production_year = 2007)
                                      ->  Index Scan using kind_type_pkey on kind_type kt  (cost=0.13..0.15 rows=1 width=4)
                                            Index Cond: (id = t.kind_id)
                                            Filter: ((kind)::text = 'tv series'::text)
                                ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..1.41 rows=5 width=8)
                                      Index Cond: (movie_id = t.id)
                          ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.44 rows=1 width=23)
                                Index Cond: (id = mc.company_id)
                    ->  Index Scan using title_pkey on title t1  (cost=0.43..0.51 rows=1 width=25)
                          Index Cond: (id = mc1.movie_id)
              ->  Index Scan using kind_type_pkey on kind_type kt1  (cost=0.13..0.15 rows=1 width=4)
                    Index Cond: (id = t1.kind_id)
                    Filter: ((kind)::text = 'tv series'::text)
        ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.51 rows=2 width=13)
              Index Cond: (movie_id = mc.movie_id)
              Filter: ((info)::text < '3.0'::text)
