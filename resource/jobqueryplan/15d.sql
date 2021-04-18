SELECT MIN(at.title) AS aka_title,
       MIN(t.title) AS internet_movie_title
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


Finalize Aggregate  (cost=241361.59..241361.60 rows=1 width=64)
  ->  Gather  (cost=241361.37..241361.58 rows=2 width=64)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=240361.37..240361.38 rows=1 width=64)
              ->  Nested Loop  (cost=6.07..240352.63 rows=1747 width=38)
                    Join Filter: (t.id = at.movie_id)
                    ->  Nested Loop  (cost=5.65..239998.77 rows=682 width=33)
                          ->  Nested Loop  (cost=5.23..239699.60 rows=682 width=37)
                                ->  Hash Join  (cost=4.80..239608.36 rows=52 width=29)
                                      Hash Cond: (mc.company_type_id = ct.id)
                                      ->  Nested Loop  (cost=3.71..239606.99 rows=52 width=33)
                                            ->  Nested Loop  (cost=3.29..239542.82 rows=144 width=37)
                                                  ->  Nested Loop  (cost=2.86..239524.64 rows=29 width=25)
                                                        ->  Hash Join  (cost=2.43..239268.80 rows=42 width=4)
                                                              Hash Cond: (mi.info_type_id = it1.id)
                                                              ->  Parallel Seq Scan on movie_info mi  (cost=0.00..239253.38 rows=4775 width=8)
                                                                    Filter: ((note)::text ~~ '%internet%'::text)
                                                              ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                                                    ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
                                                                          Filter: ((info)::text = 'release dates'::text)
                                                        ->  Index Scan using title_pkey on title t  (cost=0.43..6.09 rows=1 width=21)
                                                              Index Cond: (id = mi.movie_id)
                                                              Filter: (production_year > 1990)
                                                  ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.58 rows=5 width=12)
                                                        Index Cond: (movie_id = t.id)
                                            ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.45 rows=1 width=4)
                                                  Index Cond: (id = mc.company_id)
                                                  Filter: ((country_code)::text = '[us]'::text)
                                      ->  Hash  (cost=1.04..1.04 rows=4 width=4)
                                            ->  Seq Scan on company_type ct  (cost=0.00..1.04 rows=4 width=4)
                                ->  Index Scan using movie_id_movie_keyword on movie_keyword mk  (cost=0.43..1.30 rows=45 width=8)
                                      Index Cond: (movie_id = t.id)
                          ->  Index Only Scan using keyword_pkey on keyword k  (cost=0.42..0.44 rows=1 width=4)
                                Index Cond: (id = mk.keyword_id)
                    ->  Index Scan using movie_id_aka_title on aka_title at  (cost=0.42..0.48 rows=3 width=25)
                          Index Cond: (movie_id = mk.movie_id)
