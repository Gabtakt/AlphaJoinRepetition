SELECT MIN(mi.info) AS release_date,
       MIN(t.title) AS youtube_movie
FROM aka_title AS AT,
     company_name AS cn,
     company_type AS ct,
     info_type AS it1,
     keyword AS k,
     movie_companies AS mc,
     movie_info AS mi,
     movie_keyword AS mk,
     title AS t
WHERE cn.country_code = '[us]'
  AND cn.name = 'YouTube'
  AND it1.info = 'release dates'
  AND mc.note LIKE '%(200%)%'
  AND mc.note LIKE '%(worldwide)%'
  AND mi.note LIKE '%internet%'
  AND mi.info LIKE 'USA:% 200%'
  AND t.production_year BETWEEN 2005 AND 2010
  AND t.id = at.movie_id
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND t.id = mc.movie_id
  AND mk.movie_id = mi.movie_id
  AND mk.movie_id = mc.movie_id
  AND mk.movie_id = at.movie_id
  AND mi.movie_id = mc.movie_id
  AND mi.movie_id = at.movie_id
  AND mc.movie_id = at.movie_id
  AND k.id = mk.keyword_id
  AND it1.id = mi.info_type_id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id;


Finalize Aggregate  (cost=6435.24..6435.25 rows=1 width=64)
  ->  Gather  (cost=6435.12..6435.23 rows=1 width=64)
        Workers Planned: 1
        ->  Partial Aggregate  (cost=5435.12..5435.13 rows=1 width=64)
              ->  Nested Loop  (cost=2.84..5435.10 rows=5 width=60)
                    ->  Nested Loop  (cost=2.42..5432.90 rows=5 width=64)
                          ->  Nested Loop  (cost=1.99..5431.02 rows=1 width=76)
                                ->  Nested Loop  (cost=1.85..5430.71 rows=1 width=80)
                                      ->  Nested Loop  (cost=1.41..5428.14 rows=1 width=29)
                                            ->  Nested Loop  (cost=0.98..5427.22 rows=1 width=8)
                                                  ->  Nested Loop  (cost=0.85..5427.06 rows=1 width=12)
                                                        ->  Nested Loop  (cost=0.43..5425.37 rows=1 width=8)
                                                              ->  Parallel Seq Scan on company_name cn  (cost=0.00..5068.50 rows=1 width=4)
                                                                    Filter: (((country_code)::text = '[us]'::text) AND ((name)::text = 'YouTube'::text))
                                                              ->  Index Scan using company_id_movie_companies on movie_companies mc  (cost=0.43..356.86 rows=1 width=12)
                                                                    Index Cond: (company_id = cn.id)
                                                                    Filter: (((note)::text ~~ '%(200%)%'::text) AND ((note)::text ~~ '%(worldwide)%'::text))
                                                        ->  Index Only Scan using movie_id_aka_title on aka_title at  (cost=0.42..1.66 rows=3 width=4)
                                                              Index Cond: (movie_id = mc.movie_id)
                                                  ->  Index Only Scan using company_type_pkey on company_type ct  (cost=0.13..0.15 rows=1 width=4)
                                                        Index Cond: (id = mc.company_type_id)
                                            ->  Index Scan using title_pkey on title t  (cost=0.43..0.93 rows=1 width=21)
                                                  Index Cond: (id = at.movie_id)
                                                  Filter: ((production_year >= 2005) AND (production_year <= 2010))
                                      ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..2.55 rows=1 width=51)
                                            Index Cond: (movie_id = t.id)
                                            Filter: (((note)::text ~~ '%internet%'::text) AND ((info)::text ~~ 'USA:% 200%'::text))
                                ->  Index Scan using info_type_pkey on info_type it1  (cost=0.14..0.23 rows=1 width=4)
                                      Index Cond: (id = mi.info_type_id)
                                      Filter: ((info)::text = 'release dates'::text)
                          ->  Index Scan using movie_id_movie_keyword on movie_keyword mk  (cost=0.43..1.43 rows=45 width=8)
                                Index Cond: (movie_id = t.id)
                    ->  Index Only Scan using keyword_pkey on keyword k  (cost=0.42..0.44 rows=1 width=4)
                          Index Cond: (id = mk.keyword_id)
