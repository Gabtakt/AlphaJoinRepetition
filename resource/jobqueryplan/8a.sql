SELECT MIN(an.name) AS actress_pseudonym,
       MIN(t.title) AS japanese_movie_dubbed
FROM aka_name AS an,
     cast_info AS ci,
     company_name AS cn,
     movie_companies AS mc,
     name AS n,
     role_type AS rt,
     title AS t
WHERE ci.note = '(voice: English version)'
  AND cn.country_code = '[jp]'
  AND mc.note LIKE '%(Japan)%'
  AND mc.note NOT LIKE '%(USA)%'
  AND n.name LIKE '%Yo%'
  AND n.name NOT LIKE '%Yu%'
  AND rt.role = 'actress'
  AND an.person_id = n.id
  AND n.id = ci.person_id
  AND ci.movie_id = t.id
  AND t.id = mc.movie_id
  AND mc.company_id = cn.id
  AND ci.role_id = rt.id
  AND an.person_id = ci.person_id
  AND ci.movie_id = mc.movie_id;



Aggregate  (cost=41668.34..41668.35 rows=1 width=64)
  ->  Gather  (cost=5776.21..41668.33 rows=1 width=33)
        Workers Planned: 2
        ->  Nested Loop  (cost=4776.21..40668.23 rows=1 width=33)
              ->  Nested Loop  (cost=4775.78..40666.73 rows=2 width=41)
                    ->  Hash Join  (cost=4775.35..40665.66 rows=1 width=21)
                          Hash Cond: (ci.role_id = rt.id)
                          ->  Nested Loop  (cost=4774.19..40664.46 rows=9 width=25)
                                ->  Nested Loop  (cost=4773.62..40490.38 rows=92 width=25)
                                      ->  Parallel Hash Join  (cost=4773.19..39878.56 rows=92 width=4)
                                            Hash Cond: (mc.company_id = cn.id)
                                            ->  Parallel Seq Scan on movie_companies mc  (cost=0.00..35097.06 rows=3167 width=8)
                                                  Filter: (((note)::text ~~ '%(Japan)%'::text) AND ((note)::text !~~ '%(USA)%'::text))
                                            ->  Parallel Hash  (cost=4722.92..4722.92 rows=4022 width=4)
                                                  ->  Parallel Seq Scan on company_name cn  (cost=0.00..4722.92 rows=4022 width=4)
                                                        Filter: ((country_code)::text = '[jp]'::text)
                                      ->  Index Scan using title_pkey on title t  (cost=0.43..6.65 rows=1 width=21)
                                            Index Cond: (id = mc.movie_id)
                                ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..1.88 rows=1 width=12)
                                      Index Cond: (movie_id = t.id)
                                      Filter: ((note)::text = '(voice: English version)'::text)
                          ->  Hash  (cost=1.15..1.15 rows=1 width=4)
                                ->  Seq Scan on role_type rt  (cost=0.00..1.15 rows=1 width=4)
                                      Filter: ((role)::text = 'actress'::text)
                    ->  Index Scan using person_id_aka_name on aka_name an  (cost=0.42..1.06 rows=2 width=20)
                          Index Cond: (person_id = ci.person_id)
              ->  Index Scan using name_pkey on name n  (cost=0.43..0.75 rows=1 width=4)
                    Index Cond: (id = an.person_id)
                    Filter: (((name)::text ~~ '%Yo%'::text) AND ((name)::text !~~ '%Yu%'::text))
