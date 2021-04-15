SELECT MIN(cn.name) AS company_name,
       MIN(lt.link) AS link_type,
       MIN(t.title) AS western_follow_up
FROM company_name AS cn,
     company_type AS ct,
     keyword AS k,
     link_type AS lt,
     movie_companies AS mc,
     movie_info AS mi,
     movie_keyword AS mk,
     movie_link AS ml,
     title AS t
WHERE cn.country_code != '[pl]'
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
                  'German')
  AND t.production_year BETWEEN 1950 AND 2000
  AND lt.id = ml.link_type_id
  AND ml.movie_id = t.id
  AND t.id = mk.movie_id
  AND mk.keyword_id = k.id
  AND t.id = mc.movie_id
  AND mc.company_type_id = ct.id
  AND mc.company_id = cn.id
  AND mi.movie_id = t.id
  AND ml.movie_id = mk.movie_id
  AND ml.movie_id = mc.movie_id
  AND mk.movie_id = mc.movie_id
  AND ml.movie_id = mi.movie_id
  AND mk.movie_id = mi.movie_id
  AND mc.movie_id = mi.movie_id;



Aggregate  (cost=3767.25..3767.26 rows=1 width=96)
  ->  Nested Loop  (cost=8.78..3767.24 rows=1 width=48)
        Join Filter: (ml.movie_id = t.id)
        ->  Nested Loop  (cost=8.35..3766.74 rows=1 width=47)
              Join Filter: (ml.movie_id = mi.movie_id)
              ->  Nested Loop  (cost=7.92..3764.93 rows=1 width=43)
                    Join Filter: (mc.company_type_id = ct.id)
                    ->  Nested Loop  (cost=7.92..3763.87 rows=1 width=47)
                          ->  Nested Loop  (cost=7.50..3763.41 rows=1 width=32)
                                Join Filter: (ml.movie_id = mc.movie_id)
                                ->  Nested Loop  (cost=7.07..3762.85 rows=1 width=20)
                                      Join Filter: (ml.link_type_id = lt.id)
                                      ->  Seq Scan on link_type lt  (cost=0.00..1.23 rows=1 width=16)
                                            Filter: ((link)::text ~~ '%follow%'::text)
                                      ->  Nested Loop  (cost=7.07..3761.50 rows=10 width=12)
                                            ->  Nested Loop  (cost=6.78..3747.04 rows=34 width=4)
                                                  ->  Seq Scan on keyword k  (cost=0.00..2626.12 rows=1 width=4)
                                                        Filter: ((keyword)::text = 'sequel'::text)
                                                  ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1117.89 rows=303 width=8)
                                                        Recheck Cond: (keyword_id = k.id)
                                                        ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                              Index Cond: (keyword_id = k.id)
                                            ->  Index Scan using movie_id_movie_link on movie_link ml  (cost=0.29..0.38 rows=5 width=8)
                                                  Index Cond: (movie_id = mk.movie_id)
                                ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.54 rows=2 width=12)
                                      Index Cond: (movie_id = mk.movie_id)
                                      Filter: (note IS NULL)
                          ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.46 rows=1 width=23)
                                Index Cond: (id = mc.company_id)
                                Filter: (((country_code)::text <> '[pl]'::text) AND (((name)::text ~~ '%Film%'::text) OR ((name)::text ~~ '%Warner%'::text)))
                    ->  Seq Scan on company_type ct  (cost=0.00..1.05 rows=1 width=4)
                          Filter: ((kind)::text = 'production companies'::text)
              ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..1.80 rows=1 width=4)
                    Index Cond: (movie_id = mk.movie_id)
                    Filter: ((info)::text = ANY ('{Sweden,Norway,Germany,Denmark,Swedish,Denish,Norwegian,German}'::text[]))
        ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=21)
              Index Cond: (id = mk.movie_id)
              Filter: ((production_year >= 1950) AND (production_year <= 2000))
