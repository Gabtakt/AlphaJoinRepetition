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
WHERE cct1.kind IN ('cast',
                    'crew')
  AND cct2.kind = 'complete'
  AND cn.country_code != '[pl]'
  AND (cn.name LIKE '%Film%'
       OR cn.name LIKE '%Warner%')
  AND ct.kind = 'production companies'
  AND k.keyword = 'sequel'
  AND lt.link LIKE '%follow%'
  AND mc.note IS NULL
  AND mi.info IN ('Sweden',
                  'Germany',
                  'Swedish',
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



Aggregate  (cost=2527.82..2527.83 rows=1 width=96)
  ->  Nested Loop  (cost=340.58..2527.81 rows=1 width=48)
        ->  Nested Loop  (cost=340.16..2449.26 rows=178 width=52)
              Join Filter: (ml.movie_id = mk.movie_id)
              ->  Hash Join  (cost=339.73..2441.67 rows=4 width=68)
                    Hash Cond: (cc.subject_id = cct1.id)
                    ->  Nested Loop  (cost=338.65..2440.55 rows=9 width=72)
                          Join Filter: (ml.movie_id = t.id)
                          ->  Nested Loop  (cost=338.22..2425.55 rows=25 width=51)
                                Join Filter: (ml.movie_id = mi.movie_id)
                                ->  Hash Join  (cost=337.79..2283.96 rows=69 width=47)
                                      Hash Cond: (mc.company_type_id = ct.id)
                                      ->  Nested Loop  (cost=336.73..2281.41 rows=275 width=51)
                                            ->  Nested Loop  (cost=336.31..1550.18 rows=1602 width=36)
                                                  Join Filter: (ml.movie_id = mc.movie_id)
                                                  ->  Hash Join  (cost=335.88..682.32 rows=662 width=24)
                                                        Hash Cond: (cc.status_id = cct2.id)
                                                        ->  Merge Join  (cost=334.81..666.95 rows=2647 width=28)
                                                              Merge Cond: (cc.movie_id = ml.movie_id)
                                                              ->  Index Scan using movie_id_complete_cast on complete_cast cc  (cost=0.42..6337.00 rows=135086 width=12)
                                                              ->  Sort  (cost=334.38..338.55 rows=1666 width=16)
                                                                    Sort Key: ml.movie_id
                                                                    ->  Nested Loop  (cost=38.82..245.23 rows=1666 width=16)
                                                                          ->  Seq Scan on link_type lt  (cost=0.00..1.23 rows=1 width=16)
                                                                                Filter: ((link)::text ~~ '%follow%'::text)
                                                                          ->  Bitmap Heap Scan on movie_link ml  (cost=38.82..225.26 rows=1875 width=8)
                                                                                Recheck Cond: (link_type_id = lt.id)
                                                                                ->  Bitmap Index Scan on link_type_id_movie_link  (cost=0.00..38.35 rows=1875 width=0)
                                                                                      Index Cond: (link_type_id = lt.id)
                                                        ->  Hash  (cost=1.05..1.05 rows=1 width=4)
                                                              ->  Seq Scan on comp_cast_type cct2  (cost=0.00..1.05 rows=1 width=4)
                                                                    Filter: ((kind)::text = 'complete'::text)
                                                  ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..1.29 rows=2 width=12)
                                                        Index Cond: (movie_id = cc.movie_id)
                                                        Filter: (note IS NULL)
                                            ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.46 rows=1 width=23)
                                                  Index Cond: (id = mc.company_id)
                                                  Filter: (((country_code)::text <> '[pl]'::text) AND (((name)::text ~~ '%Film%'::text) OR ((name)::text ~~ '%Warner%'::text)))
                                      ->  Hash  (cost=1.05..1.05 rows=1 width=4)
                                            ->  Seq Scan on company_type ct  (cost=0.00..1.05 rows=1 width=4)
                                                  Filter: ((kind)::text = 'production companies'::text)
                                ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..2.04 rows=1 width=4)
                                      Index Cond: (movie_id = mc.movie_id)
                                      Filter: ((info)::text = ANY ('{Sweden,Germany,Swedish,German}'::text[]))
                          ->  Index Scan using title_pkey on title t  (cost=0.43..0.59 rows=1 width=21)
                                Index Cond: (id = mc.movie_id)
                                Filter: ((production_year >= 1950) AND (production_year <= 2000))
                    ->  Hash  (cost=1.05..1.05 rows=2 width=4)
                          ->  Seq Scan on comp_cast_type cct1  (cost=0.00..1.05 rows=2 width=4)
                                Filter: ((kind)::text = ANY ('{cast,crew}'::text[]))
              ->  Index Scan using movie_id_movie_keyword on movie_keyword mk  (cost=0.43..1.34 rows=45 width=8)
                    Index Cond: (movie_id = mc.movie_id)
        ->  Index Scan using keyword_pkey on keyword k  (cost=0.42..0.44 rows=1 width=4)
              Index Cond: (id = mk.keyword_id)
              Filter: ((keyword)::text = 'sequel'::text)
