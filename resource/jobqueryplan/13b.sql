SELECT MIN(cn.name) AS producing_company,
       MIN(mi_idx.info) AS rating,
       MIN(t.title) AS movie_about_winning
FROM company_name AS cn,
     company_type AS ct,
     info_type AS it,
     info_type AS it1,
     kind_type AS kt,
     movie_companies AS mc,
     movie_info AS mi,
     movie_info_idx AS mi_idx,
     title AS t
WHERE cn.country_code = '[us]'
  AND ct.kind = 'production companies'
  AND it.info = 'rating'
  AND it1.info = 'release dates'
  AND kt.kind = 'movie'
  AND t.title != ''
  AND (t.title LIKE '%Champion%'
       OR t.title LIKE '%Loser%')
  AND mi.movie_id = t.id
  AND it1.id = mi.info_type_id
  AND kt.id = t.kind_id
  AND mc.movie_id = t.id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id
  AND mi_idx.movie_id = t.id
  AND it.id = mi_idx.info_type_id
  AND mi.movie_id = mi_idx.movie_id
  AND mi.movie_id = mc.movie_id
  AND mi_idx.movie_id = mc.movie_id;



Aggregate  (cost=19206.36..19206.37 rows=1 width=96)
  ->  Gather  (cost=1004.54..19206.35 rows=1 width=41)
        Workers Planned: 2
        ->  Nested Loop  (cost=4.54..18206.25 rows=1 width=41)
              ->  Nested Loop  (cost=4.40..18205.90 rows=2 width=45)
                    Join Filter: (t.id = mi.movie_id)
                    ->  Nested Loop  (cost=3.97..18203.87 rows=1 width=53)
                          ->  Nested Loop  (cost=3.84..18203.70 rows=1 width=57)
                                ->  Nested Loop  (cost=3.42..18203.25 rows=1 width=42)
                                      Join Filter: (t.id = mc.movie_id)
                                      ->  Nested Loop  (cost=2.99..18202.60 rows=1 width=30)
                                            ->  Nested Loop  (cost=2.86..18202.37 rows=1 width=34)
                                                  ->  Hash Join  (cost=2.43..15253.60 rows=5089 width=9)
                                                        Hash Cond: (mi_idx.info_type_id = it.id)
                                                        ->  Parallel Seq Scan on movie_info_idx mi_idx  (cost=0.00..13685.15 rows=575015 width=13)
                                                        ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                                              ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                                    Filter: ((info)::text = 'rating'::text)
                                                  ->  Index Scan using title_pkey on title t  (cost=0.43..0.58 rows=1 width=25)
                                                        Index Cond: (id = mi_idx.movie_id)
                                                        Filter: (((title)::text <> ''::text) AND (((title)::text ~~ '%Champion%'::text) OR ((title)::text ~~ '%Loser%'::text)))
                                            ->  Index Scan using kind_type_pkey on kind_type kt  (cost=0.13..0.18 rows=1 width=4)
                                                  Index Cond: (id = t.kind_id)
                                                  Filter: ((kind)::text = 'movie'::text)
                                      ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.59 rows=5 width=12)
                                            Index Cond: (movie_id = mi_idx.movie_id)
                                ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.45 rows=1 width=23)
                                      Index Cond: (id = mc.company_id)
                                      Filter: ((country_code)::text = '[us]'::text)
                          ->  Index Scan using company_type_pkey on company_type ct  (cost=0.13..0.15 rows=1 width=4)
                                Index Cond: (id = mc.company_type_id)
                                Filter: ((kind)::text = 'production companies'::text)
                    ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..1.50 rows=43 width=8)
                          Index Cond: (movie_id = mc.movie_id)
              ->  Index Scan using info_type_pkey on info_type it1  (cost=0.14..0.16 rows=1 width=4)
                    Index Cond: (id = mi.info_type_id)
                    Filter: ((info)::text = 'release dates'::text)
