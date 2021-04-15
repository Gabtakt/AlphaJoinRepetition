SELECT MIN(mi.info) AS budget,
       MIN(t.title) AS unsuccsessful_movie
FROM company_name AS cn,
     company_type AS ct,
     info_type AS it1,
     info_type AS it,
     movie_companies AS mc,
     movie_info AS mi,
     movie_info_idx AS mi_idx,
     title AS t
WHERE cn.country_code ='[us]'
  AND ct.kind IS NOT NULL
  AND (ct.kind = 'production companies'
       OR ct.kind = 'distributors')
  AND it1.info = 'budget'
  AND it.info = 'bottom 10 rank'
  AND t.production_year > 2000
  AND (t.title LIKE 'Birdemic%'
       OR t.title LIKE '%Movie%')
  AND t.id = mi.movie_id
  AND t.id = mi_idx.movie_id
  AND mi.info_type_id = it1.id
  AND mi_idx.info_type_id = it.id
  AND t.id = mc.movie_id
  AND ct.id = mc.company_type_id
  AND cn.id = mc.company_id
  AND mc.movie_id = mi.movie_id
  AND mc.movie_id = mi_idx.movie_id
  AND mi.movie_id = mi_idx.movie_id;



Aggregate  (cost=19208.40..19208.41 rows=1 width=64)
  ->  Gather  (cost=1006.70..19208.40 rows=1 width=60)
        Workers Planned: 2
        ->  Hash Join  (cost=6.70..18208.30 rows=1 width=60)
              Hash Cond: (mi.info_type_id = it1.id)
              ->  Nested Loop  (cost=4.27..18205.83 rows=16 width=64)
                    Join Filter: (t.id = mi.movie_id)
                    ->  Nested Loop  (cost=3.84..18203.79 rows=1 width=29)
                          ->  Nested Loop  (cost=3.42..18203.35 rows=1 width=33)
                                ->  Nested Loop  (cost=3.29..18203.03 rows=2 width=37)
                                      Join Filter: (t.id = mc.movie_id)
                                      ->  Nested Loop  (cost=2.86..18202.37 rows=1 width=25)
                                            ->  Hash Join  (cost=2.43..15253.60 rows=5089 width=4)
                                                  Hash Cond: (mi_idx.info_type_id = it.id)
                                                  ->  Parallel Seq Scan on movie_info_idx mi_idx  (cost=0.00..13685.15 rows=575015 width=8)
                                                  ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                                        ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                              Filter: ((info)::text = 'bottom 10 rank'::text)
                                            ->  Index Scan using title_pkey on title t  (cost=0.43..0.58 rows=1 width=21)
                                                  Index Cond: (id = mi_idx.movie_id)
                                                  Filter: ((production_year > 2000) AND (((title)::text ~~ 'Birdemic%'::text) OR ((title)::text ~~ '%Movie%'::text)))
                                      ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.59 rows=5 width=12)
                                            Index Cond: (movie_id = mi_idx.movie_id)
                                ->  Index Scan using company_type_pkey on company_type ct  (cost=0.13..0.15 rows=1 width=4)
                                      Index Cond: (id = mc.company_type_id)
                                      Filter: ((kind IS NOT NULL) AND (((kind)::text = 'production companies'::text) OR ((kind)::text = 'distributors'::text)))
                          ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.45 rows=1 width=4)
                                Index Cond: (id = mc.company_id)
                                Filter: ((country_code)::text = '[us]'::text)
                    ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..1.50 rows=43 width=51)
                          Index Cond: (movie_id = mc.movie_id)
              ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                    ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
                          Filter: ((info)::text = 'budget'::text)
