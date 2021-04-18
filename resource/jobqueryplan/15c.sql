SELECT MIN(mi.info) AS release_date,
       MIN(t.title) AS modern_american_internet_movie
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
  AND it1.info = 'release dates'
  AND mi.note LIKE '%internet%'
  AND mi.info IS NOT NULL
  AND (mi.info LIKE 'USA:% 199%'
       OR mi.info LIKE 'USA:% 200%')
  AND t.production_year > 1990
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


Finalize Aggregate  (cost=271195.20..271195.21 rows=1 width=64)
  ->  Gather  (cost=271194.98..271195.19 rows=2 width=64)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=270194.98..270194.99 rows=1 width=64)
              ->  Nested Loop  (cost=5.11..270194.75 rows=46 width=60)
                    Join Filter: (t.id = at.movie_id)
                    ->  Nested Loop  (cost=4.69..270184.90 rows=19 width=76)
                          ->  Nested Loop  (cost=4.27..270176.56 rows=19 width=80)
                                ->  Nested Loop  (cost=3.84..270174.81 rows=1 width=72)
                                      ->  Nested Loop  (cost=3.71..270174.65 rows=1 width=76)
                                            ->  Nested Loop  (cost=3.29..270172.87 rows=4 width=80)
                                                  ->  Nested Loop  (cost=2.86..270172.24 rows=1 width=68)
                                                        ->  Hash Join  (cost=2.43..270163.89 rows=1 width=47)
                                                              Hash Cond: (mi.info_type_id = it1.id)
                                                              ->  Parallel Seq Scan on movie_info mi  (cost=0.00..270161.12 rows=124 width=51)
                                                                    Filter: ((info IS NOT NULL) AND ((note)::text ~~ '%internet%'::text) AND (((info)::text ~~ 'USA:% 199%'::text) OR ((info)::text ~~ 'USA:% 200%'::text)))
                                                              ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                                                    ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
                                                                          Filter: ((info)::text = 'release dates'::text)
                                                        ->  Index Scan using title_pkey on title t  (cost=0.43..8.36 rows=1 width=21)
                                                              Index Cond: (id = mi.movie_id)
                                                              Filter: (production_year > 1990)
                                                  ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.58 rows=5 width=12)
                                                        Index Cond: (movie_id = t.id)
                                            ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.45 rows=1 width=4)
                                                  Index Cond: (id = mc.company_id)
                                                  Filter: ((country_code)::text = '[us]'::text)
                                      ->  Index Only Scan using company_type_pkey on company_type ct  (cost=0.13..0.15 rows=1 width=4)
                                            Index Cond: (id = mc.company_type_id)
                                ->  Index Scan using movie_id_movie_keyword on movie_keyword mk  (cost=0.43..1.30 rows=45 width=8)
                                      Index Cond: (movie_id = t.id)
                          ->  Index Only Scan using keyword_pkey on keyword k  (cost=0.42..0.44 rows=1 width=4)
                                Index Cond: (id = mk.keyword_id)
                    ->  Index Only Scan using movie_id_aka_title on aka_title at  (cost=0.42..0.48 rows=3 width=4)
                          Index Cond: (movie_id = mk.movie_id)
