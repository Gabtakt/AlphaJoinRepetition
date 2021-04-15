SELECT MIN(cn.name) AS producing_company,
       MIN(lt.link) AS link_type,
       MIN(t.title) AS complete_western_sequel
FROM complete_cast AS cc,
     comp_cast_type AS cct1,
     comp_cast_type AS cct2,
     company_name AS cn,
     company_type AS ct,
     keyword AS k,
     link_type AS lt,
     movie_companies AS mc,
     movie_info AS mi,
     movie_keyword AS mk,
     movie_link AS ml,
     title AS t
WHERE cct1.kind = 'cast'
  AND cct2.kind LIKE 'complete%'
  AND cn.country_code != '[pl]'
  AND (cn.name LIKE '%Film%'
       OR cn.name LIKE '%Warner%')
  AND ct.kind = 'production companies'
  AND k.keyword = 'sequel'
  AND lt.link LIKE '%follow%'
  AND mc.note IS NULL
  AND mi.info IN ('Sweden',
                  'Norway',
                  'Germany',
                  'Denmark',
                  'Swedish',
                  'Denish',
                  'Norwegian',
                  'German',
                  'English')
  AND t.production_year BETWEEN 1950 AND 2010
  AND lt.id = ml.link_type_id
  AND ml.movie_id = t.id
  AND t.id = mk.movie_id
  AND mk.keyword_id = k.id
  AND t.id = mc.movie_id
  AND mc.company_type_id = ct.id
  AND mc.company_id = cn.id
  AND mi.movie_id = t.id
  AND t.id = cc.movie_id
  AND cct1.id = cc.subject_id
  AND cct2.id = cc.status_id
  AND ml.movie_id = mk.movie_id
  AND ml.movie_id = mc.movie_id
  AND mk.movie_id = mc.movie_id
  AND ml.movie_id = mi.movie_id
  AND mk.movie_id = mi.movie_id
  AND mc.movie_id = mi.movie_id
  AND ml.movie_id = cc.movie_id
  AND mk.movie_id = cc.movie_id
  AND mc.movie_id = cc.movie_id
  AND mi.movie_id = cc.movie_id;



Aggregate  (cost=2082.72..2082.73 rows=1 width=96)
  ->  Nested Loop  (cost=4.76..2082.69 rows=3 width=48)
        Join Filter: (ml.movie_id = mi.movie_id)
        ->  Nested Loop  (cost=4.32..2080.81 rows=1 width=68)
              ->  Nested Loop  (cost=3.90..2080.35 rows=1 width=53)
                    ->  Nested Loop  (cost=3.48..1844.74 rows=534 width=57)
                          Join Filter: (ml.movie_id = mk.movie_id)
                          ->  Nested Loop  (cost=3.05..1822.42 rows=12 width=49)
                                Join Filter: (ml.movie_id = t.id)
                                ->  Nested Loop  (cost=2.62..1812.82 rows=16 width=28)
                                      Join Filter: (mc.company_type_id = ct.id)
                                      ->  Nested Loop  (cost=2.62..1810.79 rows=65 width=32)
                                            Join Filter: (ml.link_type_id = lt.id)
                                            ->  Merge Join  (cost=2.62..1792.09 rows=1165 width=24)
                                                  Merge Cond: (mc.movie_id = ml.movie_id)
                                                  ->  Nested Loop  (cost=0.85..19898.19 rows=20428 width=16)
                                                        ->  Nested Loop  (cost=0.42..8871.98 rows=8443 width=4)
                                                              Join Filter: (cct2.id = cc.status_id)
                                                              ->  Nested Loop  (cost=0.42..8364.34 rows=33772 width=8)
                                                                    Join Filter: (cct1.id = cc.subject_id)
                                                                    ->  Index Scan using movie_id_complete_cast on complete_cast cc  (cost=0.42..6337.00 rows=135086 width=12)
                                                                    ->  Materialize  (cost=0.00..1.05 rows=1 width=4)
                                                                          ->  Seq Scan on comp_cast_type cct1  (cost=0.00..1.05 rows=1 width=4)
                                                                                Filter: ((kind)::text = 'cast'::text)
                                                              ->  Materialize  (cost=0.00..1.05 rows=1 width=4)
                                                                    ->  Seq Scan on comp_cast_type cct2  (cost=0.00..1.05 rows=1 width=4)
                                                                          Filter: ((kind)::text ~~ 'complete%'::text)
                                                        ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..1.29 rows=2 width=12)
                                                              Index Cond: (movie_id = cc.movie_id)
                                                              Filter: (note IS NULL)
                                                  ->  Index Scan using movie_id_movie_link on movie_link ml  (cost=0.29..959.51 rows=29997 width=8)
                                            ->  Materialize  (cost=0.00..1.23 rows=1 width=16)
                                                  ->  Seq Scan on link_type lt  (cost=0.00..1.23 rows=1 width=16)
                                                        Filter: ((link)::text ~~ '%follow%'::text)
                                      ->  Materialize  (cost=0.00..1.05 rows=1 width=4)
                                            ->  Seq Scan on company_type ct  (cost=0.00..1.05 rows=1 width=4)
                                                  Filter: ((kind)::text = 'production companies'::text)
                                ->  Index Scan using title_pkey on title t  (cost=0.43..0.59 rows=1 width=21)
                                      Index Cond: (id = mc.movie_id)
                                      Filter: ((production_year >= 1950) AND (production_year <= 2010))
                          ->  Index Scan using movie_id_movie_keyword on movie_keyword mk  (cost=0.43..1.30 rows=45 width=8)
                                Index Cond: (movie_id = t.id)
                    ->  Index Scan using keyword_pkey on keyword k  (cost=0.42..0.44 rows=1 width=4)
                          Index Cond: (id = mk.keyword_id)
                          Filter: ((keyword)::text = 'sequel'::text)
              ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.46 rows=1 width=23)
                    Index Cond: (id = mc.company_id)
                    Filter: (((country_code)::text <> '[pl]'::text) AND (((name)::text ~~ '%Film%'::text) OR ((name)::text ~~ '%Warner%'::text)))
        ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..1.85 rows=3 width=4)
              Index Cond: (movie_id = mk.movie_id)
              Filter: ((info)::text = ANY ('{Sweden,Norway,Germany,Denmark,Swedish,Denish,Norwegian,German,English}'::text[]))
