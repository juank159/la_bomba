--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3 (Debian 15.3-1.pgdg120+1)
-- Dumped by pg_dump version 15.3 (Debian 15.3-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: credit_transactions_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.credit_transactions_type_enum AS ENUM (
    'debt_increase',
    'payment'
);


ALTER TYPE public.credit_transactions_type_enum OWNER TO postgres;

--
-- Name: credits_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.credits_status_enum AS ENUM (
    'pending',
    'paid'
);


ALTER TYPE public.credits_status_enum OWNER TO postgres;

--
-- Name: order_items_measurementunit_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_items_measurementunit_enum AS ENUM (
    'unidad',
    'bultos',
    'fardos',
    'cajas',
    'paquetes',
    'libras',
    'kilogramos',
    'litros',
    'metros',
    'docenas'
);


ALTER TYPE public.order_items_measurementunit_enum OWNER TO postgres;

--
-- Name: orders_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.orders_status_enum AS ENUM (
    'pending',
    'completed'
);


ALTER TYPE public.orders_status_enum OWNER TO postgres;

--
-- Name: product_update_tasks_changetype_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.product_update_tasks_changetype_enum AS ENUM (
    'price',
    'info',
    'inventory',
    'arrival'
);


ALTER TYPE public.product_update_tasks_changetype_enum OWNER TO postgres;

--
-- Name: product_update_tasks_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.product_update_tasks_status_enum AS ENUM (
    'pending',
    'completed',
    'expired'
);


ALTER TYPE public.product_update_tasks_status_enum OWNER TO postgres;

--
-- Name: users_role_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.users_role_enum AS ENUM (
    'admin',
    'supervisor',
    'employee'
);


ALTER TYPE public.users_role_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clients (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nombre character varying NOT NULL,
    celular character varying,
    email character varying,
    direccion character varying,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.clients OWNER TO postgres;

--
-- Name: credit_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.credit_transactions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    credit_id uuid NOT NULL,
    type public.credit_transactions_type_enum NOT NULL,
    amount numeric(10,2) NOT NULL,
    description text,
    created_by character varying,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.credit_transactions OWNER TO postgres;

--
-- Name: credits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.credits (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    description character varying NOT NULL,
    "totalAmount" numeric(10,2) NOT NULL,
    "paidAmount" numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    status public.credits_status_enum DEFAULT 'pending'::public.credits_status_enum NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    client_id uuid NOT NULL,
    created_by character varying,
    updated_by character varying,
    deleted_by character varying,
    deleted_at timestamp without time zone
);


ALTER TABLE public.credits OWNER TO postgres;

--
-- Name: expenses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expenses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    description character varying NOT NULL,
    amount numeric(10,2) NOT NULL,
    created_by uuid NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.expenses OWNER TO postgres;

--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    order_id uuid NOT NULL,
    product_id uuid NOT NULL,
    "existingQuantity" integer NOT NULL,
    "requestedQuantity" integer,
    "measurementUnit" public.order_items_measurementunit_enum DEFAULT 'unidad'::public.order_items_measurementunit_enum NOT NULL
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    description character varying NOT NULL,
    provider character varying,
    status public.orders_status_enum DEFAULT 'pending'::public.orders_status_enum NOT NULL,
    created_by uuid NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    credit_id uuid NOT NULL,
    amount numeric(10,2) NOT NULL,
    description character varying,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying,
    deleted_by character varying,
    deleted_at timestamp without time zone
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: product_update_tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_update_tasks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "productId" uuid NOT NULL,
    "changeType" public.product_update_tasks_changetype_enum DEFAULT 'price'::public.product_update_tasks_changetype_enum NOT NULL,
    "oldValue" jsonb,
    "newValue" jsonb,
    status public.product_update_tasks_status_enum DEFAULT 'pending'::public.product_update_tasks_status_enum NOT NULL,
    description character varying,
    "createdById" uuid NOT NULL,
    "completedById" uuid,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "completedAt" timestamp without time zone,
    notes character varying
);


ALTER TABLE public.product_update_tasks OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    description character varying NOT NULL,
    barcode character varying NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    precioa numeric(10,2) NOT NULL,
    preciob numeric(10,2),
    precioc numeric(10,2),
    costo numeric(10,2),
    iva numeric(5,2) DEFAULT '19'::numeric NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    description character varying NOT NULL,
    "isCompleted" boolean DEFAULT false NOT NULL,
    todo_id uuid NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tasks OWNER TO postgres;

--
-- Name: todos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.todos (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    description character varying NOT NULL,
    "isCompleted" boolean DEFAULT false NOT NULL,
    created_by uuid NOT NULL,
    assigned_to uuid,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.todos OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    username character varying NOT NULL,
    email character varying NOT NULL,
    password character varying NOT NULL,
    role public.users_role_enum DEFAULT 'employee'::public.users_role_enum NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clients (id, nombre, celular, email, direccion, "isActive", "createdAt", "updatedAt") FROM stdin;
30d1a9f9-c63e-4b09-bf23-e0f1e63012fd	max	\N	\N	\N	t	2025-10-18 02:05:13.224704	2025-10-18 02:05:13.224704
37ab77d5-4f19-470e-b344-0df1d34e6222	paola	\N	\N	\N	t	2025-10-18 04:04:51.317502	2025-10-18 04:04:51.317502
\.


--
-- Data for Name: credit_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credit_transactions (id, credit_id, type, amount, description, created_by, "createdAt") FROM stdin;
df7acdeb-7abd-48d8-a35a-3415261f5e37	d3c1b5e4-41dc-49db-bd4d-057725c7eb34	debt_increase	500000.00	pan y cafe	adalberto	2025-10-18 15:53:40.910367
bd62e6ed-1341-4426-86ac-120428c495a8	d3c1b5e4-41dc-49db-bd4d-057725c7eb34	debt_increase	100000.00	pastas	adalberto	2025-10-18 16:07:41.749813
ff794203-cedf-4115-9172-5941c8bf836c	d3c1b5e4-41dc-49db-bd4d-057725c7eb34	payment	200000.00	Pago	adalberto	2025-10-18 16:12:25.924586
d82c8e20-3bd5-4ef4-90a7-755461c8b520	d3c1b5e4-41dc-49db-bd4d-057725c7eb34	payment	1900000.00	pago total	adalberto	2025-10-18 16:13:07.554391
75044566-2a7c-4f41-8995-b15e9fdbd7e3	d6d6661c-c22a-4ee0-9aea-a56fad281292	debt_increase	100000.00	prestamo moto	adalberto	2025-10-18 16:13:55.046051
8706cfe0-ae3c-4418-a0b9-3599fa7ecb98	d6d6661c-c22a-4ee0-9aea-a56fad281292	debt_increase	100000.00	prestamo moto	adalberto	2025-10-18 16:14:02.604753
b53f3d7a-f0c2-4509-853e-8b93c0e4185c	d6d6661c-c22a-4ee0-9aea-a56fad281292	payment	100000.00	Pago	adalberto	2025-10-18 16:15:54.803453
1582a7a3-8257-4407-b0b4-c54e54d7d453	d6d6661c-c22a-4ee0-9aea-a56fad281292	payment	100000.00	Pago	adalberto	2025-10-18 16:16:05.277522
aab16cee-c0fc-48e0-864f-ca55c89bf5fd	d6d6661c-c22a-4ee0-9aea-a56fad281292	debt_increase	300000.00	pan y moras	adalberto	2025-10-18 16:17:19.714988
4f56c1fe-d3f5-4235-9287-52d4f9865176	d6d6661c-c22a-4ee0-9aea-a56fad281292	debt_increase	200000.00	verduras	adalberto	2025-10-18 16:24:39.702251
313cc45f-1c1d-4a40-b8e9-36e2ee81299c	d6d6661c-c22a-4ee0-9aea-a56fad281292	payment	100000.00	nequi	adalberto	2025-10-18 16:25:03.898457
fb7009b1-2387-40c0-a05f-7ccedc249565	d6d6661c-c22a-4ee0-9aea-a56fad281292	payment	700000.00	daviplata	adalberto	2025-10-18 16:25:56.864003
f700c004-10b9-47ba-874c-7266a474e436	d6d6661c-c22a-4ee0-9aea-a56fad281292	payment	700000.00	efectivo	adalberto	2025-10-18 16:27:58.610777
9de1c5c9-c341-4c20-a19a-43589cb47e2a	d6d6661c-c22a-4ee0-9aea-a56fad281292	debt_increase	300000.00	panes	adalberto	2025-10-18 16:28:15.33116
729f3922-4ac2-40b0-a539-298b06a1d121	d6d6661c-c22a-4ee0-9aea-a56fad281292	debt_increase	700000.00	prestamo moto	adalberto	2025-10-18 16:29:51.673051
68212d75-2fef-47a6-bd5c-82b228380868	d6d6661c-c22a-4ee0-9aea-a56fad281292	debt_increase	100000.00	mercancia	adalberto	2025-10-18 16:39:10.561159
\.


--
-- Data for Name: credits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credits (id, description, "totalAmount", "paidAmount", status, "createdAt", "updatedAt", client_id, created_by, updated_by, deleted_by, deleted_at) FROM stdin;
9a391f3b-b5b0-497d-a605-2ac12ac76401	arriendo	1000000.00	1000000.00	paid	2025-10-18 04:47:00.351667	2025-10-18 05:11:31.659799	37ab77d5-4f19-470e-b344-0df1d34e6222	adalberto	adalberto	\N	\N
3d3ee597-fc3e-4108-8f5e-565507bf141f	mercado	2000000.00	2000000.00	paid	2025-10-18 04:53:27.668708	2025-10-18 14:38:58.049396	30d1a9f9-c63e-4b09-bf23-e0f1e63012fd	adalberto	adalberto	\N	\N
d3c1b5e4-41dc-49db-bd4d-057725c7eb34	verduras	2100000.00	2100000.00	paid	2025-10-18 14:51:08.603762	2025-10-18 16:13:07.559471	37ab77d5-4f19-470e-b344-0df1d34e6222	adalberto	adalberto	\N	\N
d6d6661c-c22a-4ee0-9aea-a56fad281292	prestamo moto	3800000.00	1700000.00	pending	2025-10-18 14:49:05.124163	2025-10-18 16:39:10.571161	37ab77d5-4f19-470e-b344-0df1d34e6222	adalberto	adalberto	\N	\N
\.


--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.expenses (id, description, amount, created_by, "createdAt", "updatedAt") FROM stdin;
06037654-5d71-4670-b246-b53ab3b4fb0e	gasolina	40000.00	e0eb17cf-1e0a-4d42-a465-2b3d0ec62545	2025-10-18 20:41:05.620864	2025-10-18 21:01:32.598552
0f1d1fc5-71de-42f4-a8b7-afbe935a7b81	almuerzo	35000.00	e0eb17cf-1e0a-4d42-a465-2b3d0ec62545	2025-10-18 21:20:33.534921	2025-10-18 21:20:33.534921
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (id, order_id, product_id, "existingQuantity", "requestedQuantity", "measurementUnit") FROM stdin;
476d55b1-2662-44b2-ada0-7c44663337e9	40b448b5-fda7-44ff-92bd-88c78629b697	4f89884c-c072-491f-a15a-76d4570536a1	4	\N	unidad
08a840ff-3062-4157-a7a8-f87eea13d61d	40b448b5-fda7-44ff-92bd-88c78629b697	56179ab0-8fc5-4dba-8350-3b5c1962e31f	8	\N	unidad
1af6feea-22c7-45f2-b83f-951b6f9ebac3	bb5fce13-a8c4-4bff-9834-d995817add37	4f89884c-c072-491f-a15a-76d4570536a1	1	\N	unidad
148091b7-71b0-46a1-9e43-ed13eb338749	ef0f2e0c-6fd3-4a02-b7ec-82b2154dde67	9b7b2bb3-8068-40c8-8e2a-5c7a309100a0	1	\N	unidad
bcd062c1-fa48-41b8-9400-853a8295f18a	bb5fce13-a8c4-4bff-9834-d995817add37	1ee132da-ba36-4540-870d-b0dd132283e8	2	\N	unidad
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, description, provider, status, created_by, "createdAt", "updatedAt") FROM stdin;
bb5fce13-a8c4-4bff-9834-d995817add37	pedidos de empleado	\N	pending	ca1a7383-bd88-4dbd-af05-0d06ce7474d0	2025-10-19 17:06:50.46229	2025-10-19 17:06:50.46229
ef0f2e0c-6fd3-4a02-b7ec-82b2154dde67	pedido del admin	\N	pending	e0eb17cf-1e0a-4d42-a465-2b3d0ec62545	2025-10-19 17:08:45.15712	2025-10-19 17:08:45.15712
40b448b5-fda7-44ff-92bd-88c78629b697	pedido supervisor	\N	pending	731fd637-243a-443f-ad6f-c42646a40de1	2025-10-19 14:26:27.775017	2025-10-19 17:09:01.094921
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, credit_id, amount, description, "createdAt", created_by, deleted_by, deleted_at) FROM stdin;
18e3be8d-5085-4ae1-abb1-367a3be224de	9a391f3b-b5b0-497d-a605-2ac12ac76401	100000.00	abono	2025-10-18 04:47:57.160817	adalberto	\N	\N
62f5f2ed-05c2-4b58-87e6-55d905992d58	3d3ee597-fc3e-4108-8f5e-565507bf141f	150000.00	abono nequi	2025-10-18 04:54:00.811901	adalberto	\N	\N
e6eee329-5116-464b-b004-1a567cab340a	3d3ee597-fc3e-4108-8f5e-565507bf141f	150000.00	abono nequi	2025-10-18 04:54:18.138674	adalberto	\N	\N
b1cc3a2b-6be6-408b-8674-3c8ac23c8436	3d3ee597-fc3e-4108-8f5e-565507bf141f	100000.00	\N	2025-10-18 05:02:55.416588	adalberto	\N	\N
18de4142-9f73-44b9-a1d8-a0d554884067	9a391f3b-b5b0-497d-a605-2ac12ac76401	200000.00	\N	2025-10-18 05:04:52.369092	adalberto	\N	\N
ae6d68c1-1cd9-4a47-85c8-d6647556d1a5	9a391f3b-b5b0-497d-a605-2ac12ac76401	700000.00	cancelada deuda	2025-10-18 05:11:31.649161	adalberto	\N	\N
3143073d-2665-4e2a-8f61-e0d29bc13998	3d3ee597-fc3e-4108-8f5e-565507bf141f	1600000.00	\N	2025-10-18 14:38:58.030477	adalberto	\N	\N
15c1110c-3a07-46f3-8c3d-d83307bc3364	d3c1b5e4-41dc-49db-bd4d-057725c7eb34	200000.00	\N	2025-10-18 16:12:25.917947	adalberto	\N	\N
82620be9-506e-48be-8793-a58dcc721eee	d3c1b5e4-41dc-49db-bd4d-057725c7eb34	1900000.00	pago total	2025-10-18 16:13:07.548799	adalberto	\N	\N
2ce8baf9-6e45-44c4-885b-2f2ff07d516e	d6d6661c-c22a-4ee0-9aea-a56fad281292	100000.00	\N	2025-10-18 16:15:54.793	adalberto	\N	\N
1f6e610e-1757-4dad-8ea3-21281988cfdb	d6d6661c-c22a-4ee0-9aea-a56fad281292	100000.00	\N	2025-10-18 16:16:05.273006	adalberto	\N	\N
18e32d30-da91-46b7-8dc3-608b950635e3	d6d6661c-c22a-4ee0-9aea-a56fad281292	100000.00	nequi	2025-10-18 16:25:03.893204	adalberto	\N	\N
06819156-d967-4594-b221-87f1c69c8e24	d6d6661c-c22a-4ee0-9aea-a56fad281292	700000.00	daviplata	2025-10-18 16:25:56.85661	adalberto	\N	\N
6e96ab04-6390-42d8-b6ce-b85b5179073b	d6d6661c-c22a-4ee0-9aea-a56fad281292	700000.00	efectivo	2025-10-18 16:27:58.60427	adalberto	\N	\N
\.


--
-- Data for Name: product_update_tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_update_tasks (id, "productId", "changeType", "oldValue", "newValue", status, description, "createdById", "completedById", "createdAt", "updatedAt", "completedAt", notes) FROM stdin;
7408a0a1-0657-4549-a545-00e370e5af8d	9b7b2bb3-8068-40c8-8e2a-5c7a309100a0	price	{"iva": "19.00", "costo": null, "precioA": "1900.00", "precioB": "1850.00", "precioC": null, "description": "SALSA INGLESA IDEAL 165ML"}	{"iva": 19, "precioB": 1750}	completed	Precio actualizado: precioB	e0eb17cf-1e0a-4d42-a465-2b3d0ec62545	731fd637-243a-443f-ad6f-c42646a40de1	2025-10-19 04:32:20.195608	2025-10-19 04:33:56.636825	2025-10-19 04:33:56.629	\N
cc5c1b5d-64df-4647-a5c6-9f018ca786d0	9b7b2bb3-8068-40c8-8e2a-5c7a309100a0	price	{"iva": "19.00", "costo": null, "precioA": "2000.00", "precioB": "1850.00", "precioC": null, "description": "SALSA INGLESA IDEAL 165ML"}	{"iva": 19, "precioA": 1900}	completed	Precio actualizado: precioA	e0eb17cf-1e0a-4d42-a465-2b3d0ec62545	731fd637-243a-443f-ad6f-c42646a40de1	2025-10-19 02:38:10.462476	2025-10-19 04:34:01.846542	2025-10-19 04:34:01.841	\N
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, description, barcode, "isActive", precioa, preciob, precioc, costo, iva, "createdAt", "updatedAt") FROM stdin;
e3cad3f9-c33a-40c9-857e-3dd98e218c16	Aceite S.S 900Cm	7702109016977	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.793911	2025-10-19 02:29:40.793911
a5613196-37b2-4d02-9d4c-c7fc1c7f9070	MASCARILLA RESTAURADORA KIDS ROCIO DE ORO 250ML	7709193832940	t	24000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.80278	2025-10-19 02:29:40.80278
b7d02c37-c119-4f2f-aa42-79efa5a7b56c	Ak Detergente Liquido 900ml	7702310048101	t	10000.00	9750.00	\N	\N	19.00	2025-10-19 02:29:40.803354	2025-10-19 02:29:40.803354
dddb0ace-13b9-43e1-b96b-4bdcd493dd28	AK LAVAPLATO 500GR	7702310040105	t	4800.00	4650.00	\N	\N	19.00	2025-10-19 02:29:40.803744	2025-10-19 02:29:40.803744
76d79dd6-0b7f-4741-a45a-4858b3afa89e	MAIZENA FRESA 28GR	7702047040041	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:40.804036	2025-10-19 02:29:40.804036
c01e66dc-5614-4fdd-ad2c-d0c4c00fd6fa	CREMA PEINAR SAVITAL 95ML MULTIVITAMINA	7702006202817	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:40.804773	2025-10-19 02:29:40.804773
ba7241da-77dd-46ad-b538-9522cac94ffc	TINTE KERATON 10.11	7707230996266	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:40.805	2025-10-19 02:29:40.805
05e7ef86-fa2d-454e-810c-f162ce2f6350	CAREY EXFOLACION NATURAL 110GR	7702310022361	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:40.805225	2025-10-19 02:29:40.805225
335295e3-e422-480a-be64-476e03b8ab6c	SHAMPOO IKI PETS PERROS 240ML	7707370050118	t	14500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.805461	2025-10-19 02:29:40.805461
0826078e-0711-4405-8ffa-1b57a22c728c	TINTE KERATON 9.11	7707230996235	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:40.806097	2025-10-19 02:29:40.806097
6aa5abad-3e0e-4063-bdfb-7c97d8900cf3	ALUMINIO TUC CAJA 7MT	7702251044149	t	3800.00	3600.00	\N	\N	19.00	2025-10-19 02:29:40.806898	2025-10-19 02:29:40.806898
d9dfd9f8-e599-4c6e-9e82-d88331703c78	4FDGD3	41654	t	3800.00	\N	\N	\N	5.00	2025-10-19 02:29:40.807551	2025-10-19 02:29:40.807551
24a3b2db-3866-45f6-b9e1-fe0aa1b396f6	CAFE AROMA INSTANTANEO 170GR	7707199660758	t	23000.00	\N	\N	\N	5.00	2025-10-19 02:29:40.808233	2025-10-19 02:29:40.808233
00339eaa-c7f1-4278-b146-cac5832f6180	CAFFE AROMA INSTANTANEO 50GR	7707199660345	t	7500.00	7200.00	\N	\N	5.00	2025-10-19 02:29:40.808455	2025-10-19 02:29:40.808455
047a94d3-b9b1-464f-af60-ea8b9aee98a0	CAFE AROMA INSTANTANEO 85GR	7707199660352	t	10900.00	10700.00	\N	\N	5.00	2025-10-19 02:29:40.808694	2025-10-19 02:29:40.808694
6434f00f-cf0c-45f6-94b8-41bf8c5f1595	CAFE AROMA INSTANTANEO 170GR	7707199660741	t	22300.00	22000.00	\N	\N	5.00	2025-10-19 02:29:40.808942	2025-10-19 02:29:40.808942
6693d197-45bd-464d-a655-f45b1bd45b72	Aromatel Manzana 425ml	7702191164051	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:40.809183	2025-10-19 02:29:40.809183
4317ceb6-f2a6-439a-bc5d-6483dfcb2b3d	AROMATEL FLORAL 400ML	7702191164037	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:40.809411	2025-10-19 02:29:40.809411
dc83f6fd-50c0-4c0f-bf03-b153e63fbca7	ARROZ IDEAL 1.000GR	7709094571979	t	3700.00	3584.00	\N	\N	0.00	2025-10-19 02:29:40.809608	2025-10-19 02:29:40.809608
469ef549-d963-4ffe-a40b-577c13994e0f	ARROZ ZULIA 1.000GR	7707222299825	t	4000.00	3934.00	\N	\N	0.00	2025-10-19 02:29:40.809835	2025-10-19 02:29:40.809835
c980b49f-228e-43ef-b0ef-5e8f42bac0e6	AXION 450GR LIMON	7509546380742	t	5800.00	5700.00	\N	\N	19.00	2025-10-19 02:29:40.810059	2025-10-19 02:29:40.810059
6d717ef6-9f62-4708-bc5b-12428f7f06ca	AXION LIMON 235GR	7702010381256	t	3200.00	3060.00	\N	\N	19.00	2025-10-19 02:29:40.810268	2025-10-19 02:29:40.810268
b7d5de89-3ad5-4c6f-9edf-744d3292e11f	JABON COCO PRENDA DELICADA AZULK 180GR	7702310018364	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:40.810483	2025-10-19 02:29:40.810483
35aea78d-17fb-4f19-820c-007394c94209	JABON COCO BEBE 180GT	7702310018395	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:40.810717	2025-10-19 02:29:40.810717
8fd200b9-25b7-4d85-b92d-5c546699118e	BALANCE WOMEN PRACTI	7702029173781	t	4000.00	3850.00	\N	\N	19.00	2025-10-19 02:29:40.81093	2025-10-19 02:29:40.81093
fcd4aa31-da6a-4051-b7d9-930b32a88079	BATILADO FRESA 82GR	7702354320027	t	4500.00	4400.00	\N	\N	19.00	2025-10-19 02:29:40.811146	2025-10-19 02:29:40.811146
2a15a254-7d37-4b7e-b0dc-674214efc01a	CASERO VAINILLA BIMBO 220GR	7705326079152	t	6000.00	5850.00	\N	\N	19.00	2025-10-19 02:29:40.811383	2025-10-19 02:29:40.811383
c1044b7a-c663-42fc-86eb-a91f99948b96	BLANCOX BLANQUEADOR 500ML	7703812000017	t	1500.00	1355.00	\N	\N	19.00	2025-10-19 02:29:40.81158	2025-10-19 02:29:40.81158
ed052566-ec6e-4bad-a5fd-9b0aee9a346f	Bolsa Aseo 150L	ba150	t	3800.00	3700.00	\N	\N	19.00	2025-10-19 02:29:40.811808	2025-10-19 02:29:40.811808
30cbf61a-31c1-4093-babb-4c1209a47faa	Bolsa Aseo 200L	ba200	t	6400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.811999	2025-10-19 02:29:40.811999
b061db14-d545-4ae9-8d22-568aed3d5518	BOLSA DE HIELO	bhg	t	1200.00	1050.00	\N	\N	19.00	2025-10-19 02:29:40.812243	2025-10-19 02:29:40.812243
b23a656d-4532-47e6-ac23-7569f66707ef	TALCO BOROCANFOR 60GR	75930516	t	2200.00	2000.00	\N	\N	19.00	2025-10-19 02:29:40.812436	2025-10-19 02:29:40.812436
7a72c563-72a4-4340-8c06-34c26d2567da	BETUM BUFALO PASTA NEGRO 15GR	7702377000067	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:40.812621	2025-10-19 02:29:40.812621
0cd08f18-8b39-4b2b-8a91-459096a04729	BETUM BUFALO  PASTA NEGRO 36GR	7702377000050	t	5000.00	4800.00	\N	\N	19.00	2025-10-19 02:29:40.812814	2025-10-19 02:29:40.812814
205a094c-b819-4855-b55d-e984bd11d68f	CAREFREE PROTECTORES 15UND	7702031501398	t	1600.00	1500.00	\N	\N	0.00	2025-10-19 02:29:40.814179	2025-10-19 02:29:40.814179
62d2a997-9780-4f31-b2ea-0b4b08fdc06a	Carey Jabon 3U	7702310022095	t	7500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.814446	2025-10-19 02:29:40.814446
91160527-fd90-4d92-b707-fbded914c993	CEPILLO COLGATE KIDS	7509546074122	t	2300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.814717	2025-10-19 02:29:40.814717
51a9dcae-8968-426a-93fa-5b8fa4755849	CEPILLO FULLER MANO	7702856003893	t	3700.00	3600.00	\N	\N	19.00	2025-10-19 02:29:40.814976	2025-10-19 02:29:40.814976
c706bad6-af1b-4724-ab3d-2545cf71789b	CEPILLO ORAL B	7500435134415	t	2500.00	2267.00	\N	\N	19.00	2025-10-19 02:29:40.815214	2025-10-19 02:29:40.815214
d71428b2-823d-4df8-995b-acf198ffc397	CEPILLO ORAL B PRO PROFILE PASCK DUO	7501086454181	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.815429	2025-10-19 02:29:40.815429
f6332159-f7aa-4d0c-b873-8380735a6ae8	CHOCOLISTO 300GR	7702007216103	t	13200.00	13000.00	\N	\N	19.00	2025-10-19 02:29:40.815627	2025-10-19 02:29:40.815627
8ecc2caa-7b0a-4155-bcbb-e447981e4628	CHOCOLISTO 18GR	7702007085952	t	900.00	784.00	\N	\N	19.00	2025-10-19 02:29:40.815831	2025-10-19 02:29:40.815831
0eac289d-1a6c-46f4-ae4d-dbd723dac4fd	COFFEE STAR X100UNID	7707014908300	t	7700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.816266	2025-10-19 02:29:40.816266
b1c5d63b-6296-405a-9b0b-6c3d81b9de0c	COLCAFE CLASICO SUAVE 250GR	7702032053063	t	37300.00	36600.00	\N	\N	5.00	2025-10-19 02:29:40.816474	2025-10-19 02:29:40.816474
b13d02ae-6669-41e2-a4e4-00e42303c991	COLGATE MAS CEPILLO 50ML	7702010631382	t	4300.00	4170.00	\N	\N	19.00	2025-10-19 02:29:40.816711	2025-10-19 02:29:40.816711
93e430f3-d709-48ec-b46b-704daa416f00	COLGATE TRIPLE ACCION 22ML	7702010111464	t	2200.00	2067.00	\N	\N	19.00	2025-10-19 02:29:40.816935	2025-10-19 02:29:40.816935
c5a75f24-fa15-468c-9995-e1807050332d	SALCHICHA SELECIONADA COLANTA DUO	7702129073417	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:40.817171	2025-10-19 02:29:40.817171
5a09864b-17eb-451e-b5e1-4f52d9c8d1e3	COLGATE TRIPLE ACCION 60ML	7702010111501	t	3500.00	3334.00	\N	\N	19.00	2025-10-19 02:29:40.817396	2025-10-19 02:29:40.817396
24a8d01b-13f3-4507-919a-15f0c5bf5e9a	BON BON BUM X24UNID	7702011242570	t	8400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.817606	2025-10-19 02:29:40.817606
66d169e6-2593-4e3c-966b-f5f4fa86df8a	BON BON BUM FRESA X24 UNID	7702011281180	t	8400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.817937	2025-10-19 02:29:40.817937
61a8c8d3-e2be-4e89-a15f-4a8e0b32f655	COLOR DEL FOGON X50UNID	7702354003838	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:40.818461	2025-10-19 02:29:40.818461
dc45691b-a76c-467b-94c8-2d117301db4d	COMINO REY 55GR	7702175111224	t	3300.00	3160.00	\N	\N	19.00	2025-10-19 02:29:40.818854	2025-10-19 02:29:40.818854
307d44fc-5f74-45a0-9508-177ce4049f23	COMPOTA HEINZ MANZANA 113GR	608875003128	t	3500.00	3250.00	\N	\N	19.00	2025-10-19 02:29:40.81913	2025-10-19 02:29:40.81913
c72f096e-b9ba-41c8-aadf-0dbe3bf4452c	CHOCOLATE CORONA TRADICIONAL 250GR	7702007205046	t	8700.00	8550.00	\N	\N	5.00	2025-10-19 02:29:40.819416	2025-10-19 02:29:40.819416
10259e08-839d-44a3-a782-94df56130d8c	CHOCOLATE CORONA X40UNID	7702007505078	t	37000.00	\N	\N	\N	5.00	2025-10-19 02:29:40.819737	2025-10-19 02:29:40.819737
011da9c3-36ed-4d28-bb07-3b74897fe983	CHOCOLATE CORONA CYC 250GR	7702007024036	t	6900.00	6750.00	\N	\N	5.00	2025-10-19 02:29:40.819964	2025-10-19 02:29:40.819964
911cbeef-d18d-4c42-b70e-37e21d9d8698	ACEITE DE OLIVA EXTR VIRGEN MONTICELLO 250ML	7702085021842	t	27500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.820198	2025-10-19 02:29:40.820198
8d00661a-1fb0-4588-ae75-19fec5300800	BARBIE MIX ROLLO  X100GR	7703888423178	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.820393	2025-10-19 02:29:40.820393
a5856173-401e-401f-ad81-769de74db669	REVOLCON CARAMELO 50UNID	7702993032732	t	6000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.820642	2025-10-19 02:29:40.820642
46ca33d7-15d2-4261-a6a5-b7a0f510591b	DERSA DETERGENTE 125GR	7702166004054	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:40.820906	2025-10-19 02:29:40.820906
0a16518e-237c-48be-8301-42dfc012f708	AXION DISCO 130GR	7509546652559	t	1400.00	1290.00	\N	\N	19.00	2025-10-19 02:29:40.821134	2025-10-19 02:29:40.821134
1e95bf0f-1744-4241-be06-47a18dec7d63	LASAGNA DORIA 200GR	7702085043066	t	5800.00	5600.00	\N	\N	19.00	2025-10-19 02:29:40.821347	2025-10-19 02:29:40.821347
21979678-eefb-4398-9125-c623cf72febf	RIGATONI DORIA 500GR	7702085013427	t	4000.00	3870.00	\N	\N	5.00	2025-10-19 02:29:40.821563	2025-10-19 02:29:40.821563
4c4757b5-5f18-48e9-b569-51be317cfadf	SPAGHETTI DORIA SABOR A POLLO ASADO 250GR	7702085002865	t	2700.00	2600.00	\N	\N	5.00	2025-10-19 02:29:40.821771	2025-10-19 02:29:40.821771
2238bbb2-16ed-4765-8952-2d67839f40a1	SPAGHETTI DORIA SABOR RANCHERO 250GR	7702085002360	t	2700.00	2600.00	\N	\N	5.00	2025-10-19 02:29:40.822002	2025-10-19 02:29:40.822002
68df513e-d30b-4010-bdaf-e7a35b7e5476	CODO DORIA 250GR	7702085012390	t	2200.00	2100.00	\N	\N	5.00	2025-10-19 02:29:40.822223	2025-10-19 02:29:40.822223
8ee43de0-3545-48ad-957c-bc1501e27c29	SPAGHETTI DORIA 500GR	7702085013021	t	3900.00	\N	\N	\N	5.00	2025-10-19 02:29:40.823041	2025-10-19 02:29:40.823041
d1d6fdf1-729f-436a-8378-092b5b1dbc6a	SPAGHETTI DORIA SABOR A CHORIZO 250GR	7702085002766	t	2700.00	2600.00	\N	\N	5.00	2025-10-19 02:29:40.823279	2025-10-19 02:29:40.823279
933cccd5-6bd0-4f6e-83dd-989c683a190c	GALLETA DUX INTEGRAL 3X9	7702025185368	t	6400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.82351	2025-10-19 02:29:40.82351
4ff489df-669c-4ea3-980c-bb4e814f707d	EL AGUILA BOCADILLO HOJA X18UNID	7707189190982	t	6300.00	6200.00	\N	\N	0.00	2025-10-19 02:29:40.823765	2025-10-19 02:29:40.823765
51627cfc-cdea-4916-b20e-12e986eae67d	El Sazon Ajo Molido	7707270530062	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.824023	2025-10-19 02:29:40.824023
8572854f-3396-44dd-8888-61103f44ab4b	SPAGHETTI PUGLIESE 1.000GR	7702020060103	t	3500.00	3334.00	\N	\N	5.00	2025-10-19 02:29:40.824258	2025-10-19 02:29:40.824258
7aaf5b62-e59b-4450-9bc3-6f21052099fd	Esponja Dorada	7707112341627	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.824473	2025-10-19 02:29:40.824473
1904d1aa-03ec-42b0-8ae2-eae517732622	FAB PROTECCION DE COLOR 800GR	7702191163177	t	8800.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.82467	2025-10-19 02:29:40.82467
ce2b5299-91c9-44c9-9f87-667242d627cf	FAB MULTIUSOS 300GR	7702191658901	t	2900.00	2800.00	\N	\N	19.00	2025-10-19 02:29:40.824861	2025-10-19 02:29:40.824861
74480ec7-1a99-4463-be5e-82f6ec190593	PROTECTORES KOTEX X150 CON INDICADOR PH	7702425765610	t	12800.00	12200.00	\N	\N	0.00	2025-10-19 02:29:40.825086	2025-10-19 02:29:40.825086
97fdc683-8bf4-4cd3-b80e-c1ddd8e674a0	SOFT KLEAN FLORAL 1.600ML	7702310046275	t	9500.00	9250.00	\N	\N	19.00	2025-10-19 02:29:40.825294	2025-10-19 02:29:40.825294
af548387-59ca-4d0b-9c60-129db75bbc91	CEPILLO ROPA PINTO DIAMANTE	7707112320301	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:40.825516	2025-10-19 02:29:40.825516
3ffd7230-0998-4732-a60a-4b3faea77924	FAMILIA ACOLCHAMAX X12UNID	7702026196141	t	19700.00	19400.00	\N	\N	19.00	2025-10-19 02:29:40.825741	2025-10-19 02:29:40.825741
0ced92e3-e778-4300-9cf5-5551295e3239	FAMILIA COCINA 50U	7702026188528	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:40.825932	2025-10-19 02:29:40.825932
05b35ece-92c5-459c-b4cf-6ea4e8af29be	FAMILIA ELIMINA OLORES BAMBO 12ML	7702026312060	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:40.826125	2025-10-19 02:29:40.826125
67eaa723-9c08-4476-958c-ee22632fbdd9	ESCOBA ORQUIDEA SUAVE PINTO	7707112320097	t	8500.00	8200.00	\N	\N	19.00	2025-10-19 02:29:40.826351	2025-10-19 02:29:40.826351
6adb3556-1964-47bb-b5eb-0138975a42b6	SERVILLETA FAMILIA 1A1  X150UNID	7702026020927	t	2600.00	2480.00	\N	\N	19.00	2025-10-19 02:29:40.826958	2025-10-19 02:29:40.826958
9b5d516a-446f-48e3-9ef2-6668cd23e119	FASSI LAVAPLATO 450GR	7702230600274	t	5200.00	5000.00	\N	\N	19.00	2025-10-19 02:29:40.827187	2025-10-19 02:29:40.827187
e988c492-df9a-4616-bab4-5dea50a24f0a	FLUOCARDENT KIDS MAS CEPILLO 50GR	7702560044717	t	7200.00	6950.00	\N	\N	19.00	2025-10-19 02:29:40.827426	2025-10-19 02:29:40.827426
8493743f-c0c7-4be3-b5eb-452c9e551686	FRUTAS RELLENAS X100UNID	7707014908287	t	6300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.827632	2025-10-19 02:29:40.827632
0d80ad7e-6bc2-40b3-9bc0-3d6fa41cf4f2	GELATINA FRUTIÑO SIN SABOR 15GR	7702354413002	t	1700.00	1570.00	\N	\N	19.00	2025-10-19 02:29:40.827856	2025-10-19 02:29:40.827856
92826569-446c-4ae2-8678-fb81f745f26f	NUCITA WAFER X8U	7702011005397	t	4600.00	\N	\N	\N	19.00	2025-10-19 02:29:40.828073	2025-10-19 02:29:40.828073
b229b7e0-66b9-47a3-be69-4f9111c3aa6a	Gelhada Pudin	7702014515015	t	3400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.828292	2025-10-19 02:29:40.828292
3fb019a2-c1d0-4ec0-9d7f-2d93e85dbeda	GELATINA FRUTIÑO X4UNID	7702354950804	t	5900.00	5750.00	\N	\N	19.00	2025-10-19 02:29:40.828511	2025-10-19 02:29:40.828511
72816437-2610-42d6-93f8-c53b57d10fff	ARROZ GELVEZ 1KG	7707197478072	t	3900.00	3800.00	\N	\N	5.00	2025-10-19 02:29:40.828714	2025-10-19 02:29:40.828714
85701460-5337-4878-beda-14d359d9e14c	Aceite D 1L	7709215115204	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.829002	2025-10-19 02:29:40.829002
39a75df8-7090-41a2-8b0d-b769d9c246d2	GOL CHOCOLATE X24UNID	7702007080605	t	28000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.829185	2025-10-19 02:29:40.829185
fa5f68fb-3b06-4918-81d7-d05d5868446a	GUISAMAC CALDO GALLINA	7703015101443	t	1100.00	984.00	\N	\N	19.00	2025-10-19 02:29:40.829414	2025-10-19 02:29:40.829414
96752602-36f7-4fe4-b206-967f550d4441	HARINA PAN 1.000GR	7702084137520	t	3300.00	3250.00	\N	\N	5.00	2025-10-19 02:29:40.829612	2025-10-19 02:29:40.829612
b042c64d-7107-43da-a471-c6924fb281c9	HEAD SHOULDERS 2 EN 1	7500435019828	t	18000.00	17500.00	\N	\N	19.00	2025-10-19 02:29:40.829825	2025-10-19 02:29:40.829825
6eb456c2-04b9-47f8-b3a6-92867118ab1f	Head Shoulders Aceite de Coco	7500435142557	t	18000.00	17500.00	\N	\N	19.00	2025-10-19 02:29:40.83002	2025-10-19 02:29:40.83002
77baa616-e88a-46a7-8387-241259939e3a	VINAGRE BLANCO SALOME 1L	7709913154345	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:40.830241	2025-10-19 02:29:40.830241
fffad6a3-0c9f-47bc-a5a6-fe3b9ef39dcc	HUGGIES MANITAS Y CARITAS 80UNID	7702425804821	t	7900.00	7600.00	\N	\N	19.00	2025-10-19 02:29:40.83044	2025-10-19 02:29:40.83044
77a99112-9646-4873-ac15-cd231ce5efdb	DVC	jo	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.830654	2025-10-19 02:29:40.830654
18152e05-a1d4-4b78-85d0-7e09bfbfb163	JET CHOCOLATINA X50U	7702007512007	t	54000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.830858	2025-10-19 02:29:40.830858
e25c74db-dbf1-4fd7-a7b9-c0fa85634ceb	JOHNSONS BABY CABELLO OSCURO 100ML	7702031293262	t	6500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.831057	2025-10-19 02:29:40.831057
e2e786b5-134c-49ee-9e0e-fbe8c6c18a12	CREMA PARA PEINAR JHONSONS 200ML	7702031878452	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.831266	2025-10-19 02:29:40.831266
458aa8c3-f85c-4d40-98df-50757b140cb7	JOHNSONS ROSAS SANDALO 110GR	7702031414575	t	2900.00	2800.00	\N	\N	19.00	2025-10-19 02:29:40.831464	2025-10-19 02:29:40.831464
1be70d03-a7b5-4ac8-af46-b2c167a49466	JOHNSONS ALOE Y VITAMINA 110GR	7702031414360	t	3100.00	2980.00	\N	\N	19.00	2025-10-19 02:29:40.831668	2025-10-19 02:29:40.831668
c7615a92-3a23-453b-8b48-f8ba8d6eb1f9	KATORI 50 ESPIRAL	7702332000026	t	21800.00	\N	\N	\N	0.00	2025-10-19 02:29:40.831879	2025-10-19 02:29:40.831879
4819149d-597f-4438-9393-86f654478ab5	KOTEX X15 PROTECTORES	7702425544932	t	2400.00	2300.00	\N	\N	0.00	2025-10-19 02:29:40.832107	2025-10-19 02:29:40.832107
f216238f-a1c6-45ae-8f6f-9b771383060e	MERMELADA LA CONSTANCIA FRESA 200GR	7702097036650	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.832335	2025-10-19 02:29:40.832335
0a5991a2-49e5-4a5b-befa-18c86d8c82d5	SALSA DE TOMATE LA CONSTANCIA 150GR	7702097131935	t	2100.00	1980.00	\N	\N	19.00	2025-10-19 02:29:40.83254	2025-10-19 02:29:40.83254
d6054f4d-c417-490e-be5a-ef4cbf753e14	RIGATON LAVAGASSA 125GR	7707047400277	t	1000.00	\N	\N	\N	5.00	2025-10-19 02:29:40.832765	2025-10-19 02:29:40.832765
3a97e54f-6076-4acf-aca1-2d3794da6f4b	BOKA FRESA	7702354956806	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:40.832993	2025-10-19 02:29:40.832993
bc021be3-282b-43d7-a4fb-b57f30d1ba45	CERA IMPERIAL 400GR	7707279809978	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:40.833237	2025-10-19 02:29:40.833237
4f2a135b-ebc5-4ad4-8e79-5cf23b3ce6e8	EL MANICERO LA ESPECIAL X24UNID	7702007528008	t	21500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.833557	2025-10-19 02:29:40.833557
dd0a3420-0025-4b9f-9c81-bfecb8162a9e	LA MUÑECA SPAGHETTI 1K	7702020117012	t	4600.00	4459.00	\N	\N	5.00	2025-10-19 02:29:40.834476	2025-10-19 02:29:40.834476
992ee817-3a31-48ac-8bc4-4ab9d9e03f58	SPAGHETTI LA MUÑECA 250GR	7702020112123	t	1900.00	1790.00	\N	\N	5.00	2025-10-19 02:29:40.834868	2025-10-19 02:29:40.834868
7a3ad385-da67-4301-b492-49ff53ac41d7	LASAGÑA LASICILIAN 250GR	7707197300045	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.835291	2025-10-19 02:29:40.835291
e530b9a5-f14b-429a-ba11-52d1286d2757	ATUN LA SOBERANA LOMOS EN ACEITE 140GR	7702910035846	t	5800.00	5600.00	\N	\N	19.00	2025-10-19 02:29:40.835611	2025-10-19 02:29:40.835611
1a8151c6-7140-4d5e-bb3f-f688493b929f	SALMON LA SOBERANA TOMATE 101GR	7702910099701	t	4000.00	3850.00	\N	\N	19.00	2025-10-19 02:29:40.835835	2025-10-19 02:29:40.835835
23fd553b-46a9-41ae-838f-2f010f0ed844	SARDINA LA SOBERANA TOMATE 425GR	7702910099138	t	8100.00	7850.00	\N	\N	19.00	2025-10-19 02:29:40.836087	2025-10-19 02:29:40.836087
ae54fccb-c35d-431e-ab01-d3c567a5442d	SPEED STICK PRATIC 30GR	7501033204920	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:40.836309	2025-10-19 02:29:40.836309
aca489d1-498e-47b7-81e2-ac9be628e2a0	LADY SPEED STICK 24/7 GEL 10GR	7702010470103	t	1000.00	945.00	\N	\N	19.00	2025-10-19 02:29:40.836514	2025-10-19 02:29:40.836514
ed37febb-5d19-421d-9629-edb132a417a4	LADY SPEED STICK TALC DUO 9G	7501033204500	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.836714	2025-10-19 02:29:40.836714
21df432e-3120-4056-a8f8-5d9cd375a426	LE FRAGANCE FLORAL 110GR	7702310024006	t	1600.00	1485.00	\N	\N	19.00	2025-10-19 02:29:40.836924	2025-10-19 02:29:40.836924
f21c38cb-1e99-4627-9a9f-25a0f5654959	LEMON 115GR	7701018075440	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:40.837123	2025-10-19 02:29:40.837123
569c44ff-22c1-4ef0-953d-460506d5a8c0	LEMON BLANCO N115GR	7701018075457	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:40.837322	2025-10-19 02:29:40.837322
1b5db37b-658e-443b-a38d-1d2c53f1ca86	LEMON ROSADO 115GR	7701018075464	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:40.837529	2025-10-19 02:29:40.837529
e49a7de3-5efe-409a-b302-d3ae8d3b3747	Cloro 1L	7709990692334	t	2600.00	2460.00	\N	\N	19.00	2025-10-19 02:29:40.837874	2025-10-19 02:29:40.837874
9d168a79-e8d4-4dc4-b716-3ed693a4250b	LISTERINE CONTROL 180ML	7702035430090	t	8100.00	7900.00	\N	\N	19.00	2025-10-19 02:29:40.838084	2025-10-19 02:29:40.838084
87d3452a-de69-4762-9d27-e48e12e2fb10	Loza Crem Aloe Rosas	7703812009102	t	6500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.838292	2025-10-19 02:29:40.838292
4b6e1949-d2ad-4b51-8967-d83b0ce97f8f	Loza Crem Duopack	7703812011365	t	6500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.838506	2025-10-19 02:29:40.838506
511c6213-5719-4a65-8a57-5913ad2742c0	Loza Crem Limon 250gr	7703812010566	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.838716	2025-10-19 02:29:40.838716
af194bb4-ff3d-4c9a-afbb-388189e87377	LUKAFE INTENSO 125GR	7702088352707	t	4600.00	\N	\N	\N	5.00	2025-10-19 02:29:40.839146	2025-10-19 02:29:40.839146
f5d4d7ff-8e22-49ef-95c9-f43120624f1a	LUKAFE INTENSO 500GR	7702088353001	t	16900.00	\N	\N	\N	5.00	2025-10-19 02:29:40.839334	2025-10-19 02:29:40.839334
73623b35-7261-42cc-84fe-fed49375e2d2	LUKAFE INTENSO 250GR	7702088352356	t	9000.00	9000.00	\N	\N	5.00	2025-10-19 02:29:40.839567	2025-10-19 02:29:40.839567
5cc26bd7-552b-49c5-a59d-98f8dd9a15e9	GUISAMAC	7703015101405	t	1100.00	984.00	\N	\N	19.00	2025-10-19 02:29:40.839764	2025-10-19 02:29:40.839764
563d527a-fbe2-4814-b260-85c5cf9939d8	MACARRON PLUGLIESE 1.000GR	7702020060141	t	3500.00	3334.00	\N	\N	5.00	2025-10-19 02:29:40.839987	2025-10-19 02:29:40.839987
e85bb398-f80a-4a9c-953a-35caa21010a6	MAIZENA VAINILLA 28GR	7702047040058	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:40.84018	2025-10-19 02:29:40.84018
e9dcd6c4-d78e-41d4-b0c5-259ba49475c0	MAIZENA ORIGINAL 90GR	7702047003466	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:40.840362	2025-10-19 02:29:40.840362
57112297-4a52-4cba-a66c-683386ee7d15	Pepitonas 140g	7591002700058	t	6600.00	6400.00	\N	\N	19.00	2025-10-19 02:29:40.840565	2025-10-19 02:29:40.840565
3c670802-e2fd-4a90-98db-4cd61e4d2ab2	PINGUINOS MINIX 12U 240GR	7705326080530	t	11200.00	11000.00	\N	\N	19.00	2025-10-19 02:29:40.840755	2025-10-19 02:29:40.840755
a452014a-9bcd-413e-8ef7-a84c761749fd	ESPONJA BRILLO MATRIX	7453010015787	t	800.00	625.00	\N	\N	19.00	2025-10-19 02:29:40.840935	2025-10-19 02:29:40.840935
6147f48b-4efb-42ad-a03f-f1c02494bcb6	MAXCOCO X10 UNID 460GR	7702011046949	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.841145	2025-10-19 02:29:40.841145
fd9a5082-ffab-4b00-9494-5b401d7c1348	MAYONESA NATUCAMPO PREMIUM 200GR	7709990654356	t	5900.00	5700.00	\N	\N	19.00	2025-10-19 02:29:40.84137	2025-10-19 02:29:40.84137
162a6af3-8418-41ad-96a3-a00de73971a2	MILLOWS MASMELOS CREAM X50UNID	7702011157805	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.841597	2025-10-19 02:29:40.841597
e44057af-9f7a-453e-979e-3b918d7b6d09	MIRRINGO ADULTO 1K	7703090961017	t	8900.00	8650.00	\N	\N	5.00	2025-10-19 02:29:40.841803	2025-10-19 02:29:40.841803
ea15e689-bd5d-436f-b2c4-d86077e71636	MIST MENTA SURTIDO 100UND	7702174061414	t	7500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.84199	2025-10-19 02:29:40.84199
d770e062-3bd7-4e9d-a3f5-853a7011d226	Mistol Desinfectante 1000ml	mistol	t	2900.00	2800.00	\N	\N	19.00	2025-10-19 02:29:40.84218	2025-10-19 02:29:40.84218
dcad9570-699b-4d36-b81c-28385916f7ad	MISTOL SURTIDOS 500ML	7703616024103	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:40.842372	2025-10-19 02:29:40.842372
feea5cf1-16b9-438e-b9bd-24fafa506a64	MORDISQUETAS RON CON PASAS X24UNID	7702011121950	t	8700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.842579	2025-10-19 02:29:40.842579
c70dc5f9-69cd-4203-8f73-e797ca15c2e6	MUUU LECHE 18UNID	7702011070371	t	4400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.842771	2025-10-19 02:29:40.842771
1ea2aa92-da0f-4c7e-95a1-e58ff4cf1fc0	CLUB SOCIAL ORIGINAL 9X3	7622201717568	t	6200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.842983	2025-10-19 02:29:40.842983
bf061bf3-671f-4edc-8084-06d81811fea0	MAYONESA NATUCAMPO PREMIUM 400GR	7709990654318	t	10300.00	10000.00	\N	\N	19.00	2025-10-19 02:29:40.843189	2025-10-19 02:29:40.843189
7780d072-ee61-445b-885e-9d87a206e2cd	LECHE CONDENSADA TUBITO 300GR	7707226113134	t	8100.00	7900.00	\N	\N	0.00	2025-10-19 02:29:40.843378	2025-10-19 02:29:40.843378
22a05a96-a8bb-4a80-98b6-6ad944685e24	SHAMPOO NATURALEZA Y VIDA NEGRO  300ML	7702377303113	t	19000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.843569	2025-10-19 02:29:40.843569
91f814c3-05a8-492e-abad-68bc52b13b67	NESCAFE TRADICIONAL 170GR	7702024236146	t	24600.00	24000.00	\N	\N	5.00	2025-10-19 02:29:40.843762	2025-10-19 02:29:40.843762
ea1e9d40-5881-4381-8e70-d359c335e904	NESCAFE TRADICIONAL 50GR	7702024004677	t	9400.00	9100.00	\N	\N	5.00	2025-10-19 02:29:40.844169	2025-10-19 02:29:40.844169
4a689392-4f0e-47f8-a112-584b265750ce	NESCAFE TRADICIONAL 85GR	7702024532262	t	16900.00	16300.00	\N	\N	5.00	2025-10-19 02:29:40.844348	2025-10-19 02:29:40.844348
bd956e85-b75f-4362-a71b-66031d33c7f8	NESTUM TRIGO MIEL 200GR	7613033986628	t	12400.00	12000.00	\N	\N	19.00	2025-10-19 02:29:40.844534	2025-10-19 02:29:40.844534
7638b2b3-3603-4df4-986f-82b68dd68fc3	DUCALES 2TACOS 294GR	7702025113132	t	6900.00	6800.00	\N	\N	19.00	2025-10-19 02:29:40.844731	2025-10-19 02:29:40.844731
ba71ba5c-8001-4de7-a742-47e6093ed68c	FESTIVAL VAINILLA 12X4	7702025103744	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.844995	2025-10-19 02:29:40.844995
a47920c4-e780-4cf4-8d65-9172a92d68bf	FESTIVAL FRESA 12X6	7702025182145	t	12300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.845214	2025-10-19 02:29:40.845214
da717a0c-bc0e-42b6-9557-9a3fe005af22	PROTECTORES DIARIOS NOSOTRAS X15UNID	7702027434020	t	1800.00	1700.00	\N	\N	0.00	2025-10-19 02:29:40.845415	2025-10-19 02:29:40.845415
124dd1de-3af1-4942-9012-9d6ff6b8b7d3	PROTECTORES NOSOTRAS MULTIESTILO X15	7702027444685	t	1900.00	1800.00	\N	\N	0.00	2025-10-19 02:29:40.845607	2025-10-19 02:29:40.845607
164cb9f0-485a-4667-bb18-57b3912b7dd3	NOSOTRAS NORMAL ALAS 10UND	7702027401251	t	3600.00	3450.00	\N	\N	0.00	2025-10-19 02:29:40.845813	2025-10-19 02:29:40.845813
6f98a31d-7135-44dc-9984-d5a73d514479	NOSOTRAS DELGADAS X6	7702026178642	t	2200.00	\N	\N	\N	0.00	2025-10-19 02:29:40.845995	2025-10-19 02:29:40.845995
61dc050b-f884-4b30-a43b-961f4b3c8b71	NOSOTRAS DIA Y NOCHE 6UND	7702027429354	t	3300.00	3150.00	\N	\N	0.00	2025-10-19 02:29:40.846199	2025-10-19 02:29:40.846199
75ac8b8b-0cb1-49cb-a10e-c456d495c615	TOALLAS NOSOTRA INVISIBLE CLASICA X30	7702027416859	t	12000.00	11600.00	\N	\N	0.00	2025-10-19 02:29:40.846389	2025-10-19 02:29:40.846389
03c2b68c-88db-4c19-82e6-503137c9b281	NUBE CLASICO X 4UNIDADES	7707151604004	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:40.846576	2025-10-19 02:29:40.846576
b9b3d625-086b-4a96-980d-8d5f0d45cdd5	TOALLA COSINA NUBE X3UNID 50HJ	7707151602185	t	6200.00	6000.00	\N	\N	19.00	2025-10-19 02:29:40.846759	2025-10-19 02:29:40.846759
083b9b1b-ace6-4867-a371-b357d50cbfd1	NUTELLA 350GR	80177173	t	18300.00	18000.00	\N	\N	19.00	2025-10-19 02:29:40.846982	2025-10-19 02:29:40.846982
0e7b10d5-5d8e-4fad-be57-22bbd14f5d4c	NUTRE CAN CROQUETAS 800GR	7702712001872	t	5600.00	5480.00	\N	\N	5.00	2025-10-19 02:29:40.847181	2025-10-19 02:29:40.847181
a7965f27-808a-4eef-8265-5d6d95355f1d	NUTRIBELA 180ML CELULAS MADRES	7702354951740	t	10400.00	10000.00	\N	\N	19.00	2025-10-19 02:29:40.847394	2025-10-19 02:29:40.847394
509455ed-0dac-4ec5-9d6e-7a0afb7bc2c9	NUTRIBELA 180ML ENZIMOTERAPIA	7702354948504	t	10400.00	10000.00	\N	\N	19.00	2025-10-19 02:29:40.847589	2025-10-19 02:29:40.847589
ce772cc5-381e-4c65-b7aa-492d3ede1707	OREO 12X4 432GR	7590011151110	t	11000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.847776	2025-10-19 02:29:40.847776
cc4e2b3a-e1d2-43d9-adbf-6be3bdaf1839	OxyPower 500ml	7790520985569	t	13500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.847979	2025-10-19 02:29:40.847979
f1b759b0-c335-464b-b77f-962845d3c861	PALMOLIVE DE AVENA 120GR	7509546677019	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:40.848199	2025-10-19 02:29:40.848199
ca781d33-87c0-4c9a-a64a-97bc8d7a13be	HARINA PAN CHOCLO 1.000GR	7702084550015	t	8400.00	8250.00	\N	\N	19.00	2025-10-19 02:29:40.848418	2025-10-19 02:29:40.848418
67bbf319-dc73-4cce-a591-287c1363243f	HARINA PAN DE CHOCLO 500GR	7702084137551	t	5300.00	5180.00	\N	\N	19.00	2025-10-19 02:29:40.848628	2025-10-19 02:29:40.848628
5d4073bd-453f-4faa-b143-570c1b59da8f	Pantene Mascarilla 300ml	7500435151320	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.848823	2025-10-19 02:29:40.848823
d347f639-851d-4332-b084-1cb6785c35cf	LECHE ENTERA 200ML	7705241100481	t	1200.00	1100.00	900.00	\N	0.00	2025-10-19 02:29:40.849134	2025-10-19 02:29:40.849134
cef4ae0b-5369-4d41-bfa7-cdb250dedcc4	ACEITE IDEAL 500ML	7709663317229	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:40.84934	2025-10-19 02:29:40.84934
c9049803-1ae5-4c9e-934a-9f5436ac3784	CREMA DE LECHE FRESKA 100GR	7704841000122	t	2900.00	2800.00	\N	\N	0.00	2025-10-19 02:29:40.849535	2025-10-19 02:29:40.849535
4c743e03-5978-402d-9ddf-c0b78e043cce	PAÑITOS PEQUEÑIN 100UNID	7702026313715	t	10500.00	10300.00	\N	\N	19.00	2025-10-19 02:29:40.849719	2025-10-19 02:29:40.849719
f2adbc7d-7191-484c-ba0e-e3358fe2b2da	TOALLITAS PEQUEÑIN X24UNID	7702026031329	t	3300.00	3150.00	\N	\N	19.00	2025-10-19 02:29:40.850189	2025-10-19 02:29:40.850189
374d39ec-6a25-4b1f-8eb4-1a687d454453	PONY MALTA 1.5L	7702004013514	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.850513	2025-10-19 02:29:40.850513
af904653-af58-4a01-87fa-e7083a399bd6	PURINA 1K	pgk	t	3900.00	\N	\N	\N	5.00	2025-10-19 02:29:40.850716	2025-10-19 02:29:40.850716
2ab06092-a6dc-4e8a-80e0-e03b55d99505	RICAVENA INSTANTANEA QUAKER 180GR	7702193149322	t	4700.00	4530.00	\N	\N	19.00	2025-10-19 02:29:40.850942	2025-10-19 02:29:40.850942
a242cfe6-3d3d-41e9-984c-96778826ba3c	QUESADA CHOCOLATE 250GR CLAVOS	7702088131609	t	7600.00	7400.00	\N	\N	5.00	2025-10-19 02:29:40.851168	2025-10-19 02:29:40.851168
120367f5-baa5-469b-8f74-1ca505dfdca1	BROWNIE 65GR	7702914160308	t	3500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.851374	2025-10-19 02:29:40.851374
ccfe7a97-5aab-4493-8faa-c5feed3a8aed	CHOCORRAMO MINI X20UNI	7702914114103	t	14000.00	13900.00	\N	\N	19.00	2025-10-19 02:29:40.851572	2025-10-19 02:29:40.851572
b257a58b-2595-4f40-951c-ce3ab8ceb032	163	54135	t	15.00	5150.00	\N	\N	19.00	2025-10-19 02:29:40.85176	2025-10-19 02:29:40.85176
84890937-c4ba-4c77-b3a6-5e03ca1ea523	Ramo Gala 5U 315g	7702914112208	t	8800.00	8600.00	\N	\N	19.00	2025-10-19 02:29:40.85196	2025-10-19 02:29:40.85196
198cd00b-2354-496f-abfd-5a49ed77774b	SALSERO PEQUEÑO 110CC	7703812004862	t	1800.00	1700.00	\N	\N	0.00	2025-10-19 02:29:40.852165	2025-10-19 02:29:40.852165
03bf8214-1c1b-49b5-9466-e41a005a5057	REFISAL 1.000GR	7703812101202	t	2400.00	2275.00	\N	\N	0.00	2025-10-19 02:29:40.852372	2025-10-19 02:29:40.852372
3d7fcfb2-bedf-4d4f-8aff-a29a9cd1faed	REFISAL 500GR	7703812101103	t	1300.00	1240.00	\N	\N	0.00	2025-10-19 02:29:40.852574	2025-10-19 02:29:40.852574
4fe29428-9a82-425d-8e32-cbde87d3d2c3	REXONA BAMBU ROLLON 30ML	78924222	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:40.852788	2025-10-19 02:29:40.852788
82213614-1a0f-4d42-9143-f11a4131fdcb	REXONA V8 MEN ROLLON 30ML	78930841	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:40.85302	2025-10-19 02:29:40.85302
d18194e1-9e2c-41a3-b5d2-35f6a67155d3	SALSA SABOR A QUESO RIK 300GR	7590006200595	t	16000.00	15500.00	\N	\N	0.00	2025-10-19 02:29:40.853221	2025-10-19 02:29:40.853221
101490fb-1469-466c-9f3e-f9f3aad00cc0	ROBINSON LEUDANTE 1.000GR	7707197613404	t	3400.00	3300.00	\N	\N	5.00	2025-10-19 02:29:40.853418	2025-10-19 02:29:40.853418
01403634-242e-4fc0-9491-5bfe2ca23815	ROBINSON TRADICIONAL 1.000GR	7707197617846	t	3100.00	3000.00	\N	\N	5.00	2025-10-19 02:29:40.853609	2025-10-19 02:29:40.853609
ba75361b-7b26-4c52-b6e3-4defcbdc2d43	SALTIN NOEL X6UNID	7702025132652	t	9400.00	9200.00	\N	\N	0.00	2025-10-19 02:29:40.853814	2025-10-19 02:29:40.853814
657243ce-7e6d-4a79-ae7c-63a6d42f5cb4	SALTIN NOEL 9X3	7702025136001	t	5500.00	5350.00	\N	\N	19.00	2025-10-19 02:29:40.854042	2025-10-19 02:29:40.854042
f01edcea-b84f-4948-93f9-951306759dd8	SALTIN NOEL 4 TACOS	7702025125173	t	6600.00	6440.00	\N	\N	19.00	2025-10-19 02:29:40.854262	2025-10-19 02:29:40.854262
9e8dac69-3094-4012-835d-62dba979a9e4	Savital Acondicionador 100ml	7702006206020	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:40.854445	2025-10-19 02:29:40.854445
caa74b69-b3cd-4f88-96be-88d4a51e9b91	CREMA DE PEINA SAVITAL 90ML	7702006299251	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:40.854647	2025-10-19 02:29:40.854647
4bcf4f49-5d46-4fa4-b726-e0e7474e9d67	PRESTOBARBA SCHICK XTREME VERDE	7591066701015	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.854849	2025-10-19 02:29:40.854849
893a7309-fef4-493c-ba6b-5d99d96e09f1	ESPONJA LA MAQUINA SCOTCH BRITE	7702098203105	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.85506	2025-10-19 02:29:40.85506
fe2be8c0-f96b-40ca-8a8d-134e97ae47f0	SCOTT DURAMAX REUTILIZABLE X3UNID	7702425802865	t	26500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.855274	2025-10-19 02:29:40.855274
db5f06a8-a208-44e8-81f7-1193b8352771	CAFE SELLO ROJO X10UNID 500GR	7702032552023	t	23000.00	\N	\N	\N	5.00	2025-10-19 02:29:40.855503	2025-10-19 02:29:40.855503
10adaa8b-a2e8-4aae-984f-36d242a92b6f	CAFE SELLO ROJO 125GR	7702032252251	t	7100.00	6950.00	\N	\N	5.00	2025-10-19 02:29:40.855716	2025-10-19 02:29:40.855716
da65fefa-167b-4e6f-b28c-0af802db53f4	CAFE SELLO ROJO 250GR	7702032252190	t	10400.00	10200.00	\N	\N	5.00	2025-10-19 02:29:40.855927	2025-10-19 02:29:40.855927
61af62ff-abfc-4f18-8e98-b24721d2c81f	CAFE SELLO ROJO 500GR	7702032252114	t	26900.00	26650.00	\N	\N	5.00	2025-10-19 02:29:40.856112	2025-10-19 02:29:40.856112
8b5fe92e-ee11-4513-b330-42766b12ee29	PRESTOBARBA QUATRO 4	4891228530136	t	4200.00	3850.00	\N	\N	19.00	2025-10-19 02:29:40.856328	2025-10-19 02:29:40.856328
5055e4da-cfdf-4c0a-a7c8-90c9a257ab81	QIDA CAT 500GR	7702712003371	t	4800.00	4600.00	\N	\N	5.00	2025-10-19 02:29:40.856517	2025-10-19 02:29:40.856517
24bde1fd-71a2-41fe-a8b2-735ac5e44005	SPARKIES X70UNI	7702133462276	t	9300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.85669	2025-10-19 02:29:40.85669
f06464d9-639e-4275-9e40-8edbaa79c6af	SUAVITEL VAINILLA 180ML	7509546676029	t	1500.00	1380.00	\N	\N	19.00	2025-10-19 02:29:40.856871	2025-10-19 02:29:40.856871
34b9bcda-7f38-4d42-aa9e-d31595c04ee5	SUAVITEL PRIMAVERAS430ML	7702010282485	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:40.857081	2025-10-19 02:29:40.857081
4f8c01db-f085-4dda-a5e2-361c16dc6317	SUPER RIEL BARRA 400GR	7702310010429	t	3200.00	3084.00	\N	\N	19.00	2025-10-19 02:29:40.857278	2025-10-19 02:29:40.857278
9bec264d-42fa-4c8d-9ad1-192b1554b5b7	SUPREMO BARRA 300GR	7709658360193	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:40.857483	2025-10-19 02:29:40.857483
8235a814-fc8b-4d6a-adac-668af50c55ea	TORTILLA INTEGRAL MX8	7705326016485	t	10600.00	10450.00	\N	\N	19.00	2025-10-19 02:29:40.857666	2025-10-19 02:29:40.857666
85e5e664-d780-4b8d-91fd-564ea9c6302d	TRIFOGON DEL FOGON 20GR	7702354955106	t	900.00	867.00	\N	\N	19.00	2025-10-19 02:29:40.857874	2025-10-19 02:29:40.857874
efec6636-789f-45b1-83f2-7e3c6a004e9c	COLGATE TRIPLE ACCION 150ML	7509546000350	t	12000.00	11800.00	\N	\N	19.00	2025-10-19 02:29:40.858043	2025-10-19 02:29:40.858043
a2a51fe8-5f6e-49a7-92ab-eb3f35208fd2	DIABLITOS UNDER WOOD 115GR	7591072003622	t	8900.00	8600.00	\N	\N	19.00	2025-10-19 02:29:40.858229	2025-10-19 02:29:40.858229
412e528b-5a78-4204-a3da-ec95c2392355	BOMBILLOS PHILIPS DOU 12W	7702081994294	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.858407	2025-10-19 02:29:40.858407
a2689c6c-c4af-4b91-9021-e4c4b05cee83	TINTE KERATON 6.66	7707230996051	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:40.858604	2025-10-19 02:29:40.858604
c32a4de9-1446-485d-adce-a086b779bda4	VASELINA ROSADA 60GR	7708448461140	t	2500.00	2200.00	\N	\N	19.00	2025-10-19 02:29:40.858833	2025-10-19 02:29:40.858833
4a93e34f-17f4-4ce2-b257-2451cdd5da62	ATUN VAN CAMPS LOMITOS 160GR	7702367002613	t	6900.00	6800.00	\N	\N	19.00	2025-10-19 02:29:40.85904	2025-10-19 02:29:40.85904
e756dfb2-1e2a-4dd9-94f8-c84d75a9b682	VANISH ROSADO 30GR	7702626204208	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:40.859254	2025-10-19 02:29:40.859254
f5707868-ff0b-4eff-a0a6-c841191361cc	VANISH BLANCO 450ML	7702626216188	t	4800.00	4650.00	\N	\N	19.00	2025-10-19 02:29:40.859634	2025-10-19 02:29:40.859634
2a7aa6b0-7330-4569-906d-bd8b21b1b90d	VEL ROSITA 200GR	7702191163405	t	3100.00	2950.00	\N	\N	19.00	2025-10-19 02:29:40.85984	2025-10-19 02:29:40.85984
df6e0a44-8240-4f1c-b53d-1c8ce54edfe1	VELON SANTA MARIA N4	7707297960040	t	3000.00	2917.00	\N	\N	19.00	2025-10-19 02:29:40.860048	2025-10-19 02:29:40.860048
bc660f91-ee05-4cdb-a0a5-554b6b973098	Vikingos Atun Aceite 170g	7702088803575	t	3800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.860262	2025-10-19 02:29:40.860262
7f9fee48-6aa8-4b24-8f33-649de2764b2b	WINNY 4X30	7701021114006	t	39000.00	38600.00	\N	\N	19.00	2025-10-19 02:29:40.860473	2025-10-19 02:29:40.860473
a22c7847-5a11-4282-b79f-2068104e3dfb	WINNY 5X30	7701021114174	t	43000.00	42500.00	\N	\N	19.00	2025-10-19 02:29:40.860659	2025-10-19 02:29:40.860659
d2b183d6-d3a4-4cc4-9931-88d1e6fd6789	WINNY 0X30	7701021144829	t	22200.00	21800.00	\N	\N	19.00	2025-10-19 02:29:40.860891	2025-10-19 02:29:40.860891
6e7805b7-fa08-4e23-8d3f-6b2f9173a320	WINNY 2X30	7701021116536	t	27000.00	26600.00	\N	\N	19.00	2025-10-19 02:29:40.861126	2025-10-19 02:29:40.861126
fef0ae62-b31e-4e3f-bb2e-bbee380545ec	CREMA YODORA PROTECCION 12GR	7702057080044	t	3400.00	3200.00	\N	\N	19.00	2025-10-19 02:29:40.861323	2025-10-19 02:29:40.861323
97ed5170-258a-41b8-9817-6f8872d45892	ARVEJA NATURAL ZENU 580GR	7701101233160	t	6100.00	\N	\N	\N	19.00	2025-10-19 02:29:40.861531	2025-10-19 02:29:40.861531
f05809cb-108c-43e4-8491-83445e05e4fa	ARVEJA CON ZANAHORIA ZENU 300GR	7701101233085	t	5100.00	4950.00	\N	\N	19.00	2025-10-19 02:29:40.861723	2025-10-19 02:29:40.861723
bb946075-e87d-4a8d-a8ae-b18475c27854	SALCHICHA FRANFURT ZENU X7UNID	7701101244708	t	10400.00	10100.00	\N	\N	19.00	2025-10-19 02:29:40.861935	2025-10-19 02:29:40.861935
89db7034-4477-4c53-94cf-19b9094c6c73	TALCO BOROCANFOR 120GR	75930530	t	3200.00	2900.00	\N	\N	19.00	2025-10-19 02:29:40.862155	2025-10-19 02:29:40.862155
b25b1072-7f65-4ef6-b9db-709e6af83a78	PONDS AGE MIRACLE 7GR	7702006207515	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:40.862351	2025-10-19 02:29:40.862351
0fda7ecb-a650-4cb5-80e8-5c696a284464	PONDS FACIAL DESMAQUILLADORA	7702006207522	t	1500.00	1367.00	\N	\N	19.00	2025-10-19 02:29:40.862573	2025-10-19 02:29:40.862573
45231d10-0200-41b5-b6e3-215f32fd5fea	Pantene	7500435170741	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.862798	2025-10-19 02:29:40.862798
0ac21690-59ce-4859-bb39-de0a4b2fffdc	SHAMPO SAVITAL MULTIVITAMINA	7702006202367	t	1000.00	875.00	\N	\N	19.00	2025-10-19 02:29:40.862995	2025-10-19 02:29:40.862995
e570a7c6-6536-4250-87dc-1f56f91b74e3	JOHNSNS ORIGINAL 110GR	7702031414346	t	2900.00	2800.00	\N	\N	19.00	2025-10-19 02:29:40.863212	2025-10-19 02:29:40.863212
cddb97cd-93f3-4afd-ae50-8d1dffde1d0c	JOHNSONS ALMENDRAS Y AVENA 110GR	7702031407362	t	2900.00	2800.00	\N	\N	19.00	2025-10-19 02:29:40.863428	2025-10-19 02:29:40.863428
b0ad990b-8c02-41f2-9724-daa05c8e29ef	AVENA HOJUELAS QUAKER 190GR	7702193101283	t	1800.00	\N	\N	\N	5.00	2025-10-19 02:29:40.863647	2025-10-19 02:29:40.863647
d135f853-2b36-4e64-be86-fe3cf54773e4	Quaker	7702189027832	t	500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.863828	2025-10-19 02:29:40.863828
f871721d-9550-4ccd-8976-ca3e3e0bc219	QUESO REDONDO PEQUEÑO DOBLE CREMA	queso	t	5800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.864016	2025-10-19 02:29:40.864016
7ffe8dd6-09a1-4568-9051-8e9f31350c51	FESTIVAL CHOCOLATE 12X4	7702025103904	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.864246	2025-10-19 02:29:40.864246
dfa200d2-69a1-4821-bb01-306df95f94ad	FESTIVAL CHOCOLATE 12X6	7702025182169	t	12700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.864476	2025-10-19 02:29:40.864476
cf059ffa-66a5-4082-9841-8cccafe549d5	FESTIVAL LIMON 6X12	7702025182176	t	12300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.864691	2025-10-19 02:29:40.864691
1ca886b9-5fe2-409a-9ca1-a134e3bd3454	Pin Pop 24U	7702174082334	t	6600.00	\N	\N	\N	19.00	2025-10-19 02:29:40.864902	2025-10-19 02:29:40.864902
a4ae0466-efa0-4bfe-b71f-a55ce804afdc	GELATINA FRUTIÑO SIN SABOR 4UNID 30GR	7702354009397	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:40.865111	2025-10-19 02:29:40.865111
5a4fad0c-2e39-45b8-aa6c-1b1c8e92d738	AVENA HOJUELA IDEAL 500GR	7708937039249	t	2600.00	2450.00	\N	\N	5.00	2025-10-19 02:29:40.865321	2025-10-19 02:29:40.865321
9cb34aa1-72af-40d3-9929-2fedb1505882	ARROZ DIANA 500GR	7702511000014	t	2000.00	\N	\N	\N	0.00	2025-10-19 02:29:40.865503	2025-10-19 02:29:40.865503
9de30237-6633-43ac-a9c7-258ed203f46d	CREMARROZ FRESA 200GR	7703092460327	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:40.865683	2025-10-19 02:29:40.865683
c62e45f2-c422-4f4f-8f1f-693730b31ad0	CONCHITA LA MUÑECA 250GR	7702020112130	t	1900.00	1790.00	\N	\N	5.00	2025-10-19 02:29:40.865859	2025-10-19 02:29:40.865859
f42503e6-772a-4e72-b78f-938248c07163	SPAGHETTI COMARRICO 1.000GR	7707307961067	t	5600.00	5417.00	\N	\N	5.00	2025-10-19 02:29:40.86606	2025-10-19 02:29:40.86606
47b849e2-388c-4dc7-a375-9a8ec11ff83d	SPAGHETTI DORIA 250GR	7702085012024	t	2200.00	2100.00	\N	\N	5.00	2025-10-19 02:29:40.866334	2025-10-19 02:29:40.866334
59e5ea73-86e0-42e1-8116-858c4f4af64f	CABELLO DE ANGEL DORIA 250GR	7702085012079	t	2200.00	\N	\N	\N	5.00	2025-10-19 02:29:40.866572	2025-10-19 02:29:40.866572
3b68275d-7f1d-4b13-b018-da31691b4816	WINNY 3X30	7701021111821	t	32900.00	32300.00	\N	\N	19.00	2025-10-19 02:29:40.866806	2025-10-19 02:29:40.866806
54604192-a53c-47d0-a003-361751445d92	LOZACREAM BLANCOX ROSA 450GR	7703812003209	t	6500.00	6350.00	\N	\N	19.00	2025-10-19 02:29:40.867245	2025-10-19 02:29:40.867245
909fa871-cf89-445e-b26c-bc9a29798bd8	BLANCOX LOZACREM 250GR	7703812003797	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:40.867591	2025-10-19 02:29:40.867591
81dd5c77-cca0-49bd-89c4-025859b332e5	Carefree Protectores x 15U	7702031500605	t	1600.00	1500.00	\N	\N	0.00	2025-10-19 02:29:40.867851	2025-10-19 02:29:40.867851
3c432e83-be75-4634-9cfd-134a74c50cb7	NOSOTRA RAPIGEL X30UNID	7702027424038	t	13600.00	13300.00	\N	\N	0.00	2025-10-19 02:29:40.868069	2025-10-19 02:29:40.868069
9bd0cb73-1c93-47fb-b061-b3cdb2a2fb62	VELON SANTA MARIA N8	7707297960095	t	7800.00	7580.00	\N	\N	19.00	2025-10-19 02:29:40.868267	2025-10-19 02:29:40.868267
2f9d03c2-9224-4ca5-97cd-7540ec5de1fa	Knorr Rinde Mas	7702047040607	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.868528	2025-10-19 02:29:40.868528
81f11307-eeba-49d1-9740-adc2594a5e2e	BATILADO AREQUIPE 82GR	7702354320010	t	4500.00	4400.00	\N	\N	19.00	2025-10-19 02:29:40.86872	2025-10-19 02:29:40.86872
6c716377-c298-4c41-9016-b7e80eb2c26c	Batilado	7702354320065	t	4500.00	4400.00	\N	\N	19.00	2025-10-19 02:29:40.86892	2025-10-19 02:29:40.86892
dc7a65b4-78fa-4f80-ab3b-faca8b08aff4	BATILADO VAINILLA 82GR	7702354320126	t	4500.00	4400.00	\N	\N	19.00	2025-10-19 02:29:40.86914	2025-10-19 02:29:40.86914
99e752d2-ef30-4f91-84dc-9f8de37e0dfe	DOG CHOW 350GR	7702521181505	t	3800.00	3670.00	\N	\N	5.00	2025-10-19 02:29:40.869359	2025-10-19 02:29:40.869359
31652c89-2e2b-44c5-bee0-95e430741197	CHOCOLISTO 200GR	7702007216127	t	7900.00	7800.00	\N	\N	19.00	2025-10-19 02:29:40.869552	2025-10-19 02:29:40.869552
58e215f0-fb7c-4713-ac28-f4a50ebc382c	QUESADA CHOCOLATE 250GR	7702088101008	t	7600.00	7400.00	\N	\N	5.00	2025-10-19 02:29:40.869755	2025-10-19 02:29:40.869755
5b634eb4-a0af-479f-911b-8e31cfaa24a4	CHOCOLATE QUESADA 250GR	7702088132217	t	7600.00	7400.00	\N	\N	5.00	2025-10-19 02:29:40.869957	2025-10-19 02:29:40.869957
4c4a3c3d-207d-4cf0-9104-baf31b48df2b	CHOCOLATE QUESADA 500GR	7702088132088	t	12400.00	12100.00	\N	\N	5.00	2025-10-19 02:29:40.870141	2025-10-19 02:29:40.870141
e8ddcab9-3f3c-4d78-8c44-73905e692214	CHOCO LISTO CHOCOLATE TARRO 1.000GR	7702007216066	t	28500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.870488	2025-10-19 02:29:40.870488
a03fbe6c-33d6-4e95-9aa7-7b313b665e6d	PRESTOBARBA SCHICK AZUL	7591066721020	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.870697	2025-10-19 02:29:40.870697
3f33a9fb-78a2-4943-b1b5-e981c32f6eee	Sedal	7702006207591	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.870906	2025-10-19 02:29:40.870906
9e07bbb8-55e6-4a24-9b4c-fb2edf14fa0a	FRUTIÑO PANELA LIMON	7702354955953	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:40.871112	2025-10-19 02:29:40.871112
aa125549-1361-41af-96b2-0b3c48bc50e3	Head Shoulders Coco	7500435144735	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:40.871315	2025-10-19 02:29:40.871315
4c5fea67-b912-45b0-a0bd-3234cf897e24	DETERGENTE AK1 1.800ML	7702310048088	t	17400.00	17000.00	\N	\N	0.00	2025-10-19 02:29:40.871529	2025-10-19 02:29:40.871529
14c64916-1736-430c-96c9-2984c25a134f	AROMATEL FLORAL 900ML	7702191161418	t	8200.00	8000.00	\N	\N	19.00	2025-10-19 02:29:40.871775	2025-10-19 02:29:40.871775
16673b74-02c9-453c-9ebd-0a0aab6f4eb1	COCOSETTE X8	7702024381358	t	12500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.871958	2025-10-19 02:29:40.871958
75f12509-c493-4c16-adf7-33542ec21aaa	AROMATEL FLORAL 180ML	7702191162712	t	1600.00	1450.00	\N	\N	19.00	2025-10-19 02:29:40.872167	2025-10-19 02:29:40.872167
94a59414-e09b-413e-ae50-77f2f53d9362	Winny panales por unidad	WPU	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:40.87238	2025-10-19 02:29:40.87238
8c4f68a0-624a-4613-a0e7-a1f54a0aaf52	SHAMPOO FRESKITO 800ML	7709745310094	t	8500.00	8300.00	\N	\N	19.00	2025-10-19 02:29:40.872573	2025-10-19 02:29:40.872573
92ff2127-c9cc-4ecb-93d4-7c7a35e3b529	CEPILLO FLUOCARDENT KIDS	7702560042133	t	2500.00	2350.00	\N	\N	19.00	2025-10-19 02:29:40.87276	2025-10-19 02:29:40.87276
4bb99187-11de-4603-8131-eabe8fa7c968	BON AIRE VARITAS FRUTOS ROJOS 40ML	7702532312103	t	8900.00	8700.00	\N	\N	19.00	2025-10-19 02:29:40.872972	2025-10-19 02:29:40.872972
16bd657f-7ee0-4e3f-9366-0cd8b9b7fda0	KATORI LIQUIDO 120ML	7702332000286	t	2600.00	2450.00	\N	\N	0.00	2025-10-19 02:29:40.873166	2025-10-19 02:29:40.873166
06de585d-f2d6-45b9-998c-8dce05c1ca5e	SALSA BBQ IDEAL 225GR	7709747919011	t	2700.00	2580.00	2470.00	\N	19.00	2025-10-19 02:29:40.873373	2025-10-19 02:29:40.873373
97c04860-a882-488a-956f-97560ea23217	PRESTOBARBA GILLETTE 3	7702018880409	t	3900.00	3750.00	\N	\N	19.00	2025-10-19 02:29:40.874332	2025-10-19 02:29:40.874332
826b6e4e-339a-4c9b-82a5-cd0fc2f36ace	PRESTOBARBA VENUS GILLETTE 4	7702018072439	t	4200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.874542	2025-10-19 02:29:40.874542
1f32b1bd-4738-4860-bf4c-382a08236ced	PILAS EVERADY ALKALINA GOLD AA	8888021201444	t	3400.00	3200.00	\N	\N	19.00	2025-10-19 02:29:40.874738	2025-10-19 02:29:40.874738
9051300a-c633-41d7-8d19-96c4aeb3bff7	PILAS EVEREADY ALKALINA GOLD AAA	8888021201468	t	3400.00	3200.00	\N	\N	19.00	2025-10-19 02:29:40.874997	2025-10-19 02:29:40.874997
3ffe6b66-c5ce-4b2e-971c-43a8fc6fa6be	PIN POP CEREZA ECLIPSE X24 ROJO NEGRO	7702174085380	t	6600.00	\N	\N	\N	19.00	2025-10-19 02:29:40.87525	2025-10-19 02:29:40.87525
c2435e86-c20a-48a4-9cff-9957684e8b72	TOALLAS ANGELAS INVISIVLE X24UNID	7707324640884	t	5300.00	5000.00	\N	\N	0.00	2025-10-19 02:29:40.875429	2025-10-19 02:29:40.875429
633c8d02-2c08-4a3e-a2eb-e16061c220ef	BOMBILLO SANTA BLANCA LED 30W	7707822754304	t	13500.00	13000.00	\N	\N	19.00	2025-10-19 02:29:40.875623	2025-10-19 02:29:40.875623
24fa028a-bc76-4be3-a2a0-2d74f21b28a0	VELA AMBIENTADOR MANZANA CANELA BONDI	7707426910991	t	10800.00	10400.00	\N	\N	19.00	2025-10-19 02:29:40.875809	2025-10-19 02:29:40.875809
62d5bd4f-03fd-4d52-8255-a2c298fcab3e	Pastilla Cloro	Pcl	t	2000.00	\N	\N	\N	0.00	2025-10-19 02:29:40.876066	2025-10-19 02:29:40.876066
52866039-f8c9-4486-b4be-f1117c40150f	PRESTOBARBA DORCO 2	8801038562445	t	700.00	542.00	\N	\N	19.00	2025-10-19 02:29:40.87627	2025-10-19 02:29:40.87627
c8f11cca-0410-4070-92d8-bb4604bb2ca0	TINTE LISSIA 1.0	7703819301810	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.876466	2025-10-19 02:29:40.876466
13be988c-cdb3-4a7e-b6c4-9aae0aa4904b	PIAZZA CHOCO LECHE X24	7702011272720	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:40.87667	2025-10-19 02:29:40.87667
1e4f24bf-aaf6-46f3-8e93-f24b79c25b1f	PLUMERO ARCOIRIS PINTO	7707112351206	t	8900.00	\N	\N	\N	19.00	2025-10-19 02:29:40.876958	2025-10-19 02:29:40.876958
1e88ec00-dada-4a81-a037-4c00d27fba73	DUCALES 6 TACOS 882GR	7702025144822	t	15400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.877158	2025-10-19 02:29:40.877158
656d0d29-92a5-47a9-99d1-7e7e16e9cc72	WAFER 77 X24UNID	8681863142148	t	29500.00	28700.00	\N	\N	19.00	2025-10-19 02:29:40.877363	2025-10-19 02:29:40.877363
c5964734-019c-427c-994b-da6416b7bde7	GILLETE SPECIALIZEO 45GR	7500435129947	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.877557	2025-10-19 02:29:40.877557
d1fb16d7-7597-436a-ad17-cc883392888a	SUAVITEL LAVANDA 400ML	7702010282898	t	3300.00	3150.00	\N	\N	19.00	2025-10-19 02:29:40.877786	2025-10-19 02:29:40.877786
75ee55e4-8e20-4599-89f1-ee773acea543	FOFI CAT ARENA 1KG	7709052836355	t	5400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.878007	2025-10-19 02:29:40.878007
ee059e2b-9ece-40e9-8c82-33e462f8e54a	CEPILLO CON PROTECTOR	9780201372410	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.878206	2025-10-19 02:29:40.878206
8eec3ba6-30f6-4509-8b61-c8660b5c23c8	BON AIRE VARITAS BAMBU 40ML	7702532476836	t	8900.00	8700.00	\N	\N	19.00	2025-10-19 02:29:40.87838	2025-10-19 02:29:40.87838
0ff1b040-f123-43f9-a92f-134c328351a2	BON AIRE VARITAS VAINILLA 40ML	7702532312127	t	8900.00	8700.00	\N	\N	19.00	2025-10-19 02:29:40.878577	2025-10-19 02:29:40.878577
842e0b9b-263e-4961-83aa-d61e5628cd8c	MEDICASP SHAMPOO 100ML	650240029158	t	28000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.878752	2025-10-19 02:29:40.878752
2e9333bd-7fe6-4329-b504-8dfbd5bafe43	SHAMPO NATURALEZA Y VIDA RUBIOS 300ML	7702377303120	t	13500.00	\N	\N	\N	0.00	2025-10-19 02:29:40.878932	2025-10-19 02:29:40.878932
613f1fb0-5e50-4dac-9ab3-710da6aad5af	MASCARILLA NATURALEZA Y VIDA NEGROS 300ML	7702377303052	t	25500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.879151	2025-10-19 02:29:40.879151
8076ad0b-325b-4d01-95b7-8aa6c0de3355	BALANCE MEN 11.5GR	7702045442755	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.879339	2025-10-19 02:29:40.879339
4edf21a4-5991-44a0-9a20-1155612c9e15	SALCHICHA COLANTA XL X4UNID	7702129073394	t	7500.00	7300.00	\N	\N	19.00	2025-10-19 02:29:40.87953	2025-10-19 02:29:40.87953
22bfc06b-478e-4658-9fd4-365c14cbcd97	CHORIZO COCTEL DE TERNERA COLANTA	7702129072458	t	13200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.879699	2025-10-19 02:29:40.879699
bcb2d54c-fcf7-42af-93ed-f3a5daa48790	LADY SPEED STICK DUO CREMA TARRO	7702010971471	t	18400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.87988	2025-10-19 02:29:40.87988
89e0c1a2-478a-4cdc-a6e6-5cefe041bfc6	CHEETOS FLAMIN HOT 37GR	7702189055880	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.88021	2025-10-19 02:29:40.88021
7b1e497d-d53b-4373-bf42-1000a44103b0	DORITOS FLAMIN HOT 41GR	7702189055835	t	2600.00	2500.00	2390.00	\N	19.00	2025-10-19 02:29:40.880467	2025-10-19 02:29:40.880467
c0399910-4944-433c-8d4c-c042037bfb46	CHEETOS HORNEADOS 160GR	7702189045577	t	7100.00	6900.00	6800.00	\N	19.00	2025-10-19 02:29:40.880655	2025-10-19 02:29:40.880655
76f227e7-4b42-4103-b99e-40f71e8192fe	CHOCLITOS PICANTE 190GR	7702189055705	t	8000.00	7400.00	\N	\N	19.00	2025-10-19 02:29:40.880887	2025-10-19 02:29:40.880887
87394a85-9577-42fb-a251-2ef38ebb12dc	BETUM LIQUIDO PLATINO BLANCK 75ML	6901625263716	t	5200.00	5000.00	\N	\N	19.00	2025-10-19 02:29:40.881104	2025-10-19 02:29:40.881104
046bb0b9-89f9-4ba3-ac60-67e31d7c40a1	NOXPIRIN	Nospirin	t	1200.00	1000.00	\N	\N	0.00	2025-10-19 02:29:40.948954	2025-10-19 02:29:40.948954
fc4196e3-5336-4465-b163-091870882fcc	ESCOBA KARACA SIN MANGO SUAVE PINTO	7707112320967	t	11600.00	11300.00	\N	\N	19.00	2025-10-19 02:29:40.881341	2025-10-19 02:29:40.881341
3b5a7bb4-e6cf-43b7-94c2-04816807ef2f	TALLARIN DORIA 250GR	7702085012055	t	2200.00	2000.00	\N	\N	5.00	2025-10-19 02:29:40.881559	2025-10-19 02:29:40.881559
0200d5a8-06b1-4abb-a299-1c66763f1305	PONDS CLARANT B3 8.5G	7702006402620	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:40.881739	2025-10-19 02:29:40.881739
e78e38ae-e4be-4f04-b25c-a309ce05b214	EMULSION DE SCOTT FRUTAL 180ML	7707172681183	t	14500.00	14000.00	\N	\N	0.00	2025-10-19 02:29:40.881935	2025-10-19 02:29:40.881935
45cd16f2-5202-4012-96ae-50487dbaa2e8	HEAD Y SHOULDERS CONTROL CASPA 18ML	7501065922243	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:40.882162	2025-10-19 02:29:40.882162
92779432-3e0f-44b2-92cc-b6febf652482	PONDS CREMA S 8.5GR	7702006402613	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:40.88246	2025-10-19 02:29:40.88246
5139bb66-c8b0-4005-84fd-1d21d7885216	cubito	cu1	t	400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.882651	2025-10-19 02:29:40.882651
c26269d4-c742-4be2-8560-41141e5e32d8	SHAMPOO SAVITAL ACEITE DE ARGAN	7702006203982	t	1000.00	875.00	\N	\N	19.00	2025-10-19 02:29:40.882827	2025-10-19 02:29:40.882827
6ace6a56-93cc-4c67-b487-0479c2940539	CREMA PARA PEINAR SAVITAL	7702006203999	t	1000.00	900.00	\N	\N	19.00	2025-10-19 02:29:40.883038	2025-10-19 02:29:40.883038
29a5e9d0-3f43-40e5-a883-cf0d8e96b11d	Alka-Seltzer	aks	t	800.00	\N	\N	\N	0.00	2025-10-19 02:29:40.883293	2025-10-19 02:29:40.883293
b221ba08-5f2f-469f-8c22-2e491b3fae70	Buscapina Fem	4048846003898	t	1500.00	\N	\N	\N	0.00	2025-10-19 02:29:40.883641	2025-10-19 02:29:40.883641
94cb6964-2361-48de-93b9-8283c7d4f638	VICK VAPORUB 12GR	75916565	t	4800.00	4660.00	\N	\N	0.00	2025-10-19 02:29:40.884005	2025-10-19 02:29:40.884005
b45e5102-613a-4fbd-973b-f9102cfe67b2	IBUFLASH	7702057613198	t	2200.00	\N	\N	\N	0.00	2025-10-19 02:29:40.884236	2025-10-19 02:29:40.884236
f9e0cb21-a735-4c75-aa0e-1f9ea80c2f16	Sevedol Forte unidad	7702870004609	t	1200.00	\N	\N	\N	0.00	2025-10-19 02:29:40.884438	2025-10-19 02:29:40.884438
fb7d5332-c903-4069-b870-e495844737fd	SPEED STICK DUO CREMA 9G	7501033206580	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.884633	2025-10-19 02:29:40.884633
b971ccbf-456f-4bea-be8f-e7e23f5ba707	PEINE	pn1	t	600.00	\N	\N	\N	19.00	2025-10-19 02:29:40.884835	2025-10-19 02:29:40.884835
c022cd23-d2bd-49a9-bf14-547263f1ed39	COPITOS ARCOIRIS	7702208115113	t	2300.00	2100.00	\N	\N	19.00	2025-10-19 02:29:40.88507	2025-10-19 02:29:40.88507
8b6089a1-b665-46c5-abbf-e7860b033c1c	CERA EGO 60ML	7702006300063	t	4000.00	3900.00	\N	\N	19.00	2025-10-19 02:29:40.885347	2025-10-19 02:29:40.885347
684d9881-b79f-4f65-ad24-2f4335a7b55f	Dove Karite	7891150019560	t	4000.00	3840.00	\N	\N	19.00	2025-10-19 02:29:40.885527	2025-10-19 02:29:40.885527
3eaebd6a-bd81-4848-925e-82136fb2a65a	CLORO MAX 2L	7702487563247	t	3500.00	3350.00	\N	\N	19.00	2025-10-19 02:29:40.885744	2025-10-19 02:29:40.885744
2b7e4127-a368-4dac-8305-b0885033166d	SCHICK WOMEN QUATRO	7502214739620	t	4200.00	3850.00	\N	\N	19.00	2025-10-19 02:29:40.885949	2025-10-19 02:29:40.885949
7bc98519-3528-42e5-8f5e-048efece9f4d	Sanpic Lavanda	7702626218342	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:40.8862	2025-10-19 02:29:40.8862
a1984dde-d95d-48ab-883a-9e9e4e05e39b	GANCHOS PARA ROPA	7592302020877	t	5200.00	5000.00	\N	\N	19.00	2025-10-19 02:29:40.886442	2025-10-19 02:29:40.886442
93932a4c-3fea-4a89-8cb0-02ed37c176eb	F	B25	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.886998	2025-10-19 02:29:40.886998
34299ad7-3834-4fdc-abbe-6c54d00e7d50	JUGO NECTAR CALIFORNIA 215ML PERA	7702617021142	t	2400.00	2200.00	\N	\N	19.00	2025-10-19 02:29:40.88745	2025-10-19 02:29:40.88745
9c077c61-f576-41f1-8731-e77465db55bb	CD	B5	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.888047	2025-10-19 02:29:40.888047
cef677dc-48a7-4066-a22b-943f9dc2af12	DSV	DSCD	t	1000.00	\N	\N	\N	0.00	2025-10-19 02:29:40.888363	2025-10-19 02:29:40.888363
6945165d-99cd-45de-8f36-688b901dcbfc	Suavitel Complete 180 ml.	7509546676012	t	1500.00	1380.00	\N	\N	19.00	2025-10-19 02:29:40.888721	2025-10-19 02:29:40.888721
19ff19a9-0e6d-4786-bcdb-c559bc87bc4b	COLCAFE SUAVE CLASICO 200GR	7702032107834	t	27700.00	27200.00	\N	\N	5.00	2025-10-19 02:29:40.889023	2025-10-19 02:29:40.889023
36e0015e-ef76-4786-9fb9-5166be70fba5	SUAVITEL FRESAS CON CHOCOLATE 180ML	7509546676050	t	1500.00	1380.00	\N	\N	19.00	2025-10-19 02:29:40.889264	2025-10-19 02:29:40.889264
9776e45c-ecec-480b-904a-6ec3f73871ec	VELON SANTA MARIA N2	7707297960057	t	1500.00	1459.00	\N	\N	19.00	2025-10-19 02:29:40.889582	2025-10-19 02:29:40.889582
5d782977-9d8a-4100-b241-163753d6c06b	VELON SANTAMARIA TURRA X12UNID	7707297960125	t	11000.00	\N	\N	\N	0.00	2025-10-19 02:29:40.88996	2025-10-19 02:29:40.88996
f19b58c6-af3f-4901-ac55-0b12532a23ee	TOALLIN NUBE X50HOJAS	7707151602178	t	2100.00	1940.00	\N	\N	19.00	2025-10-19 02:29:40.890233	2025-10-19 02:29:40.890233
7e7cb1ce-ed6e-4f93-b291-4f033a0a582e	DURAMAX SCOTT REUTILIZABLE 58	7702425802872	t	11000.00	10700.00	\N	\N	19.00	2025-10-19 02:29:40.890478	2025-10-19 02:29:40.890478
4bd63ec6-b1fa-4fba-8be5-59c06599a4a9	PROTECTORES NOSOTRAS 120 MAS 30	7702027044199	t	15500.00	15100.00	\N	\N	0.00	2025-10-19 02:29:40.890736	2025-10-19 02:29:40.890736
54e57460-60bd-473f-9598-99d88adfeeb2	DURAZNO EN ALMIBAR PRADO 260GR	7709990496628	t	3900.00	3750.00	\N	\N	0.00	2025-10-19 02:29:40.890945	2025-10-19 02:29:40.890945
46306d36-c43c-4c73-8d12-2975e852a4d1	PAÑAL TENA SLIP LX21	7702027479731	t	63000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.891222	2025-10-19 02:29:40.891222
164a9842-5f6d-4114-a446-7256cc3d488f	SDG	DSG	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.891436	2025-10-19 02:29:40.891436
9081d7c5-f81f-4423-b3cf-615c30e41ec8	VASOS 7OZ FORMOSA X50UNID	7707330760446	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:40.891749	2025-10-19 02:29:40.891749
1a7041a0-4cf1-4202-8781-46898d5cf760	MERMELADA LA CONSTANCIA PIÑA 90GR	7702097066947	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:40.892121	2025-10-19 02:29:40.892121
ba7ba307-5c5c-4c3f-a2f9-95dfab45dfd8	MERMELADA LA CONSANCIA MORA 90GR	7702097148575	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:40.892601	2025-10-19 02:29:40.892601
07360173-bd9d-46d7-80b3-82cf39e30ad4	MOSTANEZA LA CONSTANCIA 80GR	7702097148599	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:40.893159	2025-10-19 02:29:40.893159
c22e1b44-b3c0-4e3a-9c4b-64373e7c4be3	SALSA BBQ BARY 110GR	7702439845322	t	1800.00	1650.00	\N	\N	19.00	2025-10-19 02:29:40.89377	2025-10-19 02:29:40.89377
18b286eb-8724-4dc3-9b81-b00c4db8cdc9	MAYONESA M 445GR	719503030123	t	12500.00	12100.00	\N	\N	19.00	2025-10-19 02:29:40.894401	2025-10-19 02:29:40.894401
9df65fda-1912-4dc7-b3f1-fa693cb8ea36	BEBEX 2M X30UNID	7707199340940	t	22900.00	22500.00	\N	\N	19.00	2025-10-19 02:29:40.895026	2025-10-19 02:29:40.895026
2e6f2e51-459f-4654-b1d5-1ce9b674e985	CAJA JABON ORO 25UND	17702141000535	t	30500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.895484	2025-10-19 02:29:40.895484
390d266e-e86f-4a3d-abbb-10fda5db8e03	DUCALES TENTACION X8UNID	7702025114016	t	7200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.895811	2025-10-19 02:29:40.895811
3a51a303-6149-4ae6-977e-d736e7b27298	AVENA DON PANCHO HOJUELA 180GR	7702193101252	t	1600.00	1500.00	\N	\N	5.00	2025-10-19 02:29:40.896297	2025-10-19 02:29:40.896297
273cd3e0-a3ef-4624-b7ce-afbbf5459fdb	CHOCOLATE QUESADA 500GR	7702088132422	t	12400.00	12100.00	\N	\N	5.00	2025-10-19 02:29:40.896676	2025-10-19 02:29:40.896676
e1def5ca-10d2-4553-b873-4056464accc1	QUESADA CHOCOLATE 500GR	7702088102050	t	12400.00	12100.00	\N	\N	5.00	2025-10-19 02:29:40.89696	2025-10-19 02:29:40.89696
a4b286ad-b461-412a-aecc-7be47cfa52b8	LA ESPECIAL MAIZ TOSTADO 160GRR	7702007013757	t	5200.00	5000.00	\N	\N	19.00	2025-10-19 02:29:40.897298	2025-10-19 02:29:40.897298
c0c0fa17-a332-40a5-ae0d-a9ed872590e5	WAFER ITALO	7702117007875	t	5900.00	\N	\N	\N	19.00	2025-10-19 02:29:40.89757	2025-10-19 02:29:40.89757
bb0e811d-ea66-4a8f-b20b-d1a8a7c3f5aa	CLUB SOCIAL INTEGRAL 9X3	7750168001694	t	6500.00	\N	\N	\N	5.00	2025-10-19 02:29:40.897859	2025-10-19 02:29:40.897859
0d1a72db-20f4-4902-96a7-8ad003235113	SALTIN NOEL TACO DIA 110GR	7702025150748	t	1900.00	1780.00	\N	\N	19.00	2025-10-19 02:29:40.898123	2025-10-19 02:29:40.898123
1ba3087b-d22a-446e-9555-ab7ef816bf3f	FRUTICAS LOVE CANDY X100UNID	7702011009722	t	9200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.898476	2025-10-19 02:29:40.898476
56c76d57-30a3-4668-bbe2-0a809559eec8	GLOBOOM HUEVITOS 60UNID	7703888298493	t	4600.00	\N	\N	\N	19.00	2025-10-19 02:29:40.898705	2025-10-19 02:29:40.898705
1f9eee62-c0bb-4f8e-bb6f-a66bd0ee4d8d	BIGBOM BLACK XXL X48	7707014902841	t	15700.00	\N	\N	\N	0.00	2025-10-19 02:29:40.898964	2025-10-19 02:29:40.898964
0870f60d-3973-4b6b-bbac-f02f20258446	TRULULU FRESITAS	7702993025130	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:40.899209	2025-10-19 02:29:40.899209
21c693e3-b073-4409-85f7-78ceda1f031d	BIANCHI COOKIES AND CREAM	7702993038246	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:40.899496	2025-10-19 02:29:40.899496
845d6f94-2070-44ea-b86c-d7afae157770	BIANCHI CHOCOLATE	7702993038222	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:40.899704	2025-10-19 02:29:40.899704
dab62b45-df63-445a-bee4-d14a9ccc870d	LOKIÑO MASTICABLE X100UNID	7702993030073	t	7700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.90003	2025-10-19 02:29:40.90003
4e48897b-8bd4-4792-a2fb-da00cde61bbb	TRULULU AROS	7702993031292	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:40.900532	2025-10-19 02:29:40.900532
03c3d573-6a7c-4fea-8245-27e3998cce9e	Trululu Sirenas	7702993039182	t	1900.00	\N	\N	\N	19.00	2025-10-19 02:29:40.901039	2025-10-19 02:29:40.901039
0523e625-10ec-4cbb-b5ca-7c08a7a137de	FULL CLORO 3.8ML	c2001	t	6800.00	6600.00	\N	\N	0.00	2025-10-19 02:29:40.901596	2025-10-19 02:29:40.901596
41e5991c-bdbb-47e0-966d-b46a8237a549	Bianchi Chocolate blanco	7702993038215	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:40.901822	2025-10-19 02:29:40.901822
ed865eee-e704-4e27-ac1b-d44143c5c921	SPLOT CHICLE TATTO 120UNID	7707282387609	t	15300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.902161	2025-10-19 02:29:40.902161
df4aa0fc-bd2a-4d0a-ba5f-3ac010e5eb1f	CREMA DE LECHE NESTLE 90GR	7702024033868	t	3000.00	2900.00	\N	\N	0.00	2025-10-19 02:29:40.902408	2025-10-19 02:29:40.902408
2f41aa91-3538-48ed-a905-2a354fad7ce0	SALMON SOBERANA TOMATE PICANTE	7862910031351	t	4200.00	4070.00	\N	\N	19.00	2025-10-19 02:29:40.902679	2025-10-19 02:29:40.902679
f66e7530-590d-4644-a9f0-eb804cd00291	ATUN LA SOBERANA VEGETALES 160GR	7702910745615	t	6200.00	6000.00	\N	\N	19.00	2025-10-19 02:29:40.902966	2025-10-19 02:29:40.902966
a5879aae-7e94-49c8-aaae-03b369196f92	SALCHICHA RICA VIENA 150GR	7702398007212	t	4500.00	4380.00	\N	\N	19.00	2025-10-19 02:29:40.903203	2025-10-19 02:29:40.903203
c18090bb-f4cb-4009-b29a-6d7637cfe403	ARROZ MARY DORADO 1.000GR	781718832977	t	3600.00	3534.00	\N	\N	0.00	2025-10-19 02:29:40.903458	2025-10-19 02:29:40.903458
08a6bcb7-afa1-4b55-a1f7-95e54aff2e08	LAJOYA LIMPIAPISOS 1.000ML	7702088902506	t	6200.00	5950.00	\N	\N	19.00	2025-10-19 02:29:40.903953	2025-10-19 02:29:40.903953
f7773245-1329-42de-8001-06b4983c8f12	NESTUM 5 CEREALES 200GR	7613033985584	t	13300.00	13000.00	\N	\N	19.00	2025-10-19 02:29:40.904628	2025-10-19 02:29:40.904628
739f28da-7d1b-4d7b-9fbe-53b0e281a785	TUMIX MENTA X100UNID	7703888298684	t	9700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.904909	2025-10-19 02:29:40.904909
66ccad18-bcf3-4e04-aed4-68425cbd1327	ACEITE OLEOCALI GIRASOL 900ML	7701018065991	t	12000.00	11600.00	\N	\N	0.00	2025-10-19 02:29:40.905315	2025-10-19 02:29:40.905315
03dcb511-1043-4765-85e7-bf843f899806	PASPAN LEUDANTE 1.000GR	7707046940170	t	2600.00	2550.00	\N	\N	5.00	2025-10-19 02:29:40.905595	2025-10-19 02:29:40.905595
6c994814-b774-4c15-af52-2363ebf8e3d3	GATSY PESCADO 500GR	7702521098254	t	6000.00	\N	\N	\N	5.00	2025-10-19 02:29:40.905826	2025-10-19 02:29:40.905826
17e1549d-13a9-4c68-be00-f1de7ae05c32	JUGO HIT 500ML	7702090029888	t	2500.00	2292.00	\N	\N	19.00	2025-10-19 02:29:40.906187	2025-10-19 02:29:40.906187
bb8c57a4-a20d-4895-a5b9-f54b15a599df	SPEED MAX	7702090039214	t	1400.00	1334.00	\N	\N	19.00	2025-10-19 02:29:40.906499	2025-10-19 02:29:40.906499
1bfd0fc2-126d-42ca-8121-5a3d0745757f	JUGO HIT 500ML	7702090029864	t	2500.00	2292.00	\N	\N	19.00	2025-10-19 02:29:40.906755	2025-10-19 02:29:40.906755
9dedbd53-f93d-4c2b-bf15-780e181abbfd	GATORADE 500ML	7702192422051	t	3200.00	2875.00	\N	\N	19.00	2025-10-19 02:29:40.906998	2025-10-19 02:29:40.906998
07d62050-8570-4207-b2af-ee7d186a5a6a	COCA COLA 2.5	7702535001783	t	6900.00	6313.00	\N	\N	19.00	2025-10-19 02:29:40.90723	2025-10-19 02:29:40.90723
56bb7a90-e9e5-4893-81db-8e8c4f0dc77a	DORITOS MEGA QUESO 185GR	7702189045782	t	7600.00	7340.00	7200.00	\N	19.00	2025-10-19 02:29:40.90761	2025-10-19 02:29:40.90761
eb4743db-7755-4ad7-bb03-3af89416948b	Agua Cistal	7702090068696	t	2400.00	\N	\N	\N	0.00	2025-10-19 02:29:40.90781	2025-10-19 02:29:40.90781
6ac6832f-c0cb-4e0b-bc11-e1499ce24083	ARROZ ZULIA 5.000GR	7707222292673	t	20000.00	19700.00	\N	\N	0.00	2025-10-19 02:29:40.908162	2025-10-19 02:29:40.908162
c5e52fa0-8acc-426d-852b-257a4cbfa784	DURAZNO LA PRADERA EN ALMIBAR 500GR	7707209120432	t	6200.00	6000.00	\N	\N	19.00	2025-10-19 02:29:40.908365	2025-10-19 02:29:40.908365
2ebc0633-ed32-4627-b308-c7bf28dd3815	Nectar Respin	7702167175500	t	2100.00	\N	\N	\N	0.00	2025-10-19 02:29:40.908626	2025-10-19 02:29:40.908626
fd1b9d01-63d3-40eb-8d5a-0fe99ba7c38d	MIRAMONTE LECHE ENTERA 800GR	7707228547630	t	18700.00	18300.00	\N	\N	0.00	2025-10-19 02:29:40.909143	2025-10-19 02:29:40.909143
e9f3ef28-4537-4c2a-8719-434e7ff18008	LevaPan Levadura	7702014000252	t	600.00	\N	\N	\N	0.00	2025-10-19 02:29:40.909467	2025-10-19 02:29:40.909467
4776e70b-6f11-48e9-a75a-e326b1d02c3e	DE TODITO NATURAL 165GR	7702189057617	t	7600.00	7340.00	7200.00	\N	19.00	2025-10-19 02:29:40.909756	2025-10-19 02:29:40.909756
2aa6d192-6ede-44df-a94f-93a41593ec20	Golpe Con Todo	7703133073509	t	6000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.909997	2025-10-19 02:29:40.909997
77da6721-bfef-42a0-b34b-f4f3d4ede42c	DESEO ALGAS MARINAAS 110GR	7702538251307	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:40.910316	2025-10-19 02:29:40.910316
18acf05b-95d1-410e-a9c4-1c15b8d2a1b7	DESEO MANZANA VERDE 110GR	7702538252205	t	2000.00	1900.00	\N	\N	0.00	2025-10-19 02:29:40.910526	2025-10-19 02:29:40.910526
47d572bf-bf2e-403d-b8f6-0ae448603bc6	SAVILOE 320ML	7702354946210	t	2500.00	2300.00	\N	\N	19.00	2025-10-19 02:29:40.910767	2025-10-19 02:29:40.910767
59011f26-5388-481a-96a2-6f46a28f16ad	Vive 100	7702354944995	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:40.910995	2025-10-19 02:29:40.910995
509641a9-e919-4aac-96b4-bc98adcb7ccc	COCA COLA 3L	7702535024522	t	9700.00	8917.00	\N	\N	19.00	2025-10-19 02:29:40.911205	2025-10-19 02:29:40.911205
f8ef5326-3c80-47df-8b93-90dee15dc0c5	LECHE ENTERA LA MEJOR 400ML	7705241100368	t	2100.00	1900.00	1800.00	\N	0.00	2025-10-19 02:29:40.911489	2025-10-19 02:29:40.911489
09265f25-6ef4-497a-855d-7a4c24d5a3be	SALCHICHA CARNOSAN X9	7709912988828	t	6700.00	6400.00	6200.00	\N	19.00	2025-10-19 02:29:40.911695	2025-10-19 02:29:40.911695
eea8b9dc-70a7-4a8e-8fd5-45637a9aae0b	Zenu Salchicha Long 10U	c2240	t	6000.00	\N	\N	\N	0.00	2025-10-19 02:29:40.911899	2025-10-19 02:29:40.911899
04c25fb7-1ead-42d3-a70d-d5711946581f	Zenu Mortadela	7701101270158	t	6500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.912132	2025-10-19 02:29:40.912132
976e0838-70e0-4e1e-9c6d-749cd820f592	JUGO HIT NECTAR 237ML PERA	7702090069242	t	1900.00	1688.00	\N	\N	19.00	2025-10-19 02:29:40.912321	2025-10-19 02:29:40.912321
5d0e34d2-cf87-4ba3-96ba-1a1f436d0d29	KOTEX X30 NOCTURNA	7702425802759	t	19600.00	16200.00	\N	\N	0.00	2025-10-19 02:29:40.912496	2025-10-19 02:29:40.912496
4684838c-2a6b-4a4e-8f44-58f2cf91add3	KOTEX NOCTURNAS X8	7702425803008	t	6700.00	6500.00	\N	\N	0.00	2025-10-19 02:29:40.912799	2025-10-19 02:29:40.912799
a4c54598-0146-4a56-b839-a6a736821174	Pantene Champu	7500435155847	t	16500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.912993	2025-10-19 02:29:40.912993
ad8ed97c-145c-4f80-aaf0-40a6ef73ee9e	KINDER JOY	78602731	t	6700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.913223	2025-10-19 02:29:40.913223
3dfd293a-61a5-4c43-9bb2-4edd491207a9	MANTEQUILLA MA 500GR	7590006200137	t	9200.00	8800.00	\N	\N	19.00	2025-10-19 02:29:40.913468	2025-10-19 02:29:40.913468
ece7f5ec-8076-4d8a-8cf2-d61dbb7a234c	BOKA DURAZNO	7702354935559	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:40.913686	2025-10-19 02:29:40.913686
b600bd9f-66a5-404d-a4c1-5d17e9c5f272	Boka 2L 10U	7702354033651	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:40.913889	2025-10-19 02:29:40.913889
61e6aa5c-0d28-4831-af2c-4711717ef755	Boka 2L 10U	7702354032951	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:40.914315	2025-10-19 02:29:40.914315
f18b4990-a15d-487a-8094-fe5efbe538c4	LECHE DESLACTOSADA LA MEJOR 900ML	7705241100467	t	4500.00	4000.00	3900.00	\N	0.00	2025-10-19 02:29:40.914608	2025-10-19 02:29:40.914608
6224b516-8f94-4a5c-8972-0a0c457bb0da	LECHE ENTERA LA MEJOR 900ML	7705241100450	t	4000.00	3600.00	3500.00	\N	0.00	2025-10-19 02:29:40.914876	2025-10-19 02:29:40.914876
4ada38ad-161f-4d3b-9aeb-ffd64e2f0630	ELLAS TOALLAS 10UND	7702108203057	t	2300.00	2200.00	\N	\N	0.00	2025-10-19 02:29:40.915081	2025-10-19 02:29:40.915081
1e697805-160b-4448-b16c-3c9b2319d922	SUPER ROMBO 200GR BARRA	7702826100508	t	1300.00	1200.00	\N	\N	19.00	2025-10-19 02:29:40.915373	2025-10-19 02:29:40.915373
3649f0fc-322a-44ac-bd35-e5d312e4746f	fab barra 240g	7702191660089	t	2800.00	\N	\N	\N	0.00	2025-10-19 02:29:40.915586	2025-10-19 02:29:40.915586
e9ac25c4-208f-4695-a297-d2ed831fc89d	supremo barra 200g	7709658360155	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:40.915818	2025-10-19 02:29:40.915818
556e632c-0f53-450c-836f-8f85488f81c8	nube basico 4 rollos	7707151600266	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:40.916071	2025-10-19 02:29:40.916071
15ec81b0-0556-4eb8-9cee-3f14a6edc696	GELAGURT SABOR A FRESA 50GR	7702354016708	t	2000.00	1880.00	\N	\N	19.00	2025-10-19 02:29:40.916332	2025-10-19 02:29:40.916332
0444b648-2ded-488b-ac89-57c48f2f4af8	GELAGURT SABOR A MORA 50GR	7702354016746	t	2000.00	1880.00	\N	\N	19.00	2025-10-19 02:29:40.916552	2025-10-19 02:29:40.916552
5d970dc4-0f22-4d50-a8a5-ef3e765bd916	GELAGURT SABOR A GUANABANA 50GR	7702354016722	t	2000.00	1880.00	\N	\N	19.00	2025-10-19 02:29:40.916863	2025-10-19 02:29:40.916863
98b5b0ea-c84c-4417-bcd7-8c0ebadfeef5	SPEED STICK CLINICAL 100GR	7509546668666	t	13200.00	12700.00	\N	\N	19.00	2025-10-19 02:29:40.917086	2025-10-19 02:29:40.917086
6c9b081c-4625-48d1-93e6-649fee9ebbf2	LADY SPEED STICK CLINICAL 100GR	7509546679907	t	13200.00	12700.00	\N	\N	19.00	2025-10-19 02:29:40.917555	2025-10-19 02:29:40.917555
9769833d-a5b7-4f66-b82c-f375c40ba83a	DUX ORIGINAL 3X9	7702025101306	t	6400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.918068	2025-10-19 02:29:40.918068
71b0477c-43ae-4e8a-96c8-e58bafc2be2a	SALTIN NOEL QUESO Y MANTEQUILLA 3X9	7702025189632	t	4500.00	4300.00	\N	\N	19.00	2025-10-19 02:29:40.9183	2025-10-19 02:29:40.9183
0a7f938f-17e3-479a-9a2c-97197bfccdb7	DE TODITO BBQ 400GR	7702189055040	t	16600.00	16400.00	\N	\N	19.00	2025-10-19 02:29:40.918481	2025-10-19 02:29:40.918481
31908949-a29c-4908-80d3-49f507a06cef	CHOCOLISTO SABOR A CARAMELO 160GR	7702007079234	t	5400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.918697	2025-10-19 02:29:40.918697
41874ee3-0219-499f-9167-c65394ea9cdb	LOCION PARA PERROS PETS 30ML	7707370058077	t	2900.00	2700.00	\N	\N	19.00	2025-10-19 02:29:40.918938	2025-10-19 02:29:40.918938
87df8a7d-8a83-455b-88b7-2611c71be926	LOCION PARA PERROS HEMBRAS 30ML	7707370055984	t	2900.00	2700.00	\N	\N	19.00	2025-10-19 02:29:40.919232	2025-10-19 02:29:40.919232
0ba5a587-0edd-4598-9ae3-282df8fc3688	CREMA DE PEINAR SEDAL DUO MAS BOLSA  PEINE	7709843147196	t	26000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.919431	2025-10-19 02:29:40.919431
f1272685-38c6-4870-8379-ff53bbae01a0	ARDEN FOR MEN POWER 100GR	7702044283939	t	9800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.919688	2025-10-19 02:29:40.919688
2ba7923b-d080-43b2-98fe-47eb2cc8c51d	TALCO MEXANA 150GR MAS 85GR	7702123011613	t	13400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.920459	2025-10-19 02:29:40.920459
30b11efe-1275-4539-8922-2a72c36a0908	SPRAY DESENREDANTE JOHSONS 200ML	7702031413462	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:40.920642	2025-10-19 02:29:40.920642
8ad132d9-cd98-4645-ab9f-4e8ce26be2af	NATUCHIPS VERDE 38GR	7702189055453	t	2400.00	2300.00	2200.00	\N	19.00	2025-10-19 02:29:40.920828	2025-10-19 02:29:40.920828
5dd19ce8-6959-4aaf-9703-d7abf4c299d7	NATUCHIPS MADURA 38GR	7702189055484	t	2400.00	2300.00	2200.00	\N	19.00	2025-10-19 02:29:40.921061	2025-10-19 02:29:40.921061
4cdc04ab-bc70-4917-b784-e99827089d93	DORITOS DINAMITA FLAMIT 50GR	7702189057921	t	3100.00	3000.00	2900.00	\N	19.00	2025-10-19 02:29:40.921279	2025-10-19 02:29:40.921279
d61d6463-7e0b-4a5e-b580-60166200ae36	DORITOS DINAMITAS LIMON 50GR	7702189057945	t	3100.00	3000.00	2900.00	\N	19.00	2025-10-19 02:29:40.921948	2025-10-19 02:29:40.921948
2e85c307-319c-45b9-bdfb-4062a46fc9f4	CHOCLITO LIMON 40GR	7702189058546	t	2200.00	2100.00	2000.00	\N	19.00	2025-10-19 02:29:40.92213	2025-10-19 02:29:40.92213
623c054c-0448-41c5-bbdb-3669a1f4b275	CHOCLITOS PICANTE 40GR	7702189057853	t	2200.00	2100.00	2000.00	\N	19.00	2025-10-19 02:29:40.922336	2025-10-19 02:29:40.922336
3443e482-2152-4033-a048-db5cd5d58909	BOMBILLO HOGARLUX AMARILLO	2017032300075	t	1200.00	1100.00	\N	\N	19.00	2025-10-19 02:29:40.922528	2025-10-19 02:29:40.922528
532c1e02-cbdf-4123-89ae-335f14523fb5	LOZACREAM BLANCOX LIMON 450GR	7703812010610	t	6500.00	6350.00	\N	\N	19.00	2025-10-19 02:29:40.922702	2025-10-19 02:29:40.922702
8fcf06f3-b7fe-4831-8c7d-94c1d94c94b9	LOZA CREm 250gr	7703812003193	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.922886	2025-10-19 02:29:40.922886
42f3df71-5bf0-40dd-9db4-7cd16358c539	axion lavaloza aloe 235g	7702010380860	t	3200.00	3060.00	\N	\N	19.00	2025-10-19 02:29:40.923079	2025-10-19 02:29:40.923079
4964745b-201c-4b55-b3da-a364a8458f41	FASSI LAVAPLATOS 230GR	7702230600120	t	2900.00	2800.00	\N	\N	19.00	2025-10-19 02:29:40.923293	2025-10-19 02:29:40.923293
286229d6-b6af-48c0-a85b-7c485c084728	AXION 450GR ANTIBACTERIAL	7509546671246	t	5800.00	5700.00	\N	\N	19.00	2025-10-19 02:29:40.923483	2025-10-19 02:29:40.923483
2f0e18dd-78bf-4f62-8e96-fd04a5632106	lavaloz ak limon 900g	7702310040204	t	9400.00	9100.00	\N	\N	19.00	2025-10-19 02:29:40.923683	2025-10-19 02:29:40.923683
301d7d53-a53d-4b0e-aa69-0334d0afa4c2	WINNY 1X30	7701021116499	t	22800.00	22300.00	\N	\N	19.00	2025-10-19 02:29:40.923879	2025-10-19 02:29:40.923879
31e64cfb-359e-4a45-9b08-a49bef28b093	BABYSEC 3X30	7707199340803	t	32400.00	31800.00	\N	\N	19.00	2025-10-19 02:29:40.924076	2025-10-19 02:29:40.924076
590c7986-21f2-461a-b45d-0ab726534382	BABYSEC 2X30	7707199340797	t	27200.00	26500.00	\N	\N	19.00	2025-10-19 02:29:40.924255	2025-10-19 02:29:40.924255
d18ca57b-0c59-493e-b9b5-1191cf194f64	BABYSEC 4X30	7707199340810	t	40000.00	39500.00	\N	\N	19.00	2025-10-19 02:29:40.924456	2025-10-19 02:29:40.924456
ce908792-3dd5-4744-8ba7-a1812ddeb2de	CLORO YES 450CC	7702560031700	t	1400.00	1334.00	\N	\N	19.00	2025-10-19 02:29:40.924684	2025-10-19 02:29:40.924684
0eacd612-df03-44cd-b5f9-757b27043eab	COPITOS ARCOIRIS 300UNID	7702208100126	t	6100.00	5850.00	\N	\N	19.00	2025-10-19 02:29:40.924871	2025-10-19 02:29:40.924871
d127c3ef-42e8-453b-93cc-5722e0e9f558	VANISH 450ML	7702626214931	t	4800.00	4650.00	\N	\N	19.00	2025-10-19 02:29:40.925091	2025-10-19 02:29:40.925091
c80b42c8-cb6a-4ad6-9876-e22fbcce4afd	SUAVITEL 360ML	7509546658827	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:40.925283	2025-10-19 02:29:40.925283
b929e559-1164-4cac-99c8-ee4ed806e05d	AK1 3KG FLORAL	7702310047241	t	24000.00	23600.00	\N	\N	19.00	2025-10-19 02:29:40.925468	2025-10-19 02:29:40.925468
8afe48bd-0397-41c4-b7ec-2981f6ae9113	AK1 450GR FLORAL	7702310044257	t	4900.00	4750.00	\N	\N	19.00	2025-10-19 02:29:40.925657	2025-10-19 02:29:40.925657
62192f84-9d3a-4ef2-b72b-f72565619c4c	SUPER RIEL LIQUIDO 500ML	7702310043120	t	3500.00	3350.00	\N	\N	19.00	2025-10-19 02:29:40.925835	2025-10-19 02:29:40.925835
790d6be7-cdeb-48cd-890f-26533766e2e2	FAB MULTIUSOS 300GR	7702191658895	t	2900.00	2800.00	\N	\N	19.00	2025-10-19 02:29:40.926026	2025-10-19 02:29:40.926026
428a3a4b-2458-4f27-be3f-7beb517114f1	ELITE MAX33MT	7707199342562	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:40.926227	2025-10-19 02:29:40.926227
921d2561-7327-4827-8d91-39466a003436	FAB LAVADO COMPLETO 500GR	7702191163900	t	5500.00	5400.00	\N	\N	19.00	2025-10-19 02:29:40.92642	2025-10-19 02:29:40.92642
e1111a7a-03c2-4972-8c0e-27151dc7ea6d	DETODITO NATURAL 400GR	7702189030443	t	16600.00	16400.00	\N	\N	19.00	2025-10-19 02:29:40.926604	2025-10-19 02:29:40.926604
01d86d08-ee20-4833-af2e-a0cea3940dee	BIANCHI CHOCO BOMBONES X30	7702993040676	t	7300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.926814	2025-10-19 02:29:40.926814
840e730a-0638-4e45-8fee-062890f433c5	ARIEL TRIPLE PODER 1KG	7500435112413	t	11000.00	10500.00	\N	\N	19.00	2025-10-19 02:29:40.926977	2025-10-19 02:29:40.926977
fe3e9806-ddc8-4ff2-b2c9-bef0bc7d1fdb	FAB DETERGENTE 450GR	7702191658871	t	5200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.927145	2025-10-19 02:29:40.927145
891470a7-d98b-467e-842d-858f03de10cf	ARIEL REVITACOLOR 450GR	7500435160179	t	5200.00	5000.00	\N	\N	19.00	2025-10-19 02:29:40.927369	2025-10-19 02:29:40.927369
8eefcc3d-7389-47ea-812e-a46f4c83c519	WINNY PANTS ETAPA 6 X30UNID	7701021118868	t	48700.00	47900.00	\N	\N	19.00	2025-10-19 02:29:40.92756	2025-10-19 02:29:40.92756
f9e66c13-d3b3-4030-9f63-e30b24559a02	NORAVER GARGANTA	54DF	t	1800.00	\N	\N	\N	0.00	2025-10-19 02:29:40.927746	2025-10-19 02:29:40.927746
827fddf5-a5ae-445d-b77b-5a003bc046fc	FILPO 30KILOS	fk	t	108000.00	\N	\N	\N	5.00	2025-10-19 02:29:40.927932	2025-10-19 02:29:40.927932
3e36efb6-2df0-46a9-9e9d-7682c2eb3998	DOG CHOW CACHORROS 350GR	7702521028268	t	3800.00	3670.00	\N	\N	5.00	2025-10-19 02:29:40.928121	2025-10-19 02:29:40.928121
2067b1c7-4e63-480b-8cb3-f691c3bb6a8c	Dove Leche de Coco	7891150034075	t	4000.00	3840.00	\N	\N	19.00	2025-10-19 02:29:40.92831	2025-10-19 02:29:40.92831
ff4bc2ab-d832-4aba-9696-24ddd063189b	DOVE ORIGINAL 90GR	7898422746759	t	4000.00	3840.00	\N	\N	19.00	2025-10-19 02:29:40.9285	2025-10-19 02:29:40.9285
4ef8d19e-63a9-4904-8758-c5091d6a9b83	PROTEX AVENA 110GR	7509546693552	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:40.929086	2025-10-19 02:29:40.929086
1ea1be1b-2811-4770-b7da-fa23dd2224d6	Carey nuteritivo	7702310022255	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:40.929318	2025-10-19 02:29:40.929318
761fadac-b170-4538-9945-12e9aedd8f32	CAREY EXFOLIANTE 110GR	7702310022248	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:40.929501	2025-10-19 02:29:40.929501
8d4711de-d9e6-4840-baf3-e8eb7796a06f	LE FRAGANCE FRUTAL	7702310024013	t	1600.00	1485.00	\N	\N	19.00	2025-10-19 02:29:40.929675	2025-10-19 02:29:40.929675
1441e38d-ae0b-4bff-875d-4f78c404b109	FLUOCARDENT MAS CEPILLO  50ML	7702560041792	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:40.929934	2025-10-19 02:29:40.929934
f3f92858-8cb3-4503-a8f3-2e0ec1862eaf	Colgate Triple Accion Blancura 60ml	7702010111587	t	3800.00	3667.00	\N	\N	19.00	2025-10-19 02:29:40.93017	2025-10-19 02:29:40.93017
af23918b-00a3-4894-8641-4e8f3f688733	ALCOHOL JGB 350ML	7702560009532	t	5000.00	4900.00	\N	\N	0.00	2025-10-19 02:29:40.930419	2025-10-19 02:29:40.930419
de7d9711-2719-49d3-bee6-212cc6906fae	ALCOHOL JGB 700ML	7702560009525	t	7700.00	7400.00	\N	\N	0.00	2025-10-19 02:29:40.930614	2025-10-19 02:29:40.930614
5cf965f0-f492-47e7-885d-d211d73d6f24	PONY MALTA 1LITRO	7702004013842	t	3500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.930828	2025-10-19 02:29:40.930828
2d3a69a0-303b-4064-8a5c-17a5a146a6a5	PONY MALTA 330ML	7702004013484	t	2300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.931005	2025-10-19 02:29:40.931005
9f971d2e-fc35-42b9-b28d-3a3314ab2236	Pony Malta 200ml	7702004013668	t	1500.00	1367.00	\N	\N	19.00	2025-10-19 02:29:40.931186	2025-10-19 02:29:40.931186
494606fe-20a5-4c91-ac5d-34609a51c621	AREQUIPE LA MEJOR 250GR	7705241700209	t	5700.00	5100.00	5000.00	\N	19.00	2025-10-19 02:29:40.931399	2025-10-19 02:29:40.931399
40bd2514-1ee0-42be-a5a8-b7eb7543daea	AREQUIPE EL ANDINO 900GR	7709068596694	t	11300.00	10900.00	\N	\N	0.00	2025-10-19 02:29:40.931619	2025-10-19 02:29:40.931619
40c45619-d816-4561-ad5d-2dfe679cea2a	LONJA BOCADILLO 300GR	7707189190340	t	2100.00	2000.00	\N	\N	19.00	2025-10-19 02:29:40.931813	2025-10-19 02:29:40.931813
4bac7e4c-ad85-46f7-9451-4a367cc49648	FLAN GELADA 60G	7702014525113	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.932018	2025-10-19 02:29:40.932018
db353b88-0d93-4823-bbc3-4ada87273461	FS	ZVCDS	t	1000.00	\N	\N	\N	0.00	2025-10-19 02:29:40.932196	2025-10-19 02:29:40.932196
9c0cb831-d4c6-4a0d-8095-a8911d027a2f	LECHE CONDENSADA EL ANDINO 500GR	7709068596687	t	7200.00	7000.00	\N	\N	19.00	2025-10-19 02:29:40.932414	2025-10-19 02:29:40.932414
22bf1294-2bc4-45d7-94dd-5f9e14847bc8	CAPRI WAFER 24U VAINILLA	7702011200914	t	6100.00	\N	\N	\N	19.00	2025-10-19 02:29:40.932597	2025-10-19 02:29:40.932597
5b781497-45ed-4838-b391-09059d6ed006	DUCALES TACO DIA 120GR	7702025150977	t	2800.00	2667.00	\N	\N	19.00	2025-10-19 02:29:40.932791	2025-10-19 02:29:40.932791
89b40854-69ea-4376-b41f-8e1e09a529c8	FESTIVAL VAINILLA 12X6	7702025182152	t	12300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.932984	2025-10-19 02:29:40.932984
831b3304-50f2-4f6e-b9b2-1abfc57ae4cc	CREMA DE ARROZ BABU 450GR	7708345181172	t	5300.00	5150.00	\N	\N	5.00	2025-10-19 02:29:40.933182	2025-10-19 02:29:40.933182
f1ee5989-0484-4ff1-9eb3-82914ea37f74	ATUN CALIDAD LOMITO ACEITE 175GR	7866640700419	t	4100.00	3980.00	\N	\N	19.00	2025-10-19 02:29:40.933482	2025-10-19 02:29:40.933482
3a63971b-76c6-4ade-b5b0-fe5098881abb	ACONDICIONADOR SAVITAL 100ML	7702006404594	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:40.933675	2025-10-19 02:29:40.933675
fc4c237a-1a73-453e-9760-d27800d2613e	Leche Miramonte 200g	7707228548095	t	5100.00	4900.00	\N	\N	0.00	2025-10-19 02:29:40.933866	2025-10-19 02:29:40.933866
6dd1c8c8-c849-4c8c-a0cf-031a7ed9f91c	HARINA PAN INTEGRAL 1000GR	7702084137858	t	4400.00	4300.00	\N	\N	5.00	2025-10-19 02:29:40.934084	2025-10-19 02:29:40.934084
623f69e4-437a-46f2-8756-b0c826f38f4d	HARINA PAN AMARILLA 1.000GR	7702084137537	t	3700.00	3550.00	\N	\N	5.00	2025-10-19 02:29:40.934291	2025-10-19 02:29:40.934291
4c296b14-8054-42e0-9fbd-b8e83c09863c	LETRAS DORIA 250GR	7702085012246	t	2200.00	2100.00	\N	\N	5.00	2025-10-19 02:29:40.934498	2025-10-19 02:29:40.934498
42368a4c-c0a4-4e0a-8af0-7e9762b942b7	FIDEOS DORIA 250GR	7702085012062	t	2200.00	2100.00	\N	\N	5.00	2025-10-19 02:29:40.934691	2025-10-19 02:29:40.934691
7cc57c73-41d5-4910-9263-e4213944b809	AZUCAR MAYAGUEZ 1.000GR	7707007200459	t	4200.00	4080.00	\N	\N	5.00	2025-10-19 02:29:40.93487	2025-10-19 02:29:40.93487
dfba4b04-70e9-491c-9074-0b2f82d153bb	Arroz Pesado x libra	7709531779548	t	2200.00	\N	\N	\N	0.00	2025-10-19 02:29:40.935072	2025-10-19 02:29:40.935072
00c4448e-51f0-401b-a6c7-7c3e70603f4c	SPAGHETTI DORIA 1.000GR	7702085019023	t	5900.00	5667.00	\N	\N	5.00	2025-10-19 02:29:40.935272	2025-10-19 02:29:40.935272
8eed78d2-535f-43f8-8d76-47971c0650d6	CHOCOLATE CORONA FLASH 200GR	7702007033618	t	7200.00	7000.00	\N	\N	19.00	2025-10-19 02:29:40.935533	2025-10-19 02:29:40.935533
db689b11-03eb-4a9a-becd-845ce81c5a60	ROBINSON LEUDANTE 500GR	7707197610274	t	2100.00	1980.00	\N	\N	5.00	2025-10-19 02:29:40.935755	2025-10-19 02:29:40.935755
9c29d772-c1d5-4cfa-90de-5df01a03c756	AVENA DON PANCHO HOJUELA 600GR	7702193100491	t	5000.00	4850.00	\N	\N	5.00	2025-10-19 02:29:40.93595	2025-10-19 02:29:40.93595
6d450204-a974-4db7-9d5a-cbd586672a13	AVENA EXTRA SEÑORA HOJUELA 200GR	7708345181455	t	1400.00	1250.00	\N	\N	5.00	2025-10-19 02:29:40.936167	2025-10-19 02:29:40.936167
0756c71b-7705-4e79-a4f3-a54ba2b604f3	LAK SENSACIONES 115GR	7702310020688	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.936366	2025-10-19 02:29:40.936366
bf03d3f5-632f-4a84-96c5-09557a45a115	LAK SUAVIDAD 115GR	7702310020695	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.936546	2025-10-19 02:29:40.936546
3b60438a-1af2-44c9-a5d3-dae53e167e96	LAK PROTECCION 115GR	7702310020718	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.936726	2025-10-19 02:29:40.936726
be289e61-3b8f-4453-b63f-a65245ef7954	LAK FRESCURA 115GR	7702310020701	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.936926	2025-10-19 02:29:40.936926
76f8508a-d2ba-47e9-b337-ca679c314011	CHOCOLATE CORONA CYC 500GR	7702007043419	t	15000.00	\N	\N	\N	5.00	2025-10-19 02:29:40.93713	2025-10-19 02:29:40.93713
733a16e5-b5b0-450f-8497-bd288042094f	COLCAFE CLASICO SUAVE 85GR	7702032253135	t	17600.00	17300.00	\N	\N	5.00	2025-10-19 02:29:40.937327	2025-10-19 02:29:40.937327
049103dd-442c-4401-8fb9-6b70463e96da	CHOCOLATE CORONA TRADICIONAL 500GR	7702007043396	t	14600.00	14300.00	\N	\N	5.00	2025-10-19 02:29:40.937508	2025-10-19 02:29:40.937508
aa953482-c325-4251-998c-c4e37bdd4c6a	DFCGH	FDH	t	1000.00	\N	\N	\N	5.00	2025-10-19 02:29:40.937718	2025-10-19 02:29:40.937718
84ed372b-c80e-4e48-a2e7-18c9d1312a30	COLCAFE INTENSO GRANULADO 85GR	7702032104376	t	18500.00	18200.00	\N	\N	5.00	2025-10-19 02:29:40.937921	2025-10-19 02:29:40.937921
8aae7da2-ca4f-4aaa-b1aa-7f779ab455d5	PRACTIS CON SAL 400GR	7701018006932	t	7200.00	7000.00	\N	\N	19.00	2025-10-19 02:29:40.938122	2025-10-19 02:29:40.938122
a65dd70a-1d25-44f6-b2eb-de7413755332	PLATO HONDO DARNEL 25OZ X20UND	7702458014242	t	5100.00	4900.00	\N	\N	19.00	2025-10-19 02:29:40.938319	2025-10-19 02:29:40.938319
2411725a-34ed-4396-8cb3-afda5421cd0a	PAPEL ALUMINIO HOUSE 40M	7707320620682	t	9500.00	9150.00	\N	\N	19.00	2025-10-19 02:29:40.938514	2025-10-19 02:29:40.938514
f85f8f12-10d0-4767-ae5c-19cd606051df	DE TODITO MIX 165GR	7702189057631	t	7600.00	7340.00	7200.00	\N	19.00	2025-10-19 02:29:40.938706	2025-10-19 02:29:40.938706
25cbd083-185d-4c33-bde6-fa476fc1d21f	DORITOS BOLSAZA 80GR	7702189059642	t	4200.00	4050.00	3950.00	\N	19.00	2025-10-19 02:29:40.938902	2025-10-19 02:29:40.938902
1143e43d-4c04-4aca-adeb-ccaf62bc5e39	ARVEJA ZENU NATURAL 300GR	7701101233207	t	4400.00	4240.00	\N	\N	19.00	2025-10-19 02:29:40.939311	2025-10-19 02:29:40.939311
11c93dcb-7538-42b5-96fa-8d9e9b5f784c	MAIZ ZENU DULCE 241GR	7701101358139	t	5900.00	5750.00	\N	\N	19.00	2025-10-19 02:29:40.939504	2025-10-19 02:29:40.939504
10225ecd-fae2-4c52-97a9-ebd32ab12150	CONTENEDOR DARNEL 16OZ X20UNID	7702458002287	t	7500.00	7200.00	\N	\N	19.00	2025-10-19 02:29:40.93967	2025-10-19 02:29:40.93967
358cc0c1-b8b1-4f8b-98de-55d17e050dba	VASOS SUPERPLAST 3.0 X50UNID	7707050200840	t	1500.00	1380.00	\N	\N	19.00	2025-10-19 02:29:40.939869	2025-10-19 02:29:40.939869
2ae08636-bf1c-4ba9-befa-f1323dcc0079	VASOS SUPERPLAST 3.3 50U	7707050200321	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:40.940076	2025-10-19 02:29:40.940076
72beb8dc-8d9e-46b2-90cd-0ef673b26a3c	VASOS VBC 5.5 X50UNID	7709174732818	t	2100.00	2000.00	\N	\N	19.00	2025-10-19 02:29:40.940272	2025-10-19 02:29:40.940272
c4b76506-525c-4649-b8e0-755a9d7831e1	Pinza Metal	Pinza	t	500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.940442	2025-10-19 02:29:40.940442
c29e95f9-7633-433c-80d0-4b78297b3bf0	DESODORANTE ESIKA 50ML	L602	t	4700.00	4500.00	\N	\N	19.00	2025-10-19 02:29:40.940644	2025-10-19 02:29:40.940644
9abc93de-0040-45df-992a-a90411304b9b	FRUTIÑO MAARACUYA	7702354955878	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:40.9409	2025-10-19 02:29:40.9409
25016e0e-424d-4b36-a8cb-537b32fa1dd4	ALCANCIA GRANDE	Alcan	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:40.941106	2025-10-19 02:29:40.941106
756eb2dc-5bbd-4b4f-8872-614ece8745ad	ALCANCIA PEQUEÑA	ALP	t	1200.00	1100.00	\N	\N	19.00	2025-10-19 02:29:40.941283	2025-10-19 02:29:40.941283
9d858f0c-9da6-4752-9d7b-1de462f90ec3	SALSA BARY HARDYS 90GR	7702439793326	t	1200.00	1100.00	\N	\N	19.00	2025-10-19 02:29:40.941556	2025-10-19 02:29:40.941556
582efa21-323d-4fba-987a-7a948d912905	Gelatin La Mejor 120g	7705241110107	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.941756	2025-10-19 02:29:40.941756
b86fe9de-0065-4487-a5f4-fd1f1401acb5	Gelatin Uva 120g	7705241110015	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.941949	2025-10-19 02:29:40.941949
8e1eefa5-b53a-4d47-b022-54dcb28e3a60	CHOCORRAMO 65GR	7702914596787	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.942151	2025-10-19 02:29:40.942151
b568699f-58f2-4773-bd8c-7034834408b0	YOGOLIN MELOCOTON LA MEJOR 150GR	7705241400932	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:40.942338	2025-10-19 02:29:40.942338
56654f65-ca2b-4818-b200-4f7413d934da	YOGOLIN VASO X4UNID	7705241400970	t	6000.00	5300.00	5200.00	\N	19.00	2025-10-19 02:29:40.942532	2025-10-19 02:29:40.942532
630357be-3eba-42e8-8a39-aa14da8254e4	YOGOLIN MIX CEREAL 130GR LA MEJOR	7705241400277	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.942737	2025-10-19 02:29:40.942737
a8787278-6ec7-453d-8933-1c8872fcf4aa	YOGOLIN MIX X3UNID	7705241400390	t	6200.00	5500.00	5400.00	\N	19.00	2025-10-19 02:29:40.942931	2025-10-19 02:29:40.942931
6b5bade8-00ce-47e3-92af-96956d609689	SALCHICHA X32UNID	7700675206280	t	9000.00	8800.00	\N	\N	19.00	2025-10-19 02:29:40.943128	2025-10-19 02:29:40.943128
84c191cf-42b3-4a30-a4db-0073a3a218fc	PANQUE BIMBO 60GR	7705326076588	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.943329	2025-10-19 02:29:40.943329
c973da31-7eb9-4a58-8b02-d6cd908d9022	Cheese Tris	7702189056788	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.94352	2025-10-19 02:29:40.94352
bf1e6991-51b0-494e-9d17-d2ba41dd9671	Manis Apache 40g	Mani	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.943716	2025-10-19 02:29:40.943716
e19f9206-e1f5-4ef7-b996-b0a09cd0b47b	MR BROWN 75GR	7705326079008	t	3500.00	3450.00	\N	\N	19.00	2025-10-19 02:29:40.943927	2025-10-19 02:29:40.943927
0484c1cb-5ba3-41ab-84ff-94aba6441aab	Gaseosa Litron  retornable	gaseosa	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.944128	2025-10-19 02:29:40.944128
3fbf4103-844f-49f0-9214-b1a48b6a643e	TOSTADAS INTEG 10U 115GR	7705326079381	t	3700.00	3600.00	\N	\N	0.00	2025-10-19 02:29:40.944331	2025-10-19 02:29:40.944331
14c03c47-04a7-445e-8391-812ed12b560b	Jet Chocolatina 30g	7702007212105	t	3700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.944556	2025-10-19 02:29:40.944556
22515d13-ac4c-48d8-8f4b-afa4b9ca7e83	JET CHOCOLATINA 11GR	77010148	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.944751	2025-10-19 02:29:40.944751
fd77956b-dcee-4c02-a7c6-9e490abef51b	Club Social Original	7590011205158	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.944946	2025-10-19 02:29:40.944946
ea12ae0f-b6bd-410c-be17-8f879027f0b7	GOL CHOCOLATE	7702007080599	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.945135	2025-10-19 02:29:40.945135
c940d87c-4727-494c-8c38-69123318dba7	COCOSETTE46GR	7702024283973	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.945324	2025-10-19 02:29:40.945324
45b77f14-17c9-4b03-b4d1-c26932fa4a7a	MANICERO LA ESPECIAL	7702007228007	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.945515	2025-10-19 02:29:40.945515
fa96c737-73fd-4ef9-9a6e-622f082657c1	JOHNSONS BABY SHAMPOO 100ML	7702031291534	t	6500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.945719	2025-10-19 02:29:40.945719
af66fa10-ec0a-4926-b44b-9c807e6d8342	ALCOHOL JGB 120ML	7702560026577	t	3100.00	3000.00	\N	\N	0.00	2025-10-19 02:29:40.945925	2025-10-19 02:29:40.945925
3813609a-d257-4978-9887-1e419789a15a	LISTERINE COOL MINTMENTA 180ML	7702035432117	t	8600.00	8300.00	\N	\N	19.00	2025-10-19 02:29:40.946166	2025-10-19 02:29:40.946166
d20709a9-8d22-417b-801f-c7e44d9e91d5	CHUPO PEQUEÑO CORCHITO	7707233050026	t	700.00	600.00	\N	\N	19.00	2025-10-19 02:29:40.946404	2025-10-19 02:29:40.946404
671abd34-b1b5-49c2-9805-ce8cfbc9b71c	SEDAL CREMA PEINA RIZOS 300ML	7501056340131	t	10700.00	10400.00	\N	\N	19.00	2025-10-19 02:29:40.946601	2025-10-19 02:29:40.946601
ad69449a-c052-49cc-b51c-73272248c0ae	BETUM BUFALO AUTO BRILLO LIQUIDO  60ML	7702377001507	t	6200.00	6000.00	\N	\N	19.00	2025-10-19 02:29:40.946793	2025-10-19 02:29:40.946793
dc1796fe-d980-4658-82e5-77419e93b53c	CEREBRIT X8UNID	7702354946104	t	6000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.94698	2025-10-19 02:29:40.94698
90801782-d027-4c9c-8ffc-6f9eaa3fd104	TORTILLA RAPIDITAS 8M	7705326077837	t	7500.00	7400.00	\N	\N	19.00	2025-10-19 02:29:40.947193	2025-10-19 02:29:40.947193
b40671be-664e-4e4b-8b3e-dc9a6658a005	ALGODON MK 25G	7702057077112	t	2100.00	2000.00	\N	\N	0.00	2025-10-19 02:29:40.947395	2025-10-19 02:29:40.947395
51d2557f-50d9-4a65-bf2a-08f41d740ee8	Guisatodo Curri	7709521034794	t	600.00	\N	\N	\N	0.00	2025-10-19 02:29:40.947589	2025-10-19 02:29:40.947589
2da508a1-ed6b-4d5e-9802-442f7a3d4dbd	Guisatodo Pimienta Molida	2484	t	600.00	\N	\N	\N	19.00	2025-10-19 02:29:40.947778	2025-10-19 02:29:40.947778
ef58cce0-2b27-433b-aa77-dbf8284925c7	CEPILLO FLUOCARDENT	7702560042058	t	2100.00	1917.00	\N	\N	19.00	2025-10-19 02:29:40.947957	2025-10-19 02:29:40.947957
c8253f73-eeaa-4816-9059-0edf026e38c9	TALCO REXONA PIES 60GR	7702006051118	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.94817	2025-10-19 02:29:40.94817
f147a449-5ffb-4a10-9043-b7f2dbcd3e5f	TALCO YODORA 60GR	7702057081027	t	5100.00	4900.00	\N	\N	19.00	2025-10-19 02:29:40.948394	2025-10-19 02:29:40.948394
cc960662-d6c3-4d33-99df-def8ed296403	LADY SPEED STICK PRATIC 30GR	7702010972287	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:40.948583	2025-10-19 02:29:40.948583
49b943fe-2965-46d9-8ca5-1203efe361c5	TALCO REXONA EFFICIENT 55GR	7702006301442	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.948776	2025-10-19 02:29:40.948776
5a49deee-65fd-4aa1-ba84-3734e4f035ef	Acetaminofen La sante	ALS	t	1000.00	\N	\N	\N	0.00	2025-10-19 02:29:40.949291	2025-10-19 02:29:40.949291
65f0448c-cdd9-4cc0-88b0-b54eaf2c782e	NARAVER GARGANTA	Noraver	t	1700.00	\N	\N	\N	0.00	2025-10-19 02:29:40.949525	2025-10-19 02:29:40.949525
e4b47557-285f-4f60-842a-fcfbe1317fd6	PALILLOS PANDA 180UNID	7703252002152	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.949716	2025-10-19 02:29:40.949716
e083221e-ddb1-4d53-985c-2c753f2c9157	LECHE KLIM 26GR	7702024237464	t	1300.00	1225.00	\N	\N	0.00	2025-10-19 02:29:40.950003	2025-10-19 02:29:40.950003
db705c00-a461-42bb-91f6-aad7d6e2af7a	NESTUM TRIGO MIEL 25GR	7613038640334	t	1300.00	1180.00	\N	\N	19.00	2025-10-19 02:29:40.950228	2025-10-19 02:29:40.950228
4417a76b-a94d-4144-95a5-f5040b1b232c	NESCAFE TRADICIONAL 10GR	7702024040446	t	1600.00	\N	\N	\N	5.00	2025-10-19 02:29:40.950667	2025-10-19 02:29:40.950667
7115ada8-1e75-43f3-a04f-1e1cb8d41828	DOVE SHAMPO RECONSTRUCCION COMPLETA 15ML	7702006400480	t	1000.00	900.00	\N	\N	19.00	2025-10-19 02:29:40.951098	2025-10-19 02:29:40.951098
90d5b7c5-3399-4d43-a413-db95232b167b	Nutribela Enzimoterapia	7702354949624	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.95145	2025-10-19 02:29:40.95145
d15c2bb4-5977-49d8-a809-87e9922964dd	ACONDICIONADOR KONZIL 25ML	7702045665147	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.951833	2025-10-19 02:29:40.951833
a22df1d1-5dd1-4f31-96dd-11657e11a6fd	SUNTEA MARACUYA	7702354948368	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:40.952091	2025-10-19 02:29:40.952091
a8c9eb5e-6771-43ee-975d-8134fd6f71f6	MEXANA ULTRA AEROSOL 260ML	7702123011507	t	12300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.952401	2025-10-19 02:29:40.952401
400ec83d-b7d8-47c9-9a69-82e58428529b	NUTRIBELA 10 REPARACION INTENCIVA 180ML	7702354948443	t	10400.00	10000.00	\N	\N	19.00	2025-10-19 02:29:40.952717	2025-10-19 02:29:40.952717
c303b370-a2b4-4b28-9cbb-6be63bdb6380	SHAMPO SAVITAL MULTIOLEOS 25ML	7702006206068	t	1000.00	875.00	\N	\N	19.00	2025-10-19 02:29:40.95302	2025-10-19 02:29:40.95302
1d7a2b4b-5009-42a8-bcc0-a96d8184ae4b	Sedal Crema Para peinar	7702006000253	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.95325	2025-10-19 02:29:40.95325
9f731ded-cbf2-42cd-82bc-e18e75ea768d	PONDS REJUVENES 8.5GR	7702006402606	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:40.953507	2025-10-19 02:29:40.953507
b31bc068-13b2-4293-af34-339659e300a3	CHOCOLATE CORONA PASTILLA 25GR	7702007016376	t	1000.00	913.00	\N	\N	5.00	2025-10-19 02:29:40.953764	2025-10-19 02:29:40.953764
b3ccdb22-b8c8-4265-8bd4-068a8ca60d0e	Shick Hojilla	48937740	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:40.954113	2025-10-19 02:29:40.954113
8a41978b-b477-4f06-a149-eacff3634929	MORADITAS AMERICANDY X100UNID	7707014904302	t	5400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.95433	2025-10-19 02:29:40.95433
0ed5d347-d457-4f25-8c06-108f89f45616	GALLETA TOSH X36UNID SURTIDAS	7702025148486	t	21200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.954545	2025-10-19 02:29:40.954545
af56f5d1-9806-46d5-a673-676e269e1a33	BALANCE CLINICAL WOMEN GEL 10GR	7702045553413	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:40.95477	2025-10-19 02:29:40.95477
8e2becb1-87e1-47b7-8e54-24f1e65a3f03	CHAMPIOJO 12ML	7707210530060	t	1300.00	1200.00	\N	\N	19.00	2025-10-19 02:29:40.954986	2025-10-19 02:29:40.954986
8a8d39fc-4515-4d25-8e47-b9cfbdfc0f2c	Suntea Durazno	7702354948337	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:40.955297	2025-10-19 02:29:40.955297
29c75e3c-0ef5-4e89-ad9e-eb75560d20b9	Dove Acondicionador	7702006204323	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:40.955545	2025-10-19 02:29:40.955545
913dadbd-d069-44e0-a637-b2fa8d646bb0	CREMA PARA PEINAR KONZIL 25ML	7702045792041	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.955813	2025-10-19 02:29:40.955813
6e37e1bd-f213-43f2-a816-01c0ffde5990	HEAD Y SHOULDERS LIMPIEZA 18ML	7501007492568	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:40.95606	2025-10-19 02:29:40.95606
a327a293-e233-45bb-a330-63f9a07e06ae	PRESTOBARBA STRAME HAWAI 3	7591066711014	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.956341	2025-10-19 02:29:40.956341
8062096e-4c17-478c-baf1-2514526cf6fb	KATORY ASPIRAL X2	7702332584595	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.956611	2025-10-19 02:29:40.956611
444e5f78-8b77-4e71-9f2f-58aef664d34a	Suntea Manzana	7702354948405	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:40.957006	2025-10-19 02:29:40.957006
23c73409-9572-4cb8-af46-352e4aa740ac	SUNTEA FRUTOS ROJOS	7702354948412	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:40.957469	2025-10-19 02:29:40.957469
ee9b43cb-0e61-4705-98d7-c93ab6ed6513	Sedal shampoo	7702006000239	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.957714	2025-10-19 02:29:40.957714
64a26823-9196-4066-9a32-8f8f4fb099aa	JAIBEL DE MANZANILLA 18GR	7702807482197	t	3100.00	2980.00	\N	\N	19.00	2025-10-19 02:29:40.957949	2025-10-19 02:29:40.957949
540b65de-b7e5-47ce-ae53-d3e26443a924	FOSFORO GLOBO X10	7707015501982	t	1200.00	1100.00	\N	\N	0.00	2025-10-19 02:29:40.958188	2025-10-19 02:29:40.958188
7e8b1402-3459-44fd-bc8b-9e6ace66d427	MENTAS CHAO FRESA X100	7702993031681	t	7000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.958384	2025-10-19 02:29:40.958384
00074bbe-9e1a-416c-b100-2edf7dffed72	TINTE KERATON 6.60	7707230996044	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:40.958631	2025-10-19 02:29:40.958631
3f2f008e-3819-4c27-bdbc-1943c465a50b	TINTE LISSIA 3.0	7703819301827	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.95893	2025-10-19 02:29:40.95893
dff1df97-6b35-4208-8b2a-b7f83f350dfd	ARROZ DIANA 5K	7702511000045	t	20000.00	\N	\N	\N	5.00	2025-10-19 02:29:40.959203	2025-10-19 02:29:40.959203
86b0c311-a627-4c48-8894-caa59bf7fa55	TINTE LISSIA 5.7	7703819301988	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.959448	2025-10-19 02:29:40.959448
b135e0f4-06c7-4521-8d3e-c3f23702044f	TINTE LISSIA  7.7	7703819302077	t	8900.00	8500.00	\N	\N	0.00	2025-10-19 02:29:40.959659	2025-10-19 02:29:40.959659
1c5f2f17-9126-4417-80b2-5ffe7f1b8ba8	TINTE LISSIA 6.4	7703819304934	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.959856	2025-10-19 02:29:40.959856
7e315f8e-8003-4151-8a74-e2d709e33ebc	FRUTIÑO PIÑA	7702354032418	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:40.960072	2025-10-19 02:29:40.960072
ab290fd4-1859-47ee-b517-a1f77d4efae2	FRUTIÑO UVA	7702354032425	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:40.960302	2025-10-19 02:29:40.960302
37e50f59-e2f3-4e5c-b998-fec15a09ebfb	FRUTIÑO LULO	7702354955922	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:40.960526	2025-10-19 02:29:40.960526
f2301cba-bbc3-4e58-b47e-99fffdf19a61	FRUTIÑO FRESA	7702354955830	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:40.960729	2025-10-19 02:29:40.960729
e0d506af-7962-4251-864b-89c2ee3150a6	FRUTIÑO SALPICON	7702354955847	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:40.960996	2025-10-19 02:29:40.960996
9a288831-d4f6-4488-9b55-441e315ef984	HALLS BARRA	7622202015212	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:40.961249	2025-10-19 02:29:40.961249
aae4a5d3-549a-4368-84e8-c1536bef2f7b	Guisamac	7703015101450	t	1100.00	984.00	\N	\N	19.00	2025-10-19 02:29:40.96144	2025-10-19 02:29:40.96144
c41c2dfb-9b70-4f9a-86b6-6908c219f72b	Bardot esmalte	7703799116602	t	2500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.961666	2025-10-19 02:29:40.961666
ecb19571-be98-4d2a-9466-4f6c6d84b04d	Esmalte mundo color	esmalte mundo color	t	2300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.961853	2025-10-19 02:29:40.961853
f907c628-297c-4c5c-b84c-12ed8b8fef9f	MANTECA DE CACAO LABIAL	7707175440305	t	1000.00	850.00	\N	\N	19.00	2025-10-19 02:29:40.962031	2025-10-19 02:29:40.962031
9c52667c-7a0d-4a7e-8cb3-e44f32c4cac8	CORTA UÑA GIGANTE FIGURA	Corta unas pequeno	t	3000.00	2600.00	\N	\N	19.00	2025-10-19 02:29:40.96234	2025-10-19 02:29:40.96234
287d8f6a-08ee-4126-afef-17aeeff72c42	VELA VOLCAN	vela volcan	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:40.962587	2025-10-19 02:29:40.962587
a1852e08-3c0b-4ac4-be28-16dfbf2c7d8e	Cuaderno cubitos	7707825992000	t	11500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.962811	2025-10-19 02:29:40.962811
411e8111-e42f-4cb7-b6c5-486463cabcba	Ligas	7453015101874	t	400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.963038	2025-10-19 02:29:40.963038
a07a83ac-a6a8-42ab-a91a-fc6165b89a37	AROMATEL MANDARINA 180ML	7702191162729	t	1600.00	1450.00	\N	\N	19.00	2025-10-19 02:29:40.963271	2025-10-19 02:29:40.963271
03290980-f54c-4c83-bcbc-4549712677bc	Dove delicius care 90g	7702191662892	t	4000.00	3840.00	\N	\N	19.00	2025-10-19 02:29:40.963473	2025-10-19 02:29:40.963473
c37d656d-3ac4-4399-83b3-b6121cc835f1	SCOTT CUIDADO COMPLETO	7702425977280	t	1900.00	\N	\N	\N	19.00	2025-10-19 02:29:40.963673	2025-10-19 02:29:40.963673
c6d9edca-4ea8-419f-91d3-c0f7a10878b0	FIDEOS COMARRICO 250GR	7707307962224	t	1800.00	1700.00	\N	\N	5.00	2025-10-19 02:29:40.963897	2025-10-19 02:29:40.963897
bc79855d-8ebe-498f-953e-d61bf051d12a	CONCHITA COMARRICO 250GR	7707307962453	t	1800.00	1700.00	\N	\N	5.00	2025-10-19 02:29:40.964132	2025-10-19 02:29:40.964132
f8a5bad1-09be-4aae-8afa-ca4ffb793eb5	CODITOS COMARRICO 250GR	7707307962279	t	1800.00	1700.00	\N	\N	5.00	2025-10-19 02:29:40.964346	2025-10-19 02:29:40.964346
55e6709e-294b-484a-b1f9-044ea645af61	SPAGHETTI COMARRICO 250GR	7707307961074	t	1800.00	1700.00	\N	\N	5.00	2025-10-19 02:29:40.964553	2025-10-19 02:29:40.964553
417b4601-8845-4441-b06c-4c12bfb3d8ff	PLATOS DARNEL 23CM X20UNID	645667223814	t	4600.00	4480.00	\N	\N	19.00	2025-10-19 02:29:40.964777	2025-10-19 02:29:40.964777
ef66e7c2-2af0-4e20-9564-3d159e38692d	PLATOS DARNEL 15.5  X20UNID	645667223784	t	2300.00	2180.00	\N	\N	19.00	2025-10-19 02:29:40.965036	2025-10-19 02:29:40.965036
0481f2a0-7508-47d0-b9ca-6d0a210264fb	HUEVOS MEDIO CARTON	HVRM	t	6300.00	\N	\N	\N	0.00	2025-10-19 02:29:40.965437	2025-10-19 02:29:40.965437
a47b8d45-d4d6-44a9-a241-ef1fc269738e	CARTON DE HUEVOS X30UNID	HVC	t	12600.00	\N	\N	\N	0.00	2025-10-19 02:29:40.96569	2025-10-19 02:29:40.96569
505ca689-f0f1-48f1-bb93-75dc9b3b0d4c	TOSTADA MANTEQUILLA X10	7705326079374	t	3500.00	3375.00	\N	\N	0.00	2025-10-19 02:29:40.965916	2025-10-19 02:29:40.965916
129455cd-1b71-4e9b-91a9-b87688c95cab	Velon Resucito	Velon	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:40.966121	2025-10-19 02:29:40.966121
761ba69a-669f-41ee-b5e1-4471e56aa89d	CAFE SELLO ROJO 50GR	7702032120345	t	2400.00	\N	\N	\N	5.00	2025-10-19 02:29:40.966335	2025-10-19 02:29:40.966335
7fa7f678-e7c8-4a16-8d90-06490807184e	MIRAMONTE LECHE 380GR	7707228547906	t	9500.00	9000.00	\N	\N	0.00	2025-10-19 02:29:40.966547	2025-10-19 02:29:40.966547
bcda5f73-282c-4b67-83b2-ed1e0106bbbd	FESTIVAL FRESA 12X4	7702025103867	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:40.966916	2025-10-19 02:29:40.966916
9e56ee4f-14c3-49ba-99e4-3555eee3bb37	FRUTIÑO LIMON	7702354032340	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:40.967744	2025-10-19 02:29:40.967744
dff0df83-b368-4474-a642-6ca6f5396b59	LIMPIDO QUITAMANCHA 450ML	7702137629569	t	2900.00	2800.00	\N	\N	19.00	2025-10-19 02:29:40.968183	2025-10-19 02:29:40.968183
ebbe382b-f5c0-4e70-9170-4a13f95782a1	Carey Relajacion Natural	7702310022279	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:40.968531	2025-10-19 02:29:40.968531
b44f7105-ec69-4383-ae26-6a0755064552	LIMPIDO MULTIUSOS 460ML	7702137007534	t	1400.00	1313.00	\N	\N	19.00	2025-10-19 02:29:40.968841	2025-10-19 02:29:40.968841
9b3a3eee-1fcb-4497-9e5f-62fbb093f8fd	VELON SAN JORGE N21 960GR	7707159821144	t	17500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.96907	2025-10-19 02:29:40.96907
0bbbd000-0702-4d5f-acd2-ab6a44018e53	AROMATEL MANZANA 180ML	7702191162699	t	1600.00	1450.00	\N	\N	19.00	2025-10-19 02:29:40.969294	2025-10-19 02:29:40.969294
60f413af-56a2-4155-a0e9-d687ac6ecc14	YOGOLIN FRESA LA MEJOR 150GR	7705241400925	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:40.969539	2025-10-19 02:29:40.969539
1a76d8af-c722-4e86-85c1-ed15a221566c	GANCHO ROPA COLORES X20	7453038432245	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.969777	2025-10-19 02:29:40.969777
efa22b1c-f9c4-4758-854e-8df360641f9f	CHOCOSO 65GR	7705326070371	t	2300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.970202	2025-10-19 02:29:40.970202
e4a2f54f-ae83-48e2-a5aa-6b8708cdae51	YOGOLIN DE MORA VASO 150GR	7705241400246	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:40.970712	2025-10-19 02:29:40.970712
23a0022a-a637-4646-a60a-08221ffc153f	YOGOLIN DE MELOCOTON VASO 150GR	7705241400260	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:40.972116	2025-10-19 02:29:40.972116
2d2ec063-9cc4-4ac9-b34a-ee6ae5d5d709	CHORIZO CAMPESINO COLANTA 250GR X5UNID	7702129072342	t	9400.00	9300.00	\N	\N	19.00	2025-10-19 02:29:40.973768	2025-10-19 02:29:40.973768
0ceab15d-ce2a-4443-91eb-1fdb64af1a64	YOGURT LA MEJOR 1LITRO	7705241400703	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.974484	2025-10-19 02:29:40.974484
5735061b-2c80-4808-8da1-810afbbae6cf	SOPA DE GALLINA CON FIDEOS 65GR	7702024015215	t	2200.00	2050.00	\N	\N	19.00	2025-10-19 02:29:40.974978	2025-10-19 02:29:40.974978
ca46b866-309f-4ab3-bc18-c0091480e708	GRAGEAS MULTICOLOR 250GR	7708730121271	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:40.975841	2025-10-19 02:29:40.975841
675b0277-cf67-4ef7-943c-2a7d04546f43	CLUB SOCIAL MANTEQUILLA X9	7622201720216	t	6700.00	\N	\N	\N	19.00	2025-10-19 02:29:40.976477	2025-10-19 02:29:40.976477
5fa8a12d-848e-428f-9c6f-7c88c9c4ec30	TAMPON NOSOTRAS UND	7702027437076	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.977266	2025-10-19 02:29:40.977266
b8b721fb-7269-43ee-86ab-6917a118ea2b	Lapiz Mongol Und	Lapiz Mongol Und	t	600.00	\N	\N	\N	0.00	2025-10-19 02:29:40.977964	2025-10-19 02:29:40.977964
ab0e408a-145e-4311-acf3-57d4f085b6f3	Hojilla cejas	Hojilla Cejas	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.978654	2025-10-19 02:29:40.978654
64ec4caf-3324-42f6-8a10-015ed1ae6694	CHUPAS PARA BAÑOS	7708304265585	t	3300.00	3100.00	\N	\N	19.00	2025-10-19 02:29:40.97908	2025-10-19 02:29:40.97908
1abf5a84-e3f9-42d9-934b-7981a47c041f	CEPILLO PARA BAÑO CON BASE	7707305120213	t	4300.00	4300.00	\N	\N	19.00	2025-10-19 02:29:40.979613	2025-10-19 02:29:40.979613
df096f3c-d558-4a7d-9191-84f89c2c5ee4	HUEVOS	hv	t	500.00	\N	\N	\N	0.00	2025-10-19 02:29:40.979962	2025-10-19 02:29:40.979962
f67e2a0d-60b3-44ee-ad7b-dc11d54f67fe	CREMA DE ARROZ PRIMOR POTE  900GR	7591002000165	t	10800.00	10450.00	\N	\N	19.00	2025-10-19 02:29:40.980649	2025-10-19 02:29:40.980649
091d594c-0477-4aa2-8030-32d1863f05bf	ARROZ MOLINERA 1.000GR	7709990544251	t	3600.00	3563.00	\N	\N	0.00	2025-10-19 02:29:40.981231	2025-10-19 02:29:40.981231
51ab5643-2dac-4ac8-9781-525acb7b0900	WINNY 4X100UNID	7701021116116	t	121000.00	118800.00	\N	\N	19.00	2025-10-19 02:29:40.981891	2025-10-19 02:29:40.981891
40b80795-4dc7-4500-b256-5af2bbc0cbc6	WINNY 3X100UNID	7701021116123	t	101500.00	99700.00	\N	\N	19.00	2025-10-19 02:29:40.982923	2025-10-19 02:29:40.982923
bc23d101-20e5-4d13-bea4-2b04d45459ce	TINTE KERATON 5.0	7707230996013	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:40.983693	2025-10-19 02:29:40.983693
d2e4dba4-0123-4e3a-a264-1acfd228c59f	TINTE LISSIA  4.0	7703819301834	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.984555	2025-10-19 02:29:40.984555
36d1c0be-6989-4d21-8216-d3178045dab5	PAN ARABE BIMBO X5UNID	7705326080462	t	5500.00	5300.00	\N	\N	19.00	2025-10-19 02:29:40.985331	2025-10-19 02:29:40.985331
2e6d3e9b-5a89-4888-8c61-2e1ee399ecd0	BIMBOLETE BIMBO X24UNID	7705326063199	t	21000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.985713	2025-10-19 02:29:40.985713
a7c0def2-a4f4-488a-b881-bb606b883fc6	MR BROWN X10UNID BIMBO	7705326079084	t	8400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.985988	2025-10-19 02:29:40.985988
4551352f-03b6-4205-9778-09597a2374a7	MR BROWN AREQUIPE 60GR	7705326078995	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:40.986271	2025-10-19 02:29:40.986271
90fc025a-b86d-4032-bdd4-245e4a272d3a	SUBMARINO 33GRMARINELA	7705326079022	t	1400.00	1250.00	\N	\N	19.00	2025-10-19 02:29:40.986579	2025-10-19 02:29:40.986579
d7d6e98c-7220-433e-97b6-769343e747dc	SUBMARINO MARINELA 35GR	7705326070593	t	1400.00	1250.00	\N	\N	19.00	2025-10-19 02:29:40.986937	2025-10-19 02:29:40.986937
e6ec9a97-706d-4c64-99f4-df0fe54d94b9	TINTE LISSIA  6.7	7703819301995	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.987405	2025-10-19 02:29:40.987405
b8198a68-9a43-4387-a487-d45e45e96d43	TINTE LISSIA 8.43	7703819304637	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.987757	2025-10-19 02:29:40.987757
47fd45a0-d608-4e5d-8b95-fd0b69a4d1bb	TINTE LISSIA 9.2	7703819304606	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.988193	2025-10-19 02:29:40.988193
61b86afa-e6e2-4842-999d-64a2f8a76332	TINTE LISSIA 1.1	7703819302039	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.988591	2025-10-19 02:29:40.988591
9dd307c6-ae2f-4f6f-8722-89f494a1e3ea	TINTE LISSIA 8.1	7703819301902	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.989133	2025-10-19 02:29:40.989133
d079ec36-613f-4246-ab39-9e7677f5f563	TINTE LISSIA 1.6	7703819302046	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.989442	2025-10-19 02:29:40.989442
48da5965-e896-4927-a47d-e1dd7b3268d0	TINTE LISSIA 7.2	7703819301933	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.98977	2025-10-19 02:29:40.98977
34005e1a-f513-4d92-9323-c88efe47912d	TINTE LISSIA 6.3	7703819301957	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.990123	2025-10-19 02:29:40.990123
7b805846-88c2-492f-985a-04576f606fcd	TINTE LISSIA 4.64	7703819302053	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:40.990359	2025-10-19 02:29:40.990359
34759c84-f3af-4d88-b3bd-2efb1625d097	ACEITE DE ROMERO CORPORAL	0737186833893	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.990614	2025-10-19 02:29:40.990614
a93cb33c-d306-421a-9228-9948180fd1f8	ACEITE DE COCO CORPORAL	0737186833824	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.990869	2025-10-19 02:29:40.990869
d0581baa-475b-483a-ab11-5254232bfcfa	ACEITE DE NARANJA CORPORAL	0737186833848	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.991097	2025-10-19 02:29:40.991097
41a17651-610d-4980-8e1a-460091dbdf1e	ACEITE DE AGUACATE CORPORAL	0737186833831	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.991586	2025-10-19 02:29:40.991586
3aad9cbd-12ff-4b35-8fd0-4b3a9e72f54d	TINTE KERATON 6.0	7707230996037	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:40.991864	2025-10-19 02:29:40.991864
6879839c-394c-48c9-9e4c-3c074275bcc2	AGUA DE ROSAS 500ML	7709183563540	t	5300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.99212	2025-10-19 02:29:40.99212
6ac2dfe1-1dbf-4918-a490-84a9369b7868	AGUA DE ROSAS 250ML	7709183563502	t	4300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.992392	2025-10-19 02:29:40.992392
08f64aea-9ebb-4a0d-b1dc-98c9850cff56	ARAN CHOCOLATE 1KG	8697635700195	t	19500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.992614	2025-10-19 02:29:40.992614
e74aa3ef-24ae-4301-bee3-6ff718be00a6	MALLITAS DE COLORES  X15UNID	454SS	t	6200.00	5900.00	\N	\N	19.00	2025-10-19 02:29:40.992835	2025-10-19 02:29:40.992835
113607cf-1613-4cb9-811c-9554088173de	ARRIVO X2UNID X24UNID	18681038213502	t	21800.00	21200.00	\N	\N	19.00	2025-10-19 02:29:40.993093	2025-10-19 02:29:40.993093
575b2a27-8c9a-4a1f-8217-4b4e7e1a04a2	ACEITE RIQUISIMO 3L	7701018007526	t	26100.00	25600.00	\N	\N	19.00	2025-10-19 02:29:40.993342	2025-10-19 02:29:40.993342
5c54ee1e-dd35-4faf-ac6e-1f5ea6777f55	ACEITE DE COCO SPRAY 50ML	545HJK	t	3800.00	3650.00	\N	\N	19.00	2025-10-19 02:29:40.993593	2025-10-19 02:29:40.993593
0b4d377e-7696-4dbb-9e9f-9196f5c8b62e	HUGGIES XTRA PROTECCION 4X25	7702425145108	t	23200.00	22600.00	\N	\N	19.00	2025-10-19 02:29:40.993832	2025-10-19 02:29:40.993832
d2e9bf73-accd-4b09-a345-7c5229185dee	CREMA PONDS HYDRATANTE 50GR	7501056330323	t	9000.00	8700.00	\N	\N	19.00	2025-10-19 02:29:40.994059	2025-10-19 02:29:40.994059
703b478d-0934-4ade-8204-d960d1d54487	SILICONA SPRAY 30ML	45S3FDA	t	4000.00	3900.00	\N	\N	19.00	2025-10-19 02:29:40.994394	2025-10-19 02:29:40.994394
54217d86-0f0f-4c1f-b89c-4c6bb063fdec	COLONIA CHICO 110ML	7591061647264	t	10000.00	9700.00	\N	\N	19.00	2025-10-19 02:29:40.99461	2025-10-19 02:29:40.99461
39cfb901-5cd3-4d87-8d54-681b7d3ac479	LASAGNA DORIA 380GR MAS 5MOLDE	7702085003411	t	9600.00	\N	\N	\N	19.00	2025-10-19 02:29:40.994806	2025-10-19 02:29:40.994806
ed401e41-6c7f-4c23-a85e-b56ed2cc65c7	CERO PLAGAS GEL 5GR	7707296880097	t	9000.00	\N	\N	\N	19.00	2025-10-19 02:29:40.995012	2025-10-19 02:29:40.995012
49b0f382-5208-4e5f-8d53-c95c72aaad01	DOÑA GALLINA DESMENUZADO X24UNID	7702354954055	t	7500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.995249	2025-10-19 02:29:40.995249
24795f25-4ee3-47d5-b282-a0ef6aac50c5	AXION LIMON 425GR	7509546687575	t	5600.00	5430.00	\N	\N	19.00	2025-10-19 02:29:40.995479	2025-10-19 02:29:40.995479
3f7357c5-b774-470e-b1d2-8559a7fa250d	GEL EGO ALFA 110ML	7702006205177	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:40.995688	2025-10-19 02:29:40.995688
fed03c8b-96ad-4700-9cd7-474d4df137d8	LADY SPEED STICK DERMA ACLARADO 150ML	7509546067919	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.99591	2025-10-19 02:29:40.99591
5bb747b5-bbd2-4d95-8721-503a09a8f5f6	REDONDITAS FRES 12X4	7707323130416	t	7400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.996142	2025-10-19 02:29:40.996142
929f6556-d6ff-4962-8b0b-cd2cdfa1006e	REXONA V8 BARRA 50GR	75024956	t	14500.00	14000.00	\N	\N	19.00	2025-10-19 02:29:40.996384	2025-10-19 02:29:40.996384
4836789c-44e3-4a5f-8faa-4440958e3e64	REXONA V8 AEROSOL 1500ML	7791293022567	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.996653	2025-10-19 02:29:40.996653
4dbd3c3b-6c15-4f88-9ce5-bff14575c621	PALITOS PARA HELADOS 1.000 INCOMAD	7707312109232	t	14000.00	13500.00	\N	\N	19.00	2025-10-19 02:29:40.996842	2025-10-19 02:29:40.996842
1cd887c8-d8d0-4f8d-85df-d3d200b27633	AMBIENTADOR GLADE MORA RADIANTE 400ML	7501032930851	t	11000.00	10600.00	\N	\N	19.00	2025-10-19 02:29:40.997046	2025-10-19 02:29:40.997046
4eb4db77-971f-4bee-81b6-8bd90ed8b472	AMBIENTADOR GLADE PARAIZO AZUL 400ML	7501032916176	t	11000.00	10600.00	\N	\N	19.00	2025-10-19 02:29:40.997379	2025-10-19 02:29:40.997379
5fa45760-9785-477d-8a8f-c30d95560b6a	AMBIENTADOR GLADE CHAMPGNE 400ML	7503035298075	t	11000.00	10600.00	\N	\N	19.00	2025-10-19 02:29:40.997639	2025-10-19 02:29:40.997639
f085043a-da40-4517-8a8d-f6b686c03cc0	AMBIENTADOR GLADE LAVANDA 400ML	7501032938215	t	11000.00	10600.00	\N	\N	19.00	2025-10-19 02:29:40.997858	2025-10-19 02:29:40.997858
151dfe13-2d94-433e-bdc8-7f5f60b37df6	HONY BRAN 3X9	7622300117184	t	6300.00	\N	\N	\N	19.00	2025-10-19 02:29:40.998052	2025-10-19 02:29:40.998052
4c65787c-eca7-4d86-8774-0d206ede7e98	APRONAX GEL CAPSULA	SDA4	t	1500.00	\N	\N	\N	0.00	2025-10-19 02:29:40.99825	2025-10-19 02:29:40.99825
5cf85a34-1f9b-4701-bffc-b59445923343	LA SOPERA CREMA DE SANCOCHO 84GR	7702354949891	t	2500.00	2340.00	\N	\N	19.00	2025-10-19 02:29:40.998466	2025-10-19 02:29:40.998466
6a664cc7-bb72-4d91-8280-3d53f501fe4f	LA SOPERA CREMA DE POLLO 85GR	7702354931032	t	2500.00	2340.00	\N	\N	19.00	2025-10-19 02:29:40.998694	2025-10-19 02:29:40.998694
aae559f6-e5f5-4401-993e-e2e178d073d2	BABYSEC XG/100	7709085938477	t	115000.00	112200.00	\N	\N	19.00	2025-10-19 02:29:40.998903	2025-10-19 02:29:40.998903
3b5724c4-aec9-4502-94dc-2e35a5d7a6db	VASOS 3.0OZ  50UNID	7709227102575	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:40.999122	2025-10-19 02:29:40.999122
c3d62763-5424-4e37-8bab-5eb2eed83b76	MIXTON BBQ 40GR	7706642007140	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:40.999351	2025-10-19 02:29:40.999351
5d6d982a-7ddb-4fe4-b4f8-f51d15e7b68e	ESTUCHE JOHNSONS BABY KIT	7702031583363	t	24500.00	\N	\N	\N	19.00	2025-10-19 02:29:40.999652	2025-10-19 02:29:40.999652
b856f000-0cc8-406b-8595-7e9f494b6060	REDONDITAS LIMON 12X4	7707323130423	t	7400.00	\N	\N	\N	19.00	2025-10-19 02:29:40.999887	2025-10-19 02:29:40.999887
085a4a6f-2449-469a-9d0c-4f1a110271eb	CREMA DEPILATORIA VEET 2 EN 1	7702626214207	t	21800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.000208	2025-10-19 02:29:41.000208
c7a42091-5b50-4994-9a85-1d1acf5eef88	NESCAFE 1.5GR	7702024066101	t	300.00	\N	\N	\N	5.00	2025-10-19 02:29:41.000462	2025-10-19 02:29:41.000462
145ab497-7385-4a74-a4e4-9c1a321acad0	ZUCARITAS KELLOGGS 250GR	7591057015107	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:41.000702	2025-10-19 02:29:41.000702
4f1de9a1-e959-4f3e-bd22-d29d778e7203	NESCAFE TRADICIONAL 48 SOBRES	7702024066118	t	10700.00	\N	\N	\N	5.00	2025-10-19 02:29:41.000933	2025-10-19 02:29:41.000933
0a7a94ba-ad35-4840-b66f-6bcdb06086e5	PEKITAS 33GR	7705326079121	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:41.001195	2025-10-19 02:29:41.001195
78facefd-b307-4eb4-b709-46eb538d1e92	MANCHITAS 45GR	7705326076908	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:41.001478	2025-10-19 02:29:41.001478
5329a5da-8f6a-4347-8fec-b6b84699bf55	Hit Mora 200 ml	7702090013016	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.001861	2025-10-19 02:29:41.001861
ca5b88a1-2e93-40f5-aa13-3545fa16d13b	SPAGHETTI LA NIEVE 1.000GR	7707237416101	t	3500.00	3417.00	\N	\N	5.00	2025-10-19 02:29:41.002131	2025-10-19 02:29:41.002131
1c5941fd-516a-40da-87a0-c293cfed63a0	ARROZ GELVEZ 900GR	7707197472131	t	3600.00	3500.00	\N	\N	5.00	2025-10-19 02:29:41.002419	2025-10-19 02:29:41.002419
42b6825f-8f95-4040-84a5-0d8008052ccd	MACARRON LA NIEVE 1.000GR	7707237417955	t	3500.00	3417.00	\N	\N	5.00	2025-10-19 02:29:41.002646	2025-10-19 02:29:41.002646
f9733328-605d-4808-86cd-02d150281a75	AVENA INST VAINILLA EXTRA SEÑ 180GR	7709990972061	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:41.002864	2025-10-19 02:29:41.002864
c384957c-66af-43fa-bc65-dfdd019e00a9	AVENA EXTRA SEÑORA INSTANTANEA FRESA 180GR	7708345181622	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:41.003089	2025-10-19 02:29:41.003089
6b691a7b-5360-4e08-b4b0-bf185af65b4f	YOGOLIN DE FRESA VASO 150GR	7705241400253	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.003313	2025-10-19 02:29:41.003313
ad060f04-6f0b-4e21-8eec-771aafe58c02	SALCHICHON FINO COLANTA 125GR	7702129074445	t	2100.00	2000.00	\N	\N	5.00	2025-10-19 02:29:41.003837	2025-10-19 02:29:41.003837
0a25837d-1ebc-4df4-b018-19aff62b2d35	AREPA REPA 1.000GR	7702910002022	t	2800.00	2750.00	\N	\N	5.00	2025-10-19 02:29:41.004191	2025-10-19 02:29:41.004191
ebad035e-e76f-464e-a95b-f5de05955361	COMARRICO MACARRON CORTO 250GR	7707307962231	t	1800.00	1700.00	\N	\N	5.00	2025-10-19 02:29:41.004446	2025-10-19 02:29:41.004446
bcf142fc-7207-4c60-ba8e-e6b563ce4206	PIRULITO X24UNID	7702011021106	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.004651	2025-10-19 02:29:41.004651
3ac08935-31f2-43c1-a958-b99dd9f623c4	CAMPI ESPARCIBLE CON SAL 125GR	7702109018797	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.00495	2025-10-19 02:29:41.00495
32c8e4d4-36c0-4fe0-ac33-e766a4473535	ICE MINT MENTA HIELO X100UNID	7707014904333	t	5900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.005206	2025-10-19 02:29:41.005206
2cf19385-2e15-4397-9b66-615e8b97db12	TOLLIN FAVORITA MULTIUSOS 45TOALLAS	7702120009569	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:41.005443	2025-10-19 02:29:41.005443
00012457-53f4-4584-ae8c-5104392f220b	paketon papas limon	7702189037275	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.005654	2025-10-19 02:29:41.005654
205442c8-adea-4725-a590-9e357e46ba00	AK1 450GR MANZANA	7702310047012	t	4900.00	4750.00	\N	\N	19.00	2025-10-19 02:29:41.005876	2025-10-19 02:29:41.005876
aa6393a2-58ee-45d4-b076-013053c91ae5	SALSA TARTARA LA CONSTANCIA 85GR	7702097148650	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.006106	2025-10-19 02:29:41.006106
f72e300b-017f-4ee0-8c17-e0c5dc62d96d	granola mixta ceregran	7707324631097	t	9000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.00633	2025-10-19 02:29:41.00633
b702cd8b-8a56-48c4-8efe-c2a318c14173	CLORO FULL GLOSS GALON	7700228012986	t	3800.00	3650.00	\N	\N	19.00	2025-10-19 02:29:41.006559	2025-10-19 02:29:41.006559
75d1fb9d-4297-4407-a4d7-43a54b3e30dc	DE TODITO PAQUETON BBQ 45 G	7702189019646	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.006784	2025-10-19 02:29:41.006784
b4c2da0d-06c8-4cdb-905c-0776ff047c16	JUGO HIT	7707133025919	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.007003	2025-10-19 02:29:41.007003
ec5d6840-b7bb-4741-a198-c06a2292c7ba	COLGATE MAXWHITE BLANCURA 100ML X3UNID	7702010612084	t	25000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.007237	2025-10-19 02:29:41.007237
f982c7c2-f144-4f67-9513-8a2fa561a67b	YOGURT DE MORA LA MEJOR 1LITRO	7705241400802	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.007453	2025-10-19 02:29:41.007453
829aa4f5-0c75-4dbd-bad5-3d7a8d961221	PAN TAJADO MANTEQUILLA GUADALUPE	7705326020505	t	6000.00	5900.00	\N	\N	0.00	2025-10-19 02:29:41.007658	2025-10-19 02:29:41.007658
d6ead081-b08c-4f7a-aa2f-edad19536d20	DOÑA AREPA 1.000GR	7702020212052	t	4600.00	4500.00	\N	\N	5.00	2025-10-19 02:29:41.007867	2025-10-19 02:29:41.007867
b93cf63c-56a2-48ad-b07a-3f82cba3c9a6	FAMILIA  MORADO	7702026148348	t	1300.00	1146.00	\N	\N	19.00	2025-10-19 02:29:41.008084	2025-10-19 02:29:41.008084
29ed049e-7d32-4451-b3ec-41f4fb67f5f1	QUESO CREMA COLANTA 230GR	7702129025201	t	5300.00	5200.00	\N	\N	0.00	2025-10-19 02:29:41.008297	2025-10-19 02:29:41.008297
1ba9819a-4b9c-46f6-8745-2d99edc0cde2	SUPER RIEL 200GR BARRA	7702310010405	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.008514	2025-10-19 02:29:41.008514
86b49557-2e36-4a73-a7c3-07343f735540	MACARRON COMARRICO 1.000GR	7707307962521	t	5600.00	5417.00	\N	\N	5.00	2025-10-19 02:29:41.008738	2025-10-19 02:29:41.008738
c4abdcfd-8b65-435c-b833-90e8d6657e12	Ak Lavaloza 500g	7702310040280	t	4800.00	4650.00	\N	\N	19.00	2025-10-19 02:29:41.008971	2025-10-19 02:29:41.008971
81398bdc-21ee-49a7-a1a3-12d3d5284291	CAFE AROMA 125GR	7702088343903	t	6600.00	6450.00	\N	\N	5.00	2025-10-19 02:29:41.009182	2025-10-19 02:29:41.009182
bf67b7ee-3cf6-42e2-9a8c-67b8c5879e56	SALSA BBQ BARY 170GR	7702439690168	t	3300.00	3150.00	\N	\N	19.00	2025-10-19 02:29:41.009418	2025-10-19 02:29:41.009418
ba673b6f-cf27-48c5-998a-39a45ca7ae6b	PAÑO LIMPION SECATODO 1UNID	7702037873109	t	1700.00	1580.00	\N	\N	19.00	2025-10-19 02:29:41.009631	2025-10-19 02:29:41.009631
7a4abb18-cad2-4e65-9df8-0d43c3596fe2	MACARRON LA NIEVE 500GR	7707237417900	t	1900.00	1800.00	\N	\N	5.00	2025-10-19 02:29:41.00985	2025-10-19 02:29:41.00985
ad04d575-90c6-4f39-beb0-ba1615e70550	Pasta La Nieve Spaguetti 500g	7707237416057	t	1900.00	1800.00	\N	\N	5.00	2025-10-19 02:29:41.01006	2025-10-19 02:29:41.01006
aee9c06e-74d7-4d5e-ad01-310b1d2f14ae	DETERK 1KG	7702310045391	t	5700.00	5550.00	\N	\N	19.00	2025-10-19 02:29:41.010335	2025-10-19 02:29:41.010335
db340cc9-ab69-4704-aa05-8c8d1316d357	ARIEL REVITACOLOR 1KG	7500435149563	t	11000.00	10500.00	\N	\N	19.00	2025-10-19 02:29:41.01054	2025-10-19 02:29:41.01054
9c95c021-f08f-4232-8124-dea8f0c21b99	CAFE AROMA 250GR	7702088343934	t	13900.00	13500.00	\N	\N	5.00	2025-10-19 02:29:41.010742	2025-10-19 02:29:41.010742
141272de-d658-4bb8-9f4b-61644043f134	BOKA TAMARINDO	7702354952907	t	800.00	710.00	\N	\N	0.00	2025-10-19 02:29:41.010951	2025-10-19 02:29:41.010951
a9f889d7-d1ec-4870-9693-703f978ee7b9	ELITE DOU ROLLAZO ROJO	7707199348380	t	2000.00	1834.00	\N	\N	19.00	2025-10-19 02:29:41.011185	2025-10-19 02:29:41.011185
7afb3913-14b5-4399-a8e1-5243d8789aaf	ACEITE IDEAL LITRO	7709067256650	t	6400.00	6084.00	\N	\N	19.00	2025-10-19 02:29:41.011406	2025-10-19 02:29:41.011406
3c0c326d-11a7-482f-ab3c-01edc2aa0aec	TOALLA COSINA FAVORITA 45HJ	7702120014440	t	2200.00	2050.00	\N	\N	19.00	2025-10-19 02:29:41.011621	2025-10-19 02:29:41.011621
ec0fe566-c997-4e23-bf95-f73eae4b35c2	REFISAL LIGERA TARRO 500GR	7703812408967	t	8600.00	\N	\N	\N	0.00	2025-10-19 02:29:41.011832	2025-10-19 02:29:41.011832
fadc3e03-d364-412e-b447-c0e8590bf1fa	JET COOKIES AND CREAM X50GR	7702007042276	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.012076	2025-10-19 02:29:41.012076
3611cd0d-29a4-4a29-8ac1-1191cfa59b0e	ACEITE IDEAL 2.7LITROS	7709385952807	t	19300.00	18900.00	\N	\N	19.00	2025-10-19 02:29:41.012332	2025-10-19 02:29:41.012332
b9b7985d-a383-4978-a8e5-ebff1c472189	PIRULITO X24UNID	7702011020987	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.012539	2025-10-19 02:29:41.012539
25b80b20-e204-4d37-8275-9f450e2bd913	Atun Lomo Aceite	7700618020249	t	3800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.012785	2025-10-19 02:29:41.012785
27374a59-0dfc-4ec7-ae67-81a5ef8a51ef	ARIEL 2.000GR	7500435149570	t	22500.00	21800.00	\N	\N	19.00	2025-10-19 02:29:41.012994	2025-10-19 02:29:41.012994
4e5f7135-3900-4f73-8e8e-03f7f1c32b84	DETERK LIBRA FLORAL	7702310045384	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:41.013253	2025-10-19 02:29:41.013253
a6e392b8-4f27-4deb-92b4-83104b2556c0	COLCAFE GRANULADO INTENSO 25GR	7702032109319	t	6100.00	5950.00	\N	\N	5.00	2025-10-19 02:29:41.013478	2025-10-19 02:29:41.013478
778c5d3a-edb1-41fa-a25c-e3632bdea398	CAFE AROMA 500GR	7702088343897	t	24500.00	23900.00	\N	\N	5.00	2025-10-19 02:29:41.013694	2025-10-19 02:29:41.013694
5ab5b2b0-3841-47e4-b8c9-8ffc6b8ae812	MERMELADA LA CONSTANCIA FRESA 90GR	7702097148568	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:41.013943	2025-10-19 02:29:41.013943
88c15206-a26c-4b67-b6bb-4ac24d95958c	AZUCAR PALACIO 1.000GR	7709990854251	t	4000.00	3860.00	\N	\N	5.00	2025-10-19 02:29:41.014156	2025-10-19 02:29:41.014156
2d8e9dee-b08e-43be-85b2-65f823ff9056	FLUOCARDENT 150ML	7702560041785	t	10000.00	9750.00	\N	\N	19.00	2025-10-19 02:29:41.014399	2025-10-19 02:29:41.014399
1d3b7b38-cfbf-4dde-8790-e18587015cde	CONCHAS DORIA 250GR	7702085012123	t	2200.00	2100.00	\N	\N	5.00	2025-10-19 02:29:41.014607	2025-10-19 02:29:41.014607
9fc2dede-dd90-4276-82b0-a7d4d6bf508c	KOTEX DISCRETA 10U 15 PROT	7702425806566	t	6000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.014948	2025-10-19 02:29:41.014948
ee83889a-413d-473e-b944-2fcab5802418	SUAVITEL 430ML CUIDADO SUPERIOR	7702010282751	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.015155	2025-10-19 02:29:41.015155
7f04034d-57b5-4afb-b2d2-e2eb34063f9b	NOSOTRAS INVISIBLE RAPIGEL 10 MAS 5	7702026177874	t	5200.00	5050.00	\N	\N	0.00	2025-10-19 02:29:41.015358	2025-10-19 02:29:41.015358
820718e4-a666-42a1-ada0-333a0cc8e100	MAYONESA IDEAL 450GR	7708969766076	t	4500.00	4370.00	4200.00	\N	19.00	2025-10-19 02:29:41.015606	2025-10-19 02:29:41.015606
ab0f42a1-b3de-45f1-bf6a-8c59ad38e218	MAYONESA IDEAL 200GR	7708969766090	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.015831	2025-10-19 02:29:41.015831
89bac208-3616-478e-a63f-bd75a603996f	CHEESE TRIS 80GR	7702189056795	t	3700.00	3600.00	\N	\N	19.00	2025-10-19 02:29:41.016063	2025-10-19 02:29:41.016063
a8fa0a19-8d0a-4cb4-91b2-43ff685c9d1a	Vinagre	7707265950028	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.016286	2025-10-19 02:29:41.016286
14de0a2e-cb95-4bc6-aa00-97158e52fa9f	SHAMPO SAVITAL COLAGENO Y SABILA 550ML	7702006299565	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:41.016486	2025-10-19 02:29:41.016486
e476a299-e179-44bb-b95a-550e3b67eff7	CHIDOS MERO QUESO 38GR	7702152119434	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.016789	2025-10-19 02:29:41.016789
a9fdfaaa-055a-41c3-86aa-ad01d489103a	DERSA DETERGENTE 4.000GR	7702166041516	t	31000.00	30500.00	\N	\N	19.00	2025-10-19 02:29:41.017089	2025-10-19 02:29:41.017089
ed231acb-82e4-44fe-915b-11772b47f046	DORITOS MEGA QUESO 43GR	7702189053817	t	2600.00	2500.00	2390.00	\N	19.00	2025-10-19 02:29:41.01731	2025-10-19 02:29:41.01731
96126094-0776-4508-9806-e5a95731dfc8	SOTF KLEAN FLORAL 450ML	7702310046244	t	3100.00	2950.00	\N	\N	19.00	2025-10-19 02:29:41.017524	2025-10-19 02:29:41.017524
62334461-b2c6-4da8-a28d-f57380b497c7	MARGARINA CREMOSA LA BUENA 125GR	7702109011996	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:41.01773	2025-10-19 02:29:41.01773
7aed8231-7aaf-41a5-95cd-8f359da2cd78	TORNILLO COMARRICO 250GR	7707307962262	t	1800.00	1700.00	\N	\N	5.00	2025-10-19 02:29:41.017948	2025-10-19 02:29:41.017948
3b058376-5ebf-44d7-927b-8daee7570707	REXONA CLINICAL MEN V8 SACHET 8.5	7702006205511	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.018178	2025-10-19 02:29:41.018178
47f8e9fe-cdb6-44f3-ab2e-b74e67a04adf	TOALLIN ELITE X70	7707199347802	t	2400.00	2280.00	\N	\N	0.00	2025-10-19 02:29:41.018611	2025-10-19 02:29:41.018611
cadcfd79-ff58-4a2b-aa8c-e5e14ee6298c	COLGATE KIDS FRESA 50GR	7891024034095	t	4100.00	4000.00	\N	\N	19.00	2025-10-19 02:29:41.018813	2025-10-19 02:29:41.018813
317aa00e-1def-4492-8751-055d6d4e2357	SAZONAREY 55GR	7702175156799	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:41.019042	2025-10-19 02:29:41.019042
d6a0d39b-a80e-4850-abbe-8cefdcfd668b	GUSTOSITA ESPARCIBLE 220GR	7702028879103	t	3500.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.019269	2025-10-19 02:29:41.019269
ef47b97a-5fc4-4e08-b0b6-b8b34af9ee8d	Scotch Brite Cocina	7702098040328	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.019527	2025-10-19 02:29:41.019527
d8a359ea-05ed-4292-aeeb-d2f6535fbd1b	SHAMPOO PANTENE PRO V 18ML	7500435108294	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.019729	2025-10-19 02:29:41.019729
36786b95-ccf2-4c1f-bdc6-d6fcc3e75d9d	CHOCOLISTO 220GR	7702007068023	t	7200.00	7000.00	\N	\N	19.00	2025-10-19 02:29:41.019949	2025-10-19 02:29:41.019949
b9f5029a-0012-44e9-a4e7-75b2030cc4a6	7cereales200g	cer7	t	1900.00	\N	\N	\N	5.00	2025-10-19 02:29:41.020191	2025-10-19 02:29:41.020191
92fea507-dfca-44b5-8788-0f48f967bcd3	Nutribela Repolizacion10	7702354944148	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.020438	2025-10-19 02:29:41.020438
6c0ad65d-1f4b-4743-a78e-5b3d946d64b8	FRUTIÑO PIÑA NARANJA	7702354032395	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:41.020667	2025-10-19 02:29:41.020667
d5af9d3e-b9ba-43bb-abde-40ba1962c406	CHOCOLISTO 100GR	7702007085891	t	3800.00	3700.00	\N	\N	19.00	2025-10-19 02:29:41.020976	2025-10-19 02:29:41.020976
3c501fb9-86c9-47a4-8ad9-d4596fd04a8f	SPEED MAX BOTELLA 250ML	7702090039436	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.021248	2025-10-19 02:29:41.021248
eb0371a8-0850-44df-b501-6ed7c7699201	POPETAS CARAMELO	7702354934255	t	1900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.021502	2025-10-19 02:29:41.021502
5786f5cf-b5f0-47d6-bdc8-3faa18aa5148	SALTIN NOEL INTEGRAL 136GR	7702025139972	t	3100.00	2960.00	\N	\N	19.00	2025-10-19 02:29:41.021733	2025-10-19 02:29:41.021733
f27a1f62-21ae-4735-9bb2-8d9bb595bbd7	LAK X4	7702310020855	t	6700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.021959	2025-10-19 02:29:41.021959
a53e6d44-7a0a-4010-be8d-01b0bde53129	BIMBOLETE X2 BIMBO	7705326012395	t	2100.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.022211	2025-10-19 02:29:41.022211
9fcd80f2-013e-4842-bdf4-8f8275f12c6c	BEBEX 3X30	7707199340957	t	25200.00	24600.00	\N	\N	19.00	2025-10-19 02:29:41.02245	2025-10-19 02:29:41.02245
3e388dc0-a7ba-4bff-88e3-59007881f2b3	SALCHICHA ZENU 150GR	7701101242049	t	5700.00	5500.00	\N	\N	19.00	2025-10-19 02:29:41.022655	2025-10-19 02:29:41.022655
a19f2efe-40da-4d1e-aa35-c2c30253d41f	DE TODITO BBQ 165GR	7702189057624	t	7600.00	7340.00	7200.00	\N	19.00	2025-10-19 02:29:41.022871	2025-10-19 02:29:41.022871
1407fbc0-c7a0-42c9-9c72-e09edf147f06	COLOR REY 20GR	7702175108590	t	500.00	330.00	\N	\N	19.00	2025-10-19 02:29:41.02311	2025-10-19 02:29:41.02311
2c304aa9-1bcd-4dd1-87e1-990e0761fa8c	BETUN BUFALO MARRON 36GR	7702377000104	t	4000.00	3850.00	\N	\N	19.00	2025-10-19 02:29:41.023366	2025-10-19 02:29:41.023366
f600c8ba-bed3-4495-9ab9-f881ccbebf62	COLOR REY 55GR	7702175111248	t	1200.00	1100.00	\N	\N	19.00	2025-10-19 02:29:41.023596	2025-10-19 02:29:41.023596
809eeae8-2811-4033-b901-68cd2ffe5354	TORNILLO COMARRICO 1.000GR	7707307962217	t	5600.00	5417.00	\N	\N	5.00	2025-10-19 02:29:41.023801	2025-10-19 02:29:41.023801
9169feb9-2a12-4ec1-923d-628508d4c121	JET COOKIES AND CREAM 10UND 210GR	7702007052381	t	34500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.024123	2025-10-19 02:29:41.024123
0afd6141-b222-45a4-8a1a-cd0e733186c0	BURBUJET CRUJIVAINILLA 12U 600GR	7702007056372	t	31400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.024333	2025-10-19 02:29:41.024333
e2ce4f3d-eb72-45d6-a93b-d87d5352dc22	BURBUJET CRUJIVAINILLA 50GR	7702007055986	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.024575	2025-10-19 02:29:41.024575
cd6041df-6410-4159-9eb1-173db2abc5ab	JET CREMA 18GR	7702007053050	t	2600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.02483	2025-10-19 02:29:41.02483
7d5ee9a2-4233-479d-98ee-5ed0d9bca123	MANI KRAKS CHILE LIMON	7702007074673	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.025063	2025-10-19 02:29:41.025063
4c7b030a-4dc8-41bd-82a2-76e5d9244a57	MANI POLLO BARY	7702439663803	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.025398	2025-10-19 02:29:41.025398
f5f0e164-e28a-4ca8-b513-8871dc8fe6d6	CEPILLO COLGATE MEDIO	7509546015040	t	2200.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.025607	2025-10-19 02:29:41.025607
20a0c499-c25f-47ce-a7ff-4f378406314b	Jugo del Valle	7702535002469	t	6300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.025817	2025-10-19 02:29:41.025817
0b5048fe-fa38-48d9-9edd-b6931428d6e7	AGUA CRISTAL 300ML	7702090073065	t	700.00	563.00	\N	\N	0.00	2025-10-19 02:29:41.026028	2025-10-19 02:29:41.026028
e476776e-b349-4dd4-a83c-fa551a89c540	CHEETOS HORNEADOS PICANTE 34GR	7702189057884	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:41.026333	2025-10-19 02:29:41.026333
c7927bcf-f021-46b9-8766-be4704826b60	ALBONDIGA CERDO ZENU 162GR	7701101247648	t	6900.00	6700.00	\N	\N	19.00	2025-10-19 02:29:41.026549	2025-10-19 02:29:41.026549
e7998844-963f-4763-be4d-5576cb87a359	REXONA CLINICAL SACHET 8.5	7702006205535	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.026771	2025-10-19 02:29:41.026771
e96d072a-1714-480d-ad38-4253851b4784	SHAMPO KONZIL 25ML	7702045257922	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.026995	2025-10-19 02:29:41.026995
1ca4834b-93cf-4333-ad04-3f6de94c292e	BEBEX 4X30	7707199340964	t	30300.00	29500.00	\N	\N	19.00	2025-10-19 02:29:41.027259	2025-10-19 02:29:41.027259
67842628-460d-4f0d-8cbd-2b0a71c84d72	DETERGENTE 3D 125GR	7702191348611	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.02751	2025-10-19 02:29:41.02751
d109ac14-31fe-4a77-b46e-aa70d506664b	VANISH BLANCO 450ML	7702626214948	t	4800.00	4650.00	\N	\N	19.00	2025-10-19 02:29:41.027719	2025-10-19 02:29:41.027719
27e61da6-bba4-43eb-8da6-143d9b25e246	BONICE X10UNID SURTIDO	7702354942915	t	7300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.027929	2025-10-19 02:29:41.027929
55df49ea-be2d-44ac-92c5-57815bb3c996	EMULSION SCOTT 180ML	7707172681107	t	14500.00	14000.00	\N	\N	19.00	2025-10-19 02:29:41.028325	2025-10-19 02:29:41.028325
1b104f0f-58e9-4e19-9ed0-14caeb65e7d7	EMULSION DE SCOTT TRADICIONAL 180ML	7707172681060	t	14500.00	14000.00	\N	\N	19.00	2025-10-19 02:29:41.028532	2025-10-19 02:29:41.028532
7cc3b38c-948a-45a7-b8f5-1d9a6934e0c1	ROSAL PLUS GRANDE G	7702120010169	t	1300.00	1167.00	\N	\N	19.00	2025-10-19 02:29:41.02876	2025-10-19 02:29:41.02876
4aa470dc-8295-4771-ab18-4084ed6a927c	FRUTIÑO FRUTOS ROJOS 18GR	7702354955946	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:41.028998	2025-10-19 02:29:41.028998
ab869b4c-10c4-45e3-8a12-281a44eab057	AK1 1450GR FLORAL	7702310044981	t	12400.00	11900.00	\N	\N	19.00	2025-10-19 02:29:41.029247	2025-10-19 02:29:41.029247
ec184f8f-8422-4048-867c-65ce12ee6d7e	Jugo del Valle 500 ml	7702535022054	t	1700.00	1584.00	\N	\N	19.00	2025-10-19 02:29:41.029514	2025-10-19 02:29:41.029514
fbc32f2e-a753-43bf-8406-366ec0a1f61c	KOTEX DIA Y NOCHE 8UND	7702425807648	t	4300.00	4000.00	\N	\N	0.00	2025-10-19 02:29:41.029729	2025-10-19 02:29:41.029729
8ee07d1a-9b63-41f5-8d67-5bdc200fcfc2	Shampoo H y S 33 ml.	7500435126601	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.029952	2025-10-19 02:29:41.029952
1dadcb68-e138-49d4-bd75-12485a66cec5	ATUN VIKINGOS RALLADO ACEITE	7702088198350	t	4400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.030153	2025-10-19 02:29:41.030153
84eb58d9-cd51-4249-9bdb-173c5c8a918d	LE FRAGANCE X3UNID	7702310024051	t	4000.00	3900.00	\N	\N	19.00	2025-10-19 02:29:41.030358	2025-10-19 02:29:41.030358
6df3a23f-7561-4042-8c4c-b2a50e53d1e9	PEPSI 2.5L	7702192004202	t	4800.00	4438.00	\N	\N	19.00	2025-10-19 02:29:41.030568	2025-10-19 02:29:41.030568
acd22d74-c86e-46f1-aeab-95f1b17c9c2a	FRUTI CANDY X100UNID	7707014904241	t	4400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.030789	2025-10-19 02:29:41.030789
80c12dad-fa57-4db8-9e41-1c0f083ab864	BOMBILLO SYLVANIA 7W	7702048231752	t	2100.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.031008	2025-10-19 02:29:41.031008
e7aaa4ba-4188-4057-849d-1162aa611880	COCA COLA 250ML	77035684	t	1700.00	1559.00	\N	\N	19.00	2025-10-19 02:29:41.031243	2025-10-19 02:29:41.031243
50f88036-0d12-40b3-99dd-5c6256d7bc77	KOTEX X16 NOCTURNA	7702425805316	t	10900.00	10500.00	\N	\N	0.00	2025-10-19 02:29:41.031499	2025-10-19 02:29:41.031499
7c8a75cb-c51e-4032-88e1-81ff864ea16b	JUGO VALLE X6UNID	7702535030189	t	6300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.031761	2025-10-19 02:29:41.031761
c9618491-ed58-4b89-b779-60b38bae7c7e	COCA COLA 400ML	7702535011089	t	2700.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.031985	2025-10-19 02:29:41.031985
56d8f6ab-e1bf-45fc-a0e4-ceae158b4965	SABRINA ESPARCIBLE 125GR	7702028021663	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.032211	2025-10-19 02:29:41.032211
aa901c0c-a4a6-4f4e-beea-9c3ad1201a4d	TRULULU CLASICAS	7702993031285	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.032446	2025-10-19 02:29:41.032446
fdc44404-ae9e-4d4d-823b-af677a0ab6bb	TALCO MEXANA 85GR	7702502705300	t	2200.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.032685	2025-10-19 02:29:41.032685
dc435fe0-8c56-452c-a784-9d02372255ca	3D DETERGENTE BICARBONATO 250GR	7702191348536	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:41.032914	2025-10-19 02:29:41.032914
e1ef7615-aa76-41df-b9c1-748ed195b171	ARIEL TRIPLE PODER 450GR	7500435124683	t	5200.00	5100.00	\N	\N	19.00	2025-10-19 02:29:41.033148	2025-10-19 02:29:41.033148
f77c3153-5d61-4a75-b838-3e9aab2c8d8b	Vive 100	7702354945008	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:41.03377	2025-10-19 02:29:41.03377
fb340206-cd4c-4558-a5ac-67a0ed11c14b	TOALLAS STAYFREE 42UND	7702031580010	t	13500.00	13000.00	\N	\N	19.00	2025-10-19 02:29:41.034183	2025-10-19 02:29:41.034183
a03ac40b-6eac-4c1d-a6ed-bdd7299ee4d4	GILLETTE SPECIALIZEO COOL WAVE 82GR	7702018913664	t	17900.00	17400.00	\N	\N	19.00	2025-10-19 02:29:41.034436	2025-10-19 02:29:41.034436
7a968959-c3bf-4e12-a4a2-7ce5203d130e	SUPER HIPER ACIDOS X100	7703888589270	t	11700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.034687	2025-10-19 02:29:41.034687
0ae96ed3-8935-460a-95c0-4c1a78235706	CHICLE AGOGO ORIGINAL GIGANTE X100UNID	7703888292491	t	7000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.034935	2025-10-19 02:29:41.034935
58c9dad4-a501-4dbb-a20f-ee6e6bef5afe	SALSA PARA CARNES NORSAN 170GR	7709834109295	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.035164	2025-10-19 02:29:41.035164
ba7b0c79-fcac-4599-a950-3fdb5e614863	SALSA DE SOYA NORSAN 1LITRO	7709140575081	t	6600.00	6450.00	\N	\N	19.00	2025-10-19 02:29:41.035381	2025-10-19 02:29:41.035381
f49f976c-1658-42e7-a866-b584d8bbdbda	AK11 DETERGENTE 300ML	7702310048040	t	3300.00	3100.00	\N	\N	19.00	2025-10-19 02:29:41.03559	2025-10-19 02:29:41.03559
036036d9-eec1-4a05-b1f9-17a5f9cdbb87	AREPASAN 1.000GR	7705525010123	t	2900.00	2750.00	\N	\N	5.00	2025-10-19 02:29:41.035818	2025-10-19 02:29:41.035818
2fd6f2ba-9b20-43ab-a25b-4d5a60c293e9	ARROZ ORO 1.000GR	7707222295728	t	4200.00	4134.00	\N	\N	0.00	2025-10-19 02:29:41.036025	2025-10-19 02:29:41.036025
7a892a5c-f882-4eb2-bd28-bec5ba3080e6	SALSA TOMATE IDEAL 400GR	7708969766014	t	4000.00	3850.00	3700.00	\N	19.00	2025-10-19 02:29:41.036501	2025-10-19 02:29:41.036501
753608a1-c3e6-4183-a432-1ba3050543a1	AREPA LA NIEVE 1.000GR	7707237414046	t	2700.00	2600.00	\N	\N	5.00	2025-10-19 02:29:41.036735	2025-10-19 02:29:41.036735
e4199bcf-866a-4932-a2bd-966680d6b02c	AGUA POOL 600ML	7708984708709	t	1000.00	575.00	\N	\N	0.00	2025-10-19 02:29:41.037113	2025-10-19 02:29:41.037113
f8745d5b-1fbc-4e14-81c0-7ee60d13e567	PONQUE TRADICIONAL RAMO 230GR	7702914594462	t	6200.00	6100.00	\N	\N	19.00	2025-10-19 02:29:41.037355	2025-10-19 02:29:41.037355
1db7f96a-d33a-4c23-9a84-d6b1a565564e	FAMILIA ACOLCHAMAX MEGA ROLLO	7702026147471	t	2100.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.037555	2025-10-19 02:29:41.037555
62e5ab8a-1ae3-414b-b5a6-5948f13f42fb	REXONA CLINICAL MEN 8.5GR	7702006205542	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.037773	2025-10-19 02:29:41.037773
1f4a7124-f141-42c9-831f-4c1a5076839a	FRUTIÑO MANGO	7702354032449	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:41.038011	2025-10-19 02:29:41.038011
1512029f-38fb-4c7d-968c-6e3f8c263f14	AK LAVALOZA MANZANA VERDE 900GR	7702310040273	t	9100.00	8900.00	\N	\N	19.00	2025-10-19 02:29:41.038263	2025-10-19 02:29:41.038263
fba2131a-f5f7-416c-9781-d878cac1e15d	AK LAVALOZA LIQUIDO 360ML	7702310049108	t	3700.00	3550.00	\N	\N	19.00	2025-10-19 02:29:41.038517	2025-10-19 02:29:41.038517
9cac4e9e-bffc-436b-aca6-1e1fa24e2991	PAN TAJADO BLANCO GUADALUPE	7705326091611	t	5100.00	4900.00	\N	\N	0.00	2025-10-19 02:29:41.038757	2025-10-19 02:29:41.038757
72513067-23fb-412c-8d14-815a438b2343	Gala Chocolate 63g	7702914112017	t	7500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.038984	2025-10-19 02:29:41.038984
7998dbd8-0237-4f52-938e-5fb1ea9b3706	QUIPITOS POPS	7702354930783	t	600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.039224	2025-10-19 02:29:41.039224
80c81141-9eaa-4ef5-ac53-87b711bbd132	SALTINAS ORIGINAL 106GR	7702024071747	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.03944	2025-10-19 02:29:41.03944
2cdfa976-9c30-470c-a162-a7a2ed89ba46	PROTECTORES NOSOTRAS MULTI ESTILO X60UNID .20	7702026174866	t	10500.00	10100.00	\N	\N	0.00	2025-10-19 02:29:41.039634	2025-10-19 02:29:41.039634
58026680-019b-4c69-afbf-9341f14ec414	POQUE RAMO CHOCOLATE 230GR	7702914594479	t	8000.00	7900.00	\N	\N	19.00	2025-10-19 02:29:41.039855	2025-10-19 02:29:41.039855
22929544-37a1-4a22-af06-aca6c7536fa7	AK1 DETERGENTE LIQUIDO 900ML	7702310048064	t	10000.00	9750.00	\N	\N	19.00	2025-10-19 02:29:41.040072	2025-10-19 02:29:41.040072
f9924923-1055-45ab-b618-356c813cf1e1	PROTECTORES DIARIO LARGOS X10UNID	7702027434242	t	1800.00	1700.00	\N	\N	0.00	2025-10-19 02:29:41.040293	2025-10-19 02:29:41.040293
9c07a712-2efe-420e-bd8e-8d65802a8014	Trident	7702133867101	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.040511	2025-10-19 02:29:41.040511
43d690f0-9011-47f9-a8e3-6a1ca0caaa18	MAYONESA IDEAL 255GR	7708969766045	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.040703	2025-10-19 02:29:41.040703
e20bf899-9656-4908-9d3e-50219fb7e254	KALUA	7705241090171	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.040908	2025-10-19 02:29:41.040908
7e9c8974-cf2b-4e2f-90f7-f72ca3809ed0	JUMBO FLOU CHOCOLATE 48GR	7702007039689	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.041119	2025-10-19 02:29:41.041119
f010b1fa-37cf-4ca1-a93f-3357704aef37	PROTEX OMEGA 3 110GR	7702010420849	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:41.041321	2025-10-19 02:29:41.041321
932ded97-8c8c-4c7f-a6a0-0496b068f381	SALSAS BARY X3UNID	7702439005849	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.041543	2025-10-19 02:29:41.041543
4a119fc3-2db9-4b55-941f-a5cca29d0faa	REMOVEDOR DE MARIPOSA 50ML	7709338238798	t	2200.00	2070.00	\N	\N	19.00	2025-10-19 02:29:41.041767	2025-10-19 02:29:41.041767
021e96d8-9f71-4f68-b0da-19470a4ae04d	Pool Cola	7709990654967	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.042023	2025-10-19 02:29:41.042023
70ea57c5-e880-4fdb-9fd0-efb65e6952a7	COMPOTA BABYFRUIT MANZANA 113GR	7707262682571	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:41.042356	2025-10-19 02:29:41.042356
c3361558-52c0-442b-8bb4-4e2b9bca5ec9	Pool Manzana	7709342033778	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.042572	2025-10-19 02:29:41.042572
14defadf-e3e7-4f96-9147-d23cd1620ec7	Gomitas Trululu sabores	7702993028483	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.042771	2025-10-19 02:29:41.042771
59565711-9dd2-4469-95ae-7af92d6f8ad4	TRULULU SPLASH	7702993051887	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.042996	2025-10-19 02:29:41.042996
0b916e47-f88c-46e9-ab02-a565d9e9a661	Hidronutritivo	7709990733860	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.043245	2025-10-19 02:29:41.043245
8f26ccf4-0bec-4c62-ac4a-f7991c99f7f9	VASOS 10OZ X50UNID	7709174732870	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:41.043468	2025-10-19 02:29:41.043468
3257e1d5-af48-4297-b97a-38f16e7d296a	PIN POP FRESA X24UNID	7702174082327	t	6600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.043679	2025-10-19 02:29:41.043679
135d5d84-aa6a-40d8-925e-92da83cce280	MUU SANDWICH CHOCOLATE 12X4	7702011271518	t	6600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.043898	2025-10-19 02:29:41.043898
44453c00-853d-42a5-9bed-b11ebf9e2899	MUU AVENA LECHE 12X4	7702011271525	t	6600.00	6500.00	\N	\N	19.00	2025-10-19 02:29:41.044101	2025-10-19 02:29:41.044101
ef862193-2921-494a-912b-64a350a70dd2	Muu Yogurt Fresa	7702011271495	t	6600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.044372	2025-10-19 02:29:41.044372
a2904005-5d2e-480f-b5f0-d2fcd8e49a6c	Muu Yogur Mora	7702011276360	t	6600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.044587	2025-10-19 02:29:41.044587
349603a8-8254-4aaa-9be6-1beefc542b3e	Hit Naranja Pina	7702090013047	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.044786	2025-10-19 02:29:41.044786
ad63d766-70ab-42b6-8e14-ab781f221545	SARDINA CALIDAD TOMATE 425GR	7709747005998	t	5600.00	5300.00	\N	\N	19.00	2025-10-19 02:29:41.045027	2025-10-19 02:29:41.045027
4968f416-6d71-41e0-92d1-c57f368ead0b	3D BICARBONATO 500GR	7702191348512	t	4200.00	4050.00	\N	\N	19.00	2025-10-19 02:29:41.045287	2025-10-19 02:29:41.045287
ac28af7d-d576-4191-9aa6-d2d76a198f84	ENCENDEDOR ELECTRICO SWISS LITE	7707448970720	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.045519	2025-10-19 02:29:41.045519
79a83b2a-4f3e-428f-b407-2aaee72701fe	INDULECHE 800GR	7706921028002	t	26600.00	26000.00	\N	\N	0.00	2025-10-19 02:29:41.045734	2025-10-19 02:29:41.045734
17f732c3-eb0c-4703-bfba-39d742ad00d6	Raquety Tocineta	7702189026132	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.045939	2025-10-19 02:29:41.045939
2b178af4-ecce-4ca8-a93c-017c68f22747	SALSA DE TOMATE IDEAL 200GR	7708969766007	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:41.046215	2025-10-19 02:29:41.046215
dbe32e26-bcd2-40b0-914c-7926383b047d	AK1 3900KG FLORAL	7702310047135	t	29400.00	28800.00	\N	\N	19.00	2025-10-19 02:29:41.046462	2025-10-19 02:29:41.046462
e6deb913-1391-46b6-8779-bd726730bdff	KALUA X6 UNID	7705241090188	t	6900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.046672	2025-10-19 02:29:41.046672
2bd8130e-a21f-4027-8487-76e63573e9e4	GUSTOSITA DELI 110GR	7702028021588	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.046859	2025-10-19 02:29:41.046859
4a3cd7da-674f-42d0-8fd5-7ba023fa0647	LECHE CONDENSADA TUBITO 100GR	7707226110645	t	2800.00	2700.00	\N	\N	0.00	2025-10-19 02:29:41.047092	2025-10-19 02:29:41.047092
cfb23891-12d7-4fd0-8eef-bb249b1bb397	JET BURBUJA AREQUIPE X12UNID	7702007046144	t	12800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.047336	2025-10-19 02:29:41.047336
97665cf2-36ee-4737-8985-5cb9a967ab7e	ATUN LOMITO VAN CAMPS AGUA	7702367002620	t	6900.00	6800.00	\N	\N	19.00	2025-10-19 02:29:41.047578	2025-10-19 02:29:41.047578
8132f4ab-1ad9-4d30-88c0-5615897b4deb	La costancia Salsa de Tomate 130g	7702097058874	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:41.047949	2025-10-19 02:29:41.047949
cbde3ce4-fe26-493d-8f3c-797df36af860	SALSA SABOR A QUESO RIK 200GR	75930288	t	12600.00	12200.00	\N	\N	19.00	2025-10-19 02:29:41.048177	2025-10-19 02:29:41.048177
e0991717-ab7a-440a-afd2-161d8f8e7980	LECHE KLIM 1 500GR	7702024025733	t	31500.00	30750.00	\N	\N	0.00	2025-10-19 02:29:41.048395	2025-10-19 02:29:41.048395
e3aff882-8571-4366-aef9-5616f8c1af5f	BIOEXPERT OMEGA SHAMPO SIN SAL 16ML	7702006203630	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.048596	2025-10-19 02:29:41.048596
09e2b579-9202-4da9-baed-b2131ace128e	DERSA BICARBONATO 1KG	7702166002432	t	8500.00	8360.00	\N	\N	19.00	2025-10-19 02:29:41.04881	2025-10-19 02:29:41.04881
9c304eb3-704e-4c35-ab39-7a6f27da9b8f	DERSA BICARNBONATO 500GR	7702166002449	t	4700.00	4580.00	\N	\N	19.00	2025-10-19 02:29:41.049026	2025-10-19 02:29:41.049026
f20a1958-09a5-4156-a8a1-2e0be7a984da	DOGOURMET CACHORRO LECHE 350GR	7702084850900	t	3200.00	3100.00	\N	\N	5.00	2025-10-19 02:29:41.049243	2025-10-19 02:29:41.049243
17279ed7-bc4a-42be-955f-fbd5bb8cbeea	ACEITE OLIVERDE LITRO	7709216929619	t	6800.00	6417.00	\N	\N	19.00	2025-10-19 02:29:41.049463	2025-10-19 02:29:41.049463
f449775f-ac49-4016-82d2-84e935d90606	Guante domesticas 7/2	7702037567978	t	3900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.049682	2025-10-19 02:29:41.049682
9ebf50d0-0480-4ea5-a0c7-ae60cb75506f	LECHE CONDENSADA COLOMBINA 300GR	7702097066541	t	7600.00	7400.00	\N	\N	10.00	2025-10-19 02:29:41.049916	2025-10-19 02:29:41.049916
5a33f690-1355-429c-9ea6-64180ed9483d	NOSOTRAS INVISIBLE CLASICA 10	7702027041662	t	3900.00	3800.00	\N	\N	0.00	2025-10-19 02:29:41.050167	2025-10-19 02:29:41.050167
b8bd736b-a5c3-4532-8c23-b325670ec614	COLCAFE CLASICO 25GR	7702032110674	t	6100.00	5950.00	\N	\N	5.00	2025-10-19 02:29:41.050515	2025-10-19 02:29:41.050515
af7138fc-2ef0-481f-844b-18c7879098f5	PINGUINOS COOKIES AND CREAM	7705326088574	t	3900.00	3800.00	\N	\N	19.00	2025-10-19 02:29:41.050752	2025-10-19 02:29:41.050752
748c02d9-feed-4fa0-b964-b4c7624b6feb	Guantes Limpia Ya	7702037567985	t	3900.00	3770.00	\N	\N	19.00	2025-10-19 02:29:41.051054	2025-10-19 02:29:41.051054
f48220fb-bd81-4242-a9a4-b2dead5050c0	MECHAS LOCAS CHOCOLATE X6UNID	7702174078948	t	16800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.051266	2025-10-19 02:29:41.051266
fc8bb717-b9ea-47ba-8fd4-b0aeaf3f4473	TORNILLO DORIA 250G	7702085012482	t	2200.00	2050.00	\N	\N	5.00	2025-10-19 02:29:41.051503	2025-10-19 02:29:41.051503
5888efc3-c44f-4efa-9cc7-8d7efd8c4bf4	Nutribela 10	7702354945404	t	1500.00	1350.00	\N	\N	19.00	2025-10-19 02:29:41.051719	2025-10-19 02:29:41.051719
91cc5153-4f94-49b6-9d40-a82aab234933	PAÑO HUMEDO LIMPIA YA 1UNID	7702037873116	t	1800.00	1630.00	\N	\N	19.00	2025-10-19 02:29:41.051968	2025-10-19 02:29:41.051968
dd4c3180-0dca-453d-b96c-11bed3f701e2	AK1 1450GR MANZANA	7702310047166	t	12400.00	11900.00	\N	\N	19.00	2025-10-19 02:29:41.052248	2025-10-19 02:29:41.052248
43a2fdca-bbf5-4035-8f51-e7ade7637754	SHAMPOO SAVITAL MULTIVITAMINAS 550ML	7702006202930	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:41.052489	2025-10-19 02:29:41.052489
e589f423-857d-4e11-95c6-e3ba44f60e05	ACONDICIONADOR SAVITAL 100ML	7702006202824	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:41.052695	2025-10-19 02:29:41.052695
b1e85e24-428a-47e9-a48a-d89bd1474be3	SHAMPOO SAVITAL MULTIOLEOS 100ML	7702006205955	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.052989	2025-10-19 02:29:41.052989
648dda76-1a2e-4108-9344-44acd14b4004	SALSA INGLESA SAN JORGE 90ML	7702014626674	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.053234	2025-10-19 02:29:41.053234
ec9dd9f9-f720-4132-af00-b6a733beb8c9	LADY SPEED STICK CLINICAL 30GR	7702010470486	t	3400.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.053445	2025-10-19 02:29:41.053445
0d6e3e2b-1cc9-40e3-a7f2-5cd94ce1c091	SPEED STICK CLINICAL 30GR	7702010470479	t	3400.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.053671	2025-10-19 02:29:41.053671
acd213a0-65d0-4dd5-bc36-0d8e8739c5d6	COMPOTA HEINZ PERA 113GR	608875003142	t	3500.00	3250.00	\N	\N	19.00	2025-10-19 02:29:41.053879	2025-10-19 02:29:41.053879
cb734d9e-3154-4015-bfaf-7e62be21033f	DON KAT ADULTOS 500GR	7702084057156	t	6000.00	5850.00	\N	\N	5.00	2025-10-19 02:29:41.054148	2025-10-19 02:29:41.054148
7ef86884-3e44-4473-9a9d-cd467a75854f	DON KAT GATICOS 500GR	7702084057125	t	6200.00	6000.00	\N	\N	5.00	2025-10-19 02:29:41.054361	2025-10-19 02:29:41.054361
7315b7ab-f46e-429a-8645-396d372b431b	Doria conchita 250g	7702085012215	t	2200.00	\N	\N	\N	5.00	2025-10-19 02:29:41.054557	2025-10-19 02:29:41.054557
d4e94aab-6959-4d56-8da4-3671e260500d	MACARRON DORIA 250GR	7702085012093	t	2200.00	2100.00	\N	\N	5.00	2025-10-19 02:29:41.054759	2025-10-19 02:29:41.054759
01e7cac4-954e-497b-982f-40bbd2290e40	ARROZ DIANA 1.000GR	7702511000021	t	4100.00	4000.00	\N	\N	0.00	2025-10-19 02:29:41.054968	2025-10-19 02:29:41.054968
40bb5b17-03e9-4479-a178-d886aa6c6173	POOL 1700ML	7709168680903	t	3200.00	2938.00	\N	\N	19.00	2025-10-19 02:29:41.055184	2025-10-19 02:29:41.055184
7a83d2bd-fe5a-40ef-8ba8-e91a5d2c9b74	CHORIZO COLANTA DUO	7702129072175	t	3700.00	3600.00	\N	\N	19.00	2025-10-19 02:29:41.055384	2025-10-19 02:29:41.055384
8dcbd231-47d9-4b5c-8c71-539b4e8c4e7e	CARACOLCOMARRICO 1.000GR	7707307962200	t	5600.00	5417.00	\N	\N	5.00	2025-10-19 02:29:41.055599	2025-10-19 02:29:41.055599
fd4e0a42-6797-4b03-b892-684b4f11afe5	PINGUINO X2	7705326053206	t	3500.00	3450.00	\N	\N	19.00	2025-10-19 02:29:41.055797	2025-10-19 02:29:41.055797
d03eefe6-7f9b-40c4-a584-dc0b3a502c30	FLAN GERHADA FRESA 60GR	7702014525137	t	3400.00	3285.00	\N	\N	19.00	2025-10-19 02:29:41.056006	2025-10-19 02:29:41.056006
491973f5-540a-4fe3-9673-403ebe1930ef	MAXCOCO	7702011046963	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.056242	2025-10-19 02:29:41.056242
0a426653-bb62-4d38-aa7b-203eeaec6cdb	HALLS NEGRO PIPA X100UNID	7702133445118	t	11500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.056448	2025-10-19 02:29:41.056448
b78549b7-c730-4a00-83e0-6f9d46b90c78	KATORI INCEPTICIDA 24PAST	7702332000484	t	15200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.056651	2025-10-19 02:29:41.056651
c3ada8ef-73d2-4752-a763-a60912f151d3	BETUM BUFALO AUTOBRILLO LIQUIDO NEGRO 60ML	7702377001408	t	6200.00	6000.00	\N	\N	19.00	2025-10-19 02:29:41.056871	2025-10-19 02:29:41.056871
811ca37f-0aac-4739-a148-6988214212b4	COMINO DEL FOGON 50S	7702354003869	t	2100.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.057087	2025-10-19 02:29:41.057087
690baf43-76c5-4a46-9158-6f224bc81a01	TRULULU MAS MEMLOS	7702993028957	t	2000.00	1890.00	\N	\N	19.00	2025-10-19 02:29:41.057311	2025-10-19 02:29:41.057311
55fdd710-c68a-40d1-961b-73d8f010ee94	Savital Acondicionador Multivitaminas	7702006202350	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.057521	2025-10-19 02:29:41.057521
9385d279-2ebf-4fdf-a799-964044d049ff	PILAS ALKALINA TRONEX AA	7707249650043	t	4200.00	4000.00	\N	\N	19.00	2025-10-19 02:29:41.057727	2025-10-19 02:29:41.057727
7f6010b5-5719-4f94-a1d9-cc9283e2f81b	BALANCE WOMEN	7702045790290	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.057938	2025-10-19 02:29:41.057938
c8585e88-d33d-4c5a-b4b3-d2764a4293e6	YODOSILATO CREMA 30GR	77012845	t	2000.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.058152	2025-10-19 02:29:41.058152
3dcf1631-2d05-4ede-a96a-9b40c698cacd	INDULECHE 380GR	7706921023809	t	12700.00	12400.00	\N	\N	0.00	2025-10-19 02:29:41.058405	2025-10-19 02:29:41.058405
21f4e9a8-738f-42ea-878f-49cef72baa53	LISTERINE COOL MINT MENTA 500ML	7702035432339	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:41.058597	2025-10-19 02:29:41.058597
6ed123ca-92f8-49ad-ba1f-74adb127a5ae	Salsa De Tomate San Jorge 170g	7702014620245	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.058935	2025-10-19 02:29:41.058935
7157a43a-6267-4343-b9f9-3c6c5e4aba20	AVENA LA MEJOR 200ML	7705241900012	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.059142	2025-10-19 02:29:41.059142
a199ebd3-e4c9-4968-92da-4f3991a363bb	AREPA CANDOR 1.000GR	7707032407922	t	2600.00	2500.00	\N	\N	5.00	2025-10-19 02:29:41.059392	2025-10-19 02:29:41.059392
e7c31dea-810d-468c-a932-6f7b72c92cb9	VANISH BLANCO 130ML	7702626216942	t	2100.00	1980.00	\N	\N	19.00	2025-10-19 02:29:41.059593	2025-10-19 02:29:41.059593
37267aee-5355-4ce8-af5b-d0cb08eb597f	VANISH GEL COLOR 130ML	7702626216935	t	2100.00	1980.00	\N	\N	19.00	2025-10-19 02:29:41.059813	2025-10-19 02:29:41.059813
da13d536-da14-47e1-be60-076cfeee0364	AVENA EXTRA SEÑORA HOJUELAS 500GR	7708345181158	t	2900.00	2800.00	\N	\N	5.00	2025-10-19 02:29:41.060022	2025-10-19 02:29:41.060022
06b41946-a88c-46ea-bafe-984e08ce9052	AJI IDEAL 160G	7709913154307	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.060263	2025-10-19 02:29:41.060263
48fea4a9-63bf-4e2e-aadb-7325ed1c00d2	MAYONESA IDEAL 900GR	7708969766083	t	7900.00	7750.00	7450.00	\N	19.00	2025-10-19 02:29:41.06049	2025-10-19 02:29:41.06049
c24b7025-a2ee-4162-b874-6e1faaf50cc7	ARROZ GRANO BLANCO	7709924893257	t	3100.00	2980.00	\N	\N	0.00	2025-10-19 02:29:41.060688	2025-10-19 02:29:41.060688
7fd514e2-126b-4fae-a1f9-7399bfe157b4	FRIJOL  ZENU ANTIOQUEÑO 310GR	7701101356715	t	6200.00	6000.00	\N	\N	19.00	2025-10-19 02:29:41.06092	2025-10-19 02:29:41.06092
da64cc5d-f8af-4d71-a1c1-f082b2b7cd2e	RINDEX 10 FRESCURA 500GR	7500435150569	t	4600.00	4500.00	\N	\N	19.00	2025-10-19 02:29:41.061169	2025-10-19 02:29:41.061169
508dee63-5e09-4c4c-94d6-96d75688e564	RINDEX 10 LIMON 1KG	7500435143486	t	9100.00	8900.00	\N	\N	19.00	2025-10-19 02:29:41.061387	2025-10-19 02:29:41.061387
37a02fef-3449-498a-b13b-cc237b1b5926	SALSA DE TOMATE IDEAL 1.000GR	7708969766021	t	8600.00	8400.00	8150.00	\N	19.00	2025-10-19 02:29:41.061589	2025-10-19 02:29:41.061589
6ea642f6-5263-424a-9254-02fdca5f114d	AREQUIPE LA MEJOR 300GR X6UNID	7705241700100	t	9300.00	8200.00	8100.00	\N	19.00	2025-10-19 02:29:41.061816	2025-10-19 02:29:41.061816
8c4ec6e9-f08c-46a7-8214-ab39c4a4c389	ARROZ DIANA 3000GR	7702511000038	t	12000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.062019	2025-10-19 02:29:41.062019
86b9f43c-ed59-48a7-acbe-aee5ba7c4c75	TINTE KERATON 8.0	7707230996167	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.062275	2025-10-19 02:29:41.062275
7ac226e5-5f15-48f3-ab75-3fa0a09c6422	TINTE KERATON 4.5	7707230996006	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.062465	2025-10-19 02:29:41.062465
3fe2d120-32c1-4b8a-9bd6-6dbe3acfcecc	TINTE KERATON 1.1	7707230995979	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.062676	2025-10-19 02:29:41.062676
9336a184-696e-4a99-8bea-38994b04594b	VEL ROSITA DETERGENTE 300ML	7702006925426	t	5600.00	5450.00	\N	\N	19.00	2025-10-19 02:29:41.062868	2025-10-19 02:29:41.062868
fb8a9061-ee62-4cf0-b36e-79fb04ac5751	TINTE KERATON VIOLETA CARNESI	7707230996280	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.063087	2025-10-19 02:29:41.063087
de57a37b-3080-437f-b482-e5a96ace92fe	ALMENDRAS ITALO 50GR	7702117008216	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:41.063296	2025-10-19 02:29:41.063296
4d32b6c6-a994-4f4b-8fb7-0fb5c9c74f40	ALMENDRA ITALO CHOCOLATE 50GR	7702117111121	t	4100.00	4000.00	\N	\N	19.00	2025-10-19 02:29:41.063512	2025-10-19 02:29:41.063512
58a46b9b-b0b6-481d-9b12-1ca0f0ddb2ef	TINTE KERATON 5.43	7707230996020	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.063758	2025-10-19 02:29:41.063758
a63334d7-a4d7-471f-a04a-5b86610841d1	TINTE KERATON 4.0	7707230995993	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.063965	2025-10-19 02:29:41.063965
cb0f917b-cecf-47fb-a63b-e19368b6cb50	TINTE KERATON 7.0	7707230996075	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.06423	2025-10-19 02:29:41.06423
0de65dde-46b8-41af-98c4-04dc8e062729	HEAD SHOULDERS LIMPIEZA RENOVADORA 180ML	7500435019958	t	12000.00	11700.00	\N	\N	19.00	2025-10-19 02:29:41.064431	2025-10-19 02:29:41.064431
f4b96aed-3308-4303-9395-329e70034d72	HEAD Y SHOULDERS 2 EN 1 180ML	7500435019811	t	12000.00	11700.00	\N	\N	19.00	2025-10-19 02:29:41.064632	2025-10-19 02:29:41.064632
6514e5a6-9f48-4245-ba45-6ad591a2ffc5	HEAD SHOULDER LIMPIEZA 375ML	7500435020008	t	18000.00	17500.00	\N	\N	19.00	2025-10-19 02:29:41.064844	2025-10-19 02:29:41.064844
0f993ee1-812a-418c-8053-d514653b883a	SALSA BBQ IDEAL 200GR	7709392006050	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:41.065063	2025-10-19 02:29:41.065063
5520edef-6c1b-489d-bbbb-ead42becc5ec	SALMON CALIDA TOMATE 101GR	7709747005974	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:41.065278	2025-10-19 02:29:41.065278
710afe22-5ae5-4efa-8993-c02cb7f1258e	AK1 3900KG MANZANA	7702310047173	t	29400.00	28800.00	\N	\N	19.00	2025-10-19 02:29:41.065489	2025-10-19 02:29:41.065489
c82d675c-21d4-4e75-a87e-7b25280734c4	GEL ROLDAN BLACK EDICION ESPECIAL	7707342223588	t	4300.00	4200.00	\N	\N	19.00	2025-10-19 02:29:41.065687	2025-10-19 02:29:41.065687
55d8f13b-b613-45d8-8144-0ca33ccde86f	AVENA INST CANELA EXTRA S 180GR	7708345181226	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:41.065944	2025-10-19 02:29:41.065944
d84f3ddf-fe9d-4a7e-ae86-d883e0325542	ELLAS NOCTURNA 8 Y 8 DELGADA	7702108207369	t	4600.00	4450.00	\N	\N	0.00	2025-10-19 02:29:41.066288	2025-10-19 02:29:41.066288
8afada6e-7c0a-4faa-bb66-2306330e1b69	HEAD Y SHOULDER 375 MAS 180	7500435126816	t	28800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.066625	2025-10-19 02:29:41.066625
20e1cd3f-02e9-414a-8a8b-e3340384fa60	PAPEL ALUMINI 7METROS SKAAP	7707371217305	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.066904	2025-10-19 02:29:41.066904
330701e6-194c-4dc6-be83-b761c4c3cf92	FLUO CARDENT TRIPLE ACCION 40ML	7702560041754	t	1900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.067208	2025-10-19 02:29:41.067208
0c4edd06-ccc9-436d-a81f-e09660bc0da7	CEREBRIT 330GR	7702354945367	t	17500.00	17200.00	\N	\N	19.00	2025-10-19 02:29:41.067638	2025-10-19 02:29:41.067638
c8132009-d403-4e58-97a6-36acb1e8ac18	CEREBRIT 135GR	7702354945343	t	8900.00	8650.00	\N	\N	19.00	2025-10-19 02:29:41.068094	2025-10-19 02:29:41.068094
45109d3a-eaae-4ca0-a2f3-9070008aa742	CEREBRIT 15GR	7702354945305	t	800.00	750.00	\N	\N	19.00	2025-10-19 02:29:41.068607	2025-10-19 02:29:41.068607
83bc10b4-fd47-4d30-99f5-41d17a34fac7	SHAMPOO NUTRIT NEGRO 750ML	7702277131113	t	17500.00	17000.00	\N	\N	19.00	2025-10-19 02:29:41.069222	2025-10-19 02:29:41.069222
c8bc784d-99a7-42e4-8846-934b23e9eaf5	SHAMPOO NUTRIT REPARAMAX 750ML	7702277144304	t	17500.00	17000.00	\N	\N	19.00	2025-10-19 02:29:41.069663	2025-10-19 02:29:41.069663
930cf5be-8cb7-4caa-bba6-c96cbf1582b4	Nutrit Shampoo Keratinmax	7702277869658	t	17500.00	17000.00	\N	\N	19.00	2025-10-19 02:29:41.070085	2025-10-19 02:29:41.070085
17bc6fc8-54de-41cb-8656-1a2ffdb2dd45	NUTRI RINDE EL RODEO 108 GR	7702024392583	t	4000.00	4800.00	\N	\N	0.00	2025-10-19 02:29:41.070507	2025-10-19 02:29:41.070507
aa278709-e935-47fa-b881-8817fff4cb74	SPORADE 500ML	7707244561375	t	2200.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.070954	2025-10-19 02:29:41.070954
9208509a-a3d5-4a69-b9b4-62e5bbb58078	SPEED MAX 1LITRO	7702090050974	t	3500.00	3250.00	\N	\N	19.00	2025-10-19 02:29:41.07124	2025-10-19 02:29:41.07124
46c164ec-4b7f-4d3b-be75-6288b20daba8	Dogourmet Adulto Parrillada	7702084850887	t	3200.00	3100.00	\N	\N	5.00	2025-10-19 02:29:41.071452	2025-10-19 02:29:41.071452
c03d8de6-8a5a-46c9-8931-0ed6ca476ba8	MANZANA POSTOBON 2.5L	7702090064186	t	4800.00	4438.00	\N	\N	19.00	2025-10-19 02:29:41.071798	2025-10-19 02:29:41.071798
99452bb1-0693-44e9-9940-473e4461a9c7	NIEVE LEUDANTE 1.000GR	7707237413971	t	2700.00	2600.00	\N	\N	5.00	2025-10-19 02:29:41.072617	2025-10-19 02:29:41.072617
9dc6e9f3-e1dc-46a0-b7c5-9dfdb82d3cd3	ATUN LUHOMAR RALLADO 175GR	7862119502942	t	2300.00	2150.00	\N	\N	19.00	2025-10-19 02:29:41.073795	2025-10-19 02:29:41.073795
a6214813-7da0-4e06-a30c-c46762e59b7b	GOL MEGA	7702007057188	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.07447	2025-10-19 02:29:41.07447
403987e9-d22f-4c4b-b083-1697212e8e55	GEL EGO ATRACTION 110ML	7702006298940	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.074763	2025-10-19 02:29:41.074763
d31795e8-c3b9-4628-90ff-9c5484fa23ce	Nutribela 10 Termoproteccion	7702354946081	t	10400.00	10000.00	\N	\N	19.00	2025-10-19 02:29:41.075243	2025-10-19 02:29:41.075243
6580847d-89bd-4761-958f-0abc50605cce	AROMATEL MANDARINA 400ML	7702191162095	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:41.075564	2025-10-19 02:29:41.075564
abea2e1c-851f-4bcd-88c3-1494acf30117	AVENA INSTANTANEA EXTRA SEÑORA FRESA 400GR	7708345181448	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:41.075935	2025-10-19 02:29:41.075935
04b2c7ce-72d3-45da-840c-82ba4c21abd8	AVENA  INSTANTANEA EXTRA SEÑORA AREQUIPE  X400GR	7708345181097	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:41.07638	2025-10-19 02:29:41.07638
f26fcdf9-9cd0-4787-bbba-c26838e490cb	Rindex 10  125g	7500435186476	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.076678	2025-10-19 02:29:41.076678
6e8321a8-985c-4596-ba5f-cbf43eb95e46	NESTUM TRIGO MIEL 350GR	7613034027610	t	20300.00	19700.00	\N	\N	19.00	2025-10-19 02:29:41.077068	2025-10-19 02:29:41.077068
4e35be97-75bf-4d5b-ad41-ff8126946e77	CHAMPIÑONES ZENU 130GR	7701101356548	t	4500.00	4400.00	\N	\N	19.00	2025-10-19 02:29:41.077422	2025-10-19 02:29:41.077422
ab0d1f67-c318-4201-b815-b3ad5b9eac22	CAFE AROMA X10UNID 500G	7702088354459	t	22400.00	\N	\N	\N	5.00	2025-10-19 02:29:41.077695	2025-10-19 02:29:41.077695
b9d7af43-ca78-4a12-8a40-5392ba85619e	GEL EGO ATTRACTION SOBRE 25ML	7702006204057	t	1200.00	967.00	\N	\N	19.00	2025-10-19 02:29:41.077955	2025-10-19 02:29:41.077955
62bea50e-ce41-43f9-88ce-f6f632930ad6	NESTUM CERELAC 360GR	7613033975844	t	19900.00	19200.00	\N	\N	19.00	2025-10-19 02:29:41.078296	2025-10-19 02:29:41.078296
ca3b8292-5fbb-45ca-80bf-28b82e8c687c	DETERK 450GR	7702310045421	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:41.078519	2025-10-19 02:29:41.078519
f30b2418-807a-4ea5-a428-1dab47957430	LASAGNA DORIA 400GR	7702085003428	t	10700.00	10300.00	\N	\N	19.00	2025-10-19 02:29:41.078777	2025-10-19 02:29:41.078777
cfa8b142-225d-448b-b78c-8182665f1ccc	BIANCHI LINEA X24UNID	7702993033470	t	9200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.079039	2025-10-19 02:29:41.079039
0138cf01-635a-48c8-b93f-e3f41d646835	Ak.1 Con el Poder De La Barra 450g	7702310047197	t	4800.00	\N	\N	\N	0.00	2025-10-19 02:29:41.079299	2025-10-19 02:29:41.079299
2db9a545-2711-402b-98f2-d04ebec61ae1	NUTRIBELA CELULAS MADRES 24ML	7702354957247	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.079735	2025-10-19 02:29:41.079735
536cafcc-2c52-4286-8487-64482a1065ab	AVENA INSTANTANEA EXTRA SEÑORA VAINILLA 400GR	7708345181332	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:41.080136	2025-10-19 02:29:41.080136
a56b11d1-828d-414f-b41e-d2a03194cd24	MOSTAZA LA OCAÑERITA 200G	7709025282462	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.080551	2025-10-19 02:29:41.080551
0e187f2a-8efe-4314-956d-3302a2fb231a	NATUMALTA 200ML	7707430873855	t	1400.00	1250.00	\N	\N	19.00	2025-10-19 02:29:41.08083	2025-10-19 02:29:41.08083
b2247422-25a7-45e6-9eae-85c8781ac1f9	NOSOTRAS EXTRA PROTECCION DIA Y NOCHE X24UNID	7702027429293	t	12700.00	12300.00	\N	\N	0.00	2025-10-19 02:29:41.081198	2025-10-19 02:29:41.081198
e4df1d80-7c54-42a3-9be7-09f1f7cf8da3	AROMAX DUO X10UNID	7702354946432	t	5700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.081465	2025-10-19 02:29:41.081465
efe7e77e-3e22-44e7-a96c-8f0fc56039c0	AROMAX UND	7702354946425	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.081725	2025-10-19 02:29:41.081725
7085dcd5-0300-4c7a-8101-61fd7d0aa5bb	AZUL KLEAN LAVANDA 950ML	7702310042437	t	6000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.082135	2025-10-19 02:29:41.082135
812662b3-e201-4720-aba1-879345db2517	AREPA DE TRIGO 7UND	7709052847696	t	5400.00	5300.00	\N	\N	0.00	2025-10-19 02:29:41.082382	2025-10-19 02:29:41.082382
159fc819-ad7a-4324-850c-6fc462dbcfed	DERSA BARRA 230GR	7702166009110	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:41.082616	2025-10-19 02:29:41.082616
35a440cd-f03b-4d7d-bcd3-25c6c074c207	Sal Cristal	7707226410271	t	800.00	660.00	\N	\N	0.00	2025-10-19 02:29:41.083005	2025-10-19 02:29:41.083005
f0f7ea82-7281-4c33-bb79-c704fb1ab0df	NUTRIBELA 180ML CAUTERIZACION	7702354946500	t	10400.00	10000.00	\N	\N	19.00	2025-10-19 02:29:41.083518	2025-10-19 02:29:41.083518
5a7fd1fb-9bdd-43dc-9b19-b4dac6d8697a	NATUMALTA LITRO	7707430875552	t	3600.00	3338.00	\N	\N	19.00	2025-10-19 02:29:41.083874	2025-10-19 02:29:41.083874
f4b23479-5b9d-44d9-bb78-d385b9308336	TRULULU CULEBRITAS	7702993028261	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.084257	2025-10-19 02:29:41.084257
ef09187f-d3e7-4ca9-9811-cff82868b42f	LISSO INTELIGENTE 15ML	7707279840278	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.085073	2025-10-19 02:29:41.085073
fe4dc3c1-e9a1-412e-a71d-fa4b0b5e0b99	ACEITE IDEAL 2L	7709663317212	t	14800.00	14400.00	\N	\N	19.00	2025-10-19 02:29:41.08563	2025-10-19 02:29:41.08563
88c7f77c-965a-4718-adb3-d3012f280006	AVENA QUAKER HOJUELAS 115GR	7702193101269	t	1200.00	1100.00	\N	\N	5.00	2025-10-19 02:29:41.086124	2025-10-19 02:29:41.086124
fe1d164e-c844-4f95-8e72-3b878393c35f	COCOA SUPERIOS CORONA 230GR	7702007031553	t	15800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.086445	2025-10-19 02:29:41.086445
93bf4476-7d7e-44e1-9dc3-f1f91f7f1012	BOMBILLO PHILIPS 12W	8718699765538	t	6600.00	6600.00	\N	\N	19.00	2025-10-19 02:29:41.086694	2025-10-19 02:29:41.086694
ca1091bc-ff8a-4659-85eb-1a36b881ab84	ATUN CATALINA ACEITE	7866640700358	t	4800.00	4700.00	\N	\N	19.00	2025-10-19 02:29:41.086952	2025-10-19 02:29:41.086952
b2fd14af-0113-47eb-8b36-b58d72661594	FLUOCARDENT 75ML	7702560041761	t	3300.00	3150.00	\N	\N	19.00	2025-10-19 02:29:41.087218	2025-10-19 02:29:41.087218
bf590ff7-c5dc-4ce2-ae38-ccbe5421a20e	SPARTA 269ML	7702354946463	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:41.087548	2025-10-19 02:29:41.087548
ea8a6557-9790-4bde-ae9f-9cc4e16c5236	CREMA ORAL B 4 EN 1 60GR	7506195167113	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.087829	2025-10-19 02:29:41.087829
e6a1d959-64b2-41da-a0d2-dcc357d35b6b	SUPREMO LAVALOZA TAZA 150GR	7708872634226	t	1700.00	1640.00	\N	\N	0.00	2025-10-19 02:29:41.088208	2025-10-19 02:29:41.088208
49c2e754-1961-46b2-9f4a-1955ea84a050	Nosotras Oferta Extraproteccion	7702026174736	t	12700.00	12300.00	\N	\N	0.00	2025-10-19 02:29:41.088559	2025-10-19 02:29:41.088559
878c70ff-2ea6-49f3-9fd6-fae0aa9b9c7d	SANPIC VAINILLA 200ML	7702626219240	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:41.088819	2025-10-19 02:29:41.088819
ab45ff91-970b-4274-93f3-f64ef7b77da8	COLGATE MAXIMA PROTECCION 60ML	7509546652139	t	3300.00	3167.00	\N	\N	19.00	2025-10-19 02:29:41.089109	2025-10-19 02:29:41.089109
177e0a53-0c34-4cf3-acd4-ab586733feef	DOG CHOW ADULTOS MINIS 350GR	7702521034986	t	4000.00	3850.00	\N	\N	5.00	2025-10-19 02:29:41.089352	2025-10-19 02:29:41.089352
e75fe6e6-5ad7-4ef0-9d81-3586286b1551	YOGOLIN MIX AZUCARADAS X3UNID	7705241400635	t	6200.00	5500.00	5400.00	\N	19.00	2025-10-19 02:29:41.089625	2025-10-19 02:29:41.089625
5bfc9074-c3a5-43b6-a871-a6c1a0856221	AROMAX CJ 24S	7702354947514	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.089964	2025-10-19 02:29:41.089964
970ef17a-d710-451f-806a-ec58daf7a424	SAL CRISTAL 1.000GR	7707226418819	t	1400.00	1300.00	\N	\N	0.00	2025-10-19 02:29:41.090372	2025-10-19 02:29:41.090372
1f9a50cd-2857-4dec-8c63-7deea541a2a6	LECHE CONDENSADA NATULAC 397GR	7592396000922	t	9400.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.090963	2025-10-19 02:29:41.090963
9b4fb799-3349-4a89-8058-d27e4481ea07	DOGOURMET ADULTOS 350GR	7702084850863	t	3200.00	3100.00	\N	\N	5.00	2025-10-19 02:29:41.091238	2025-10-19 02:29:41.091238
ecdd543b-727b-4ef5-97af-6b6af4dc01ec	AK LAVALOZA LIQUIDO 360ML	7702310049115	t	3700.00	3550.00	\N	\N	19.00	2025-10-19 02:29:41.091491	2025-10-19 02:29:41.091491
b216a00f-3645-4d32-980f-a97d5be7fba4	PRESTOBARBA  DORCO X5UNID	8801038562421	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:41.091746	2025-10-19 02:29:41.091746
f16e93e6-b1ac-4329-9783-447ee4f86187	Savital acondicionador	7702006204002	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.09209	2025-10-19 02:29:41.09209
ad59b69a-9ec9-44e4-9846-03f250e124d9	JHONSONS SHAMPO CABELLO OSCURO 25ML	7702031350712	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.092368	2025-10-19 02:29:41.092368
1c3690c9-e5ce-4bee-9d51-ccabefd46baa	polvo decolarante	7707180630661	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.092608	2025-10-19 02:29:41.092608
634749a8-d901-4f94-a0bf-380ce2849c30	SARDINA CATALINA 425GR	7862111871060	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:41.092809	2025-10-19 02:29:41.092809
0559333b-0f3c-40cc-b983-ff2ea9a39910	ACEITE IDEAL 250ML	7709663317267	t	2200.00	2042.00	\N	\N	19.00	2025-10-19 02:29:41.093007	2025-10-19 02:29:41.093007
2786633a-bf50-453d-884d-59a5cd22a5d2	COLCAFE CLASICO SUAVE TARRO 100GR	7702032114344	t	13600.00	13200.00	\N	\N	5.00	2025-10-19 02:29:41.093239	2025-10-19 02:29:41.093239
8d7bba84-bb4b-4f4d-8703-babfa7072a40	PAÑITOS WINNY X100UNID	7701021145949	t	11800.00	11500.00	\N	\N	19.00	2025-10-19 02:29:41.09343	2025-10-19 02:29:41.09343
83189966-91b6-45c1-bac2-f8a72ef856a1	NATUMALTA X6UNID	7702090051551	t	8300.00	8250.00	\N	\N	19.00	2025-10-19 02:29:41.093633	2025-10-19 02:29:41.093633
d3b89a61-66ac-48d6-963f-7b5b1395d2da	OREO MINI 40GR	7622210633842	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:41.093928	2025-10-19 02:29:41.093928
07418754-abb5-41d2-ba81-c6cf4599643f	SHAMPOO SAVITAL 550ML	7702006205245	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:41.094153	2025-10-19 02:29:41.094153
79de0ccc-cb2c-4f54-91ac-7784425ffee5	SALSA BOLOGNESA LA CONSTANCIA 106GR	7702097086631	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.094374	2025-10-19 02:29:41.094374
2101171f-63b6-442f-bbc4-29a591fc0626	VANISH ROSADO 450ML	7702626216171	t	4800.00	4650.00	\N	\N	19.00	2025-10-19 02:29:41.094598	2025-10-19 02:29:41.094598
08063105-8f7b-4393-b041-d360d8aeec07	LIMPIAPISOS BRILLA KING BICARBONTO 1L	7700304882441	t	3200.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.094801	2025-10-19 02:29:41.094801
9803cf5c-1cdc-470f-9a07-3050e741a31d	ROPA COLOR SUPER B LITRO	7707291393387	t	3300.00	3140.00	\N	\N	19.00	2025-10-19 02:29:41.095004	2025-10-19 02:29:41.095004
fa9dd491-1159-440f-921c-3a538cab2f99	AK1 3KG MANZANA	7702310047234	t	24000.00	23600.00	\N	\N	19.00	2025-10-19 02:29:41.095285	2025-10-19 02:29:41.095285
12080f3a-13b7-490c-9961-7a30101d6fc1	AROMATEL COCO 400ML	7702191349861	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:41.095582	2025-10-19 02:29:41.095582
624b7547-6c3f-4c96-89b9-eacc9487c51b	AROMATEL COCO 180ML	7702191451854	t	1600.00	1450.00	\N	\N	19.00	2025-10-19 02:29:41.095866	2025-10-19 02:29:41.095866
716bc11a-a491-444a-96f9-d89c3bb03775	FESTIVAL CHIPS X6	7702025144198	t	7500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.096078	2025-10-19 02:29:41.096078
ed60ad9c-64de-47ed-b15a-4799f8f314a9	PURINA PARA GATO MAGIC FRIENDS KILO	7700304895786	t	7500.00	7200.00	\N	\N	19.00	2025-10-19 02:29:41.096319	2025-10-19 02:29:41.096319
3643793a-5efb-459a-af3b-2dc454f568b9	SUPERB LAVAPLATO LIMON 500GR	7707291393431	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.09654	2025-10-19 02:29:41.09654
787587d9-e798-4fda-8628-dd6e7c27daf2	PAÑITOS HUGGIES MANITAS Y CARITAS X48UNID	7702425809772	t	4800.00	4600.00	\N	\N	19.00	2025-10-19 02:29:41.096799	2025-10-19 02:29:41.096799
e8ead95e-5da1-466c-81e6-766c41f6aced	RINDEX 10 125GR	7500435186483	t	1400.00	1320.00	\N	\N	19.00	2025-10-19 02:29:41.09701	2025-10-19 02:29:41.09701
e129b6a7-c30a-4ae8-a97f-487c624daade	RICAVENA INSTANTANEA QUAKER 600	7702193149339	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.097216	2025-10-19 02:29:41.097216
bbabc37c-476b-441b-a793-54295a0e9bb9	ELITE MAX X4UNIDADES	7707199348687	t	5400.00	5200.00	\N	\N	19.00	2025-10-19 02:29:41.097449	2025-10-19 02:29:41.097449
1d318859-28b9-45e8-8f90-3797e758351f	AROMATEL FLORAL 800ML	7702191164068	t	7500.00	7350.00	\N	\N	19.00	2025-10-19 02:29:41.097678	2025-10-19 02:29:41.097678
b9390f5e-7da5-4e59-aeaf-853695877438	NATUMALTA 1.5	7702090051810	t	4900.00	4500.00	\N	\N	19.00	2025-10-19 02:29:41.098	2025-10-19 02:29:41.098
28a28091-7227-4f69-bfed-e573940f0c34	JABON REY EN BARRA 300GR	7702166006003	t	2900.00	2780.00	\N	\N	19.00	2025-10-19 02:29:41.098296	2025-10-19 02:29:41.098296
fdf243d6-c810-4a42-8da2-d3836354cd67	YOGURT LA MEJOR 1 LITRO	7705241400604	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.098546	2025-10-19 02:29:41.098546
f4a2c1c8-279f-4d3f-870b-aa5ecd453af0	GUSTOSITA ESPARCIBLE 125GR	7702028021625	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.098874	2025-10-19 02:29:41.098874
0d4d8c59-14aa-4a88-8198-9074e97135f5	GALLETAS SALTISIMA X4 TACOS	7700304810727	t	4700.00	4500.00	\N	\N	19.00	2025-10-19 02:29:41.099209	2025-10-19 02:29:41.099209
79b68593-16e1-4439-8140-efb13a52f504	LIMPIADOR BICARBONATO SUPERB 960ML	7707426910137	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:41.099586	2025-10-19 02:29:41.099586
14a690c3-7fb7-4b55-90ee-912d8038ef11	DUCALES 241GR	7702025120192	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:41.100062	2025-10-19 02:29:41.100062
5d86a16b-396e-4c65-ba1f-01bf2dd04878	RINDEX 10 FRESCURA 1KG	7500435150576	t	9100.00	8900.00	\N	\N	19.00	2025-10-19 02:29:41.100293	2025-10-19 02:29:41.100293
eecbffd0-e56f-4360-bbbf-2a1f5eba2fd2	BOMBILLO EVEREADY 8W	8888021306873	t	4300.00	4000.00	\N	\N	19.00	2025-10-19 02:29:41.100763	2025-10-19 02:29:41.100763
2dbd47ea-7a78-4226-ab01-9f67046f3a6b	CORTACUTICULA TRIM	6953451586767	t	7900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.101142	2025-10-19 02:29:41.101142
e48a7183-10be-49f5-8b2f-d716507a5317	ORAL B 3DWHITE 53ML	7506295388487	t	7600.00	7400.00	\N	\N	19.00	2025-10-19 02:29:41.101579	2025-10-19 02:29:41.101579
87561340-ed8a-47b3-b332-d15cc14d1f5f	ACAROL CUTANEO CONTROL DE PARASITOS 60ML	7707296880035	t	16500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.101862	2025-10-19 02:29:41.101862
e86ddb27-cc91-4463-be0b-70053cc8808a	MISTERMINT 60ML	7708350073332	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:41.10222	2025-10-19 02:29:41.10222
d81f1ea5-8cbd-4968-8383-39e8fd84d486	ENJUAGUE BUCAL SONRIEDEN 6-12	7702314122319	t	5000.00	4800.00	\N	\N	19.00	2025-10-19 02:29:41.10262	2025-10-19 02:29:41.10262
781b0fef-0409-4c53-9d75-124f722b8419	SHAMPOO ANTICASPA EGO BLANCK 400ML	7702006300292	t	17200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.102871	2025-10-19 02:29:41.102871
8bc83585-bfad-463b-bad9-8027afcd1748	DESODORANTE AMATIC 70ML	7707291397903	t	3900.00	3690.00	\N	\N	19.00	2025-10-19 02:29:41.103438	2025-10-19 02:29:41.103438
c3245f2c-809c-49eb-8329-fb41d0fa5ae1	DESODORANTE AMATIC DAMA 70ML	7707291393745	t	3900.00	3690.00	\N	\N	19.00	2025-10-19 02:29:41.103902	2025-10-19 02:29:41.103902
2a846810-8e3c-47ed-920d-3c64a7ae2472	FOSFOROS EXTRA LARGO EL SOL 9.5	7707015502514	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:41.104528	2025-10-19 02:29:41.104528
b7d2c83a-4b31-406a-a1c1-ec0dab73af36	LAPIZ MARIPOSA	LAIPZ MARIPOSA	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.104763	2025-10-19 02:29:41.104763
a569a86c-9158-45e5-b15f-3016267bfa73	Palmolive	7702010410864	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:41.105132	2025-10-19 02:29:41.105132
b5eb2214-3d09-48c2-b1ac-accbb5fb7c9f	PALMOLIVE SENSACION 110GR	7702010410840	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:41.105365	2025-10-19 02:29:41.105365
233cff98-684f-4397-853e-8ddc4fb664ba	CREMA DE LECHE PARMALAT 125ML	7700604054630	t	2700.00	2600.00	\N	\N	0.00	2025-10-19 02:29:41.105813	2025-10-19 02:29:41.105813
29caae85-5507-42f6-97d5-32c460951075	CREMA DE LECHE PARMALAT 200ML	7700604054616	t	4400.00	4250.00	\N	\N	0.00	2025-10-19 02:29:41.106093	2025-10-19 02:29:41.106093
9e6cc348-66b6-429d-bc2f-399cffc97d93	VANART COCO KERATINA 50ML	650240039225	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.10643	2025-10-19 02:29:41.10643
ae3ee494-9ff0-46c0-89ab-60cf577e3626	Nosotras invisible multiestilo 30und	7702026184155	t	12900.00	\N	\N	\N	0.00	2025-10-19 02:29:41.10679	2025-10-19 02:29:41.10679
9a0f59a9-3892-4c1a-899a-392e5773997b	Hit Mngo 1000ml	7702090038071	t	4200.00	3817.00	\N	\N	19.00	2025-10-19 02:29:41.107129	2025-10-19 02:29:41.107129
30703a85-addd-4cf3-b617-188e7b7a51dd	GEL DE BAÑO BOTANICALS MANZANA VERDE 750ML	7700304409174	t	9300.00	9000.00	\N	\N	19.00	2025-10-19 02:29:41.107665	2025-10-19 02:29:41.107665
0754edb9-66c3-4921-b32c-dfb31d4cf66c	SHAMPOO VANART BONDADES DEL CHILE 600ML	650240060991	t	6200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.10816	2025-10-19 02:29:41.10816
91814201-17d8-45c4-95ac-be58b5c125c1	COLCAFE CLASICO SUAVE 42GR	7702032114016	t	11100.00	10900.00	\N	\N	5.00	2025-10-19 02:29:41.108507	2025-10-19 02:29:41.108507
0314196a-cb3a-4783-a6af-82cb8321bc88	AGUA LA MEJOR 6LITROS	7705241700322	t	2600.00	\N	2000.00	\N	0.00	2025-10-19 02:29:41.108777	2025-10-19 02:29:41.108777
afcc0af9-9854-4961-9045-986e7363e632	GUSTOSITA ESPARCIBLE 450GR	7702028021472	t	6300.00	6100.00	\N	\N	19.00	2025-10-19 02:29:41.109135	2025-10-19 02:29:41.109135
58a46221-dc0f-487c-a5ac-fd19ee1b0d34	3D BICARBONATO 1KG	7702191348499	t	7700.00	7600.00	\N	\N	19.00	2025-10-19 02:29:41.109521	2025-10-19 02:29:41.109521
3c868048-705a-4ec1-b559-f1814884dc00	VELON SAN JORGE N8	7707159821083	t	5200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.109919	2025-10-19 02:29:41.109919
8d6d895b-5c49-49b9-8501-7bfa629c729c	JABON SUPERB LIQUIDO ROJO	7707291390492	t	4000.00	3890.00	\N	\N	19.00	2025-10-19 02:29:41.110362	2025-10-19 02:29:41.110362
2d1aba2a-7c20-44c2-9550-51b3f13240f2	SUAVIZANTE FLORAL BONAROPA 3 LITROS	7700304410446	t	10800.00	10380.00	\N	\N	19.00	2025-10-19 02:29:41.110849	2025-10-19 02:29:41.110849
9b8f6964-5bff-4ecd-8637-a8478106d93e	RAID ZANCUDO Y MOSCA 285CC	7501032926175	t	11000.00	10600.00	\N	\N	0.00	2025-10-19 02:29:41.111237	2025-10-19 02:29:41.111237
73424615-9726-4c1b-a75a-32e049b0575b	Ego Gel Extreme 110ml	7702006300148	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.111746	2025-10-19 02:29:41.111746
efba1b4e-06ee-446e-8e7d-02284ecea7bb	FESTIVAL UND LIMON	7702025136797	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.112178	2025-10-19 02:29:41.112178
1bddea8f-b7db-4d29-aa0b-5c1da275fe6f	AZUCAR MORENA PALACIO 1.000GR	7709241447706	t	4200.00	4100.00	\N	\N	5.00	2025-10-19 02:29:41.112466	2025-10-19 02:29:41.112466
421b3a2e-d4e9-41e9-ad93-b9c0bd3dc4c2	ACEITE IDEAL 4800ML	7709958636486	t	33500.00	32800.00	\N	\N	19.00	2025-10-19 02:29:41.112837	2025-10-19 02:29:41.112837
c103dbd0-44c9-463c-b7a6-8b840844d55c	INDULECHE 200GR	7706921022000	t	7800.00	7650.00	\N	\N	0.00	2025-10-19 02:29:41.113138	2025-10-19 02:29:41.113138
145111c2-ee6f-4597-aa65-e38804ffc4cf	JOHNSONS CABELLO CLARO 100ML	7702031293217	t	6500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.113522	2025-10-19 02:29:41.113522
72fcd219-34a4-446a-bea4-c073d518b995	COCA COLA 1.5	7702535024423	t	5600.00	5209.00	\N	\N	19.00	2025-10-19 02:29:41.113882	2025-10-19 02:29:41.113882
cbacf30a-ab6d-4294-9641-0e28767f601c	Doña Gañina x 12Cubitos	7702354002930	t	400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.114362	2025-10-19 02:29:41.114362
42b6a93a-9b42-41d2-ab74-7329407826f5	RICOSTILLA X12UNID	7702354949525	t	4900.00	4800.00	\N	\N	19.00	2025-10-19 02:29:41.115001	2025-10-19 02:29:41.115001
4cf26de2-c53a-4ec8-94da-7f5ba72a3eb8	UNICO LIMON PLUS	7701018075518	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.115288	2025-10-19 02:29:41.115288
bb300ac7-15d5-42cd-97c4-50bc84594de7	INDULECHE 360GR	7706921000114	t	12400.00	12150.00	\N	\N	0.00	2025-10-19 02:29:41.115533	2025-10-19 02:29:41.115533
18206109-43c1-4cc4-9162-de6706c5c50f	JABON INTIMO NOSOTRAS 200ML	7702026179656	t	12500.00	12000.00	\N	\N	19.00	2025-10-19 02:29:41.115762	2025-10-19 02:29:41.115762
14a02706-4094-4247-95b9-1fd5c608fc0e	FAMILIA EXPERT 4 HOJAS	7702026148515	t	2400.00	2271.00	\N	\N	19.00	2025-10-19 02:29:41.116125	2025-10-19 02:29:41.116125
5b2db86a-968b-43dc-b6c8-251b6f215e70	VELON SAN JORGE N7	7707159822004	t	4000.00	3900.00	\N	\N	19.00	2025-10-19 02:29:41.116496	2025-10-19 02:29:41.116496
f18be53e-57ab-4bf3-b719-15829af65b57	MACARRON DORIA 500GR	7702085013090	t	4000.00	3870.00	\N	\N	5.00	2025-10-19 02:29:41.11683	2025-10-19 02:29:41.11683
ec863f71-2b21-41fe-a593-848552199029	SHAMPOO SAVITAL ANTICASPA 100ML	7702006202848	t	3600.00	3480.00	\N	\N	19.00	2025-10-19 02:29:41.117196	2025-10-19 02:29:41.117196
46f852ea-e2be-4866-b6e2-67a2e3521c6b	Kola Granulada Mk	7702057733650	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.11756	2025-10-19 02:29:41.11756
4e34f7c2-aee1-4f78-80f7-005c72ccd901	PAÑITOS PEQUEÑIN ALOE X24UNID	7702026312251	t	3600.00	3500.00	\N	\N	19.00	2025-10-19 02:29:41.117801	2025-10-19 02:29:41.117801
19ee70bd-23b4-4422-af9b-f946fbd7a019	SEDA DENTAL ORAL PLUS 30M	7704631200190	t	2400.00	2200.00	\N	\N	19.00	2025-10-19 02:29:41.118142	2025-10-19 02:29:41.118142
1e28653d-ff2d-47fb-aad8-42feeb0024d3	TINTE KERATON 7.43	7707230996129	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.118444	2025-10-19 02:29:41.118444
bb1e0a13-1bc3-4264-8d31-61866a8ad577	GEL FRUTO NARANJA 250GR	7708984578517	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.118776	2025-10-19 02:29:41.118776
ab1af923-335b-452c-b33d-5a028e0f9970	ATUN DIAMANTE 175GR	7862127010316	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:41.119273	2025-10-19 02:29:41.119273
628fc7de-3c15-41ae-addc-c539dfe3414b	FAB POLVO 800GR	7702191163184	t	8800.00	8500.00	\N	\N	19.00	2025-10-19 02:29:41.11962	2025-10-19 02:29:41.11962
390207bd-b4db-49b5-91e5-795c9679e1aa	POOL COLA 3.020ML	7709237598511	t	5700.00	5167.00	\N	\N	19.00	2025-10-19 02:29:41.120019	2025-10-19 02:29:41.120019
5b004653-9efa-4f4d-8bb0-83c41f6a364a	SAL DE FRUTAS	7702057802110	t	2200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.12037	2025-10-19 02:29:41.12037
bcdf6a35-c3c6-42f6-8b74-9eb8cb40ffcf	NUTRI RINDE EL RODEO 405GR	7702024472186	t	18800.00	18400.00	\N	\N	0.00	2025-10-19 02:29:41.120735	2025-10-19 02:29:41.120735
d69de5f8-bd67-43e2-a686-67f7bcdf9ed4	NUTRIRINDE EL RODEO 810GR	7702024083344	t	28500.00	29100.00	\N	\N	0.00	2025-10-19 02:29:41.121089	2025-10-19 02:29:41.121089
e8b88f44-7bc3-4f59-9240-bcb71f43e226	GEL EGO EXTREME MAX 110ML	7702006299923	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.121474	2025-10-19 02:29:41.121474
cf9c5ff8-14d4-4079-9dee-d7d2aada9b35	DOÑA GALLINA X8UNID	7702354949839	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.121698	2025-10-19 02:29:41.121698
fb0b13c8-1ddd-4fb2-a400-3a8ffca5ae3d	Hit Familiar Frutas Tropicales	7702090064599	t	4500.00	4167.00	\N	\N	19.00	2025-10-19 02:29:41.121962	2025-10-19 02:29:41.121962
69122bae-f244-4cfc-8ac6-7af155e81ce1	Hir Familiar Mango	7702090041521	t	4600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.12229	2025-10-19 02:29:41.12229
d6428c51-d004-44c2-a873-989b48018824	LIMPIADOR JAZMIN LAVANDA 3 LITROS	7700304455881	t	7700.00	7400.00	\N	\N	19.00	2025-10-19 02:29:41.122677	2025-10-19 02:29:41.122677
51658beb-4584-42af-8487-273f5f965702	COCA COLA 3L	7702535024447	t	9700.00	8917.00	\N	\N	19.00	2025-10-19 02:29:41.12313	2025-10-19 02:29:41.12313
2bb25136-8c8c-4e33-a461-73b23d41199a	MAIZENA 380GR	7702047003497	t	13200.00	12700.00	\N	\N	19.00	2025-10-19 02:29:41.123349	2025-10-19 02:29:41.123349
aacd3dbc-8209-48c7-9a75-b0eeb53dcb37	DOGOURMETCACHORROS 350GR	7702084050881	t	3200.00	3100.00	\N	\N	5.00	2025-10-19 02:29:41.123828	2025-10-19 02:29:41.123828
e1daf4a8-9c66-4635-93b7-7a5f8fea0e56	COLGATE TRIPLE ACCION 150ML	7509546063331	t	12000.00	11800.00	\N	\N	19.00	2025-10-19 02:29:41.124074	2025-10-19 02:29:41.124074
93278b58-7cea-4388-b04b-9d04df37ee4c	SERVILLETA MIA 200	7707151601164	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.12429	2025-10-19 02:29:41.12429
a20f7f4a-7934-4d9d-aa68-9c8835b57a9c	PAPEL ALUMINIO GOLDENWRAP 7MT	7707339930321	t	2500.00	2350.00	\N	\N	19.00	2025-10-19 02:29:41.124655	2025-10-19 02:29:41.124655
25a21cb9-7fd7-451d-9f0e-3dbfc27a90c6	BAYGON MOSCAS 400CM	7501032926052	t	15700.00	15200.00	\N	\N	19.00	2025-10-19 02:29:41.124927	2025-10-19 02:29:41.124927
66ef6bc4-6ada-4e7a-bd57-5e9c594730ae	MAYONESA BARY 100GR	7702439392758	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:41.125196	2025-10-19 02:29:41.125196
c5bc99ef-0a44-4eb4-ac0f-93cd7da0fa75	SALSA TOMATE BARY 170GR	7702439339715	t	2700.00	2560.00	\N	\N	19.00	2025-10-19 02:29:41.125502	2025-10-19 02:29:41.125502
952d0bf5-2274-4dcb-a5b7-7f1085f9eb59	SALSA TOMATE BARY 120GR	7702439417062	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:41.125763	2025-10-19 02:29:41.125763
4944dde9-05c8-4f13-8e0e-4b5aeec9c341	SALMON RICURAS DEL MAR	7708153154276	t	3300.00	3150.00	\N	\N	0.00	2025-10-19 02:29:41.125993	2025-10-19 02:29:41.125993
10adc67d-da55-465f-8595-d33a533402ae	SARDINA NORSAN 425GR	7709861625836	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:41.126458	2025-10-19 02:29:41.126458
2320962e-3a5e-429a-89b8-ebc50495eca8	GUANTE ETERNA MAS PAÑOS	7702037564625	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.126813	2025-10-19 02:29:41.126813
7d938658-8909-4572-ae31-92898bb16ca7	SALSA NORSAN X3 UNID	7708441522015	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.127189	2025-10-19 02:29:41.127189
3bb88d3e-2da0-4b26-adcf-d8f3eec27c74	LECHE CONDENSADA EL ANDINO 900GR	7709068596601	t	11300.00	10900.00	\N	\N	0.00	2025-10-19 02:29:41.127554	2025-10-19 02:29:41.127554
89f72ddd-ee17-48b5-a752-6594487afb9c	GILLETE MACH3 REPUESTO	7506339399523	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.127872	2025-10-19 02:29:41.127872
a7f896db-db5e-42de-aadb-6aa8bdf3e0d2	TROPI SABOR MANTECADO 65ML	7707373084561	t	2300.00	2150.00	\N	\N	19.00	2025-10-19 02:29:41.128252	2025-10-19 02:29:41.128252
259d75f2-5f4f-4c0a-b2fe-3e2e59f0704d	TROPI SABOR COCO 65ML	7707373084202	t	2300.00	2150.00	\N	\N	0.00	2025-10-19 02:29:41.128612	2025-10-19 02:29:41.128612
af9421c2-8160-4cb9-961c-3b62e90e074d	MONCLEAR AVENA Y ARGAN 145GR	7708872634783	t	2600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.128917	2025-10-19 02:29:41.128917
941b93af-de30-4701-807c-e925cceee0a0	NATUREY CON SAL MARINA 30GR	7702175935066	t	1300.00	1200.00	\N	\N	19.00	2025-10-19 02:29:41.129137	2025-10-19 02:29:41.129137
eb5f057f-87fd-4e9e-b2b6-646366e7b4de	TOALLAS NOSOTRAS INVISIBLE RAPIGEL X30 MAS 4 BUENAS NOCHES	7702026158538	t	13900.00	13500.00	\N	\N	0.00	2025-10-19 02:29:41.129366	2025-10-19 02:29:41.129366
0312a5aa-1172-4d6e-a835-b5bef7c23e81	LAVALOZA SUPERB 500ML	7707291393370	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.12958	2025-10-19 02:29:41.12958
1284ca19-817c-418e-b324-caffde8ef061	INVISIBLE CLASICA MULTIESTILO NOSOTRAS	7702026182335	t	4900.00	4700.00	\N	\N	0.00	2025-10-19 02:29:41.129897	2025-10-19 02:29:41.129897
5794f6e2-2823-4704-9d22-702474b06e9d	SUPREMO BEBE 180GR	7708669890613	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:41.130128	2025-10-19 02:29:41.130128
b4ef665c-b455-4ccc-9296-dd83289e5263	GEL ROLDA AZUL 120GR	7707342220112	t	4300.00	4200.00	\N	\N	19.00	2025-10-19 02:29:41.130433	2025-10-19 02:29:41.130433
7f060c28-1048-477d-aeff-31c52eeb3517	BALANCE MEN PRACTIT 32GR	7702029509382	t	4000.00	3850.00	\N	\N	19.00	2025-10-19 02:29:41.130823	2025-10-19 02:29:41.130823
77924b70-5152-4eac-a066-729cf3b3997b	ARROZ ZULIA 3.000GR	7707222290204	t	12000.00	11800.00	\N	\N	0.00	2025-10-19 02:29:41.131219	2025-10-19 02:29:41.131219
fb33cae3-49f6-4138-a235-6ebdab6de9cc	ACEITE SARA 1000ML	7709385952883	t	6900.00	6900.00	\N	\N	19.00	2025-10-19 02:29:41.131443	2025-10-19 02:29:41.131443
6ac6c07b-a44e-4428-9e76-a64da4858b75	BOMBILLO EVEREADY 5W	8888021303131	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.131715	2025-10-19 02:29:41.131715
c8a8a8a0-6470-433b-9026-0814a0b40bd2	BOMBILLO EVERADY  8W	8888021303162	t	4300.00	4000.00	\N	\N	19.00	2025-10-19 02:29:41.132087	2025-10-19 02:29:41.132087
8ab71f30-43f7-4d26-906d-a7dac1cdb27d	MACARRON COMARRICO 250GR	7707307962286	t	1800.00	1700.00	\N	\N	5.00	2025-10-19 02:29:41.132511	2025-10-19 02:29:41.132511
732b6421-f41f-466e-8849-6fe6e179bb43	HUGGIES TRIPLE PROTECCION G/3 X25UNID	7702425321670	t	19000.00	18300.00	\N	\N	19.00	2025-10-19 02:29:41.132881	2025-10-19 02:29:41.132881
7a42e02f-dfa6-4349-a930-288403f8c634	Don Kat 1Kg	7702084057163	t	10500.00	\N	\N	\N	5.00	2025-10-19 02:29:41.133312	2025-10-19 02:29:41.133312
4432b177-99f8-4cb5-bc01-38bb40b70cdd	CERA LIMPIADORA LA JOYA 1.000ML	7702088902636	t	8500.00	8200.00	\N	\N	19.00	2025-10-19 02:29:41.133635	2025-10-19 02:29:41.133635
d2cf9498-d548-4705-9c16-33726cbe4ebe	REXONA CLINICA 18G X2	7702006207713	t	1200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.133949	2025-10-19 02:29:41.133949
84a492e2-7485-47e5-99a3-c8b2e6e2eaa4	SALSA NAPOLITANA 106GR	7702097086259	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.134184	2025-10-19 02:29:41.134184
ac4cbd5d-2b22-4df2-a5bd-b618656185eb	MECHAS LOCAS DE CHOCOLATE	7702174078955	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.134542	2025-10-19 02:29:41.134542
e5663d91-7b66-440c-8f48-2635d85c9fb4	CHIDOS CHILE DULCE 170GR	7702152119465	t	5500.00	5350.00	\N	\N	19.00	2025-10-19 02:29:41.13502	2025-10-19 02:29:41.13502
df16bf9a-b240-4fd9-9b66-dc1d45f0df17	BOMBILLO PHILIPS 8W	8718699765453	t	4600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.135352	2025-10-19 02:29:41.135352
41fa6d4f-a2ae-4fe8-9e20-6c96b181c83d	BON AIRE VARITAS CANELA Y MANZANA  40ML	7702532312110	t	7000.00	6800.00	\N	\N	19.00	2025-10-19 02:29:41.135832	2025-10-19 02:29:41.135832
bd9dce54-a22f-4d23-864f-b2f373400bce	multi absorb	7702425809925	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.136112	2025-10-19 02:29:41.136112
4dbd2a21-90f6-4c65-97ca-a3727730ee5e	TRULULU CASQUITOS	7702993051863	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.136448	2025-10-19 02:29:41.136448
b7e9b256-64a4-45cc-923b-0442ae6076d5	SUPER RIEL LIQUIDO 925ML	7702310043113	t	6000.00	5850.00	\N	\N	19.00	2025-10-19 02:29:41.136654	2025-10-19 02:29:41.136654
92621cd5-c9f2-4ace-9bfa-c4e0bb4141f7	COCA COLA LATA 235ML	7702535021712	t	2600.00	2417.00	\N	\N	19.00	2025-10-19 02:29:41.136983	2025-10-19 02:29:41.136983
7b4d81be-9bcf-42f5-89d8-efb28cfe0f7b	CARACOL PUGLIESE 1.000GR	7702020060110	t	3500.00	3334.00	\N	\N	5.00	2025-10-19 02:29:41.137209	2025-10-19 02:29:41.137209
d410e396-4234-4b0a-851f-a3e9cd012859	MAYONESA BARY 400GR	7702439902667	t	7700.00	7500.00	\N	\N	19.00	2025-10-19 02:29:41.137522	2025-10-19 02:29:41.137522
eb0ad9a6-4899-4ecd-af36-929305b07ed4	CAFE AROMA 50GR	7702088199821	t	2400.00	2300.00	\N	\N	5.00	2025-10-19 02:29:41.137733	2025-10-19 02:29:41.137733
9572f7fb-cbcc-412b-93fd-c455f82cb65b	MAYONESA BARY 200GR	7702439000813	t	2700.00	2560.00	\N	\N	19.00	2025-10-19 02:29:41.138056	2025-10-19 02:29:41.138056
33682ed6-0982-44a0-a93a-91a7b71dd02d	AVENA EN HOJUELAS QUESADA 270GR	7702088204587	t	2100.00	\N	\N	\N	5.00	2025-10-19 02:29:41.138488	2025-10-19 02:29:41.138488
350d3821-efe7-4b18-abed-c833888206fd	PANELADA 29G	7702354950354	t	1400.00	1290.00	\N	\N	19.00	2025-10-19 02:29:41.138937	2025-10-19 02:29:41.138937
f2290f73-a8ec-4fd3-9841-3d6bd9ca5121	PAÑITOS PEQUEÑIN MANZANILLA X60UNID	7702026180010	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:41.139451	2025-10-19 02:29:41.139451
de410d47-2dbd-4805-9272-9e5576fe70a4	Bary Mani con Pasas	7702439962272	t	9200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.139764	2025-10-19 02:29:41.139764
72923a30-8839-4d98-af38-64a9290baa5c	MANI BARY CON SAL 35GR	7702439275754	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.140245	2025-10-19 02:29:41.140245
10db3f37-f65a-43c5-aa45-5175774f8cd8	FRUTY AROS KARYMBA 240GR	7591039451046	t	6800.00	6600.00	\N	\N	19.00	2025-10-19 02:29:41.14059	2025-10-19 02:29:41.14059
9b561554-9bb0-4359-8da7-fba5a06be496	AZUCARADA 250G KARYMBA	7702807456433	t	6800.00	6600.00	\N	\N	19.00	2025-10-19 02:29:41.140832	2025-10-19 02:29:41.140832
2004f4b5-365b-4954-b6e3-bc9be5bc89ca	SALSA MOSTAZA BARY 140GR	7702439417833	t	2600.00	2480.00	\N	\N	19.00	2025-10-19 02:29:41.141122	2025-10-19 02:29:41.141122
a82ee4a5-fd92-404b-a155-d9aaff266ed5	AVENA INSTANTANEA EXTRA SEÑORA CANELA 400GR	7708345181103	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:41.141632	2025-10-19 02:29:41.141632
a8b8d182-0021-46cc-ae83-e9ea982e913f	CEPILLO PRO DELUXE	7501006711615	t	2800.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.14203	2025-10-19 02:29:41.14203
b3fb30d9-8d11-498e-afc9-81c9a54bdb11	CHORIZO CAMPESINO COLANTA X9UNID	7702129073547	t	17300.00	17000.00	\N	\N	19.00	2025-10-19 02:29:41.142389	2025-10-19 02:29:41.142389
73c7a8a4-ea93-453b-b875-dbbf76272e8d	TOALLIN FAMILIA PRACTIPLU 50UNID	7702026188917	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.142588	2025-10-19 02:29:41.142588
4de95260-e596-450b-a521-28fdecdedf8a	CHOCOBITZ KARYMBA 260GR	7707200712124	t	6700.00	6500.00	\N	\N	19.00	2025-10-19 02:29:41.142863	2025-10-19 02:29:41.142863
c4e09c68-d70a-4617-b46f-69037659cb92	MIRAMONTE LECHE 800GR	7709021393841	t	18700.00	18300.00	\N	\N	0.00	2025-10-19 02:29:41.143165	2025-10-19 02:29:41.143165
50b2693b-7c41-43c9-9dd3-942285448b68	PAN TAJADO INTEGRAL GUADALUPE	7705326020499	t	6900.00	6700.00	\N	\N	0.00	2025-10-19 02:29:41.143379	2025-10-19 02:29:41.143379
ca72f34e-adf8-495f-9f74-934179fc3a50	YOGOLIN MORA LA MEJOR 150GR	7705241400949	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.143743	2025-10-19 02:29:41.143743
2be2ff69-4484-4004-a383-f86b3ba20d28	AZUCAR RIOPAILA	7702127108029	t	4200.00	4080.00	\N	\N	5.00	2025-10-19 02:29:41.143962	2025-10-19 02:29:41.143962
96c72da4-8d27-4b0e-be69-d60b8f2c4704	SALSA QUESO CHEDDAR BARY 200GR	7702439269326	t	7000.00	6800.00	\N	\N	19.00	2025-10-19 02:29:41.144375	2025-10-19 02:29:41.144375
842d29d1-02b5-4181-a7fc-7432fd7ad262	KOTEX NORMAL ALAS 10UND	7702425810310	t	6000.00	5800.00	\N	\N	0.00	2025-10-19 02:29:41.144608	2025-10-19 02:29:41.144608
3eeed5c3-4da2-4a9c-993a-4a6c0a0888d3	FESTIVAL RECREO 12X6	7702025142026	t	13700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.144888	2025-10-19 02:29:41.144888
a03c8a92-7265-4560-bfcc-30da6051bf9d	DOÑA GALLINA X12UNID	7702354949761	t	4900.00	4750.00	\N	\N	19.00	2025-10-19 02:29:41.145245	2025-10-19 02:29:41.145245
43d6ff78-4776-4493-b0a9-bbbb341025be	SALSA ROSADA BARY 140GR	7702439845827	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.145596	2025-10-19 02:29:41.145596
e1780745-5a8c-4e1f-b338-190c090e010f	GALLETAS RUEDITAS VAINILLA 12X4	7707014960599	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.145818	2025-10-19 02:29:41.145818
9edc8965-18ce-4081-b4fe-e03d03ce7a9e	SODA POOL 400ML	7709004927773	t	1200.00	1063.00	\N	\N	0.00	2025-10-19 02:29:41.146383	2025-10-19 02:29:41.146383
162f5256-5c18-40eb-9ec5-6bd4030a72b2	MAYONESA BARY 1000GR	7702439001087	t	14800.00	14400.00	\N	\N	19.00	2025-10-19 02:29:41.146672	2025-10-19 02:29:41.146672
1e6496e3-54d6-40a1-9f73-e2bbf304eda2	Jumbo Rosca	7702007065831	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.147044	2025-10-19 02:29:41.147044
ec1daa3c-d59c-429f-a4a6-dda64194bb16	AXION LAVALOZA850GR	7702010382147	t	12000.00	11700.00	\N	\N	19.00	2025-10-19 02:29:41.147641	2025-10-19 02:29:41.147641
ab0bc069-507f-4f87-a117-7342ed2f8eb4	BIANCHI MANI SNACKS	7702993039151	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.14819	2025-10-19 02:29:41.14819
a43d4d6e-7c85-4d20-9d2f-983498b1a730	CITRONELA MAGHIX 1000ML	671875654317	t	3200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.148608	2025-10-19 02:29:41.148608
1c1447ef-d7a1-4bb5-93ee-e65b348b12bb	Head Shoulders	7500435176217	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.148876	2025-10-19 02:29:41.148876
2433d04e-2828-4b25-a1dd-fcd301a25262	MOSTAZA BARY 110GR	7702439811327	t	2100.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.149125	2025-10-19 02:29:41.149125
fced2d15-c24c-41f9-8f55-ea2a5b3c687c	BABY FRUIT MANZANA	7707262683738	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.149683	2025-10-19 02:29:41.149683
e5c3a641-036b-433d-90e5-977c36e9c0c4	MANI BARY LIMON 35GR	7702439883089	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.150022	2025-10-19 02:29:41.150022
aedba3d0-838b-49e0-9f50-d2231033798b	BILAC LECHE ACHOCOLATADA BOLSA 200	7702090061000	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.15034	2025-10-19 02:29:41.15034
d5c61aae-72a0-4776-93f9-d606962b1b52	FLIPS CHOCOLATE 120GR	7707200710342	t	4700.00	4550.00	\N	\N	19.00	2025-10-19 02:29:41.150589	2025-10-19 02:29:41.150589
05f41e80-e87d-416d-b612-83c091e2b3e2	NATUREY 6GR	7702175775334	t	500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.150814	2025-10-19 02:29:41.150814
5f46ff79-aa76-4843-9f2f-eb08def0356d	Dulces Fiestas Galleta Navideña	7709990356984	t	600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.151162	2025-10-19 02:29:41.151162
f21cf740-165c-4ffe-976f-fb90e0e4b11e	COMPOTA HIT MANZANA 90GR	7702439630423	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.15146	2025-10-19 02:29:41.15146
75003220-7db1-44cd-825b-0270473b83a1	COMPOTA HIT SABOR A PERA 90GR	7702439061173	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.151761	2025-10-19 02:29:41.151761
81abf062-ec39-4c36-b06c-8f3b985bfa57	BOMBILLO PHILIPS 14W	8718699731724	t	8800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.152243	2025-10-19 02:29:41.152243
c4d414b1-bff1-473b-8cfb-31bf6fb4f131	CHOCO CRONCH KARIMBA 240GR	7702807995321	t	6800.00	6600.00	\N	\N	19.00	2025-10-19 02:29:41.152465	2025-10-19 02:29:41.152465
9c94f437-6ab6-46a8-a54c-2c1e7ad9aefd	RINDEX 10 500GR MULTIUSOS	7500435181044	t	4600.00	4500.00	\N	\N	19.00	2025-10-19 02:29:41.152925	2025-10-19 02:29:41.152925
2df4017c-3968-4350-a696-9b78957f296d	CHORIZO TERNERA MONTEFRIO 250GR X5UNID	7702129072922	t	8100.00	8000.00	\N	\N	19.00	2025-10-19 02:29:41.15322	2025-10-19 02:29:41.15322
67bf45dd-71b2-40b9-974c-4eee7b0f97cc	SALSA MAIZ NATUCAMPO 200GR	7709197690089	t	5200.00	4950.00	\N	\N	19.00	2025-10-19 02:29:41.153446	2025-10-19 02:29:41.153446
25de2970-67f7-4d1b-8603-e6341753b691	SALSA TOCINETA NATUCAMPO 200GR	7709593384575	t	4800.00	4600.00	\N	\N	19.00	2025-10-19 02:29:41.153758	2025-10-19 02:29:41.153758
5253d7c0-bdf8-4c50-b7c1-c88bc323459f	TRICOMPLETO REY55GR	7702175111279	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:41.153973	2025-10-19 02:29:41.153973
8df7491b-b4d2-409d-b856-5df050f95999	CASERO 3 LECHES 220GR	7705326002044	t	8000.00	7900.00	\N	\N	19.00	2025-10-19 02:29:41.154233	2025-10-19 02:29:41.154233
3525910a-690a-4864-a8c1-8abf1c05fd5e	SANPIC CANELA 200ML	7702626219233	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:41.154481	2025-10-19 02:29:41.154481
205a3083-f553-42b5-a1ea-7194fc73fea1	Dogourmet Pavo y Pollo 350g	7702084051000	t	3200.00	3100.00	\N	\N	5.00	2025-10-19 02:29:41.154785	2025-10-19 02:29:41.154785
801cdcb6-ac61-4a29-8bf5-e291d6fad7cc	SUPERCOCO CHOCO SNACKS	7702993038208	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:41.154999	2025-10-19 02:29:41.154999
51b9928b-702f-4e70-9ef3-140e20dbabca	SALSA DE SOYA BARY PROFECIONAL 1165ML	7702439008833	t	9600.00	9300.00	\N	\N	19.00	2025-10-19 02:29:41.155247	2025-10-19 02:29:41.155247
ba04a947-db2f-401e-b30a-a6b4f79bdf13	FAMILIA ACOLCHAMAX EXTRA GRANDE X4UNID	7702026196134	t	7700.00	7500.00	\N	\N	19.00	2025-10-19 02:29:41.155471	2025-10-19 02:29:41.155471
7c7e4765-62bd-4a84-80c2-bc63608bbfbb	SHAMPOO SAVITAL MULTIOLEOS 550ML	7702006205931	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:41.155783	2025-10-19 02:29:41.155783
9636b6ac-0d45-4f07-a405-6b950263c5a0	SHAMPOO SAVITAL KERATINA 550ML	7702006299107	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:41.156126	2025-10-19 02:29:41.156126
75b6b046-86c0-4e81-8b0d-e55d8ad64988	SHAMPOO SAVITAL SHAMPOO Y ACONDICIONADOR 550ML	7702006652674	t	29000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.15638	2025-10-19 02:29:41.15638
e03eb2cb-d742-4b35-9566-1d65a9e650a1	SUPERCOCO TURRON X100UNID	7702993018668	t	15400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.156743	2025-10-19 02:29:41.156743
cf89ebe4-9845-4fac-99e9-1110c8afd7aa	ATUN ROBIN HOOD ACEITE 175GR	7862119507220	t	3700.00	3600.00	\N	\N	19.00	2025-10-19 02:29:41.157252	2025-10-19 02:29:41.157252
05067795-2aa4-484a-818e-9b4b6b686753	Boka Panela y Limon	7702354951559	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:41.157863	2025-10-19 02:29:41.157863
1311fb1d-99aa-492a-9df4-eb88ce316b21	ATUN ZENU ACEITE DE GIRASOL 160GR	7701101359587	t	6500.00	6350.00	\N	\N	19.00	2025-10-19 02:29:41.158296	2025-10-19 02:29:41.158296
86412835-5b26-41a1-9d98-7f5124e802d2	ATUN ZENU LOMO AGUA	7701101359594	t	6500.00	6350.00	\N	\N	19.00	2025-10-19 02:29:41.158645	2025-10-19 02:29:41.158645
9b83b19b-04b7-4d94-85fc-31336fd4d2e8	Limpia Ya Guante n 7	7702037567909	t	3600.00	3480.00	\N	\N	19.00	2025-10-19 02:29:41.158904	2025-10-19 02:29:41.158904
7c23376c-d523-4c12-9873-b25263cbd450	ESTUCHE ARRURRU BABY SHOWER	7702277334262	t	44000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.159621	2025-10-19 02:29:41.159621
ae3eadce-2241-43ab-bd59-9b8a6a29e738	CREMARROZ VAINILLA 200GR	7707232993034	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:41.160128	2025-10-19 02:29:41.160128
8cfb4980-300f-40dd-a687-a5868ee58f62	CREMARROZ NATURAL 200GR	7707232993027	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:41.160623	2025-10-19 02:29:41.160623
c0101a5d-df04-4730-83e1-2a57369d48aa	BIANCHI CARAMELO MANI	7702993038239	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.161006	2025-10-19 02:29:41.161006
51d0663a-bf99-4c98-9231-dbd203622290	BIANCHI CRUNCHY SNASCKS	7702993042298	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.161413	2025-10-19 02:29:41.161413
65111647-4d37-4ea7-8dd5-6cf8bf5f9420	BabyFrut Compota Pera	7707262683714	t	2100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.16219	2025-10-19 02:29:41.16219
07d91b1f-070e-4a76-9ce3-3088b57c9463	CREMA DE ARROZ BOLSA PRI 900GR	7591002100124	t	7700.00	7300.00	\N	\N	19.00	2025-10-19 02:29:41.162706	2025-10-19 02:29:41.162706
ef62501c-b552-4335-8f96-05e8e4065c36	MORITAS AMERICANDY X100UNID	7702174079181	t	5700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.163096	2025-10-19 02:29:41.163096
d727efbb-6b94-4abf-950c-2f3895d5b82b	PIN POP LULIMON X24UNID	7702174081641	t	6600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.163678	2025-10-19 02:29:41.163678
766db32e-f2e0-4d97-9aca-f1116221c2fa	SUPERCOCO BOMBON X24UNID	7702993031957	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.164375	2025-10-19 02:29:41.164375
44f6c511-f26d-4811-94ea-e4b027462e7e	ANGELA INVISIBLE 8UND	7707324641140	t	2000.00	1850.00	\N	\N	0.00	2025-10-19 02:29:41.165313	2025-10-19 02:29:41.165313
d255e609-eaa3-4387-89c3-934a0bdd63da	TOALLAS ANGELA X30UNID MAS X30PROTECTORES	7707324640976	t	7800.00	7450.00	\N	\N	0.00	2025-10-19 02:29:41.165963	2025-10-19 02:29:41.165963
e78b68c1-056d-433b-b803-1adf31121d37	ANGELA 8 NOCTURNA Y 8 DELGADA	7707324640044	t	4400.00	4300.00	\N	\N	0.00	2025-10-19 02:29:41.166419	2025-10-19 02:29:41.166419
9a61c5e0-a645-4c6d-8061-cbbc68f47653	SALTINAS INTEGRAL 133GR	7702024327820	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.167355	2025-10-19 02:29:41.167355
2db4e1b1-0f25-429c-86c0-466fc7d01281	MANY BARY CROCANTE 20GR	7702439879655	t	800.00	717.00	\N	\N	19.00	2025-10-19 02:29:41.168319	2025-10-19 02:29:41.168319
7af7755d-de15-443e-aad6-2852856c51a5	SALSA HARDYS 130GR	7702439837808	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.169017	2025-10-19 02:29:41.169017
5192df5c-4688-443e-8c16-376728d7e1b9	Flips Crema Chocolate	7702807053182	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.169993	2025-10-19 02:29:41.169993
18f4252e-263a-4a3d-ba08-621353e2d7b4	SUAVITEL PRIMAVERA 180ML	7509546676142	t	1500.00	1380.00	\N	\N	19.00	2025-10-19 02:29:41.170645	2025-10-19 02:29:41.170645
739a55ab-fe71-4448-bfa7-2b03cd9db1f8	SUAVITEL COMPLETE 160ML	7509546676043	t	1500.00	1450.00	\N	\N	19.00	2025-10-19 02:29:41.171002	2025-10-19 02:29:41.171002
1d1a9188-6fd5-40a4-9539-b15540abbf8b	MAXCOMBI CARAMELO BLANDO X100UNI	7702011121448	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.171377	2025-10-19 02:29:41.171377
8c8257c7-a197-4276-bff9-bfb46c00a31b	JABON INTIMO NOSOTRAS 18ML	7702026177164	t	1300.00	1200.00	\N	\N	19.00	2025-10-19 02:29:41.171866	2025-10-19 02:29:41.171866
4802aeb8-c5da-45f3-91a8-08cc941ad441	FIDEO PUGLIESE 1.000GR	7702020060202	t	3500.00	3334.00	\N	\N	5.00	2025-10-19 02:29:41.172411	2025-10-19 02:29:41.172411
c158b5d2-d4ba-4fce-b3b1-224515c14ff3	GASTRUM PLUX	77025388	t	2200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.172771	2025-10-19 02:29:41.172771
30876b46-3ed2-4013-b191-c3520f192342	HEAD Y SHOULDERS DERMO SENSITIVE  180ML	7500435148047	t	12000.00	11500.00	\N	\N	19.00	2025-10-19 02:29:41.1734	2025-10-19 02:29:41.1734
54f6c3ee-de4f-402b-aa7b-162da07b3457	BABY DREAMS 3X30	7709674433413	t	23500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.173967	2025-10-19 02:29:41.173967
f4183057-2653-4ca3-a129-eaa3f2c20e38	SAL MARINA	7707061202109	t	900.00	825.00	\N	\N	0.00	2025-10-19 02:29:41.174572	2025-10-19 02:29:41.174572
a8a2a782-327d-45bd-b5eb-35b4aee7ca77	GEL ROLDA SPORT BLACK 120GR	7708457895196	t	4300.00	4200.00	\N	\N	19.00	2025-10-19 02:29:41.175098	2025-10-19 02:29:41.175098
e57eba26-dbb3-460e-9368-6b4121a20ca7	GEL ROLDA BLACK POWER 120GR	7708457895554	t	4300.00	4200.00	\N	\N	19.00	2025-10-19 02:29:41.175792	2025-10-19 02:29:41.175792
91e23693-62f1-4ecf-bd06-0e0199955f59	TOALLAS ANGELA INVISIBLE X30UNID	7707324640730	t	5900.00	5700.00	\N	\N	0.00	2025-10-19 02:29:41.176746	2025-10-19 02:29:41.176746
edeaaf7e-cdf8-41d5-b162-4327d2af6405	BABY QUAKER AVENA Y BANANO 25GR	7702193605125	t	800.00	670.00	\N	\N	19.00	2025-10-19 02:29:41.177666	2025-10-19 02:29:41.177666
f2e23abd-02dd-4b1e-9aa9-3d4e96614b61	VELA AMBIENTADOR BONDI DULCE VAINILLA	7707291398184	t	10800.00	10400.00	\N	\N	19.00	2025-10-19 02:29:41.178563	2025-10-19 02:29:41.178563
58ab5241-8d25-46e1-9e38-d05fa508a50e	AMPER ENERGY 473ML	7702354954994	t	2900.00	2684.00	\N	\N	19.00	2025-10-19 02:29:41.1792	2025-10-19 02:29:41.1792
93ec6bd2-186c-4e97-9004-76ffe162b466	REDONDITAS CHOCOLATE 4X12	7707323130447	t	7400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.179906	2025-10-19 02:29:41.179906
72a14099-9a19-4d5a-a606-f818ec16db0e	COMEDERO MASCOTA	7708968254116	t	3800.00	3600.00	\N	\N	19.00	2025-10-19 02:29:41.180486	2025-10-19 02:29:41.180486
b876f681-9f8d-4dd5-838a-0694605e99a7	SONETTO ROSADO100UND	7702174078887	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.180849	2025-10-19 02:29:41.180849
ea62ae14-ea7a-4aa9-9931-fedb0d68a112	ESENCIA CARAMELO LEVAPAN	77066800	t	4900.00	4740.00	\N	\N	19.00	2025-10-19 02:29:41.181413	2025-10-19 02:29:41.181413
e1a9154b-1b7d-4c90-a70c-974faecfd8a6	ESENCIA BANANP LEVAPAN 60ML	77093677	t	4900.00	4740.00	\N	\N	19.00	2025-10-19 02:29:41.182166	2025-10-19 02:29:41.182166
62dc5567-1a87-4b5f-8655-bb9d8650075b	PARMALAT MAS LECHE 104GR	7700604052636	t	2700.00	\N	\N	\N	0.00	2025-10-19 02:29:41.182766	2025-10-19 02:29:41.182766
97ecebab-928e-4b8f-90f1-272600bedcbd	TEST	36236525632	t	150.00	450.00	\N	105.00	0.00	2025-10-19 02:29:41.183415	2025-10-19 02:29:41.183415
21581b7a-a7d0-4f41-a0a4-4a8280828891	BULTO TEST X 24U	BT	t	11000.00	\N	\N	2520.00	0.00	2025-10-19 02:29:41.18409	2025-10-19 02:29:41.18409
f4ba4ccf-efcb-4c10-b383-9ad3949f8a5c	SERVICIO DE TRANSPORTE	st	t	100.00	\N	\N	100.00	0.00	2025-10-19 02:29:41.18431	2025-10-19 02:29:41.18431
684ea420-34f4-4981-ac0d-052244321409	TRANSPORTE DE MERCANCIA	tra	t	1000000.00	\N	\N	1100000.00	0.00	2025-10-19 02:29:41.184859	2025-10-19 02:29:41.184859
0605e15b-9dd4-43d9-8c7f-c52431c32e4b	NUZART BARQUILLO	1011011031524	t	8500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.185505	2025-10-19 02:29:41.185505
7d62e7fc-9094-45f9-9b7b-5fcbc3fff7fc	FLIPS LECHE 120GR	7707200710359	t	4700.00	4550.00	\N	\N	19.00	2025-10-19 02:29:41.185732	2025-10-19 02:29:41.185732
2cd0c9ae-3dbd-4226-a916-44673ac784ff	SHAMPOO VANART ANTI ESPONJADO COCO KERATINA 600ML	650240039324	t	12800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.1863	2025-10-19 02:29:41.1863
127b0a2e-0305-4e69-b1db-68086121b6be	ALCOHOL JGB 300ML	7702560040313	t	4600.00	4400.00	\N	\N	0.00	2025-10-19 02:29:41.186782	2025-10-19 02:29:41.186782
6cdaeaaa-db8d-4df9-b3a2-a5875e91a7a8	TORTILLAS XL 8U	7705326016423	t	14900.00	14700.00	\N	\N	19.00	2025-10-19 02:29:41.187314	2025-10-19 02:29:41.187314
16540129-0504-45fb-bff0-fc6acc98a431	TAKIS XPLOSION 185G	7500810003954	t	9000.00	8200.00	\N	\N	19.00	2025-10-19 02:29:41.187884	2025-10-19 02:29:41.187884
796d78b5-7063-4042-8ae6-8941e0dace31	TAKIS FUEGO 185G	7500810003664	t	9000.00	8200.00	\N	\N	19.00	2025-10-19 02:29:41.188102	2025-10-19 02:29:41.188102
1339f0b3-7633-434d-836d-ee6b214db352	TAKIS ORIGINAL 185G	7500810003657	t	8400.00	8200.00	\N	\N	19.00	2025-10-19 02:29:41.188901	2025-10-19 02:29:41.188901
50e8975c-51bc-4d56-97f0-22ac50afaafa	ARTESANO BANANO 75GR	7705326002600	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.189132	2025-10-19 02:29:41.189132
a7ac84c3-29b5-4ecd-b845-cbc677dde802	ARTESANO ZANAHORIA 75GR	7705326002594	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.189705	2025-10-19 02:29:41.189705
9cd69964-9dd5-4d8d-95f6-f8e771deca6e	PAN TAJADO BLANCO BIMBO 470GR	7705326625502	t	5600.00	5500.00	\N	\N	0.00	2025-10-19 02:29:41.190682	2025-10-19 02:29:41.190682
87b095dd-aae7-47ab-8c9a-baa383e88c21	TOSTADA MANTEQUILL 24U 280GR	7705326079336	t	7600.00	7450.00	\N	\N	0.00	2025-10-19 02:29:41.191129	2025-10-19 02:29:41.191129
6824c9c9-4d3c-400d-ae69-40b2ccb98dcb	TAKIS ORIGINAL 45GR	7500810001301	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.191663	2025-10-19 02:29:41.191663
7ce82c12-0897-4f86-aea6-b98a046810d7	TAKIS XPLOSION 45G	7500810001318	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.191914	2025-10-19 02:29:41.191914
bdc34ff9-fb59-4a53-88a4-c8d4cc8b4dc4	TOSTADA INTG 24U GUADALUPE	7705326079343	t	7500.00	7400.00	\N	\N	0.00	2025-10-19 02:29:41.192406	2025-10-19 02:29:41.192406
2b587167-4144-4ad6-9ee0-134329cb0799	CHOCOSO MINI 20U 400GR	7705326090874	t	15200.00	15000.00	\N	\N	19.00	2025-10-19 02:29:41.192758	2025-10-19 02:29:41.192758
ea3e9a90-8d53-4273-bdd8-d336493a4cae	SUBMARINO MIX 6U 204GR	7705326081223	t	8900.00	8800.00	\N	\N	19.00	2025-10-19 02:29:41.193047	2025-10-19 02:29:41.193047
643ba932-df9e-4aaf-bc21-f11b475c5639	FABULOSO FLORAL 180ML	7509546683287	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.193272	2025-10-19 02:29:41.193272
b6fa20e9-5c0f-4cde-aef2-46a200c03308	FABULOSO ALTERNATIVA 180ML	7509546683690	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.193573	2025-10-19 02:29:41.193573
e9059c9d-aef1-4a56-8445-4daa541327e0	FABULOSO LAVANDA 180ML	7509546683263	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.194036	2025-10-19 02:29:41.194036
04be5220-ff8c-4f8b-b371-084f6273576a	FABULOSO BEBE 180ML	7509546683270	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.194455	2025-10-19 02:29:41.194455
761e05ca-b2b4-4c50-b080-bde50f9e1b93	PROTEX HERBAL 110GR	7702010420382	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:41.194813	2025-10-19 02:29:41.194813
23cfdaa1-735d-4d28-ab0a-162efc85cf6b	PROTEX LIMPIEZA PROFUNDA 110GR	7509546693538	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:41.195148	2025-10-19 02:29:41.195148
169ffe98-5de8-44cf-a414-5f9ad3895fae	PALMOLIVE CARBON 120GR	7509546676951	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:41.195556	2025-10-19 02:29:41.195556
326be43f-9146-40c4-bfa5-16653675716e	PALMOLIVE HUMECTACION 110GR	7509546676920	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:41.195798	2025-10-19 02:29:41.195798
bb26ca53-ba62-4c20-bdd9-c6535908e861	AXION BARRA LIMON 300GR	7509546652542	t	2400.00	2250.00	\N	\N	19.00	2025-10-19 02:29:41.196083	2025-10-19 02:29:41.196083
9af20204-cca0-4e5c-8437-6851b415c790	VELON SAN JORGE #18	7707159821182	t	19800.00	19200.00	\N	\N	19.00	2025-10-19 02:29:41.196419	2025-10-19 02:29:41.196419
967dd948-33a0-47e7-ae7a-7fe0127e03fe	PROTECTORES 150U KOTEX	7702425804746	t	12800.00	12200.00	\N	\N	0.00	2025-10-19 02:29:41.196642	2025-10-19 02:29:41.196642
29f4bc43-63cd-4f8e-bbee-f5b51b8f7693	VELON SAN JORGE #10	7707159821861	t	7200.00	7000.00	\N	\N	19.00	2025-10-19 02:29:41.197108	2025-10-19 02:29:41.197108
02afd89f-ddf4-4d08-bb84-a963230c112e	TORTILLA RAPIDITAS CHIA 6M	7705326081513	t	8200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.19735	2025-10-19 02:29:41.19735
28317cdb-98e9-46b9-a4a3-02f7ae1e3bbe	ANGELA X8 NOCTURNA	7707324640747	t	3700.00	3580.00	\N	\N	0.00	2025-10-19 02:29:41.197558	2025-10-19 02:29:41.197558
925dd6bb-1295-48de-984f-0c2582aba286	BON AIRE AUTO VAINILLA 6ML	7702532188579	t	13500.00	13100.00	\N	\N	19.00	2025-10-19 02:29:41.197808	2025-10-19 02:29:41.197808
5c2391d3-2a43-44ec-9564-e7698949b73b	BON AIRE AUTO FRUTOS ROJOS 6ML	7702532314411	t	13500.00	13100.00	\N	\N	19.00	2025-10-19 02:29:41.198055	2025-10-19 02:29:41.198055
dc72f52b-d74f-41b2-b91f-e30a13d80182	RAYOL 400ML INCEPTICIDA	7702532630207	t	14000.00	13550.00	\N	\N	0.00	2025-10-19 02:29:41.198371	2025-10-19 02:29:41.198371
f6987051-16e0-4628-bf88-9dd4aa8421eb	SUPERCAN CROQUETA 500GR	7707025802741	t	2400.00	2300.00	\N	\N	5.00	2025-10-19 02:29:41.198589	2025-10-19 02:29:41.198589
895b232e-7e11-4668-b84e-d59ae6ec3a54	SUPERCAN CACHORROS 500GR	7707025802291	t	3000.00	2850.00	\N	\N	5.00	2025-10-19 02:29:41.199013	2025-10-19 02:29:41.199013
5f0bb9cf-629f-4c84-b186-7b7c92c66708	BON AIRE FRUTOS ROJOS 250ML	7702532370882	t	5900.00	5700.00	\N	\N	19.00	2025-10-19 02:29:41.199256	2025-10-19 02:29:41.199256
a3e8b851-68f1-4ddc-acc9-25cd94a29c97	OFERTA ARRURRU 190UND	7702277158820	t	19000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.199597	2025-10-19 02:29:41.199597
80f072c1-1895-4774-b93c-5d5ba5699a5e	ARRURRU X70 TOALLITAS HUMEDAS	7702277152330	t	8600.00	8300.00	\N	\N	19.00	2025-10-19 02:29:41.199965	2025-10-19 02:29:41.199965
c8f892d6-7ba3-4603-ace4-a196958c81bc	ARRURRU X120U TOALLAS HUMEDAS	7702277724308	t	12000.00	11750.00	\N	\N	19.00	2025-10-19 02:29:41.200267	2025-10-19 02:29:41.200267
5eb99a81-2f30-44f4-9302-a6b3d3289275	SHAMPOO NUTRIT KERATINMAX 750ML	7702277121497	t	17500.00	17000.00	\N	\N	19.00	2025-10-19 02:29:41.200525	2025-10-19 02:29:41.200525
95e9c856-8483-4706-9d36-f9e659d68a9a	YES CLORO 1800 Y 450ML	7702560033049	t	8500.00	8250.00	\N	\N	19.00	2025-10-19 02:29:41.200903	2025-10-19 02:29:41.200903
29118084-8755-45ca-97c1-4ff3cae22ad4	NUTRIBELA 300GR REPOLARIZACION	7702354943820	t	17300.00	16800.00	\N	\N	19.00	2025-10-19 02:29:41.201136	2025-10-19 02:29:41.201136
04fed88d-cc99-4cf0-8ab0-742e9e324686	NUTRIBELA 300GR NUTRICION	7702354939403	t	17300.00	16800.00	\N	\N	19.00	2025-10-19 02:29:41.201529	2025-10-19 02:29:41.201529
4c588fb6-9dff-47b3-bdad-01b23fcc04ec	NUTRIBELA 300GR CELULAS MADRES	7702354951757	t	17300.00	16800.00	\N	\N	19.00	2025-10-19 02:29:41.201942	2025-10-19 02:29:41.201942
9d2fbf29-2f8e-4c1d-ad8e-1d45cacdb0be	NUTRIBELA 300GR	7702354948498	t	17300.00	16800.00	\N	\N	19.00	2025-10-19 02:29:41.202202	2025-10-19 02:29:41.202202
62219500-f66c-4f5c-b967-71ddd474f65f	PAX CALIENTE DIA 6GR	7706263202603	t	2300.00	2060.00	\N	\N	0.00	2025-10-19 02:29:41.202462	2025-10-19 02:29:41.202462
df68d912-3ef3-4145-bd34-2e2459205a09	OREO ROLLITO 12U	7622201693213	t	2700.00	2590.00	\N	\N	19.00	2025-10-19 02:29:41.202733	2025-10-19 02:29:41.202733
bdabd870-04ac-4ee9-94e7-065735afc563	OKA LOKA NANO 24U	7702993049099	t	12800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.203046	2025-10-19 02:29:41.203046
1eda62a5-6e47-47d0-8880-9dd95f09b4e9	NUTRIBELA 300GR TERMOPROTECCION	7702354945381	t	17300.00	16800.00	\N	\N	19.00	2025-10-19 02:29:41.203346	2025-10-19 02:29:41.203346
c434fb5d-4120-471a-a4cf-0d4f1714355b	CHOCODISK X18 288GR	7702011052513	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.203851	2025-10-19 02:29:41.203851
fbb24fde-1b69-4091-a437-0bf8d09cfc86	AVENA DON PANCHO HOJUELA 1.200GR	7702595483840	t	10500.00	10200.00	\N	\N	5.00	2025-10-19 02:29:41.204201	2025-10-19 02:29:41.204201
93685ec0-b14a-49c1-93e5-710573c6e266	NUCITA CREMA 12UND	7702011021922	t	5300.00	5300.00	\N	\N	19.00	2025-10-19 02:29:41.204712	2025-10-19 02:29:41.204712
e08163fc-cfc6-417e-bede-6b718b2b0cf3	ALUMINIO 7MT BS	734191236183	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:41.205006	2025-10-19 02:29:41.205006
73b2b5e2-ce4c-4e6d-bc7f-d976095cf69e	SPLOT LINEA X5   X24UNID	7702011131379	t	8600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.205486	2025-10-19 02:29:41.205486
a778b500-4d65-4392-9c9d-5a22eec5c322	BIG BOM XXL 48UND	7707014902704	t	15700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.205716	2025-10-19 02:29:41.205716
cfea81df-94f3-41ff-be71-95fae118a9cc	NUTELLA 140GR	7709857224968	t	11800.00	11500.00	\N	\N	19.00	2025-10-19 02:29:41.206101	2025-10-19 02:29:41.206101
afbcffb1-c86e-4f89-b444-fb820f11b0df	POPETAS X6U CARAMELO	7702354934293	t	10700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.20634	2025-10-19 02:29:41.20634
1a2be15d-d0f9-4d92-9a9d-50903bba0174	ARIEL 4K TRIPLE PODER	7506339391671	t	40000.00	39500.00	\N	\N	19.00	2025-10-19 02:29:41.206571	2025-10-19 02:29:41.206571
da2d240f-907b-4575-87f7-ef47d42f44cd	COCOSETTE X24UNID	7702024663485	t	34000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.207089	2025-10-19 02:29:41.207089
deac2a3a-01e9-4c97-a254-ca4706262f70	SALTIN NOEL 5TACOS	7702025114672	t	7900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.207367	2025-10-19 02:29:41.207367
0ba1da87-e3ee-4685-bcd8-3a5828cddbc0	PIN POP 24U GIGANTE	7702174081313	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.207675	2025-10-19 02:29:41.207675
306c4038-a21c-4105-9e67-31fee43bc4c5	SONETTO BLANCO 100UND	7702174085434	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.20789	2025-10-19 02:29:41.20789
d106569f-343c-48bb-81a8-64b7aa6db422	SONETTO CHOCOLATE 100UND	7702174078863	t	8400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.208239	2025-10-19 02:29:41.208239
09d6dd4c-2d8f-4d19-b27e-7afe91782aeb	FRUTICAS CRUJI 100UND	7702011055309	t	9100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.208576	2025-10-19 02:29:41.208576
2d2bddd3-b1e8-48c7-ae17-3a935e3006c3	MOGOLLA INTEGRAL GUADALUPE 12U	7705326075161	t	8100.00	8000.00	\N	\N	0.00	2025-10-19 02:29:41.20882	2025-10-19 02:29:41.20882
fa57c981-1e99-42c9-85be-94d2a9c78cf4	LONCHI MIX 5U 141G	7705326081292	t	6000.00	5900.00	\N	\N	19.00	2025-10-19 02:29:41.209222	2025-10-19 02:29:41.209222
13b6af17-86a6-4672-885c-a441e614c8d4	KEKITO BIMBO 50GR	7705326070258	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:41.209499	2025-10-19 02:29:41.209499
7a434d81-49d8-407b-bcaa-92cf9d1f2aa2	ARVEJA VERDE GRANOS RINCON 500GR	7709668923364	t	2300.00	2220.00	\N	\N	0.00	2025-10-19 02:29:41.209725	2025-10-19 02:29:41.209725
e493d6b9-c71f-4694-a4b1-579d23e0e193	PANTEME COLAGENO 18ML SACHET	7500435191500	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.209978	2025-10-19 02:29:41.209978
da147870-6a1e-44e6-9579-4ed288fdb995	JUMBO FLOW MINI X10UNID BLANCA	7702007057522	t	12500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.210221	2025-10-19 02:29:41.210221
29c9d2f8-9ee9-4716-97b8-d516093ba08a	JUMBO FLOW MINI X10UNID NEGRA	7702007057515	t	12500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.210476	2025-10-19 02:29:41.210476
609ee09b-d80e-43ec-b879-edf3eca866b1	MEDICARE PAÑITOS HUMEDOS 150U	7703252040925	t	12500.00	12200.00	\N	\N	19.00	2025-10-19 02:29:41.210844	2025-10-19 02:29:41.210844
3469d314-0696-4e9e-97b3-8d108da9a0b8	PALOS PALETA PANDA 1000U	7703252011901	t	17400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.211096	2025-10-19 02:29:41.211096
7ae196f5-7173-4f9c-99eb-d215efa76c7a	ESENCIA CANELA LEVAPAN	77087720	t	4900.00	4740.00	\N	\N	19.00	2025-10-19 02:29:41.211322	2025-10-19 02:29:41.211322
4620a1d1-34a5-4fc6-966f-fdc3bd1483c7	SERVILLETA FAMILIA 450U	7702026206956	t	6900.00	6650.00	\N	\N	19.00	2025-10-19 02:29:41.211535	2025-10-19 02:29:41.211535
62a922a5-d200-4d60-9bfc-3680daa9229c	INVISIBLE CLASICA -5 DIARIO NOSOTRAS	7702026175948	t	4600.00	4480.00	\N	\N	0.00	2025-10-19 02:29:41.21191	2025-10-19 02:29:41.21191
b4ffc4a1-4cee-47a7-8e4e-513d78b3795f	SALTIN NOEL 8 TACOS	7702025150830	t	10500.00	10200.00	\N	\N	19.00	2025-10-19 02:29:41.212474	2025-10-19 02:29:41.212474
edaaf3f2-c6a4-48b9-8ea4-da11ae313c14	CHANTILLY CORDILLERA 1K	7702007075533	t	63500.00	62400.00	\N	\N	19.00	2025-10-19 02:29:41.213039	2025-10-19 02:29:41.213039
4ffdf75d-645a-44a5-9d1b-206e49dbe360	MAIZ DULCE ZENU 425GR	7701101358146	t	9700.00	9400.00	\N	\N	19.00	2025-10-19 02:29:41.21331	2025-10-19 02:29:41.21331
8a908c41-1a85-4e5c-bbac-a6ad1b33ff33	TRULULU MASMELO FRESA	7702993035238	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.213666	2025-10-19 02:29:41.213666
088ce4ec-adc8-4f09-bb37-0a307ed7e1f9	TRULULU LADRILLOS	7702993042410	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.213892	2025-10-19 02:29:41.213892
37eb91e6-a07e-4077-8d82-796d4c701447	AJIACO MAGGI	7702024796169	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.214207	2025-10-19 02:29:41.214207
d741af1d-5037-47e2-b589-1f235c9286f0	COMINO SASONES 50S	7702354030414	t	2300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.214429	2025-10-19 02:29:41.214429
631afa7a-5200-4745-ae6e-28cdce8e440f	PANELISTA 22G	7702354951573	t	900.00	891.00	\N	\N	19.00	2025-10-19 02:29:41.214832	2025-10-19 02:29:41.214832
912bb5b4-f751-4561-a32f-fa40fdc1753e	DOÑA GALLINA 48CUBOS	7702354949785	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.215142	2025-10-19 02:29:41.215142
a3eaec77-ab8b-49b4-b968-9c630f7c37e1	TRISASON 70GR SASONES	7702354024260	t	1600.00	1490.00	\N	\N	19.00	2025-10-19 02:29:41.215553	2025-10-19 02:29:41.215553
b3415b2e-9565-4d9e-bcfa-49fd6f3f2218	DOÑA GALLINA 200CUBOS TAZA	7702354949815	t	63000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.215919	2025-10-19 02:29:41.215919
753dcc61-f87a-4ef6-85b1-656743d417d0	RICOSTILLA 60 CUBOS	7702354949556	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.216193	2025-10-19 02:29:41.216193
6e29ccdc-1a28-46ea-9cc5-0eaffd67b936	CALDO COSTILLA MAGGI 54 CUBOS	7702024462767	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.216453	2025-10-19 02:29:41.216453
56b85da7-fd9c-4aee-9c6c-6c3f0625c1ca	CALDY COSTILLA 60CUBOS	7707359310721	t	19200.00	18700.00	\N	\N	19.00	2025-10-19 02:29:41.216992	2025-10-19 02:29:41.216992
c3c4fed7-02d0-479a-8882-f5ad4d790353	ATUN SOBERANA AJI LOMITO	7862910032389	t	6000.00	5870.00	\N	\N	19.00	2025-10-19 02:29:41.217874	2025-10-19 02:29:41.217874
115da665-544e-40fb-af66-d4b99e851f2e	ATUN SOBERANA LIMON	7862910032372	t	5900.00	5700.00	\N	\N	19.00	2025-10-19 02:29:41.218554	2025-10-19 02:29:41.218554
f3e4a598-97b3-4d97-b163-3bedc261e9fb	FRIJOLES ENLATADOS 320GR	1009004018720	t	3700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.219233	2025-10-19 02:29:41.219233
0816960b-e321-4f1f-9a11-ed52fc84599c	FRUTIÑO LIMON	7702354949396	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:41.219545	2025-10-19 02:29:41.219545
0e1d29cc-5d5a-4ac2-af45-fac04f7ce212	FRUTIÑO MORA DULCE	7702354948467	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:41.220028	2025-10-19 02:29:41.220028
be23f2d2-47c8-4f47-85c8-12dfc7d632cb	SUNTEA LULO	7702354948351	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:41.220331	2025-10-19 02:29:41.220331
80be3cc2-4aeb-4955-83be-3d9919785ace	RICOSTILLA X240 UNIDADES	7702354949563	t	80000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.22061	2025-10-19 02:29:41.22061
55fe8960-201a-4d2d-ad89-c0db806358ce	JAMONETA ZENU 180GR	7701101241042	t	7400.00	7200.00	\N	\N	19.00	2025-10-19 02:29:41.220963	2025-10-19 02:29:41.220963
ccd86712-d77a-4048-a072-37efce5f566b	SARDINA BJ TOMATE  425GR	7709129553185	t	5900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.221272	2025-10-19 02:29:41.221272
149a4723-71d4-426f-b640-10d93f2be573	SARDINA CALIDA ACEITE 425GR	7709747005936	t	6200.00	6000.00	\N	\N	19.00	2025-10-19 02:29:41.221634	2025-10-19 02:29:41.221634
ac78c1a7-6758-411e-ba7c-630d10a10e36	SALCHICHA VIENA POLLO ZENU 150GR	7701101240991	t	5100.00	4900.00	\N	\N	19.00	2025-10-19 02:29:41.221942	2025-10-19 02:29:41.221942
194a8b37-77ca-4559-9b5c-0fffdfa3be71	DIABLITO UNDER WOOD 54GR	7591072000027	t	4600.00	4500.00	\N	\N	19.00	2025-10-19 02:29:41.222249	2025-10-19 02:29:41.222249
949a24ad-465c-4d00-bad6-f5a777556aac	SALMON LA ESPAÑOLA TOMATE 155GR	7866640700952	t	3800.00	3650.00	\N	\N	19.00	2025-10-19 02:29:41.222565	2025-10-19 02:29:41.222565
857dbcf9-8617-4925-b269-8c895fe7c8cd	CARNE DE DIABLO 80GR	7701101240007	t	5600.00	5600.00	\N	\N	19.00	2025-10-19 02:29:41.223075	2025-10-19 02:29:41.223075
c0f4f64e-def6-41a1-8db9-2fff6eb212ce	CEBOLLITAS EN VINAGRE 250GR	7702312110011	t	4700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.223586	2025-10-19 02:29:41.223586
c97c3497-7754-4208-ba51-f4331cd7168b	SALMON CATALINA TOMATE	7862119500344	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.223992	2025-10-19 02:29:41.223992
0ce62d2d-f9d2-4ec1-ad5b-8d9c0459e28b	4163	456	t	35.00	\N	\N	\N	19.00	2025-10-19 02:29:41.224447	2025-10-19 02:29:41.224447
deea6b70-e17f-4698-b188-d3bff9f484c1	ATUN LUHOMAR LOMO ACEITE	7709747005905	t	4000.00	3850.00	\N	\N	19.00	2025-10-19 02:29:41.224889	2025-10-19 02:29:41.224889
2306af41-209b-4088-8fb5-1bf2e38842e2	AVENA EXTRA SEÑORA HOJUELAS 1.000GR	7708345181165	t	5800.00	5600.00	\N	\N	5.00	2025-10-19 02:29:41.225301	2025-10-19 02:29:41.225301
2b568729-4875-4d45-8173-3cb27f0bd7f3	AVENA EXTRA SEÑORA MOLIDA 200GR	7708345181127	t	1400.00	1300.00	\N	\N	5.00	2025-10-19 02:29:41.225616	2025-10-19 02:29:41.225616
7564ca8b-81ec-4873-b8d7-52431c25b6f3	7 CEREALES EXTRA SEÑORA 200GR	7708345181301	t	1900.00	1800.00	\N	\N	5.00	2025-10-19 02:29:41.225953	2025-10-19 02:29:41.225953
ee2d29fa-2f09-46fe-b8b8-80c0682cd346	CARVE PROTEINA VEGETAL SOYA 165GR	7702025120000	t	5300.00	5100.00	\N	\N	19.00	2025-10-19 02:29:41.226389	2025-10-19 02:29:41.226389
9178b602-8717-4f87-8b98-2883ec3b2653	7 CEREALES EXTRA SEÑORA X12UNIDADES 720GR	7708345181059	t	8700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.226946	2025-10-19 02:29:41.226946
3e8231d7-c2b3-4226-bc69-a9e5f84082ad	ALBA DEL FONCE 250GR	7707185810136	t	4100.00	3950.00	\N	\N	5.00	2025-10-19 02:29:41.227395	2025-10-19 02:29:41.227395
2ef1dd25-5b9e-4633-91c8-973cb51e74a4	ALBA DEL FONCE CHOCOLATE 250GR	7707185810129	t	4100.00	3950.00	\N	\N	5.00	2025-10-19 02:29:41.227646	2025-10-19 02:29:41.227646
fe4a4625-f052-4f80-bf02-68287aca1523	AUNT JEMIMA 100GR	7702193424016	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:41.228123	2025-10-19 02:29:41.228123
46b81720-838d-4027-a555-c1d477d1623b	AUNT JEMIMA 250GR	7702193424023	t	6300.00	6100.00	\N	\N	19.00	2025-10-19 02:29:41.228521	2025-10-19 02:29:41.228521
7e4e4aca-1765-4d53-adba-6a8a7e726666	COLCAFE CAPPUCCINO VAINILLA 200GR	7702032116065	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.229106	2025-10-19 02:29:41.229106
db799202-8b92-4575-a8c4-d3d037a1b9fc	COLCAFE CLASICO 170GR	7702032253111	t	23300.00	22850.00	\N	\N	5.00	2025-10-19 02:29:41.229401	2025-10-19 02:29:41.229401
a03a4619-192f-4831-b261-fdb7c2ee1037	CHOCOLATE AROMA 500GR	7702088152123	t	8400.00	8100.00	\N	\N	5.00	2025-10-19 02:29:41.22987	2025-10-19 02:29:41.22987
8db0d902-4b39-47e7-9e8d-b8cafdee2531	MAIZENA AREQUIPE 28GR	7702047040034	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.230194	2025-10-19 02:29:41.230194
ec3a8078-c6ef-4c1d-bf57-4a0f78a92424	CHOCOLISTO FRESA 200GR	7702007023824	t	7500.00	7200.00	\N	\N	19.00	2025-10-19 02:29:41.230615	2025-10-19 02:29:41.230615
278afebc-ad55-4a79-94f0-f1ddd70584a7	COLCAFE VAINILLA 50GR	7702032253074	t	8500.00	8270.00	\N	\N	5.00	2025-10-19 02:29:41.231089	2025-10-19 02:29:41.231089
cbc109d5-4c17-4433-914d-27b74feee17b	COLCAFE CARAMELO 50GR	7702032253678	t	10400.00	10000.00	\N	\N	5.00	2025-10-19 02:29:41.23166	2025-10-19 02:29:41.23166
23f0a72a-60c2-4821-b808-5c0561fc8fee	AVENA INSTANTANEA EXTRA SEÑORA MORA  400GR	7708345181271	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:41.232263	2025-10-19 02:29:41.232263
2c029378-2a67-404d-bf1d-0265a77394cf	CHOCOLATE CORONA TRADICIONAL 500GR	7702007067699	t	14600.00	14300.00	\N	\N	5.00	2025-10-19 02:29:41.232569	2025-10-19 02:29:41.232569
4f6cd660-7d33-4ce1-af5b-43f8b1669a96	CHOCOLISTO TARRO 1.100GR	7702007063455	t	24000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.232965	2025-10-19 02:29:41.232965
9f2ab51c-8523-4f69-a03e-59acf0232251	COLCAFE CLASICO DOY PACK 85GR	7702032109005	t	9000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.233286	2025-10-19 02:29:41.233286
0e1b6c0d-78e0-4e01-bdd9-6ffeee0a8bf9	CHOCOLISTO CHOCOLISTO FRESA 1050GR	7702007064506	t	33500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.233618	2025-10-19 02:29:41.233618
5bcc58f7-d9e2-4af5-9755-a3eb0d3d7873	CORONA FLASH 950GR	7702007051438	t	28000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.234513	2025-10-19 02:29:41.234513
1f39da71-4d78-421c-bfce-83d00f5c982d	CHOCOLATE CORONA CLASICO TAZAX18 UNIDADES	7702007060522	t	13900.00	\N	\N	\N	5.00	2025-10-19 02:29:41.235104	2025-10-19 02:29:41.235104
222348f5-1943-4c49-9cd7-550a4a1b4564	CHOCOLATE CORONA CLASICO 112GR	7702007074390	t	3900.00	3800.00	\N	\N	5.00	2025-10-19 02:29:41.23564	2025-10-19 02:29:41.23564
114d6133-6024-449c-b1e9-a4635f084a68	NESCAFE DOLCA  DOY PACK 47GR	7702024666530	t	5700.00	\N	\N	\N	5.00	2025-10-19 02:29:41.236036	2025-10-19 02:29:41.236036
4d5f716a-13e0-47fc-bd24-e8a312bc1bbe	NESCAFE DOLCA DOY PACK 73GR	7702024262343	t	7300.00	\N	\N	\N	5.00	2025-10-19 02:29:41.236428	2025-10-19 02:29:41.236428
789eb7bd-b27d-4c8d-8c79-f8e86f841456	MAYONESA LA CONSTANCIA 150GR	7702097135612	t	1800.00	1720.00	\N	\N	19.00	2025-10-19 02:29:41.236986	2025-10-19 02:29:41.236986
02ac147e-4edf-4299-b7fa-34ac54151a34	NESCAFE DOLCA DOY PACK 170GR	7702024934523	t	18000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.23731	2025-10-19 02:29:41.23731
05f9eb09-1307-408e-9527-4d5376d24450	MAYONESA IDEAL GALON	7708969766052	t	23200.00	22700.00	\N	\N	19.00	2025-10-19 02:29:41.237743	2025-10-19 02:29:41.237743
d4709d5b-af79-4606-b097-0f596afc182d	CAFE SELLO ROJO 850GR	7702032113781	t	26000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.238099	2025-10-19 02:29:41.238099
0dccc6e9-dda4-4081-b66b-de56db06706c	SALSA DE TOMATE IDEAL 4KG	7708969766038	t	28400.00	27900.00	\N	\N	19.00	2025-10-19 02:29:41.238406	2025-10-19 02:29:41.238406
3f5bf2d2-fa53-417b-9f7f-7b7c195bff9e	SALSA CON PIÑA OCAÑERITA 1000GR	7709025282455	t	5800.00	5700.00	\N	\N	19.00	2025-10-19 02:29:41.238877	2025-10-19 02:29:41.238877
474d5705-40ac-4a70-af17-b3a0fc7b2284	MOSTANEZA LA CONSTANCIA 150GR	7702097163462	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.239357	2025-10-19 02:29:41.239357
f1266f34-f9a1-4ff7-9f23-b272b7385cca	PAPAS KRUMER 150GR	7709990329933	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.239883	2025-10-19 02:29:41.239883
5f8e0a09-39e0-4867-8d95-93e3002d09c9	MOSTAZA OCAÑERITA 1000GR	7709025282486	t	5800.00	5650.00	\N	\N	19.00	2025-10-19 02:29:41.240233	2025-10-19 02:29:41.240233
76d23aad-9d16-414b-b452-7375ffa88bb3	SALSA TOMATE SAN HORGE 85GR	7702014786576	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.240532	2025-10-19 02:29:41.240532
f8def740-9ed0-458f-ba85-991f424d06e4	PAPAS FRITAS CHILOÉ 1.000GR	7709852187121	t	8500.00	8200.00	\N	\N	19.00	2025-10-19 02:29:41.240829	2025-10-19 02:29:41.240829
f93a6d42-a346-4e73-9c08-0b05498fd2e2	TARTARA LA CONSTANCIA 150GR	7702097163479	t	3300.00	3150.00	\N	\N	19.00	2025-10-19 02:29:41.241089	2025-10-19 02:29:41.241089
26bdc7a5-b3b5-48c1-a7a8-55aa5cac7f2d	SALSA NEGRA NORSAN 165GR	7709834109233	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.24152	2025-10-19 02:29:41.24152
7562df1c-3242-4904-899f-6cb616aad44e	SALSA MAIZ NATUCAMPO 400GR	7709269864141	t	9400.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.241996	2025-10-19 02:29:41.241996
2aa228a3-1665-4374-9328-95aac35b30fc	SALSA PARA CARNE BARY PROFESIONAL 1.275GR	7702439008819	t	10300.00	10000.00	\N	\N	19.00	2025-10-19 02:29:41.242438	2025-10-19 02:29:41.242438
8a424cc2-f01a-4847-9dbf-c829b7cca0f5	SALSA CHINA BARY PROFESIONAL 1.160ML	7702439008857	t	8500.00	8200.00	\N	\N	19.00	2025-10-19 02:29:41.242789	2025-10-19 02:29:41.242789
d861c01a-2c5e-4e35-959a-aa8f7b14171f	SALSA NEGRA LA CONSTANCIA SOY PACK 100ML	7702097138743	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:41.243337	2025-10-19 02:29:41.243337
f38b131d-b87f-43fe-93d1-5474debfd5e9	SALSA  DE SOYA LA CONSTANCIA DOY PACK 100ML	7702097138736	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.243782	2025-10-19 02:29:41.243782
7d65965c-a94a-42b4-b0a0-08b36b4b1d5b	AJI PICANTE LA CONSTANCIA 100GR	7702097031327	t	3900.00	3750.00	\N	\N	19.00	2025-10-19 02:29:41.244178	2025-10-19 02:29:41.244178
8e46975d-d473-425b-9841-66fc4a9fc836	GUSTOSITA ESPARCIBLE X4 UNID 500GR	7702028021632	t	6100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.244541	2025-10-19 02:29:41.244541
26cb7759-b6b8-4bb2-9b86-08bbee066b16	SABRINA ESPARCIBLE X4 UNID 500GR	7702028021670	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.244849	2025-10-19 02:29:41.244849
e254c801-c74c-4599-a096-26b6f1b624ae	MARGARINA LA BUENA X4UNID 500GR	7702109012139	t	9700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.245191	2025-10-19 02:29:41.245191
d978e374-330c-4ee1-b164-4db700c7832b	MAYONESA BARY 160GR	7702439598068	t	2700.00	2560.00	\N	\N	19.00	2025-10-19 02:29:41.245523	2025-10-19 02:29:41.245523
47c03f02-d541-4e38-9099-1afb5f81f073	LA BUENA ESPARCIBLE X4UNID 500GR	7702116000273	t	10400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.245892	2025-10-19 02:29:41.245892
8d7a4380-a9a9-45fb-945b-a89d350a1304	SALSA ROSADA LA CONSTANCIA 150GR	7702097163448	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:41.246554	2025-10-19 02:29:41.246554
53c72f73-3338-4a47-8cec-784d16433a78	LA BUENA ESPARCIBLE 125GR	7702116000280	t	2300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.246955	2025-10-19 02:29:41.246955
2735e280-23e6-4ee8-b9d1-eca06c585499	SALSA BBQ LA CONSTANCIA 150GR	7702097163455	t	2600.00	2470.00	\N	\N	19.00	2025-10-19 02:29:41.247401	2025-10-19 02:29:41.247401
236e7468-f905-41df-90ba-71843c1963a9	LOLITA ESPARCIBLE X4UNID 500GR	7702109019596	t	6700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.247674	2025-10-19 02:29:41.247674
2e2fb62e-35e6-4d80-84fe-98d2cbbd505e	LOLITA ESPARCIBLE 125GR	7702109019589	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.247942	2025-10-19 02:29:41.247942
7ebaa604-e44a-427c-820c-4db5aaa63dc4	MARGARINA NORSAN 400GR	7708931164466	t	5200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.248206	2025-10-19 02:29:41.248206
8375df14-9460-493e-b753-5e70e0961961	MARGARINA NORSAN 600GR	7709633128725	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.248462	2025-10-19 02:29:41.248462
5f648ab9-234e-48b4-9373-8ad2c3643ab7	MARGARINA NORSAN 200GR	7709433578041	t	3800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.248976	2025-10-19 02:29:41.248976
79296f01-10ad-4fb2-9416-a1016814f779	CAMPI CON SAL X5 UNID 625GR	7702109011958	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.249255	2025-10-19 02:29:41.249255
be810c31-9897-4860-b455-e631e843c65c	SALSA DE SOYA IDEAL185ML	7709747919035	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.24958	2025-10-19 02:29:41.24958
7e224a88-86ad-4b95-9ae9-4ad7fb8d60c0	ACEITE OLIVA GOURMET500ML	7702109014836	t	45500.00	44700.00	\N	\N	19.00	2025-10-19 02:29:41.249841	2025-10-19 02:29:41.249841
c7131889-0fa5-4e5d-b964-3d7da19fcd5b	FRITURA MANTECA 100GR	7702028014108	t	13900.00	13500.00	\N	\N	19.00	2025-10-19 02:29:41.250443	2025-10-19 02:29:41.250443
a830dce5-1f06-427f-adb8-cbdf85257379	ACEITE GOURMET 250ML	7702109012115	t	3700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.251214	2025-10-19 02:29:41.251214
7fde1044-879d-4a27-b33c-ecbc355bf9d8	VINAGRE ROJO CORONA 500ML	7707265950943	t	1200.00	1100.00	\N	\N	19.00	2025-10-19 02:29:41.251599	2025-10-19 02:29:41.251599
8e6c4b33-41ec-49e6-a36b-90c4c9dc4d0c	ACEITE IDEAL 430ML	7709385952838	t	3300.00	3167.00	\N	\N	19.00	2025-10-19 02:29:41.252153	2025-10-19 02:29:41.252153
6390e1b3-df88-44b2-b5a1-fe980c54460c	SALSA CON AJI NORSAN 160GR	7709990793611	t	1800.00	1670.00	\N	\N	19.00	2025-10-19 02:29:41.252478	2025-10-19 02:29:41.252478
d6477545-8d47-419f-be8d-7e7eb1ad1c25	ACEITE SOYA REYES 1000ML	7708162674673	t	6600.00	6250.00	\N	\N	19.00	2025-10-19 02:29:41.252818	2025-10-19 02:29:41.252818
4e4c14c8-4722-44df-afe3-20191db20ad8	VINAGRE BLANCO 500CC	7709913154352	t	1000.00	900.00	\N	\N	19.00	2025-10-19 02:29:41.253182	2025-10-19 02:29:41.253182
47df5a7c-d803-45c9-a88b-391c6330dbaf	ACEITE OLIVA GOURMET 250GR	7702109014829	t	24500.00	24100.00	\N	\N	19.00	2025-10-19 02:29:41.253466	2025-10-19 02:29:41.253466
3f63b551-f09d-4e1a-b6c3-061cd0c4cf67	SALSA INGLESA NORSAN 165GR	7709834109257	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.253732	2025-10-19 02:29:41.253732
a2e3bb68-1ea8-4366-bf14-17b0b0433991	ACEITE OLEOCALI 1000ML	7701018005133	t	8000.00	7667.00	\N	\N	19.00	2025-10-19 02:29:41.253998	2025-10-19 02:29:41.253998
6c461b65-0451-444e-870a-93bfc6fe0634	SALSA CHINA NORSAN 165GR	7709834109202	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.254285	2025-10-19 02:29:41.254285
44134a10-b32f-44b8-ba59-4cfcec9f772e	SALSA CON SABOR A HUMO BARY 155ML	7702439006228	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.254575	2025-10-19 02:29:41.254575
9bbd279e-7327-412c-a75d-2385317635c8	ACEITE GOURMET FAMILIA 900ML	7702141966568	t	23000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.255113	2025-10-19 02:29:41.255113
8b163ea5-cc11-4384-9a1d-5e99e19e629b	SALSA INGLESA BARY 155ML	7702439003067	t	3400.00	3250.00	\N	\N	19.00	2025-10-19 02:29:41.255621	2025-10-19 02:29:41.255621
32dd7801-f36f-49dd-8f16-64a611e6cf09	ACEITE GOURMEY FRITOS 900ML	7702141509918	t	13000.00	12500.00	\N	\N	19.00	2025-10-19 02:29:41.255936	2025-10-19 02:29:41.255936
8b672490-60e6-413c-8b79-2ba5587c533d	SALSA PARA CARNES BARY 175GR	7702439002794	t	3900.00	3750.00	\N	\N	19.00	2025-10-19 02:29:41.256206	2025-10-19 02:29:41.256206
b89ecfda-a56f-4066-b14b-cd72c9f93f6c	MANTECA FRIDA 250GR	7701018004334	t	2300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.25647	2025-10-19 02:29:41.25647
2ba92905-6888-42e9-b831-037952e6ec2c	MANTECA BUCARO 250GR	7706649289129	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:41.25675	2025-10-19 02:29:41.25675
d8532a6d-8088-46a6-a785-8e7d204d855c	SALSA SOYA BARY 155ML	7702439001490	t	3000.00	2870.00	\N	\N	19.00	2025-10-19 02:29:41.257061	2025-10-19 02:29:41.257061
a59fbdda-8e72-465f-84d6-35127a9c6787	VINAGRE 3000CC	7709844868687	t	3800.00	3600.00	\N	\N	19.00	2025-10-19 02:29:41.25739	2025-10-19 02:29:41.25739
762fc951-eece-4988-8d27-bf331f8cf4d0	7 GRANOS 500GR	741	t	2000.00	1900.00	\N	\N	5.00	2025-10-19 02:29:41.257843	2025-10-19 02:29:41.257843
19c30d5c-ae44-4c63-a9c6-0ff12466c901	CUCHUCO DE MAIZ 500GR	852	t	2000.00	1900.00	\N	\N	5.00	2025-10-19 02:29:41.25838	2025-10-19 02:29:41.25838
5f69a31b-8982-48a3-8c43-700e42df4fd2	CUCHUCO DE MAIZ 500GR	963	t	2000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.258793	2025-10-19 02:29:41.258793
13266b59-f8c4-454d-bbb0-cd2544ab0651	HARINA DE TOSTADO 250GR	520	t	1000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.259141	2025-10-19 02:29:41.259141
b85df989-3f4c-4a31-a720-4ab1ed338a2f	HARINA DE CRUDO 250GR	630	t	1000.00	900.00	\N	\N	5.00	2025-10-19 02:29:41.259409	2025-10-19 02:29:41.259409
c60367d4-8639-46fd-8efc-62277f6582f5	CUCHUCO DE CEBADADA 500GR	7596	t	2000.00	1900.00	\N	\N	5.00	2025-10-19 02:29:41.259668	2025-10-19 02:29:41.259668
69783fc7-8ea2-4e57-b61b-311a9dc3207c	HARINA DE CRUDO 250GR	5489	t	1000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.259954	2025-10-19 02:29:41.259954
ea6eb5b8-7bb1-4216-8b53-c6389b74775f	SEMILLA GIRASOL 500GR	606110323659	t	4400.00	4260.00	\N	\N	19.00	2025-10-19 02:29:41.260267	2025-10-19 02:29:41.260267
ebd34892-e39f-43da-afc5-7296e143d18c	MIRRINGO ADULTO 500GR	7703090433927	t	5400.00	5250.00	\N	\N	5.00	2025-10-19 02:29:41.260681	2025-10-19 02:29:41.260681
a287fd7c-a41f-4745-bf41-35b71e8238a3	CEBADA PERLADA 250GR	7709668923395	t	1200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.261094	2025-10-19 02:29:41.261094
7bd96944-6e36-4a01-8319-9bea10c55d83	MIRRINGO GATICOS 500GR	7703090257684	t	5600.00	5400.00	\N	\N	5.00	2025-10-19 02:29:41.261603	2025-10-19 02:29:41.261603
adce523d-5b74-41aa-a3d4-ff46792d8c5e	LENTEJA GRANOS RINCON 500GR	7709062917167	t	3300.00	3200.00	\N	\N	0.00	2025-10-19 02:29:41.2619	2025-10-19 02:29:41.2619
3c0e67c0-853e-4c12-a8e8-c399ed19abed	CARAOTA GRANOS RINCON 500GR	7709062917181	t	3100.00	3000.00	\N	\N	0.00	2025-10-19 02:29:41.262303	2025-10-19 02:29:41.262303
e1868c6a-e6cf-42a8-9a49-6edb3116ca64	FRIJOL  GRANOS RINCON 500GR	7709668923357	t	4700.00	4500.00	\N	\N	0.00	2025-10-19 02:29:41.262741	2025-10-19 02:29:41.262741
370699cb-00ac-4517-99ed-029dc6eefbea	ARROCILLO GRANOS RINCON 500GR	606110859981	t	1400.00	1300.00	\N	\N	0.00	2025-10-19 02:29:41.263012	2025-10-19 02:29:41.263012
2d2d7ba3-aa5c-485d-b2c8-b3bfae8f064e	GARBANZO SUDESPENSA 500GR	7707309250039	t	3400.00	3250.00	\N	\N	0.00	2025-10-19 02:29:41.263283	2025-10-19 02:29:41.263283
9049e113-6a9d-4a85-b2d9-eac86ac68702	MAIZ PIRA GRANOS RINCON 500GR	7709062917198	t	2200.00	2100.00	\N	\N	0.00	2025-10-19 02:29:41.263627	2025-10-19 02:29:41.263627
026d3e64-b1a4-477b-819c-8f876c4d0944	ARVEJA AMARILLA GRANOS RINCON 500GR	7709668923319	t	2100.00	1980.00	\N	\N	0.00	2025-10-19 02:29:41.264097	2025-10-19 02:29:41.264097
a3d0d275-81ff-438d-8bf9-4de147bb4094	MAIZ PILADO GRANOS RINCON 500GR	7709668923388	t	1700.00	1600.00	\N	\N	0.00	2025-10-19 02:29:41.264573	2025-10-19 02:29:41.264573
163c2ab9-bc42-4fd0-b047-d38c30954a85	ALPISTE GRANOS RINCON 500GR	606110859974	t	3200.00	\N	\N	\N	5.00	2025-10-19 02:29:41.264951	2025-10-19 02:29:41.264951
3b6bfaaf-e091-4523-afd2-99948baaf75c	SPAGHETTI MARYPAS 1.000GR	7707047400116	t	4300.00	4167.00	\N	\N	5.00	2025-10-19 02:29:41.265243	2025-10-19 02:29:41.265243
d69cca80-a144-4b44-88cf-060f96107a56	SPAGHETTI COMARRICO 400GR	7702085003657	t	2800.00	2700.00	\N	\N	5.00	2025-10-19 02:29:41.265641	2025-10-19 02:29:41.265641
03ceb703-1874-43f5-989c-73cd60a01509	CHEETOS BOLIQUESO 12U	7702189052346	t	13200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.265907	2025-10-19 02:29:41.265907
d34a7543-185c-4daa-949f-a2e944f2b626	BOLIQUESO UND	7702189051820	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.266258	2025-10-19 02:29:41.266258
3b9a287f-c5e9-43e6-b4ad-9167d5680ba3	FIDEO COMARRICO 400GR	7702085003664	t	2800.00	2700.00	\N	\N	5.00	2025-10-19 02:29:41.266759	2025-10-19 02:29:41.266759
c935206f-ba94-43f0-a5a9-f51ac8bf16e4	FIDEOS DIANA 250GR	7707166100034	t	1900.00	1800.00	\N	\N	5.00	2025-10-19 02:29:41.267077	2025-10-19 02:29:41.267077
41a741f7-e465-4441-8f05-46ed50d2f23f	CHICHARRON EXPRESS 10U	7706642009069	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.267918	2025-10-19 02:29:41.267918
10ca0226-888f-4579-aad2-0e4d12e74fd5	CHICHARRON EXPRESS UND	7706642008062	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.268229	2025-10-19 02:29:41.268229
ca59a642-7f1a-43ca-8bbe-6f378d7d16a4	CHICHARRON AMERICANOS 20GR	7700634001086	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.268622	2025-10-19 02:29:41.268622
9947099a-fce7-4803-8f29-7e7a3a943239	CODO MARYPAS 1.000GR	7707047401137	t	4300.00	4167.00	\N	\N	5.00	2025-10-19 02:29:41.268945	2025-10-19 02:29:41.268945
e91318fa-8148-4de4-8ac4-786fb807d2e9	SUPER RICAS PAPA LIMON 12U	7702152015309	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.269455	2025-10-19 02:29:41.269455
44196e76-1588-4836-beaa-617ff6f9e086	FULMINANTE MARYPAS 1.000GR	7707047470881	t	4300.00	4167.00	\N	\N	5.00	2025-10-19 02:29:41.269997	2025-10-19 02:29:41.269997
190e47a1-8fd5-4a7a-bc51-0af13d56ad40	PAPA LIMON SUPER RICA	7702152005300	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.270388	2025-10-19 02:29:41.270388
ba13ea6c-8daf-4fee-9429-64824813a9e6	DETODITO NATURAL 12U	7702189039422	t	29800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.27067	2025-10-19 02:29:41.27067
8ac29d41-7123-4bc2-8b55-3c7c8273becb	BUCATINI LA MUÑECA 250GR	7702020112253	t	1900.00	1790.00	\N	\N	5.00	2025-10-19 02:29:41.271029	2025-10-19 02:29:41.271029
d98c5318-3afc-44fc-8266-8d2d31272f24	DETODITO UNIDAD	7702189019707	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.271611	2025-10-19 02:29:41.271611
65e3815e-400f-47e9-9cc8-3a7ba4f400ea	CODO LA MUÑECA 250GR	7702020112093	t	1900.00	1790.00	\N	\N	5.00	2025-10-19 02:29:41.272241	2025-10-19 02:29:41.272241
8a10d75a-7b7a-4446-a40b-e05de1cb7e5f	PAPA NATURAL SUPER RICAS 12U	7702152012018	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.27261	2025-10-19 02:29:41.27261
2edf0d50-621b-471b-8b39-bd4b845336b4	RIGATONE LA MUÑECA 250GR	7702020112147	t	1900.00	1790.00	\N	\N	5.00	2025-10-19 02:29:41.273059	2025-10-19 02:29:41.273059
6a163df7-be5a-4f44-bbc3-196f67c967c1	FIDEO LA MUÑECA 250GR	7702020112185	t	1900.00	1790.00	\N	\N	5.00	2025-10-19 02:29:41.273545	2025-10-19 02:29:41.273545
68ce226a-c1c6-4297-81fa-108a120561c4	PAPA SUPER RICA UND	7702152002095	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.274023	2025-10-19 02:29:41.274023
a23a69a3-f2cd-4b73-a01b-233eabcf7f12	TORNILLO LA MUÑECA 250GR	7702020112154	t	1900.00	1790.00	\N	\N	5.00	2025-10-19 02:29:41.274374	2025-10-19 02:29:41.274374
a5eb2c80-c708-4755-9c4c-f360c4f52005	MACARROCITO LA MUÑECA 2500GR	7702020112161	t	1900.00	1790.00	\N	\N	5.00	2025-10-19 02:29:41.274817	2025-10-19 02:29:41.274817
88b77c56-727d-4dd3-b62d-429183df33ac	PAPA MARGARITA LIMON 12U	7702189000392	t	19400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.275093	2025-10-19 02:29:41.275093
7eced584-4cdc-43fa-9835-f71845dada19	PAPA LIMON MARGARITA	7702189000378	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.275424	2025-10-19 02:29:41.275424
406f4e3a-0837-4d07-ab3a-6a79ba81adea	TOZIMIX 20GR	7700634000782	t	800.00	750.00	\N	\N	19.00	2025-10-19 02:29:41.275837	2025-10-19 02:29:41.275837
9aafe6e4-c502-4e70-be27-d0f6d249abf9	MIXTO NATURAL 40GR	7706642007133	t	1900.00	1857.00	\N	\N	19.00	2025-10-19 02:29:41.276445	2025-10-19 02:29:41.276445
b2920cac-c2ba-4e90-827c-7150041794bf	KIKITOS CARAMELO	7700634002229	t	800.00	750.00	\N	\N	19.00	2025-10-19 02:29:41.276719	2025-10-19 02:29:41.276719
6149392d-38cb-4676-bbeb-9279ba6ff132	LECHE EN POLVO COLANTA 25GR	7702129005227	t	1300.00	1192.00	\N	\N	0.00	2025-10-19 02:29:41.277247	2025-10-19 02:29:41.277247
b4563398-98de-4397-9a5a-6120515ca286	INDULECHE CON VITAMINAS 900GR	7706921000244	t	22000.00	21500.00	\N	\N	0.00	2025-10-19 02:29:41.277524	2025-10-19 02:29:41.277524
232bd42e-0f7a-4026-935f-b7e8c96b9c33	SPAGHETTI MONTICELLO 1.000GR	7702085021736	t	12500.00	\N	\N	\N	5.00	2025-10-19 02:29:41.277976	2025-10-19 02:29:41.277976
69395f19-8ed4-4e9c-bf87-6cdb281d125e	NOVALECHE800GR	7703312400805	t	21500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.27853	2025-10-19 02:29:41.27853
5afd849d-f2d4-4904-81cd-069f734469ad	NOVALECHE 380GR	7703312400782	t	10500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.278966	2025-10-19 02:29:41.278966
963346af-560f-4f4e-b7c1-937870ba4f22	SALSA ROSADA BARY 100GR	7702439644505	t	1800.00	1670.00	\N	\N	19.00	2025-10-19 02:29:41.279591	2025-10-19 02:29:41.279591
5e759b74-d3a1-47c7-9fb6-ebded50a01d7	LECHE KLIM 1 3 1KG	7702024047612	t	49000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.280852	2025-10-19 02:29:41.280852
04f53393-02fe-41cf-bf16-931918c98a09	TORNILLO LA NIEVE 1.000	7707237418952	t	3500.00	3417.00	\N	\N	5.00	2025-10-19 02:29:41.281965	2025-10-19 02:29:41.281965
6c5b43ea-f584-4b1e-923b-1541466a48e7	FIDEOS LA NIEVE 1.000GR	7707237417405	t	3500.00	3417.00	\N	\N	5.00	2025-10-19 02:29:41.282776	2025-10-19 02:29:41.282776
bdb0f0e4-58a2-4c73-8b5f-94b60a2047ea	CONCHA LA NIEVE 1.000GR	7707237418457	t	3500.00	3417.00	\N	\N	5.00	2025-10-19 02:29:41.283673	2025-10-19 02:29:41.283673
12dbba4a-2ddd-4a79-9dcc-88616cdb0a6b	LECHE PARMALAT 900GR	7700604050908	t	26800.00	26300.00	\N	\N	0.00	2025-10-19 02:29:41.284413	2025-10-19 02:29:41.284413
ce9002c3-f84d-4eca-a322-eaf88d9848fa	CONCHAS LA NIEVE 500GR	7707237418402	t	1900.00	1800.00	\N	\N	5.00	2025-10-19 02:29:41.285015	2025-10-19 02:29:41.285015
deca44ff-9c51-492e-a485-d731e4fce2ee	MACARRON DORIA 1.000GR	7702085001615	t	6500.00	6334.00	\N	\N	5.00	2025-10-19 02:29:41.285483	2025-10-19 02:29:41.285483
03624d00-5c64-468a-a375-7b2dcc80ba7e	BABY DREAMS 2X30	7709513647643	t	24000.00	23400.00	\N	\N	19.00	2025-10-19 02:29:41.286142	2025-10-19 02:29:41.286142
8d1c5786-4079-448e-ade3-18f959a7e175	FIDEO LA NIEVE 500GR	7707237417351	t	1900.00	1800.00	\N	\N	5.00	2025-10-19 02:29:41.286733	2025-10-19 02:29:41.286733
558220c4-2487-4628-a8fa-da75f5bf6532	FRESKITICOS 100UNID	7709888659173	t	4800.00	4600.00	\N	\N	19.00	2025-10-19 02:29:41.287326	2025-10-19 02:29:41.287326
71e9361a-b9b7-41a4-8989-76ba43937100	PEQUEÑIN TOALLAS HUMEDAS 24U	7702026313272	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.288034	2025-10-19 02:29:41.288034
ac8fcd96-4d98-4cc5-b65a-200137da8927	HUGGIES TOALLA HUMEDA 16UND	7702425801387	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.288636	2025-10-19 02:29:41.288636
6f0c2906-128e-48ee-850c-976ac4fd00d9	PAÑAL TENA SLIP MX21	7702027479632	t	56000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.289176	2025-10-19 02:29:41.289176
879f1170-fe76-4b0a-81af-fdb2b8c427da	COMBO DORIA X6UNIDAD	7702085015575	t	12500.00	\N	\N	\N	5.00	2025-10-19 02:29:41.289713	2025-10-19 02:29:41.289713
ba8a5d52-fb99-4bdf-a05c-fd11438a29ea	PAÑAL RELY MX20	7709275976715	t	54600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.290762	2025-10-19 02:29:41.290762
9005a8ee-0a85-4266-92bd-2aa5c27f6c1a	PAÑAL TENA SLIP LX30	7702026174644	t	74000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.291449	2025-10-19 02:29:41.291449
0e2f4095-f2f7-4a72-a506-65841bb0d025	ARGOLLITA DORIA 250GR	7702085012307	t	2200.00	2100.00	\N	\N	5.00	2025-10-19 02:29:41.292025	2025-10-19 02:29:41.292025
727b980a-e7ac-4abc-bf3d-233e606a394e	WINNY 1X50	7701021116512	t	38200.00	37700.00	\N	\N	19.00	2025-10-19 02:29:41.292932	2025-10-19 02:29:41.292932
8bec5cb3-d891-4995-b6cc-ec4d9560f16d	WINNY 2X50	7701021116581	t	45200.00	44700.00	\N	\N	19.00	2025-10-19 02:29:41.293492	2025-10-19 02:29:41.293492
ebd86cfa-6b85-4115-9345-01fc5d49bec2	WINNY 3X50	7701021111845	t	54600.00	54100.00	\N	\N	19.00	2025-10-19 02:29:41.294174	2025-10-19 02:29:41.294174
0f70cd7b-b075-4641-abf2-30826d2d84f8	WINNY 4X50	7701021147585	t	65500.00	64900.00	\N	\N	19.00	2025-10-19 02:29:41.294711	2025-10-19 02:29:41.294711
c9525ea7-5c04-4ff6-828d-f465c5d37cae	HUGGIES 3X20	7702425810754	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.295274	2025-10-19 02:29:41.295274
b13c6346-a444-4502-863b-3ff5684a3c52	HUGGIES 4X20	7702425810761	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.295632	2025-10-19 02:29:41.295632
8c25974c-95a3-45e9-9a6b-8e2329bd152c	BABY DREAMS 4X30	7709845007306	t	31700.00	31300.00	\N	\N	19.00	2025-10-19 02:29:41.296007	2025-10-19 02:29:41.296007
8a825012-013d-4068-bd3a-dfc02c67e21e	SEÑORIAL X4 UNIDADES	7707016102126	t	5900.00	5750.00	\N	\N	19.00	2025-10-19 02:29:41.296571	2025-10-19 02:29:41.296571
b74c6532-3aaa-4795-b960-9aa2fd9683ec	PAPEL MIO X4 UNIDADES	7707151604080	t	5700.00	5500.00	\N	\N	19.00	2025-10-19 02:29:41.297159	2025-10-19 02:29:41.297159
63c9166f-1415-4e59-bb9b-a7084094dbf3	BABYSEC 3X100	7709085938491	t	92500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.297489	2025-10-19 02:29:41.297489
59834baa-bacf-445b-8cc2-da7a51f014bf	PAPEL NUBE MEGA X 4UNID	7707151604059	t	7200.00	6900.00	\N	\N	19.00	2025-10-19 02:29:41.297776	2025-10-19 02:29:41.297776
04e2076a-84e2-4154-9072-1279db2965f0	ROSAL PLUS 12UND	7702120012705	t	18200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.298059	2025-10-19 02:29:41.298059
2d57a274-e02d-46b0-926f-cca7879195d4	ELITE ULTRA X6 UNIDADES	7707199342982	t	11600.00	11250.00	\N	\N	19.00	2025-10-19 02:29:41.298477	2025-10-19 02:29:41.298477
c4279095-8667-454f-8537-19425e8a5e9b	ROSAL ULTRACONFORT 12UND	7702120013078	t	15700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.298733	2025-10-19 02:29:41.298733
b61d4946-2917-45b2-8fc4-f44a7c64950b	ROSAL PLUS XXG  X4UNIDADES	7702120014150	t	7600.00	7350.00	\N	\N	19.00	2025-10-19 02:29:41.298978	2025-10-19 02:29:41.298978
3fe8541d-da06-47e7-8649-950a01a512ad	MIO MEGA ROLLO 12UND	7707151604097	t	18400.00	17900.00	\N	\N	19.00	2025-10-19 02:29:41.299217	2025-10-19 02:29:41.299217
16222be5-a070-48a3-a847-d37793e584ef	ROSAL ECO X4UNIDADES	7702120012408	t	6500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.299447	2025-10-19 02:29:41.299447
7fe15ea4-c3be-43be-a9f4-bac5767737fc	SEÑORIAL MEGA ROLLO 12UND	7707016135292	t	15500.00	15200.00	\N	\N	19.00	2025-10-19 02:29:41.299674	2025-10-19 02:29:41.299674
34755822-2af0-4915-a94e-5ac8055b9114	ELITE ULTRA X4 UNIDADES	7707199347000	t	7800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.299936	2025-10-19 02:29:41.299936
8e270579-04a1-4995-9f62-c89b87c0026b	ELITE ULTRA TRIPLE HOJA 12R	7707199345365	t	21700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.300294	2025-10-19 02:29:41.300294
a1d6e219-81fc-4570-8735-819b72687ad1	NUBE MAX 18ROLLOS	7707151604035	t	15800.00	15200.00	\N	\N	19.00	2025-10-19 02:29:41.300571	2025-10-19 02:29:41.300571
efa4d2a8-45a9-43d0-83a3-3cd3e8d4887b	BULTO ELITE DUO ROLLAZO X24	27707199348384	t	44600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.300852	2025-10-19 02:29:41.300852
9b2ee94a-1afa-46f3-a58f-9de1f4bf5c90	SCOTT CUIDADO COMPLETO 4UNID	7702425703636	t	6500.00	6250.00	\N	\N	19.00	2025-10-19 02:29:41.301122	2025-10-19 02:29:41.301122
b67c9a21-426c-4f83-9cae-8fc013d978ed	ELITE DUO AMARILLO	7707199345006	t	1800.00	1730.00	\N	\N	19.00	2025-10-19 02:29:41.301377	2025-10-19 02:29:41.301377
fd047442-7fe9-48c3-ae82-ae32189d89c9	SCOTT RINDE MAX	7702425644724	t	1100.00	984.00	\N	\N	19.00	2025-10-19 02:29:41.301689	2025-10-19 02:29:41.301689
584b632d-81ac-4793-9a75-f8b65ca59806	ROSAL PLUS MEGAROLLLO XXG	7702120012781	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.301976	2025-10-19 02:29:41.301976
5668477b-d334-44cc-92c2-f7d46f8354b7	NOSOTRAS NOSOTRAS PLUS CANAL GEL 10UN	7702026198718	t	3900.00	3750.00	\N	\N	0.00	2025-10-19 02:29:41.302238	2025-10-19 02:29:41.302238
e64da14a-b998-40f9-bb4f-7941ffe4ce12	JABON INTIMO NOSOTRAS 18ML	7702027436987	t	1300.00	1200.00	\N	\N	19.00	2025-10-19 02:29:41.302477	2025-10-19 02:29:41.302477
014bfdd3-e950-4f71-8e3c-5b515c3b7a71	JABON INTIMO NOSOTRAS 18ML	7702026184612	t	1300.00	1200.00	\N	\N	19.00	2025-10-19 02:29:41.302713	2025-10-19 02:29:41.302713
803ef181-23b9-4df1-96ce-c1170d18713e	ELITE MAX	7707199340155	t	1200.00	1094.00	\N	\N	19.00	2025-10-19 02:29:41.302989	2025-10-19 02:29:41.302989
8ccf58bd-915a-422e-94cd-e55343f86896	SEÑORIAL DOBLE HOJAS	7707016152015	t	800.00	688.00	\N	\N	19.00	2025-10-19 02:29:41.303264	2025-10-19 02:29:41.303264
e542daf7-206e-4102-b8a9-cf4190b46a33	PROTECTORES ELLAS 15UND	7702108206768	t	1800.00	1700.00	\N	\N	0.00	2025-10-19 02:29:41.303598	2025-10-19 02:29:41.303598
e4e3d8e1-4531-4aa2-8a49-8e462d5cd7f1	KOTEX PROTECTORES 15	7702425804814	t	2000.00	1900.00	\N	\N	0.00	2025-10-19 02:29:41.303867	2025-10-19 02:29:41.303867
e61990ad-f042-4e6a-a066-f8aae14d3d6f	CAMPESINA 1.000GR	7707032402217	t	2600.00	2500.00	\N	\N	5.00	2025-10-19 02:29:41.304123	2025-10-19 02:29:41.304123
f53d2395-a1b7-4700-ab12-87cba39d9751	SAN MIGUEL LEUDANTE 1.000GR	7707237658419	t	2900.00	2850.00	\N	\N	5.00	2025-10-19 02:29:41.304359	2025-10-19 02:29:41.304359
1bb46986-09fe-4cbc-9b92-19fc81ae6905	NOSOTRAS BUENAS NOCHES 4UND	7702026174323	t	3600.00	3450.00	\N	\N	0.00	2025-10-19 02:29:41.304576	2025-10-19 02:29:41.304576
cdbaf1e5-c40a-4654-922d-7c4445991e0a	SALVADO DE TRIGO 250GR	7707767140439	t	1600.00	1560.00	\N	\N	0.00	2025-10-19 02:29:41.304818	2025-10-19 02:29:41.304818
2a3f4ae7-914b-4cd3-8d56-3e7485dbe0c6	AZUCAR PROVIDENCIA 500GR	7702104010406	t	2000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.305159	2025-10-19 02:29:41.305159
0a38f07b-fb6b-47f0-8c65-31b85f372d2f	HARINA DE TRIGO CORONA TRADICIONAL 500GR	7702007282191	t	2400.00	2300.00	\N	\N	0.00	2025-10-19 02:29:41.305426	2025-10-19 02:29:41.305426
fea9eac5-b351-4b07-bd78-f35722ab63a0	ARROZ SONORA 1.000GR	7700798030229	t	4000.00	3900.00	\N	\N	5.00	2025-10-19 02:29:41.305686	2025-10-19 02:29:41.305686
a1cc88e3-d236-49da-a0ec-84e5bdfd0c07	ARROZ SAMARA 1.000GR	7709531779517	t	3300.00	3240.00	\N	\N	0.00	2025-10-19 02:29:41.305947	2025-10-19 02:29:41.305947
6ca81eb3-994b-499e-97c3-aed88bbd09c8	ARROZ PALACIO VERDE 1.000GR	7709990854244	t	3500.00	3400.00	\N	\N	0.00	2025-10-19 02:29:41.306232	2025-10-19 02:29:41.306232
a792752c-0b95-48ee-a100-615ee6a88965	AREPA LA BLANCA 1.000GR	7709558648292	t	3900.00	3775.00	\N	\N	5.00	2025-10-19 02:29:41.306489	2025-10-19 02:29:41.306489
8725e81c-03ab-4e2e-b70b-796dfa5102bc	ARROZ LONDREZ 1.000GR	781159076473	t	3700.00	3600.00	\N	\N	0.00	2025-10-19 02:29:41.30673	2025-10-19 02:29:41.30673
2d9e264d-26f7-4931-8c0f-146b1c0c9fd0	ARROZ MORA 1.000GR	7709568744380	t	3600.00	3534.00	\N	\N	0.00	2025-10-19 02:29:41.30701	2025-10-19 02:29:41.30701
1c892a71-e27e-4344-b43c-830eb0de11ae	JABON INTIMO HIERVAS 200CM	7702026179663	t	12200.00	11700.00	\N	\N	19.00	2025-10-19 02:29:41.307268	2025-10-19 02:29:41.307268
c6d9e565-1499-4ccf-b133-cd38b4284345	ARROZ ZULIA 10.000GR	7707222290020	t	41000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.307548	2025-10-19 02:29:41.307548
9637fe5a-81d3-4aaf-b10e-aab0ea5963e7	PROTECTORES DIARIOS NOSOTRAS LARGO X80UNID	7702027044090	t	15000.00	14600.00	\N	\N	0.00	2025-10-19 02:29:41.307811	2025-10-19 02:29:41.307811
e5f8b5ca-b707-4689-81d5-f9e61eabd8e0	JUMBO MINI BROWNIE X24 UNID	7702007075229	t	19200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.308137	2025-10-19 02:29:41.308137
a2bfbd10-bdf6-4b63-8596-e1aa532d6704	TRIDENT MORA AZUL 60 UNID	7702133414466	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.308381	2025-10-19 02:29:41.308381
0f30517d-4666-4bd1-a32b-725ca7037ba6	WAFERJET SURTIDA X20UNID	7702007048421	t	36000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.30864	2025-10-19 02:29:41.30864
bfa1e56d-3a3f-4f02-8506-b9ac0af7e21d	TRIDENT OFERTA 70UNID	7702133457715	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.309498	2025-10-19 02:29:41.309498
36f81c30-ac29-422c-aa5c-3ce9fa90d891	HUEVOS SORPRESAS X12UNID	7709779816531	t	28500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.309833	2025-10-19 02:29:41.309833
030cb24e-89c6-4b9e-967f-47472ba24a30	PANELITAS X40UNID	7709471822519	t	5800.00	\N	\N	\N	0.00	2025-10-19 02:29:41.310114	2025-10-19 02:29:41.310114
786c17dc-18d5-48dc-8f78-9814e9a28435	DERSA VINAGRE 500GR	7702166004559	t	4700.00	4580.00	\N	\N	19.00	2025-10-19 02:29:41.310509	2025-10-19 02:29:41.310509
a6d2b68a-2888-42be-af11-e8204c860915	KINDER JOY X12 UNID	7708965796947	t	76000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.310765	2025-10-19 02:29:41.310765
faa7d85f-3313-44ec-a3b6-fc47a2abec3e	JUMBO MIX X12 UNID	7702007009910	t	55000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.311047	2025-10-19 02:29:41.311047
e1324d17-fb70-4a83-a708-0f77b36dc219	DERSA VINAGRE KILO	7702166004542	t	8500.00	8360.00	\N	\N	19.00	2025-10-19 02:29:41.311301	2025-10-19 02:29:41.311301
8b667bcb-feec-4b5c-a218-83525df20f4e	JUMBO FLOW BLANCA X12 48GR	7702007039726	t	40500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.311585	2025-10-19 02:29:41.311585
72dd24b6-9910-486d-9c07-c1acf9f0a5ca	JUMBO FLOW NEGRA X12 48GR	7702007039696	t	40500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.311841	2025-10-19 02:29:41.311841
e50a3277-55f1-4905-8fc9-432b71c109e4	GOL CHOCOLATE X3 UNID	7702007039870	t	3700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.312148	2025-10-19 02:29:41.312148
a554f332-0338-41cd-b1db-f9bf4f412ea2	JUMBO ROSCA X6UNID	7702007069877	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.31238	2025-10-19 02:29:41.31238
c3998e67-121b-44de-becf-5354f3170908	FAB 3KG	7702191162484	t	28000.00	27600.00	\N	\N	19.00	2025-10-19 02:29:41.312611	2025-10-19 02:29:41.312611
b6082aaf-d91f-4f8f-bda3-db139f2a6f52	DERSA PODER DE LA BARRA 1.000GR	7702166041530	t	8500.00	8360.00	\N	\N	19.00	2025-10-19 02:29:41.312849	2025-10-19 02:29:41.312849
c2a5914e-9dbf-44a0-8b0e-63f239443343	JET CREMA STICKS X12 UNID	7702007053043	t	29500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.313122	2025-10-19 02:29:41.313122
7c971df0-131f-4726-9fe9-26635324f79d	HANUTA X12UNID	7861002942001	t	24200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.313468	2025-10-19 02:29:41.313468
a4d633a6-396c-4060-a0a4-ebd4ed29bf00	BURBUJET CRUJIVAINILLA X12UNID	7702007064414	t	13700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.313747	2025-10-19 02:29:41.313747
acc4d5f8-0d46-4039-a363-e851d5893b35	BIANCHI BARRA MANI X12 UNID	7702993035122	t	9400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.313978	2025-10-19 02:29:41.313978
0aaa5c19-7123-490c-a729-fa003e3f5da4	CRUJIJET BLANCA X18UNID	7702007001846	t	58500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.31427	2025-10-19 02:29:41.31427
fa1e23c9-10ec-4de9-8b0e-9dc7781e8f4e	BURBUJAS JET AREQUIPE X10UNID	7702007070750	t	6700.00	6500.00	\N	\N	19.00	2025-10-19 02:29:41.314547	2025-10-19 02:29:41.314547
1dad1a12-3d0d-4c47-954a-32b96067bc36	JET CHOCOLATINA X35UNID  1050GR	7702007512106	t	77200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.314771	2025-10-19 02:29:41.314771
0e2e3937-04ab-4b9d-bdf6-00a6550d69ce	HALLS BARRA NEGRO X12UNID	7622202015205	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.315033	2025-10-19 02:29:41.315033
876ffc18-8ee9-4692-af14-c79b6a818b2a	TIC TAC NARANJA X12UNID	7861002910321	t	20700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.315313	2025-10-19 02:29:41.315313
466d25c0-6510-4a35-ac85-0e66f8e43c95	TRIDENT MENTA X24 3 CHICLES 122G	7702133452161	t	20700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.31557	2025-10-19 02:29:41.31557
ef8c11ae-75c3-49eb-883c-42407c9dd059	TIC TAC MENTA X12UNID	7861002910314	t	20700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.315911	2025-10-19 02:29:41.315911
db75f32f-6d8f-4e69-a4f4-06bb6b74b815	TIC TAC FRUTOS ROJOIS X12UNID	7797394002033	t	20700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.316146	2025-10-19 02:29:41.316146
72c33eff-a3f7-4cc1-950f-723bb2f12349	JET CREMA ESPARCIBLE  140GR	7702007056617	t	12300.00	12000.00	\N	\N	19.00	2025-10-19 02:29:41.31644	2025-10-19 02:29:41.31644
0b526364-7ce9-4c46-94c4-bc582486b01e	JET CREMA ESPARCIBLE 350GR	7702007049718	t	23700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.316798	2025-10-19 02:29:41.316798
d47d5a5e-438a-445e-861d-34645a9e8ef9	JET CREMA ESPARCIBLE CYC 140GR	7702007075342	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.317046	2025-10-19 02:29:41.317046
2851f214-1614-4461-b103-a179ad001e2c	QUIPITOS POPS X24UNID	7702354948092	t	12900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.317309	2025-10-19 02:29:41.317309
02932569-b2f9-41ca-9894-6992d6dd2538	BIANCHI BAR CHOCOLATE X12UNID	7702993032145	t	9400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.317586	2025-10-19 02:29:41.317586
52a005be-1be2-4fe1-9b9f-11ec017dfedc	JET COOKIES AND CREAM X24UNID 11GR	7702007045451	t	47600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.317949	2025-10-19 02:29:41.317949
23507ecc-698f-4984-a7a1-fb3fe0fff770	JET GOOL X18 UNID	7702007046120	t	6000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.318388	2025-10-19 02:29:41.318388
c82c9cc9-8145-4c69-b49b-4dcb216779d2	CREMA DE MANI CRUNCHY LA ESPECIAL  260GR	7702007077223	t	12500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.318709	2025-10-19 02:29:41.318709
07a8f58a-3be5-4f33-b91a-39f68acf6bdb	JUMBO JUMBO CHOCOSALTY 180GR	7705790943645	t	7600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.318976	2025-10-19 02:29:41.318976
7a43e6e1-fbfd-4406-ad2f-aaadb02cf266	GELATINAS FRUIT JELLY 55UNID	7441163701015	t	29900.00	28900.00	\N	\N	19.00	2025-10-19 02:29:41.319286	2025-10-19 02:29:41.319286
4f49806c-6190-4882-8dfa-fe4d4b40031e	GOL COCO X18UNID	7702007039894	t	24700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.319628	2025-10-19 02:29:41.319628
c33683f0-166b-460f-8bfc-15771c02f4b0	GOL MEGA DE AREQUIPE X8UNID	7702007080674	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.319899	2025-10-19 02:29:41.319899
44043f0f-84dc-4e35-8638-d8edb716d469	GOL BARQUILLO X16 UNID	7702007074369	t	41500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.3202	2025-10-19 02:29:41.3202
b2302e45-ee5b-427d-9f86-0dd6ee745846	DEDITOS NESTLE X24UNID	7702024045205	t	23200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.320448	2025-10-19 02:29:41.320448
32a35881-f759-42aa-8577-4da22329eb9f	FRUNAS ORIGINAL X32UNID	7702174079150	t	7800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.320715	2025-10-19 02:29:41.320715
98d3beeb-8b5e-41ad-a9fd-1c1d292801ab	MECHAS LOKAS ALIENS X6UNID	7702174079822	t	17900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.321008	2025-10-19 02:29:41.321008
005ef4f9-fdc2-48d9-ba3e-c5b5250ec7fc	JABON INTIMO AMATIC 250ML	7707291396371	t	4800.00	4480.00	\N	\N	19.00	2025-10-19 02:29:41.321467	2025-10-19 02:29:41.321467
d8d6e329-ced2-46cd-96fc-4dcb6de0aa7a	PODER X 500GR	7707181396894	t	2900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.321747	2025-10-19 02:29:41.321747
198d6c6d-b955-4fd4-a64b-e145e177b2bd	PODER X DETERGENTE 1KG	7707181396054	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.321981	2025-10-19 02:29:41.321981
1eba308c-97eb-4c98-a8a7-3603a9084692	CREMA CORPORAL NATURAL FEELING BOTANICALS MANZANA VERDE500ML	7700304249558	t	9600.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.322291	2025-10-19 02:29:41.322291
fed710f2-f13f-4fa8-ba5d-cb3ade9b8fc0	ULTREX DETERGENTE LIQ 400ML	7707183660290	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.322569	2025-10-19 02:29:41.322569
5ee2263d-34bb-4991-b160-f77e8bc71770	GEL ANTIBACTERIAL NORSAN 500ML	7707426910106	t	6600.00	\N	\N	\N	0.00	2025-10-19 02:29:41.322861	2025-10-19 02:29:41.322861
c039c49d-8b31-4277-8788-cc2e48168ef9	MENTA CHAO ORIGINAL X100UNI	7702993029954	t	7000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.323125	2025-10-19 02:29:41.323125
0b499324-e216-43e7-8d6f-00d4dcc1c327	MENTA CHAO LIMON X100UNID	7702993029978	t	7000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.323372	2025-10-19 02:29:41.323372
35bfb83e-5cc2-462d-b3a5-627335caf8ab	RICATO CARAMELO X50 UNID	7702993046586	t	7700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.323649	2025-10-19 02:29:41.323649
ea15c179-0d51-442e-b8e0-790abc876bf3	AROMATEL FLORAL 2.5ML	7702191161357	t	19600.00	19200.00	\N	\N	19.00	2025-10-19 02:29:41.323938	2025-10-19 02:29:41.323938
c5f87099-168a-41cf-8918-5fdcbbdd35dc	YOGUETA FRUTALES X24UNID	7702174084017	t	7600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.324224	2025-10-19 02:29:41.324224
03682dbc-6380-4cde-8bf6-973113f72f02	MINI BUM SURTIDO X100UNI	7702011160775	t	10700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.324475	2025-10-19 02:29:41.324475
0cb600f1-9a13-4430-89b3-a56a1fef100e	TROLLI EMOCIONES X10UNID	7702174082761	t	10000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.324736	2025-10-19 02:29:41.324736
53923cb8-93aa-4a44-8761-662c98b10242	FABULOSO ALTERNATIVA 180ML	7509546683300	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.325207	2025-10-19 02:29:41.325207
5b199cab-c4e8-41f9-9ac8-92483639520b	SANPIC FLORAL 200ML	7702626219417	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:41.325436	2025-10-19 02:29:41.325436
32a24a1f-616d-4d90-8822-e4aaf9b88a9e	GRISLY GOMITAS X50UNID	7702011122063	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.325721	2025-10-19 02:29:41.325721
c1cad972-5efd-4ab5-be67-7c59c7b70c39	ALCOHOL SPRAY 60ML	ALCOHOL SPRAY	t	2000.00	1600.00	\N	\N	0.00	2025-10-19 02:29:41.326033	2025-10-19 02:29:41.326033
ba758453-d0de-40e3-9a6e-04359dfec184	PIPAS AGUARDIENTERAS	745632	t	3400.00	\N	\N	\N	0.00	2025-10-19 02:29:41.326297	2025-10-19 02:29:41.326297
13154f15-707f-4b00-b44f-c6e29c1083a5	MISTOL SURTIDO 1000ML	7703616032290	t	2900.00	2800.00	\N	\N	19.00	2025-10-19 02:29:41.326787	2025-10-19 02:29:41.326787
336cc070-2e1c-4c91-9086-078dd7c004fc	BIANCHI BLANCO X100UND	7702993046470	t	11000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.327125	2025-10-19 02:29:41.327125
a072616e-56dd-4302-9371-0c9197544f48	LIMPIADOR LAVANDA JAZMIN 1 LITRO	7700304582464	t	3000.00	2850.00	\N	\N	19.00	2025-10-19 02:29:41.327429	2025-10-19 02:29:41.327429
f78d683d-ef46-40a1-9dcb-80b8bc64e64f	SPLOT CHICLE BOMBA ZOMBIE	7702011130686	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.32774	2025-10-19 02:29:41.32774
707fee49-2a4c-467e-9568-8f1e40e47346	PINK HEARTS X50UNID	7707014975531	t	4600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.328026	2025-10-19 02:29:41.328026
554a3027-38a3-40e1-99fe-479ce92767b6	MAYONESA BARY 150GR	7702439228453	t	2600.00	2450.00	\N	\N	19.00	2025-10-19 02:29:41.328383	2025-10-19 02:29:41.328383
aac9cffd-1b05-49bc-8179-62a2e7e9afee	GEL DE BAÑO NATURAL FEELING BOTANICAL DE NUEZ 750ML	7700304574544	t	9300.00	9000.00	\N	\N	19.00	2025-10-19 02:29:41.328695	2025-10-19 02:29:41.328695
a2b57861-bae5-4519-a797-369b310fac33	BIANCHI CHOCOLATE CARAMELO X100UNID	7702993046494	t	11000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.328979	2025-10-19 02:29:41.328979
badfa17c-e115-4a9b-a4cd-2881c3cc376f	PIAZZA VAINILLA BARQUILLO X24UNID	7702011272805	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.329249	2025-10-19 02:29:41.329249
cceb25d9-04e6-4402-8d6f-110ef7b23b1f	PPIAZZA BARQUILLO CHOCOLATE X24UNID	7702011272812	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.329501	2025-10-19 02:29:41.329501
2bb058fc-f623-4fe3-8154-61e9c3ef62e5	PIAZZA BARQUILLO BLACK X24UNID	7702011277473	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.329768	2025-10-19 02:29:41.329768
982fb745-df18-4842-bb6f-cece07c06536	PIAZZA BARQUILLO AREQUIPE X24UNID	7702011272836	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.330126	2025-10-19 02:29:41.330126
dc1e1ade-69a1-49a3-88a1-771459faec69	BIG BOM YOGURIN BABY X48 UNID	7707014902711	t	5300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.330506	2025-10-19 02:29:41.330506
41d95fce-ef7a-487e-8b00-cb4bcbc9fc15	MENTA HIELO SURTIDA X100UNID	7707014903152	t	5900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.330813	2025-10-19 02:29:41.330813
45d2b897-0934-452a-9067-8f84078ea908	SAPOLIO MOSCAS Y ZANCUDO 360ML	7751851006620	t	10800.00	\N	\N	\N	0.00	2025-10-19 02:29:41.331098	2025-10-19 02:29:41.331098
a88c1095-e1c9-449f-8aa9-bf462607db3d	KOLA GRANULADA TARRITO ROJO 135GR	7702560043291	t	10000.00	9800.00	\N	\N	19.00	2025-10-19 02:29:41.331326	2025-10-19 02:29:41.331326
e9d1e2be-3d74-40fa-82c3-283834a23c9c	KOLA GRANULADA TARRITO ROJO MAS CREMA	7702560048593	t	11000.00	10600.00	\N	\N	19.00	2025-10-19 02:29:41.331621	2025-10-19 02:29:41.331621
32fcc714-b580-414f-a330-895fa9cfe0c7	SODA CAUSTICA 300GR	7709694849133	t	5400.00	5200.00	\N	\N	19.00	2025-10-19 02:29:41.331942	2025-10-19 02:29:41.331942
6fafc7d4-5746-41ae-bbd9-0f119bb8a7d2	KOLA GRANULADA TARRITO ROJO 330GR	7702560026225	t	22800.00	22400.00	\N	\N	19.00	2025-10-19 02:29:41.332227	2025-10-19 02:29:41.332227
2856ffec-e6fd-4d91-9e17-df7deb19b513	BIO VARSOL 150CC	7707325449974	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:41.332529	2025-10-19 02:29:41.332529
0fcd3363-73a7-4457-b866-353f63ef5532	BIO VARSOL 410CC	7707325449981	t	5700.00	5600.00	\N	\N	19.00	2025-10-19 02:29:41.332906	2025-10-19 02:29:41.332906
f8b9058e-7bcd-4bae-b88b-40489b32f228	VARSOL PURO 810CC	7707280630479	t	11200.00	10900.00	\N	\N	19.00	2025-10-19 02:29:41.333448	2025-10-19 02:29:41.333448
0bde8c97-df77-4191-92dd-fa1c37ae2b71	SPLOT CHICLE X50UNID MAS DULCE	7702011032683	t	6200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.334121	2025-10-19 02:29:41.334121
2fadbe60-d8f5-4bb7-91ca-e96a2a434826	RAYO INCEPTICIDA SPRAY LITRO	RAYO SPRAY	t	6000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.334539	2025-10-19 02:29:41.334539
c01abcaf-d0c9-4664-a14e-b06988f04b22	VINO SANSON 750ML	7703588003304	t	23600.00	22800.00	\N	\N	5.00	2025-10-19 02:29:41.334877	2025-10-19 02:29:41.334877
ac7287c5-e440-42ce-ac51-324010e00a62	VARSOL PURO 150CC	7707340810162	t	2900.00	2750.00	\N	\N	19.00	2025-10-19 02:29:41.335164	2025-10-19 02:29:41.335164
e1addd31-18d7-4846-b145-6087ca3d37a1	PODEROSO POCETA 500CC	7707325440551	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.335526	2025-10-19 02:29:41.335526
f63eb17d-42fb-46d6-858a-d1f3c80b5654	AXION LIQUIDO NATURAL 640ML	7509546655970	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.335894	2025-10-19 02:29:41.335894
a2759186-6410-4395-a347-abd82052a425	CREOLINA 120CC	7707325446508	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:41.336243	2025-10-19 02:29:41.336243
6f4cd81e-9f5d-404b-95af-702012080d92	BOCADILLO DE HOJA X18UNID	7709822676037	t	6200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.336555	2025-10-19 02:29:41.336555
e06b4202-81b8-4280-ac12-50bce95f8cec	BOCADILLO COMBINADO X12UNID	7707309630015	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.336935	2025-10-19 02:29:41.336935
c19127a7-3bb2-47b0-b042-edd6ec206801	BICHEK INCEPTICIDA 230ML	7707289635390	t	7200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.337269	2025-10-19 02:29:41.337269
d69f9e9f-9d31-41f4-92d2-8ee8fb6dd9af	TUMIX SURTIDO X100UNID	7703888653223	t	9700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.337599	2025-10-19 02:29:41.337599
08ea79f5-5b85-4d54-a348-94256ea82db3	MANI LIMON BARY 150GR	7702439144241	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.337845	2025-10-19 02:29:41.337845
1520b3a2-8c8d-4e4e-937c-7f014d174df7	LAVAPLATO LA JOYA 500GR	7702088207557	t	3200.00	3080.00	\N	\N	19.00	2025-10-19 02:29:41.338151	2025-10-19 02:29:41.338151
81b6b3b3-26dd-4923-bfec-a2bfa604cc3a	MANI KRAKS LA ESPECIAL 140GR	7702007068481	t	4000.00	3800.00	\N	\N	19.00	2025-10-19 02:29:41.338418	2025-10-19 02:29:41.338418
c809ad14-5985-48f5-ad7a-5b467dc78d32	SPLOT ESPANTA OJOS X60UNID	7707282388156	t	4900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.338753	2025-10-19 02:29:41.338753
1a6dea4e-6d4e-4284-9dec-8e623d70ca83	LA ESPECIAL HABAS MIX X9UNID	7702007064063	t	8600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.339089	2025-10-19 02:29:41.339089
a3a7b2f5-4620-45b4-a295-ccb3993d2460	BUBBALOO MORA X70UNID	7622201769895	t	14800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.339402	2025-10-19 02:29:41.339402
05fefde8-26c9-4ef8-abb4-8e1bfb1d72df	CREOLINA 240CC	7707325446515	t	3200.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.339687	2025-10-19 02:29:41.339687
8eea7727-939d-4f2b-90b9-a8c4b490789f	MI DIA LAVALOZA 1KG	7705946784931	t	6400.00	6250.00	\N	\N	19.00	2025-10-19 02:29:41.339912	2025-10-19 02:29:41.339912
eb8dc403-7fce-4219-b64f-40677311cc52	BUBBALOO FRESA X70	7622201770044	t	14800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.340169	2025-10-19 02:29:41.340169
176b916f-07cd-49c4-bd27-f585da1c877b	MANI KRAKS LA ESPECIAL X18UNID	7702007073799	t	11800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.340442	2025-10-19 02:29:41.340442
144ca55e-aee6-4462-8953-6a15222ddd9c	LA ESPECIAL MIX YOGURT X12UNID	7702007075373	t	16900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.340746	2025-10-19 02:29:41.340746
1e04be28-b9b5-4de6-85f3-18bbaadf6726	COMBO YES 1.8 Y 450ML	7702560045349	t	8500.00	8250.00	\N	\N	19.00	2025-10-19 02:29:41.341207	2025-10-19 02:29:41.341207
d02ac80a-3bcb-4cc3-b1dd-5d1e31d8fc01	AZUCAR PROVIDENCIA PULVERIZADA  1.000GR	7702104010918	t	6500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.341487	2025-10-19 02:29:41.341487
43f7fd92-a1f7-4255-8d66-086fe6178c0c	AXION LIMON LIQUIDO 750ML	7705790550348	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.341746	2025-10-19 02:29:41.341746
20da99b0-bdcc-4474-9bc1-c58749010a90	MANI CON PASAS BARY X8UNID 280GR	7702439230524	t	9200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.341992	2025-10-19 02:29:41.341992
416fc41b-3168-4656-8c36-ceab104de533	MANI CON SAL BARY X8UNID  280GR	7702439539818	t	11600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.342368	2025-10-19 02:29:41.342368
460ad917-dd65-4c14-b4f8-61ce80badcc5	MANI CROCANTE BARY X12UNID   240GR	7702439207977	t	8600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.342691	2025-10-19 02:29:41.342691
f8ab1f65-14fe-4370-8c8a-1c1e35009e6c	AXION CARBON 640ML LIQUIDO	7705790831744	t	10000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.343028	2025-10-19 02:29:41.343028
3d1ee400-ccb7-4d5a-a812-92457f174f07	AREQUIPE PROLECHE 220GR	7702130614425	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.343334	2025-10-19 02:29:41.343334
97459212-85f0-4033-973c-32d419a7cdc1	PATOJITO BLANQUEADOR 450ML	7707065411934	t	1300.00	1209.00	\N	\N	19.00	2025-10-19 02:29:41.343586	2025-10-19 02:29:41.343586
2f9b28df-593a-4913-b907-956463005e0f	BUBBALOO CEREZA X70UNID	7622201769956	t	14800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.343945	2025-10-19 02:29:41.343945
8cf0c9b0-9962-47ef-a721-fefc04e6520a	FABULOSO 500ML	7509546682167	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.344244	2025-10-19 02:29:41.344244
d2497d92-58f1-4e31-ac8f-17716124f74e	AZUCAR PULVERIZADA SUPER FINA 500GR	7702011006301	t	3900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.344592	2025-10-19 02:29:41.344592
20f78d55-62b1-42b1-84a2-f2e3731f796b	CHOCO ARANDANOS LA ESPECIAL 100GR	7702007057553	t	4500.00	4200.00	\N	\N	19.00	2025-10-19 02:29:41.344966	2025-10-19 02:29:41.344966
4c5f456b-201a-4438-9c71-deaef19afd9f	CLORO BLANQUEADOR HIPERCLOR GALON	CLORO GALON	t	7100.00	6850.00	\N	\N	19.00	2025-10-19 02:29:41.345296	2025-10-19 02:29:41.345296
e3ff6c72-94fc-4fdd-98c9-f5d641791e57	GELATINA FRUTIÑO X3UNID	7702354950316	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.345584	2025-10-19 02:29:41.345584
5afd0cbe-4f2d-48df-a0d0-6a92e08d5aff	CLORO MAS 2LT	653981817213	t	3500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.345902	2025-10-19 02:29:41.345902
2949a09c-45b8-4b9b-afec-706a1657c629	PRINGLES ORIGINAL 37GR	038000846731	t	6000.00	5850.00	\N	\N	19.00	2025-10-19 02:29:41.346389	2025-10-19 02:29:41.346389
ca7679a2-b988-4479-b6ae-b275e16d818a	RAYOL INCEPTICIDA 230ML	7702532630108	t	8900.00	8600.00	\N	\N	0.00	2025-10-19 02:29:41.346724	2025-10-19 02:29:41.346724
0f00e811-bd1d-486f-a347-3d2147dade78	PRINGLES QUESO 40GR	038000846755	t	5400.00	5200.00	\N	\N	19.00	2025-10-19 02:29:41.347061	2025-10-19 02:29:41.347061
695be805-82bb-4b2d-bd74-104a1ba3b41a	PRINGLES CREMA Y CEBOLLA 40GR	038000846748	t	6000.00	5850.00	\N	\N	19.00	2025-10-19 02:29:41.347361	2025-10-19 02:29:41.347361
63d6672a-d0fd-4958-b78c-368e6d3edfdb	MANI KRAKS LIMON LA ESPECIAL 132GR	7702007071634	t	5300.00	5150.00	\N	\N	19.00	2025-10-19 02:29:41.347688	2025-10-19 02:29:41.347688
92642eb3-f344-4712-83bb-36d02a12f2cc	LA ESPECIAL MIX YOGURT 150GR	7702007073430	t	5800.00	5500.00	\N	\N	19.00	2025-10-19 02:29:41.34797	2025-10-19 02:29:41.34797
0e6a8ef4-3717-475f-bfa7-fb5289e4e16e	DERSA BARRA 320GR	7702166009097	t	4000.00	3760.00	\N	\N	19.00	2025-10-19 02:29:41.348259	2025-10-19 02:29:41.348259
0b713b33-08b2-4ad4-b814-4140de7daa9c	FAB MULTIUSOS 200GR	7702191163443	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.348536	2025-10-19 02:29:41.348536
28511063-a309-43ff-9c77-b14738e9d566	KATORI ESPIRAL 10U	7702332000019	t	4400.00	4250.00	\N	\N	0.00	2025-10-19 02:29:41.348909	2025-10-19 02:29:41.348909
7cf98168-c843-41ab-b9bf-c904b628b359	GELATINA GRL FRUTO CEREZA 500GR	7708984578593	t	10400.00	10000.00	\N	\N	19.00	2025-10-19 02:29:41.34918	2025-10-19 02:29:41.34918
2beeced7-294c-4a61-93a8-d469fe14d238	GELATINA GEL FRUTO FRAMBUESA 250GR	7708919428405	t	5200.00	5050.00	\N	\N	19.00	2025-10-19 02:29:41.34944	2025-10-19 02:29:41.34944
388c24fc-afd1-4009-933b-073ad3355064	RAYOL ELECTRICO MOSCAS	7702532956802	t	13600.00	\N	\N	\N	0.00	2025-10-19 02:29:41.349743	2025-10-19 02:29:41.349743
1b64d1c7-c8be-4e0e-8b9e-3d26d97c3b1f	GELATINA GEL FRUTO CEREZA 250GR	7708952685278	t	5200.00	5050.00	\N	\N	19.00	2025-10-19 02:29:41.350155	2025-10-19 02:29:41.350155
d2cd61e3-2a66-4765-b3cb-9d6c5c8bfa3b	CLORO HIPER CLOR 2LT	HIPERCLOR 2L	t	3600.00	3500.00	\N	\N	19.00	2025-10-19 02:29:41.350455	2025-10-19 02:29:41.350455
085c6005-613c-49eb-8074-01a690ece2af	GELATINA FRUTIÑO FRAMBUESA 35GR	7702354950187	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.350729	2025-10-19 02:29:41.350729
27d21d85-6e62-45bf-918b-8679550077a3	BARRIGON 200GR	7702191163719	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.35104	2025-10-19 02:29:41.35104
2893ec97-1cb2-4483-b3d5-75e43cf38c3c	GELATINA FRUTIÑO PIÑA 35GR	7702354950149	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.351366	2025-10-19 02:29:41.351366
33ed7714-8e84-422c-9b7b-478084d0fa8b	GELATINA FRUTIÑO MANGO DULCE 35GR	7702354950057	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.351722	2025-10-19 02:29:41.351722
ba2ca3c8-8c19-42e0-8822-bb2e1d1c4d65	BARRIGON 400GR BARRA	7702191161104	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.352086	2025-10-19 02:29:41.352086
490ce0bd-134b-48f3-98f0-a01abf361dd5	MAS FIEL 450GR BARRA	7707181393695	t	2800.00	2667.00	\N	\N	19.00	2025-10-19 02:29:41.352333	2025-10-19 02:29:41.352333
5993316e-783a-4fa4-938d-70e2eef11ebe	GELATINA FRUTIÑO LIMON 35GR	7702354950101	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.352581	2025-10-19 02:29:41.352581
5be6c88b-bc77-4775-b12c-64c0ba57b27b	GELATINA FRUTIÑO FRESA 35GR	7702354950088	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.352873	2025-10-19 02:29:41.352873
014deef1-9bf4-4722-8443-b0b06fdb65b5	GELATINA FRUTIÑO MANDARINA 35GR	7702354950118	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.353135	2025-10-19 02:29:41.353135
b92c43ee-0f30-4f40-abe6-444db8f6f99b	GELATINA FRUTIÑO MORA DULCE 35GR	7702354950170	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.353412	2025-10-19 02:29:41.353412
2c57eb3d-0646-40cd-971c-96cfb0ee8185	VEL ROSITA BARRA 180GR	7702191163795	t	3100.00	2950.00	\N	\N	19.00	2025-10-19 02:29:41.353692	2025-10-19 02:29:41.353692
2409d83b-3b69-45ed-9731-db9e5895adf5	FLIPS COOKIES Y CREAM 120GR	7707200710656	t	4700.00	4550.00	\N	\N	19.00	2025-10-19 02:29:41.353954	2025-10-19 02:29:41.353954
925deb96-440a-4247-9ad1-08ab0ffb22bc	OREO TROZOS 500GR	7622201821852	t	9700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.354211	2025-10-19 02:29:41.354211
071109a0-ba9e-44cd-b564-df9d19650de1	COCOSETTE SANDICH X12UNID	7702024066583	t	11600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.354499	2025-10-19 02:29:41.354499
00eb54cb-d322-41d7-b5cf-211558335d7c	GALLETA MILO CHOCOLECHE 12X4	7702024067818	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.354791	2025-10-19 02:29:41.354791
96ec01db-3c43-47cb-afff-196244bae5e2	GRANOLA DELICIOS 500GR	7708304514867	t	6600.00	6400.00	\N	\N	19.00	2025-10-19 02:29:41.355067	2025-10-19 02:29:41.355067
e99f3ea0-4b44-461a-b5fc-aaec190b7323	GRANOLA DELICIOS 1.000GR	7708304514874	t	12000.00	11700.00	\N	\N	19.00	2025-10-19 02:29:41.355367	2025-10-19 02:29:41.355367
f604bd61-a31b-4dbb-bac8-8cd348da4a19	FLIPS EXTRA CHOCOLATE 120GR	7707200710649	t	4700.00	4550.00	\N	\N	19.00	2025-10-19 02:29:41.355663	2025-10-19 02:29:41.355663
12efbb83-53f3-40d1-b089-a70b7c3f4cde	FESTIVAL COCO 12X6	7702025141913	t	12500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.355959	2025-10-19 02:29:41.355959
746caec1-6dd2-45ee-a3c2-fa10ac3d593f	CLARO AVENA 75GR	7709651226656	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.35628	2025-10-19 02:29:41.35628
e2e07f8e-5f87-4848-9c54-9fc6d6d72be3	CLARO LIMPIEZA 75GR	7709651226601	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.356591	2025-10-19 02:29:41.356591
6706acd5-b07a-4a7d-8d9e-dd64d80a3e03	CLARO CITRICO 75GR	7703068300527	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.356979	2025-10-19 02:29:41.356979
246749dd-7650-4d04-a929-1a2e5eba345b	CHOCO BITZ KARIMBA 120GR	7702807232341	t	3800.00	3680.00	\N	\N	19.00	2025-10-19 02:29:41.357274	2025-10-19 02:29:41.357274
c1ae7c62-dafb-4d01-8608-447aeba347c3	TOSH 4 CEREALES 9X3	7702025148554	t	7400.00	7000.00	\N	\N	19.00	2025-10-19 02:29:41.357557	2025-10-19 02:29:41.357557
e2bdaed0-c94b-4e7a-a09a-6d903e1b3d72	SALTITACOS X7UNID	7707323130324	t	6600.00	6450.00	\N	\N	19.00	2025-10-19 02:29:41.357818	2025-10-19 02:29:41.357818
dd7beaeb-8c89-49e9-b8e3-82e013a0bb31	SALTIN NOEL X10 TACOS	7702025148202	t	14500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.35812	2025-10-19 02:29:41.35812
04b8ca45-32cc-403e-8ecc-06e136914b94	WAFERS ITALO 24UNID	7702117008438	t	5900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.358374	2025-10-19 02:29:41.358374
dbd51c4d-db00-4b09-b17e-bf9cb90c9aeb	PROTEX VITAMINA E 110GR	7702010420511	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:41.358603	2025-10-19 02:29:41.358603
bc601186-5f2a-48fa-8a6c-c5515531ccac	LECHE CONDENSADA COLOMBINA X12 UNID1.200GR	7702097067029	t	28800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.358886	2025-10-19 02:29:41.358886
497269c6-63c9-4af7-8602-2dc64feccb3d	CRUNCHY CREMA FLIPS CHOCOLATE X12	7702807824584	t	16600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.359172	2025-10-19 02:29:41.359172
514a553b-91d9-46fb-ba4a-2da6b28f3c44	LECHE CONDENSADA TUBITO X12UNID 540GR	7707226110737	t	22000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.359433	2025-10-19 02:29:41.359433
359c46cc-a668-41dc-a126-8e7794da290a	REXONA LIMPIEZA 120GR	7702006402194	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:41.359774	2025-10-19 02:29:41.359774
fc9af2b9-709d-40ec-8f80-701b2968d94c	LECHE CONDENSADA TUBITO 45GR	7707226110720	t	2000.00	1884.00	\N	\N	19.00	2025-10-19 02:29:41.360393	2025-10-19 02:29:41.360393
bc47158c-23d3-462e-9a5b-2f77023ce676	REXONA BAMBOO 120GR	7702006302081	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:41.36078	2025-10-19 02:29:41.36078
880743e6-7f7f-401f-8ffa-4815999a3d52	REXONA AVENA 120GR	7702006402231	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:41.361112	2025-10-19 02:29:41.361112
d63418cf-9f76-469c-a1a7-0afd3475558f	LUX FLOR VAINILLA 125GR	7702006205023	t	3200.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.361634	2025-10-19 02:29:41.361634
152385dd-1d3e-4152-8192-3479a316b0c8	LUX ORQUIDEA NEGRA 125GR	7702006205047	t	3200.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.362042	2025-10-19 02:29:41.362042
a742cf1d-a9ea-41ef-8b17-131170494e7a	LUX ROSAS FRANCESAS 125GR	7702006205009	t	3200.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.36247	2025-10-19 02:29:41.36247
0887b4ff-a240-45cb-8f18-ca1b372790aa	LUX JAZMIN 125GR	7702006205016	t	3200.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.362756	2025-10-19 02:29:41.362756
af90d3b1-89fc-477e-8b20-98ecb5cf40db	CAREY SUAVIDAD NATURAL 110GR	7702310022354	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.363326	2025-10-19 02:29:41.363326
449bf573-44b4-4393-9425-4d7ee5a85444	CAREY SUAVIDAD 110GR	7702310022262	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.363799	2025-10-19 02:29:41.363799
e419868f-8727-4afe-b171-25ecb1ef333d	JABON HOTELERO SUITE X24UNID	7702538242176	t	5200.00	5000.00	\N	\N	19.00	2025-10-19 02:29:41.364059	2025-10-19 02:29:41.364059
f2fe5b8f-b7b3-4129-95df-33f843818976	LEMON PAQ X3 6400	7701018075495	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:41.364319	2025-10-19 02:29:41.364319
880dfea6-5377-4eb6-9e86-016f02057cf2	ESENCIA PARA HELADO 500ML	7708659741222	t	3200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.364632	2025-10-19 02:29:41.364632
27a5c323-87e3-419e-89a4-5cd28eeb1418	ESENCIA DE VAINILLA BARY 155ML	7702439006235	t	3400.00	\N	\N	\N	0.00	2025-10-19 02:29:41.364919	2025-10-19 02:29:41.364919
71ab7825-f2f4-4c59-9810-b66ff6bd032c	INFUSION FRUTOS ROJOS TOSH 10UNID	7702032115655	t	5500.00	5300.00	\N	\N	19.00	2025-10-19 02:29:41.365256	2025-10-19 02:29:41.365256
f152b719-d0f0-4d5d-80f4-1c759dd6170c	AROMATICA JAIBEL ALBAHACA 25UNID	7702807482173	t	3100.00	2980.00	\N	\N	19.00	2025-10-19 02:29:41.365706	2025-10-19 02:29:41.365706
a1a1a895-e1e4-4e7d-9e90-6d5651085cbf	AROMATICA JAIBEL LIMONARIA 25UNID	7702807482180	t	3100.00	2980.00	\N	\N	19.00	2025-10-19 02:29:41.36617	2025-10-19 02:29:41.36617
fdd04c43-9519-4d96-9941-611feaab46c1	AROMATICA JAIBEL ALINEATE 20UNID	7702807483156	t	11300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.366899	2025-10-19 02:29:41.366899
c8d441a9-a5f5-49a1-b4f6-14ed0c0c9e53	AZUCARADAS KARIMBA 120GR	7702807212985	t	3800.00	3680.00	\N	\N	19.00	2025-10-19 02:29:41.367948	2025-10-19 02:29:41.367948
c7967f3f-39e7-4318-acb2-3963b1090b75	AZUCARADAS KARIMBA 500GR	7702807449169	t	13600.00	13300.00	\N	\N	19.00	2025-10-19 02:29:41.369105	2025-10-19 02:29:41.369105
d5fcfd95-2525-48bb-8a9a-7db8a4a779e1	CORAZONES SABOR A CHOCOLATE DE KARIMBA 230GR	7702807221529	t	6400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.369732	2025-10-19 02:29:41.369732
d2d22202-a661-4d29-afda-b442969a2e42	DURAZNO EN ALMIBAR 520GR	7709990496666	t	6900.00	6700.00	\N	\N	19.00	2025-10-19 02:29:41.370021	2025-10-19 02:29:41.370021
82680e06-4f21-4c08-9f99-6e9071901b63	DURAZNO EN MITADES 425GR MI DIA	7705946237284	t	9200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.370301	2025-10-19 02:29:41.370301
9c4d7828-c5e2-4e62-9e43-e582edc413c0	LA LECHERA NESTLE  LATA 90GR	7702024255246	t	2900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.370552	2025-10-19 02:29:41.370552
9420ce7a-d673-4462-a785-5d0682886333	CREMA CHANTILLY CORONA 80GR	7702007030068	t	6600.00	6400.00	\N	\N	19.00	2025-10-19 02:29:41.370928	2025-10-19 02:29:41.370928
cb6a268b-edd4-4f11-96e0-7d1a2a3405e6	DURAZNO  SU DESPENSA 820GR	7707309250664	t	10700.00	10400.00	\N	\N	19.00	2025-10-19 02:29:41.371268	2025-10-19 02:29:41.371268
aa017b6c-ba9f-40e8-a4e5-b3ab403206e4	ACEITE 3 EN 1 SUPER 3ML	7709990468137	t	1300.00	1000.00	\N	\N	19.00	2025-10-19 02:29:41.371558	2025-10-19 02:29:41.371558
3fcf5ce5-b08e-48ee-8b93-9516ea38f7f1	AROMATICA TOSH MANZANILLA X10	7702032115662	t	5300.00	5100.00	\N	\N	19.00	2025-10-19 02:29:41.371861	2025-10-19 02:29:41.371861
3c1b5742-a676-4503-9216-cd60f6d22735	CAREY X3 330GR	7702310022316	t	8400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.372148	2025-10-19 02:29:41.372148
5c9a71bc-23a6-4503-a8c5-c25fa757e63a	MI DIA JABON X3	7705946719353	t	7000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.372413	2025-10-19 02:29:41.372413
7fa9f88d-18bc-4cbc-947b-75d96f479f30	FRUTY AROS KARIMBA 120GR	7702807459854	t	3800.00	3680.00	\N	\N	19.00	2025-10-19 02:29:41.372657	2025-10-19 02:29:41.372657
c93c5271-80de-4248-97eb-68f2becf1e98	BATI CREMA 50GR	7702354310004	t	3400.00	3250.00	\N	\N	19.00	2025-10-19 02:29:41.372956	2025-10-19 02:29:41.372956
13fe5158-4991-488c-9ef8-6dc032fbe5d7	LECHE DESLACTOSADA LA MEJOR 400ML	7705241700476	t	2200.00	2000.00	1900.00	\N	0.00	2025-10-19 02:29:41.373301	2025-10-19 02:29:41.373301
fd999232-d774-40e8-958b-9da187135d30	KINDER CHOCOLATE X24UNID	8000500125038	t	38000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.373768	2025-10-19 02:29:41.373768
a8a25921-2b92-4285-b0e2-f6c298627392	TROLLI NINJA	7702174083089	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.374171	2025-10-19 02:29:41.374171
15764e9d-1f84-4a30-8370-2686cdac4fdb	LECHE CONDENSADA ITAMBE 395GR	7896051164883	t	7800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.374594	2025-10-19 02:29:41.374594
7a0b1113-a2e9-4bef-952d-723b90aff2e7	AROMATICA JAIBEL TE VERDE 20UNID	7702807483354	t	9600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.375094	2025-10-19 02:29:41.375094
c0a2f1a6-d54f-4f39-933f-862106954a06	MERMELADA FRESA 200GR	7709989481451	t	1900.00	1780.00	\N	\N	19.00	2025-10-19 02:29:41.375744	2025-10-19 02:29:41.375744
5cc30404-18e0-440e-bb37-1b83e648e81d	GRAGEAS DE COLORES 110GR	7707899456521	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.376322	2025-10-19 02:29:41.376322
2450dbf0-090e-4298-bc56-94a33f452c47	GRAGEAS DE COLORES 500GR	789546	t	5800.00	5600.00	\N	\N	19.00	2025-10-19 02:29:41.376847	2025-10-19 02:29:41.376847
801c0deb-c3d5-4baa-b7bf-d884f413577f	GLASESE 1.000GR	7458952	t	6400.00	6200.00	\N	\N	19.00	2025-10-19 02:29:41.377348	2025-10-19 02:29:41.377348
b8be07cc-d9c7-434d-b829-b3043d5c4a24	AROMATICA JAIBEL DECISION NATURAL 20UNID	7702807483408	t	9700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.377748	2025-10-19 02:29:41.377748
b9d0cd2f-04c0-47af-aff1-78d91bfee684	JABON MI DIA DE AVENA  X3	7705946719346	t	7050.00	\N	\N	\N	19.00	2025-10-19 02:29:41.378212	2025-10-19 02:29:41.378212
85dc859c-9934-4b40-b73e-1511a053397d	LECHE CONDENSADA SANTILLANA 398GR	7707212302511	t	9000.00	8850.00	\N	\N	19.00	2025-10-19 02:29:41.378605	2025-10-19 02:29:41.378605
a01517fe-b478-4e42-854b-01a74f0d2c66	GALLETA CAMPANITAS 160GR	7709997675767	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.379082	2025-10-19 02:29:41.379082
788de4bd-e1d2-4f25-885b-ecbf8886f3c2	PAPRIKA LA SAZON DE LA VILLA 20GR	7707767149425	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.379637	2025-10-19 02:29:41.379637
9042998a-c10b-4ad1-8b89-ac4cb1a8454c	ANIS LA SAZON DE LA VILLA 8GR	7707767142037	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.380029	2025-10-19 02:29:41.380029
0e6e6c49-1d55-4d85-a65b-91ef5d16449c	ACACIA LA SAZON DE LA VILLA 10GR	7707767148336	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.380514	2025-10-19 02:29:41.380514
93ca4d0f-dc7d-44be-a729-4863552d6873	NUEZ MOSCADA LA SAZON DE LA VILLA	7707767146318	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.38109	2025-10-19 02:29:41.38109
4c2b79f3-6cf2-45ac-9cc7-51fd6474c5d6	LEVADURA LA SAZON DE LA VILLA 20GR	7707767147841	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.381645	2025-10-19 02:29:41.381645
59e648ad-7810-4c40-bf40-d4096d4fa45f	MANZANILLA LA SAZON DE LA VILLA 5GR	7707767143508	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.381939	2025-10-19 02:29:41.381939
0f6d2422-a81f-49a8-a7d3-789d9a96c8db	POLVO DE HORNEAR LA SAZON DE LA VILLA 40GR	7707767148046	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.382223	2025-10-19 02:29:41.382223
430b9cf2-9388-4d5c-acf9-85d2618c8861	COLOR AMARILLO LA SAZON DE LA VILLA 25GR	7707767140460	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.382526	2025-10-19 02:29:41.382526
5b1e5006-5e31-417d-8bc3-42dd6e789dde	BICARBONATO LA SAZON DE LA VILLA 40GR	7707767145311	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.382786	2025-10-19 02:29:41.382786
ee979c25-8edb-491d-ba94-a5499cb7e16d	ADOBO NATURAL LA SAZON DE LA VILLA 25GR	7707767143546	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.383092	2025-10-19 02:29:41.383092
776fbd4c-d88e-4253-9ed3-697a542e4fb2	JENGIBRE LA SAZON DE LA VILLA 20GR	7707767142778	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.383415	2025-10-19 02:29:41.383415
f4dec5a0-71c1-4c25-a34c-fc18b87a92a4	TROLLI ANILLOS	7702174083119	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.383852	2025-10-19 02:29:41.383852
7ba89622-749d-4195-8d79-48afa07c18e1	TOMILLO HOJA LA SAZON DE LA VILLA 7GR	7707767141986	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.384187	2025-10-19 02:29:41.384187
b75cd714-797c-405d-96d7-7c7f31cdc155	TROLLI MORDISCOS	7702174083133	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.384461	2025-10-19 02:29:41.384461
85d2325a-8d74-4277-af97-cff76c8d02f6	LAUREL HOJA  LA SAZON DE LA VILLA 5GR	7707767145663	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.385137	2025-10-19 02:29:41.385137
7e9bd895-c361-45d8-91eb-9adc0a191c2b	TROLLI EMOCIONES	7702174083126	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.385676	2025-10-19 02:29:41.385676
983728d2-a7a6-4479-837b-974b83317da7	AJONJOLI LA SAZON DE LA VILLA 100GR	7707767140088	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.386185	2025-10-19 02:29:41.386185
93c03390-ea04-4065-bb7f-5dc627f575a9	COLOR ACHIOTE LA SAZON DE LA VILLA 100GR	7707767147438	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.38658	2025-10-19 02:29:41.38658
3746e37a-f194-45be-ae5b-6e2d6fb150b1	CANELA ASTILLA LA SAZON DE LA VILLA	7707767148176	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.386863	2025-10-19 02:29:41.386863
74a0baa0-a408-44d0-9439-5a6183b45009	TROLLI BANANAS	7702174083171	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.387148	2025-10-19 02:29:41.387148
2337ce53-d779-4678-80b4-a61021217cdf	OREGANO HOJA LA SAZON DE LA VILLA 12GR	7707767146639	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.387447	2025-10-19 02:29:41.387447
123b7277-4237-4f29-a49a-3e05d0126cf3	COMINO MOLIDO LA SAZON DE LA VILLA 25GR	7707767142051	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.387703	2025-10-19 02:29:41.387703
5efc95af-4c58-4a31-9021-eba6e572f1d5	AJO MOLIDO LA SAZON DE LA VILLA 25GR	7707767149043	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.388025	2025-10-19 02:29:41.388025
213b5366-cb00-4008-9bd2-4d6b0803e5c7	TRULULU CARAMELO	7702993035245	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.38838	2025-10-19 02:29:41.38838
ee896f7b-00cc-430f-9df5-f99b8bf96d75	PIMIENTA PEPA LA SAZON DE LA VILLA	7707767145359	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.388628	2025-10-19 02:29:41.388628
85c6342c-3d3d-449f-9562-6ffd96a8de75	TRULULU SANDIAS	7702993042267	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.389095	2025-10-19 02:29:41.389095
6c569a18-37a9-4e87-bc74-27dc91eaab90	COMINO PEPA LA SAZON DE LA VILLA 15GR	7707767148800	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.3894	2025-10-19 02:29:41.3894
eaf88c9f-8c37-465f-9e35-d6c20c569ef7	CURCUMA LA SAZON DE LA VILLA	7707767143416	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.389691	2025-10-19 02:29:41.389691
64327f3e-1540-431e-89b0-c9e9bab7ed95	TOMILLO MOLIDO LA SAZON DE LA VILLA 20GR	7707767143362	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.390003	2025-10-19 02:29:41.390003
2282e7b1-203c-43c3-b900-6e2211ad5f50	ACIDO BORICO 20GR	7707767140002	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.390305	2025-10-19 02:29:41.390305
ffcddfc4-c7eb-42d6-a24a-a36f2df43da7	BOLDO LA SAZON DE LA VILLA 5GR	7707767144796	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.390597	2025-10-19 02:29:41.390597
25f1469d-826e-481b-af6f-812b67a0cebe	AJI PICANTE LA SAZON DE LA VILLA 15GR	7707767145823	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.390889	2025-10-19 02:29:41.390889
f2a1fd74-a74e-444d-8729-a8a1478f1dff	SAZONADOR LA SAZON DE LA VILLA 25GR	7707767147728	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.391184	2025-10-19 02:29:41.391184
bcdc8ea2-a53d-4379-a993-1fb6b59761ff	TRULULU PINGUINOS	7702993029381	t	1900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.391451	2025-10-19 02:29:41.391451
45e26b93-7ce3-4e99-af99-c9593dec938a	TROLLI OINK	7702174083096	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.392122	2025-10-19 02:29:41.392122
c7107826-44ca-4383-a9b7-8a51a54d2eb9	AZUFRE 40GR	7707767140569	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.392469	2025-10-19 02:29:41.392469
620c2492-97a4-4ae6-afc7-f72224bb2e44	ALBAHACA LA SAZON DE LA VILLA 10GR	7707767147520	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.39277	2025-10-19 02:29:41.39277
30b3d824-1d88-4845-9aec-2130cb9efb97	HIERBAS FINAS LA SAZON DE LA VILLA 15GR	7707767147605	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.393081	2025-10-19 02:29:41.393081
f824e3ab-5679-45fe-ba6e-3cae370a03f8	CURRY LA SAZON DE LA VILLA 20GR	7707767142709	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.393368	2025-10-19 02:29:41.393368
0522c526-c29f-47d7-a030-13ef5542a854	CANELA MOLIDA LA SAZON DE LA VILLA 15GR	7707767145618	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.393641	2025-10-19 02:29:41.393641
ccc9583c-8855-47ab-afe6-3e7155e25fea	ACHIOTE PEPA 40GR	7707767141634	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.393919	2025-10-19 02:29:41.393919
8faa39ff-be66-43af-a215-b7119eda120c	CLAVOS LA SAZON DE LA VILLA 6GR	7707767148787	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.394386	2025-10-19 02:29:41.394386
0ed1c45b-bc88-494f-93a0-2eb31e8b1c95	ROMERO LA SAZON DE LA VILLA 10GR	7707767146264	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.394695	2025-10-19 02:29:41.394695
3be73163-e9db-4b8b-b6a1-71846526fa0a	LINAZA PEPA LA SAZON DE LA VILLA 50GR	7707767148299	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.395212	2025-10-19 02:29:41.395212
1a75253f-4735-45c9-9195-83a66668e085	UVAS PASAS LA SAZON DE LA VILLA 100GR	7707767147391	t	2100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.395519	2025-10-19 02:29:41.395519
e4c50782-2e44-4ce3-873f-51293fa9810a	BIANCHI CHOCO FRESA	7702993043042	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.395837	2025-10-19 02:29:41.395837
dd787bf6-91d8-4db8-b5d6-c94b64ff11d4	COLOR ACHIOTE LA SAZON DE LA VILLA 25GR	7707767143980	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.396127	2025-10-19 02:29:41.396127
6064c47b-3b6a-4602-bbd3-8f1de059ce96	BIANCHI ARANDANOS	7702993041987	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.396381	2025-10-19 02:29:41.396381
310e8b76-001d-425d-8eec-ec2f8fb1242f	AHIOTE PEPA LA SAZON DE LA VILLA 20GR	7707767149906	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.396643	2025-10-19 02:29:41.396643
91bda993-11fd-4c3f-b8ab-4a9584a828b8	ESTEVIA LA SAZON DE LA VILLA 10GR	7707767147803	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.396891	2025-10-19 02:29:41.396891
ad1ce14d-ac29-4ade-9a71-fbdbbb2a5854	BIANCHI POPS SNACKS	7702993041031	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.397186	2025-10-19 02:29:41.397186
f54c5f31-7833-44f2-b748-7765ddabd9aa	RAPIDITAS TORTILLA MANTEQUILLA	7705326001504	t	8000.00	7800.00	\N	\N	19.00	2025-10-19 02:29:41.397483	2025-10-19 02:29:41.397483
6c55ff8c-305c-45e6-98e4-0a118268f723	RAPIDITAS TORTILLA CLASICA 15	7705326075505	t	11600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.39787	2025-10-19 02:29:41.39787
bd5f4b75-724b-467c-8130-66debb77467d	MR BROWN MINIX 15U	7705326081339	t	13800.00	13650.00	\N	\N	19.00	2025-10-19 02:29:41.398127	2025-10-19 02:29:41.398127
a2412482-1923-4228-ac3d-fe7510193d5c	CHOCORRAMO X5UND	7702914596794	t	12000.00	11850.00	\N	\N	19.00	2025-10-19 02:29:41.398387	2025-10-19 02:29:41.398387
9d649734-2630-4362-a8b6-cb56ad6ba506	AVENA LA MEJOR X6UNID   1200GR	7705241900029	t	8200.00	7300.00	7200.00	\N	19.00	2025-10-19 02:29:41.398664	2025-10-19 02:29:41.398664
bf71ac5b-bff8-4d8e-af41-ddd173200795	CHOCOSO X5UND	7705326071330	t	10900.00	10800.00	\N	\N	19.00	2025-10-19 02:29:41.398914	2025-10-19 02:29:41.398914
2ad9e6b3-b30c-41c2-8dd1-f3eb993942bd	BICARBONATO REY 50GR	7702175108385	t	700.00	650.00	\N	\N	19.00	2025-10-19 02:29:41.39921	2025-10-19 02:29:41.39921
dea4fe80-cfa4-43bf-ad50-a4e45329baaa	AJO EL REY 13GR	7702175158526	t	500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.399477	2025-10-19 02:29:41.399477
85946a03-865c-4e44-b9e6-287ac2972a2d	SAZONATODO MAGGI 90GR	7702024046479	t	2900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.400518	2025-10-19 02:29:41.400518
79694d9c-078e-4065-9316-00277635e9f0	LISTERINE ZERO ALCOHOL 1LT	7702031518631	t	30000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.401158	2025-10-19 02:29:41.401158
82cad74a-07b6-4b6e-b0f8-9c6a4d59d137	LISTERINE COOL MINT 1LY	7702035432506	t	33800.00	33200.00	\N	\N	19.00	2025-10-19 02:29:41.401533	2025-10-19 02:29:41.401533
6c7e9431-b8c8-4c36-b423-915b0367c559	COLGATE LUMINOUS WHITE X3UNID	7702010611964	t	37500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.401828	2025-10-19 02:29:41.401828
89171824-cba6-409f-b979-6e08fd8abe56	ACTIVMINT ENJUAGUE BUCAL 300ML	7709808402230	t	5600.00	5350.00	\N	\N	19.00	2025-10-19 02:29:41.40212	2025-10-19 02:29:41.40212
94ed84fc-1c49-4623-8168-c6e9e66d3650	COLGATE TOTAL 12 X3UNID75	7702010611131	t	25300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.402422	2025-10-19 02:29:41.402422
80f87cc8-05c9-4cb7-9f1a-666d352a1f2c	COLGATE LUMINOUS WHITE LISTERINE ENUAGUE	7509546678030	t	24500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.402694	2025-10-19 02:29:41.402694
c75a1a37-730d-41ed-9356-422f8106b3de	ACTIVMINT ENJUAGUE BUCAL 300ML EXPLOSION	7708977668294	t	5600.00	5350.00	\N	\N	19.00	2025-10-19 02:29:41.403014	2025-10-19 02:29:41.403014
2bb7b341-b9c2-45e3-a8e8-4ab521487024	COLGATE LUMINOUS WHITE 125ML	7509546053875	t	13500.00	13000.00	\N	\N	19.00	2025-10-19 02:29:41.403297	2025-10-19 02:29:41.403297
10890fe5-bcdd-4ea8-90c3-5f0ffd561916	ORAL B EXTRA BLANCURA 180GR	7500435176989	t	12000.00	11700.00	\N	\N	19.00	2025-10-19 02:29:41.403566	2025-10-19 02:29:41.403566
4abb33a7-758f-4849-9a3b-e3356f4186db	ENJUAGUE BUCAL VALNIS 180ML	ENJUAGUE BUCAL VALNIS	t	2900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.403844	2025-10-19 02:29:41.403844
ee34562e-85b0-4594-818f-6dfd8d88971d	FORTIDENT CUATRIACCION 76GR	7891150083882	t	2700.00	2584.00	\N	\N	19.00	2025-10-19 02:29:41.404115	2025-10-19 02:29:41.404115
66ef20e4-2601-4c44-96b6-f431326937d6	AGUA OXIGENADA VOLUMEN 30	7702615819925	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.404425	2025-10-19 02:29:41.404425
7c3865be-6d1b-44c4-adc9-a9ec933549bf	AGUA OXIGENADA VOLUMEN 10	7702615819901	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.404723	2025-10-19 02:29:41.404723
4e5a95d5-a4e3-42e9-a47e-b2a54391eca1	AGUA OXIGENADA VOLUMEN 20	7702615819918	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.405062	2025-10-19 02:29:41.405062
a7fd7583-ddcd-4d06-98f2-9e43970b2234	AGUA OXIGENADA VOLUMEN 40	7702615819932	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.405323	2025-10-19 02:29:41.405323
d529d550-da3a-414b-bd4b-bd5658cc7128	GOICOECHEA DOBLE MENTOL 400ML	650240055867	t	13800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.405612	2025-10-19 02:29:41.405612
0aff7c54-27a7-4bd4-afb1-8ab10e3fe719	ESPUMA DE AFEITAR XEN 300ML	7700304685219	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.405921	2025-10-19 02:29:41.405921
d0c72db2-d57b-446a-8908-a37780081511	TALCO NEO FUNGINA 100GR	7706142707113	t	8500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.406232	2025-10-19 02:29:41.406232
874c0e31-7294-4a16-a878-3492807a256c	TALCO NEO FUNGINA 40GR	7706142707106	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.406518	2025-10-19 02:29:41.406518
0294dc02-dfb1-4da0-8175-669523ac1d06	TALCO BABY 100GR	7708440339737	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.406766	2025-10-19 02:29:41.406766
20586407-ed61-45f0-9038-98dae48a629d	TALCO YODORA 120GR MAS 90GR ORIGINAL	7702057084981	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.407035	2025-10-19 02:29:41.407035
23316892-9883-4916-ac62-7d085a9d45d0	TALCO FRESH WOMEN 200GR MAS 85GR	7709119929525	t	5300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.40736	2025-10-19 02:29:41.40736
b925013d-76d9-4d7b-bd36-0c2a15bc7e3d	TALCO MEXANA CLASICO AEROSOL 180ML	7702123012450	t	7600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.407658	2025-10-19 02:29:41.407658
01e20c12-b0a0-4e85-a2ba-3ba1541b271d	TALCO MEXANA AVENA AEROSOL 260ML	7702123011514	t	12500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.407915	2025-10-19 02:29:41.407915
6c48915d-4626-4b7b-b718-204fce4cc5b7	TALCO MEXANA LADY AEROSOL 260ML	7702123011521	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.408198	2025-10-19 02:29:41.408198
17ccc81b-c2b8-4d6e-b106-20e8de5478d9	TALCO TEXANA 400GR	7709990944143	t	7800.00	7400.00	\N	\N	19.00	2025-10-19 02:29:41.408478	2025-10-19 02:29:41.408478
fbb65d24-0c66-4576-84f7-301f95b2fd4b	TALCO BEBE SUPER MAS 600GR	7708440339713	t	5000.00	4500.00	\N	\N	19.00	2025-10-19 02:29:41.408788	2025-10-19 02:29:41.408788
b8ec47c3-597f-4f45-b7d3-83cd9e244927	TALCO PARA BEBE DROMATIC 100GR	7701168130297	t	5800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.409061	2025-10-19 02:29:41.409061
50e045a7-62a2-49f5-8027-58a00c233ca4	GEL ROL JUHNIOS ROLD 1.000GR	7709977445359	t	9200.00	8900.00	\N	\N	19.00	2025-10-19 02:29:41.409363	2025-10-19 02:29:41.409363
ffd24ced-24d1-437f-9f04-1d1341970894	JABON BARRA ORO	7845654	t	1300.00	1220.00	\N	\N	19.00	2025-10-19 02:29:41.409631	2025-10-19 02:29:41.409631
68dc05f0-d52c-48b3-a758-a95fb828b387	TALCO PARA BEBE JULIUS 100GR	7709119929594	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.409908	2025-10-19 02:29:41.409908
8c46e8ef-73ad-4816-bc95-bc12992c9784	GEL ROLD JUHNIOS 110GR	7709696714828	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:41.410223	2025-10-19 02:29:41.410223
1526cc71-a42f-4bce-964a-a2207d002d76	CERA EGO 160ML	7702006300087	t	8600.00	8250.00	\N	\N	19.00	2025-10-19 02:29:41.410548	2025-10-19 02:29:41.410548
de65129e-ae1b-43c1-bdd0-e2a45915baca	PILAS ENERGIZER RECARGABLES AA	8888021301410	t	25000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.410846	2025-10-19 02:29:41.410846
35a2a386-2591-49cf-affa-7c75215f8a65	PILAS ENERGIZER RECARGABLE AAA	8888021301502	t	13500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.411146	2025-10-19 02:29:41.411146
a03aed3d-c8ca-4b14-8dc8-9a1f07456298	PILAS ALKALINA TRONEX AAA	7707249650050	t	4200.00	4000.00	\N	\N	19.00	2025-10-19 02:29:41.411443	2025-10-19 02:29:41.411443
f2dd4684-d5fb-43f1-9b94-655900712baf	PILAS EVEREADY 9V1	039800011626	t	5900.00	5700.00	\N	\N	19.00	2025-10-19 02:29:41.411747	2025-10-19 02:29:41.411747
08874369-6de7-412c-9402-91a547015535	SEDA DENTAL FLOSSER G.U.M 20UNID	070942306805	t	5400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.412005	2025-10-19 02:29:41.412005
6716ca37-e754-45e7-a2a0-7b3b42b8fc3e	GEL EGO ALFA CONTROL CAIDA 25ML	7702006205221	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.412263	2025-10-19 02:29:41.412263
f8fc516c-577a-4160-b630-716d802e8e90	FLUOCARDENT KIDS SIN FLUOR 96GR	7702560043857	t	11000.00	10650.00	\N	\N	19.00	2025-10-19 02:29:41.412603	2025-10-19 02:29:41.412603
f9c1a444-be6f-41e2-b7e0-3427470b7245	GANCHOS ROPA FRUESOSO COLORES X10	697855233844	t	6700.00	6500.00	\N	\N	0.00	2025-10-19 02:29:41.413278	2025-10-19 02:29:41.413278
3b3ae85c-220f-41e3-be42-3c0b192ad07b	CERA EGO PARA PEINA 18ML	7702006203777	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.413601	2025-10-19 02:29:41.413601
b1a0cb6f-a122-4220-8a4d-98d7e1729026	BALANCE WOMEN CLINICAQL DUO 8.5	7702029895614	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.41388	2025-10-19 02:29:41.41388
8f378d1c-2cc0-4583-847a-7a40cafa3df9	SHAMPO SAVITAL ANTICASPA 27ML	7702006207973	t	1000.00	875.00	\N	\N	19.00	2025-10-19 02:29:41.414163	2025-10-19 02:29:41.414163
3209951b-d02a-4907-9f11-fd1a0f662209	SHAMPOO SEDAL KERATINA DUO 24ML	7702006207669	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.414477	2025-10-19 02:29:41.414477
005c93c5-c4e4-4667-a9db-12216d189281	JHONSON SHAMPOO BAÑO LIQUIDO 25ML	7702031351498	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.414773	2025-10-19 02:29:41.414773
339b009f-8b7b-4a27-98cf-0967a33c431f	KATORI X30 PASTILLAS	7702332000453	t	9000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.415008	2025-10-19 02:29:41.415008
23b76083-dd8b-445f-9090-55560e16bd82	KATORI PASTILLA  1UNID	7702332000521	t	400.00	\N	\N	\N	0.00	2025-10-19 02:29:41.415287	2025-10-19 02:29:41.415287
ff918360-d106-4537-8995-77dfd00051b2	SHAMPOO SAVITAL FUSION DE PROTEINAS 550ML	7702006207768	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:41.415714	2025-10-19 02:29:41.415714
c58bbfbf-3c40-4ea8-829d-9f67d3202ddd	SHAMPOO SAVITAL ANTICASPA 550ML	7702006207904	t	14500.00	14000.00	\N	\N	19.00	2025-10-19 02:29:41.416007	2025-10-19 02:29:41.416007
12bab562-1cfe-4143-bf7e-895bbcf2cdce	HEAD Y SHOULDERS ACEITE DE COCO 700ML	7500435142571	t	32000.00	31500.00	\N	\N	19.00	2025-10-19 02:29:41.4163	2025-10-19 02:29:41.4163
4c1387e1-dfb6-4321-849f-2894329101ef	SHAMPOO PANTENE BAMBU 200ML	7500435155830	t	12200.00	11800.00	\N	\N	19.00	2025-10-19 02:29:41.416586	2025-10-19 02:29:41.416586
9d3bf342-3ca1-4403-a5c2-f642e6d9ca91	SHAMPOO PANTENE PRO.V 200ML	7506309840000	t	12200.00	11800.00	\N	\N	19.00	2025-10-19 02:29:41.416903	2025-10-19 02:29:41.416903
8470e92b-6d9a-49f1-8ee2-cb80d6cce0fb	CREMA PARA PEINAR TRESEMME 150ML	7506306214675	t	7900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.417137	2025-10-19 02:29:41.417137
f74e0660-e729-41b9-ab08-21b332467d68	SHAMPOO SAVITAL COLAGENO Y SABILA 385ML	7702006207539	t	9000.00	8800.00	\N	\N	19.00	2025-10-19 02:29:41.417429	2025-10-19 02:29:41.417429
a23583a6-366f-40af-b2e7-79a5be58021e	SHAMPOO SAVITAL MAS ACONDICIONADOR  TARRO	7702006653145	t	30000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.418211	2025-10-19 02:29:41.418211
5c5ac602-40e8-4a5c-be28-a80b99572a07	SHAMPOO SEDAL KERATINA 1LITROS	7506306233171	t	25000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.419026	2025-10-19 02:29:41.419026
21d91ce4-49c2-4a7c-bf96-5f6c5d58c20a	TRATAMIENTO CAPILAR TIO NACHO 300ML	7798140259930	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.420176	2025-10-19 02:29:41.420176
803c07d7-ea22-4db6-87e7-568f1dbe3ad1	NATURALEZA Y VIDA TRATAMIENTO 300ML	7702377303496	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.421165	2025-10-19 02:29:41.421165
f620be03-f665-4e8f-9240-96b2470f94b1	NUTRIBELA CAUTERIZACION 24ML	7702354951955	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.421717	2025-10-19 02:29:41.421717
7e26d8e3-d64d-4b07-89a8-a12ee9298100	SHAMPOO DOVE 1.15	7506306213357	t	37000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.422527	2025-10-19 02:29:41.422527
c1b1243c-57f5-402a-bca2-4d4dbd49f95c	CHAMPU ADRADO FAMILIA 1.250ML	8433295040925	t	18500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.422879	2025-10-19 02:29:41.422879
e1bebf9e-4bef-4b35-a177-1de4fb696175	SHAMPOO FRESKITO ROMERO 800MLL	7709745310049	t	8500.00	8300.00	\N	\N	19.00	2025-10-19 02:29:41.423352	2025-10-19 02:29:41.423352
b857ee77-46f2-49e0-bf76-8c72394e9014	SHAMPOO FRESKITOS MANZANA  VERDE 800ML	7709745310087	t	8500.00	8300.00	\N	\N	19.00	2025-10-19 02:29:41.423653	2025-10-19 02:29:41.423653
eea1fd28-a894-4df6-994f-c13e6f4fe3c7	SHAMPOO DOVE REGENERACION 400ML	7791293042176	t	15800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.424058	2025-10-19 02:29:41.424058
26eebf07-b053-482b-b14b-93b9e69e5a59	SHAMPOO PARA NIÑOS 750ML	7703819013911	t	11600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.424419	2025-10-19 02:29:41.424419
e77a74bd-fb68-484e-945b-3c0a7595144a	SHAMPOO DOVE CARE ANTICASPA 400ML	7702006206587	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.424777	2025-10-19 02:29:41.424777
a81d0f42-ead0-4dd0-a960-ddc12c4ce88d	SHAMPOO CAPIBELL CONTROL DE CASPA 470ML	7703819018732	t	12600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.425226	2025-10-19 02:29:41.425226
53799e98-0f18-4560-9072-94c67f9636f8	SHAMPOO CAPIBELL FOR MEN 500ML	7703819016219	t	11500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.425577	2025-10-19 02:29:41.425577
c9e19198-6607-4adf-b8ee-dd65364f72c1	SHAMPOO KONZIL ULTRA REPARACION 375ML	7702029635692	t	13500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.425864	2025-10-19 02:29:41.425864
aebc0adb-918f-4029-9b35-6f412b383e76	SHAMPOO SEDAL CELULAS MADRES 400ML	7702006405102	t	13500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.426244	2025-10-19 02:29:41.426244
6411010e-cae0-4a2f-ad8d-039a9340ea6d	ACONDICIONADOR SEDAL CELULAS MADRES 340ML	7702006301572	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.426535	2025-10-19 02:29:41.426535
e16135cb-41c1-40b1-9708-622ab3ff9b22	KID OFERTA CAPIBEL SHAMPOO CREMA  TRATAMIENTO	7703819364716	t	30800.00	30200.00	\N	\N	19.00	2025-10-19 02:29:41.426864	2025-10-19 02:29:41.426864
1c7a0824-cdee-4e72-aa7c-0c7bbf5a7ef3	SHAMPO KONZIL MAS ACONDICIONADOR 375	7702045475340	t	22000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.427159	2025-10-19 02:29:41.427159
19dafde8-2a94-4bc4-b9fb-61df19e16f10	JOHNSONS BABY SHAMPOO 1.000ML	7702031293514	t	36000.00	35770.00	\N	\N	19.00	2025-10-19 02:29:41.427499	2025-10-19 02:29:41.427499
1b2ca7a6-8197-4a81-a2a2-fa255fa6636e	JOHNSONS BABY CABELLO OSCURO 1.000ML	7702031293569	t	36000.00	35770.00	\N	\N	19.00	2025-10-19 02:29:41.427744	2025-10-19 02:29:41.427744
b7747198-dd3c-4009-ba2a-f682c5393eb1	JOHNSONS CABELLO CLARO 1.000ML	7702031293484	t	38000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.428022	2025-10-19 02:29:41.428022
91d8deed-6f49-4922-88d7-cfcbb86dd10d	ACEITE DE COCO ROLD 12ML	7709154396535	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.428339	2025-10-19 02:29:41.428339
44b3e0c1-1c5a-43ed-90a2-6982a7f4fe82	ACEITE DE ARGAN  10ML	7709753675338	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:41.428645	2025-10-19 02:29:41.428645
66ebc19c-08a1-42d1-86d4-cd2fd3e8642f	ACEITE DE AJO 8ML	7709461609991	t	1200.00	1100.00	\N	\N	19.00	2025-10-19 02:29:41.428918	2025-10-19 02:29:41.428918
7d352409-2c2e-4ab6-8c91-a5d8d25e9c7a	REXONA CLINICAL PRATIC  30GR	7702006206815	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:41.429147	2025-10-19 02:29:41.429147
b2b73ce0-bca2-45de-a40a-2c791d4b3f43	REXONA CLINICAL MEN PRATIC 30GR	7702006206808	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:41.429421	2025-10-19 02:29:41.429421
d72cc53f-a0cb-4464-8799-0a9cf7628dce	CRESPO INTELIGENTE 15ML	7707279840988	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.42968	2025-10-19 02:29:41.42968
3e8b9060-5354-4882-8805-7e4d7970fda9	OLD SPICE SECO MEN BARRA 50GR	7500435156875	t	13500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.429993	2025-10-19 02:29:41.429993
223f95d0-1a0b-488c-9daf-7b83b31d2144	COPITOS MEDICARE 50UNID	7703252035372	t	3400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.430277	2025-10-19 02:29:41.430277
9f995c72-2afc-4032-b5e3-9d2e228bd8b7	MEDICARE COPITOS DE ALGODON 20UNID	7703252035341	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.43055	2025-10-19 02:29:41.43055
773a17a3-27e5-4c9e-9fcb-8a29ae3e335e	PRUEBA DE EMBAZO CASETTE	7709299854204	t	2500.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.430809	2025-10-19 02:29:41.430809
76212618-5ef7-480a-a3c6-f9ffa8b90406	NIVEA MEN ROLLON BLACK Y WHITE 50ML	4005900036759	t	8400.00	\N	\N	\N	0.00	2025-10-19 02:29:41.431128	2025-10-19 02:29:41.431128
a47f7e0b-ecaa-4ddc-85de-7459cbd105e2	COPITOS SUPER MAS X50UNIDADES	6924010060059	t	2300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.431736	2025-10-19 02:29:41.431736
905989c9-360d-4f57-8136-6327912fb67b	ANTITRASPIRANTE NIVEA BLACK Y WHITE 150ML	4005900036643	t	14500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.432243	2025-10-19 02:29:41.432243
d92535ea-f577-4ac5-8189-d49886a61a9c	ANTITRANSPIRANTE REXONA XTRACOOL	7791293022581	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.432545	2025-10-19 02:29:41.432545
889d39f2-8b28-4f3c-825b-9ee8a5b32130	ANTITRANSPIRANTE REXONA BAMBOO  150ML	7791293032450	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.432845	2025-10-19 02:29:41.432845
0247b498-3ddd-4e00-bef5-67881c5c9407	ANTITRANSPIRANTE REXONA POWDER DRY 150ML	7791293032436	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.433167	2025-10-19 02:29:41.433167
65f56896-22e0-4665-80f7-b7592c3c9cf5	ANTITRANSPIRANTE NIVEA ACLARADO  150ML	4005808829675	t	12800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.433709	2025-10-19 02:29:41.433709
daad905f-01b8-4b8a-a0dc-5a47fecbc07e	6D5SFG41	74851	t	4400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.434551	2025-10-19 02:29:41.434551
e917a44b-d317-4e2a-be2e-1acbcb1d6791	DESODORANTE ROLLON V8 60ML	78923454	t	8100.00	7850.00	\N	\N	19.00	2025-10-19 02:29:41.435447	2025-10-19 02:29:41.435447
ee04e0b3-0bf6-4a4c-9e9a-08ea02cd6636	REXONA ROLLON WOMEN  60GR	75062804	t	3800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.43628	2025-10-19 02:29:41.43628
1859bbf2-2e2e-4b6c-9873-7956387c27b0	MENTHUS GEL CREMA	17709385751592	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.436757	2025-10-19 02:29:41.436757
0e8352d2-8d66-4073-b793-6f23241f28c6	MENTHUS CREMA BLUE	7709385751592	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.437577	2025-10-19 02:29:41.437577
5fe68314-a28d-40fb-890b-67ac30432ab3	DESODORANTE FANY MEN 30ML	7707262612233	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.438458	2025-10-19 02:29:41.438458
2e1709e8-c3a4-4785-8593-29f212dc01d3	TRAPERO MOPAS 500	75412	t	4200.00	4080.00	\N	\N	19.00	2025-10-19 02:29:41.439005	2025-10-19 02:29:41.439005
212cdbcc-2c4e-4b65-9a4a-ce05d75595db	BOLSA NORSAN DE ACEO X10UNIDADES	7705246215975	t	2300.00	2150.00	\N	\N	19.00	2025-10-19 02:29:41.439494	2025-10-19 02:29:41.439494
eab62159-2a4f-40cf-a40e-d7e95efa5d2c	PAPEL ALUMINIO BS BLUE REPUESTO 16MTS	7709477054075	t	4700.00	4500.00	\N	\N	19.00	2025-10-19 02:29:41.439919	2025-10-19 02:29:41.439919
6d3ac9f2-0d66-44e5-9021-5e8d9ec27044	ALUMINIO TUC RESPUESTO 7 MT	7702251042510	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.440498	2025-10-19 02:29:41.440498
3d71d5ab-552f-4b94-a1a6-42fd259a52e0	PAPEL ALUMINIO CAJA 40M SUPER BLUE	734191236206	t	12600.00	12200.00	\N	\N	19.00	2025-10-19 02:29:41.440965	2025-10-19 02:29:41.440965
d24f8f04-9764-429c-a623-bddd6316ecec	EMBOPLAST NEGRO	741580	t	3100.00	2900.00	\N	\N	19.00	2025-10-19 02:29:41.441383	2025-10-19 02:29:41.441383
b18fc44c-9d9e-471f-ab4d-7666f4c0fa54	EMBOPLAST TRASPARENTE	45879	t	3100.00	2900.00	\N	\N	19.00	2025-10-19 02:29:41.442223	2025-10-19 02:29:41.442223
3fabc64f-5609-4053-a841-bc481415190a	PITILLO PAQUETE	7458954	t	1100.00	1000.00	\N	\N	19.00	2025-10-19 02:29:41.442697	2025-10-19 02:29:41.442697
6aba9787-566e-46cc-8d61-fae965284bca	CEPILLO ORAL B MAS CREMA 70GR	7500435143172	t	11800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.44324	2025-10-19 02:29:41.44324
9bd97575-5d9c-44d2-938a-efcd6891a4d5	CUCHARA SUPERAS X100UNID PLASTIGOOD	7709631460827	t	4300.00	4100.00	\N	\N	19.00	2025-10-19 02:29:41.443751	2025-10-19 02:29:41.443751
028394b6-e29c-4a9b-8d01-d863609f07ac	TENEDOR X100UNID PLASTIGOOD	7709631460834	t	4300.00	4100.00	\N	\N	19.00	2025-10-19 02:29:41.444169	2025-10-19 02:29:41.444169
65596a1f-2318-4196-b4ae-5dc24c055b36	CUCHARAS SOPERAS X20NID	7709509365100	t	1200.00	1050.00	\N	\N	19.00	2025-10-19 02:29:41.444424	2025-10-19 02:29:41.444424
338bb4b0-eb57-4892-bf18-60ef174db32a	PALO CORTOS PALETA PARA HELADO X100 PANDA	7703252002381	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.44486	2025-10-19 02:29:41.44486
35e2ee03-d970-4d3f-9320-e50c10a597d1	CUCHARA DULCERA X100UNIDADES	7709631460889	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:41.445117	2025-10-19 02:29:41.445117
191ed99b-05d9-4f11-bd57-5bc6a0423e33	CUCHARAS ECOLOGICAS EL SOL X20UNID	7707015507083	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.44551	2025-10-19 02:29:41.44551
d16b0f24-538e-4652-b69f-cb90c278fa70	PALO PINCHO EL SOL 25CM X100UNID	7707015506307	t	2500.00	2350.00	\N	\N	19.00	2025-10-19 02:29:41.445867	2025-10-19 02:29:41.445867
4b6ac9ea-e76e-43d1-9b4f-09b661e824f8	PALO GRUESO 25CM CHEVERE X100UNID	7073399300566	t	3500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.446227	2025-10-19 02:29:41.446227
f86258ea-8097-4e50-82dc-4a56139dbe28	CUCHARAS DULCERAS CHIC X20UNID	7707355925097	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.44649	2025-10-19 02:29:41.44649
46be3f44-a92f-4103-bc46-5b7a183c0a40	TENEDOR BLU X20UNID	7709990750201	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.446796	2025-10-19 02:29:41.446796
71763883-8594-4483-a3df-6923b18e63f5	PLATOS DARNEL HONDOS X20UNID	7702458002966	t	5200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.447062	2025-10-19 02:29:41.447062
d3b1135e-a6c0-42d0-b6e5-cd7ce8bd6cad	VASOS 1ONZ TROFORMAS X50UNID	7703183010011	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.447299	2025-10-19 02:29:41.447299
3eb229e2-b38b-4dc4-93fc-3acca3f38bdb	VASOZ 7OZ  BAR X25UNID	7702251061597	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.447731	2025-10-19 02:29:41.447731
6600264c-a1cd-4e81-89c7-083dea84b70b	VELON SAN JORGE N12	7707159822011	t	11200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.448012	2025-10-19 02:29:41.448012
180ccf50-cca1-423a-b39c-96a3e0f80f39	VELON SANTA MARIA N10	7707297960101	t	11000.00	10650.00	\N	\N	19.00	2025-10-19 02:29:41.448325	2025-10-19 02:29:41.448325
261ad132-e249-4c58-a8d7-c4a1857d9aa9	VELON SANTA MARIA N6	7707297960088	t	6400.00	6180.00	\N	\N	19.00	2025-10-19 02:29:41.448679	2025-10-19 02:29:41.448679
494123aa-c393-4e2d-8c7f-b9764eb05594	VELON SANTA MARIA N12	7707297960118	t	14700.00	14300.00	\N	\N	19.00	2025-10-19 02:29:41.448921	2025-10-19 02:29:41.448921
4849150e-9fc0-48e2-9fd8-0a112cbbdc32	VELON SAN JORGE N6	7707159821847	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:41.449227	2025-10-19 02:29:41.449227
1a0526de-3b61-417b-8f60-bcb3623aeab8	MECHERA MIAMI X24 UNID	7707822754144	t	23400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.449557	2025-10-19 02:29:41.449557
96f53bda-4bc9-4d74-8c1f-42badd1491ad	MECHERA TEXAS PIEDRA X24	7707822758784	t	31500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.449877	2025-10-19 02:29:41.449877
3e71a38a-88cf-48c3-bd80-50bf49a99a45	VELAS IMPERIAL COLORES X10UNID	7707279808513	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.450803	2025-10-19 02:29:41.450803
06c2f7a1-4e82-4cff-ae53-c9b4949a1e4f	VELAS SAN BENITO COLORES X10UNID	7707269195012	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:41.451468	2025-10-19 02:29:41.451468
ca8edddf-ded0-4992-84b7-07996ab52143	VELAS IMPERIAL X8 UNID	7707279808094	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:41.451862	2025-10-19 02:29:41.451862
a69794a6-dc9f-45a6-b2a9-34f1c1634f16	VELAS IMPERIAL X10UNID	7707279806144	t	8500.00	8300.00	\N	\N	19.00	2025-10-19 02:29:41.452204	2025-10-19 02:29:41.452204
b8021638-30cd-48a4-bba2-d7257054f2ea	FOSFOROS REFUEGO X20UNID	7707015503108	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:41.452679	2025-10-19 02:29:41.452679
be007914-b257-4e7f-a09c-3b9535ad01c1	MECHERAS SUKY X25UNID	7707855875038	t	11300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.45352	2025-10-19 02:29:41.45352
b5d8fe73-0d13-4503-86d5-3eeba473fa52	MECHERA SUKY CON LINTERNA X25UNID	7707748523565	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.45407	2025-10-19 02:29:41.45407
b1b9930a-9786-40ca-bb8b-b1e9814b40e4	BOLSA CHILLONA 7X11	458402	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.454791	2025-10-19 02:29:41.454791
40a0e512-f3a6-4e10-970b-e962a37273f4	BOLSA 15K	458781	t	8000.00	7850.00	\N	\N	19.00	2025-10-19 02:29:41.455374	2025-10-19 02:29:41.455374
36011328-4497-47b0-96ed-848f678dfc24	BOLSA 3K	485321	t	3100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.456002	2025-10-19 02:29:41.456002
6a09a439-1638-4b62-8f33-1a4f29cdd912	BOLSA 2K	451120	t	2300.00	2200.00	\N	\N	19.00	2025-10-19 02:29:41.457001	2025-10-19 02:29:41.457001
e1dfd057-5cc1-4fda-bbb0-356e26dc1ab8	BOLSA DE HIELO	458145	t	1500.00	1350.00	\N	\N	19.00	2025-10-19 02:29:41.458531	2025-10-19 02:29:41.458531
99b74221-0dcd-480e-8426-7dc6ae747b53	BOLSA 5K	458751	t	4500.00	4300.00	\N	\N	19.00	2025-10-19 02:29:41.459136	2025-10-19 02:29:41.459136
93d6682e-2f61-4f56-b904-2721d791bcd3	GUANTES LIMPIA YA TALLA 7	7702037567961	t	3900.00	3770.00	\N	\N	19.00	2025-10-19 02:29:41.459589	2025-10-19 02:29:41.459589
245a0b06-580d-4511-b3e3-0588064f364e	ESCOBA LEOMAR	45874	t	5100.00	4950.00	\N	\N	19.00	2025-10-19 02:29:41.460103	2025-10-19 02:29:41.460103
e7dc95e3-2db8-43a6-8f5e-2a763391c7bc	CEPILLO LAVAR ROPA	45878	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.46086	2025-10-19 02:29:41.46086
9cb6eb8b-0ecc-4a39-ba9a-e4a668216287	BOLSA 25K	54254	t	15800.00	15400.00	\N	\N	19.00	2025-10-19 02:29:41.461711	2025-10-19 02:29:41.461711
3092141b-1fe4-4671-9de4-f266ee8ce463	GUANTES LIMPIA YA TALLA 8 MEDIO	7702037567992	t	3900.00	3770.00	\N	\N	19.00	2025-10-19 02:29:41.462126	2025-10-19 02:29:41.462126
88d40d6f-8ac6-41b5-b02a-0b6675dc92e5	ESPONJILLA FUROR X12UNID	7707335283537	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.462472	2025-10-19 02:29:41.462472
e4ed52d2-e738-4ff7-9042-7f7b72a0087d	CERA ESCARLATA GRAN ACEO ROJA	7707287311319	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.462698	2025-10-19 02:29:41.462698
038aeff4-ef7f-4233-9512-64a02865a048	BON AIRE AEROSOL ORQUIDEA 400ML	7702532370721	t	9400.00	9100.00	\N	\N	19.00	2025-10-19 02:29:41.463001	2025-10-19 02:29:41.463001
25b3ec65-79c6-4b99-817a-8116767b08c1	BON AIRE AEROSOL FRUTAS DEL CARIBE  400ML	7702532828901	t	9400.00	9100.00	\N	\N	19.00	2025-10-19 02:29:41.463237	2025-10-19 02:29:41.463237
c6ce6205-c0f9-455a-b269-e13843b92a3d	BON AIRE CANELA Y MIEL AEROSOL 400ML	7702532370912	t	9400.00	9100.00	\N	\N	19.00	2025-10-19 02:29:41.46349	2025-10-19 02:29:41.46349
2e9a3b9d-ca0f-4b52-840b-b356e6167381	BON AIRE AEROSOL MORA 400ML	7702532643207	t	9400.00	9100.00	\N	\N	19.00	2025-10-19 02:29:41.463832	2025-10-19 02:29:41.463832
49c22a4c-0b4e-4066-8bae-2101565fcd52	BON AIRE AEROSOL ALGODON 400ML	7702532370974	t	9400.00	9100.00	\N	\N	19.00	2025-10-19 02:29:41.464136	2025-10-19 02:29:41.464136
c7e0255d-bd06-47e8-87c0-096c7432e126	BON AIRE REPUESTO X3UNID	7702532840187	t	25000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.464375	2025-10-19 02:29:41.464375
c639fe60-1b93-41fb-941e-426fbe72657b	BON AIRE ELECTRICO VAINILLA 25ML	7702532300124	t	14700.00	14200.00	\N	\N	19.00	2025-10-19 02:29:41.464626	2025-10-19 02:29:41.464626
1592d396-77e8-457a-919e-4efc36cbc8d2	BON AIRE AUTO BRISA TROPICAL	7702532314404	t	13400.00	13000.00	\N	\N	19.00	2025-10-19 02:29:41.464864	2025-10-19 02:29:41.464864
5563abb9-e460-47b3-8b01-5e7c8a36a7f1	BON AIRE ELECTRICO FRUTAS TROPICAL	7702532087056	t	14700.00	14200.00	\N	\N	19.00	2025-10-19 02:29:41.465121	2025-10-19 02:29:41.465121
322b47da-91f9-4cfd-9d6f-4e8a8e1e1124	AMBIENTADOR AROMATICAL AEROSOL 400ML	7707738870266	t	7500.00	7000.00	\N	\N	19.00	2025-10-19 02:29:41.465366	2025-10-19 02:29:41.465366
1e3869ec-1a3e-4ac0-8768-6b22d4ec4b68	NUTRIBELA X12UNI	7702354951825	t	16200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.465637	2025-10-19 02:29:41.465637
fd5b1811-cdc8-43f1-bcd4-a74a31721dff	SPEED STICK X18DUO SACHET	7509546674810	t	24000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.4659	2025-10-19 02:29:41.4659
32ba4f10-9008-45bd-83d2-78e35666d82f	LADY SPEED STICK X18 DUO SACHET	7509546657882	t	24000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.466137	2025-10-19 02:29:41.466137
ce136797-9ab4-4cc2-bb7a-3e59733d2490	REXONA V8 SACHET X20UNID	7702006205429	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.466357	2025-10-19 02:29:41.466357
b66ef654-a2f1-4815-bdb1-43bf31b7d01a	REXONA CLINICAL MEN X20UNID SACHET	7702006205467	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.466671	2025-10-19 02:29:41.466671
4ac65eaf-4a35-404f-be53-d2ea6cbd6ba0	REXONA CLINICAL WOMER X20UNID	7702006205450	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.467064	2025-10-19 02:29:41.467064
7c13f56a-a36d-4d12-b696-4b0769e72179	PRESTOBARBA BIC X12UNID	7707349759196	t	29000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.467288	2025-10-19 02:29:41.467288
39f5d791-e66f-4b11-ba32-96c1bbfb0d45	PULPO MEDIANO 2 COLORES	451165	t	4600.00	4500.00	\N	\N	19.00	2025-10-19 02:29:41.467592	2025-10-19 02:29:41.467592
22ffec51-f202-499c-a695-48ff4d31a635	CINTA DE EMBALAR	456214	t	5800.00	5600.00	\N	\N	19.00	2025-10-19 02:29:41.467864	2025-10-19 02:29:41.467864
4db66d45-e019-4e7a-8d5b-7e7ec968d742	GOTA MAGICA MACAO 8GR	7708416000210	t	1000.00	584.00	\N	\N	19.00	2025-10-19 02:29:41.46816	2025-10-19 02:29:41.46816
7c5084d0-37e6-4479-a5d5-8ca3c31e164e	BOMBILLO FULGORE 8W	7506487801992	t	4400.00	4100.00	\N	\N	19.00	2025-10-19 02:29:41.468394	2025-10-19 02:29:41.468394
8d66c8ab-89ec-415e-a797-abf9b04a3653	BOMBILLO SANTA BLANCA LED 7W	7707822758470	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:41.468662	2025-10-19 02:29:41.468662
6371dc4c-27b7-42ef-9ffe-5d25a653b02f	BOMBILLO SANTABLANCA LED 12W	7707822753680	t	3800.00	3600.00	\N	\N	19.00	2025-10-19 02:29:41.469157	2025-10-19 02:29:41.469157
3c2335f9-deba-4b1f-ac02-37fe3edb984c	BOMBILLO SANTABLANCA LED 9W	7707822757091	t	3400.00	3260.00	\N	\N	19.00	2025-10-19 02:29:41.469448	2025-10-19 02:29:41.469448
4e2e84cf-d810-4ccc-b1a7-a27276ce7503	BOMBILLO STARLITE LED 12W	7703252041908	t	5800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.469697	2025-10-19 02:29:41.469697
9b9dfd0e-a3a5-4687-9f08-5a249b6d66bf	BOMBILLO STARLITE 15W	7703252755669	t	7400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.469954	2025-10-19 02:29:41.469954
7295044d-d2bb-4e72-8fd0-31ccd6c7d197	AMBIENTADOR CARRO NUEVO 70GR	7704269477582	t	4200.00	3400.00	\N	\N	19.00	2025-10-19 02:29:41.470277	2025-10-19 02:29:41.470277
668504b2-d080-4e2d-b36e-13466dc577fc	ROKET GOTA MAGICA	77074489777927	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.470493	2025-10-19 02:29:41.470493
c318e59f-cd71-4030-9da4-85358226d6c6	PITA	451674	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.470779	2025-10-19 02:29:41.470779
025d6959-7bef-48fb-a924-e4bbbd060057	BOMBILLO PHILIPS 10W	8718699765491	t	5300.00	5300.00	\N	\N	19.00	2025-10-19 02:29:41.471024	2025-10-19 02:29:41.471024
f10f0110-ea4b-47cf-adb4-1a8c953a2ee9	BOMBILLO STARLITE LED 5W	7703252036195	t	4200.00	4000.00	\N	\N	19.00	2025-10-19 02:29:41.471306	2025-10-19 02:29:41.471306
c95652a7-c827-447c-9cef-b356cf34b5b7	CEPILLO EMOJI MAS PROTECTOR	7707202220054	t	2500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.471567	2025-10-19 02:29:41.471567
a168d2e1-d27e-40e8-b7e5-e6b044231600	CEPILLO INFINTA X3 UNID	7709249438249	t	4600.00	4300.00	\N	\N	19.00	2025-10-19 02:29:41.471831	2025-10-19 02:29:41.471831
0610c574-eef4-452a-b463-119b171874d7	CEPILLO INFINITA	6948122306027	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.472084	2025-10-19 02:29:41.472084
f60896be-19f3-41be-a21a-d5f44e6f39a8	CEPILLO COLGATE PRO 360 MAS CREMA	7509546687414	t	27000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.472361	2025-10-19 02:29:41.472361
3af06b6b-bb79-464b-a918-fdcd74379d4f	CEPILLO FORTIDENT X2UNID	7702354032913	t	3800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.47261	2025-10-19 02:29:41.47261
cbc546ee-1be5-428f-adf8-5ac69c7a2c50	KID CEPILLO INFINITA X5UNID	7709351818021	t	5200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.473042	2025-10-19 02:29:41.473042
df6d0322-dd2c-478a-8a28-8fb9cb3ab139	PPRESTOBARBA QUATRO ECO	841058000884	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.473324	2025-10-19 02:29:41.473324
018515d7-dd9d-403e-a7ce-e1b62bcf606a	PRESTOBARBA DARCO	6048550243953	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.473597	2025-10-19 02:29:41.473597
c9850281-8688-49a3-9fa2-8b04591bd190	PRESTOBARBA BIC VERDE	7707349755990	t	2700.00	2500.00	\N	\N	0.00	2025-10-19 02:29:41.473887	2025-10-19 02:29:41.473887
15933387-93ba-4093-b914-0f9a962213b5	CEPILLO INFINITA	7708416000593	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.474239	2025-10-19 02:29:41.474239
a95c3c29-4e2c-4ced-8fa2-9a62dbbb3731	CEPILLO ORAL B PRO PACK 2	7501086454198	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.474584	2025-10-19 02:29:41.474584
75c968fb-57ff-420a-8359-be7cd8075642	PRESTOBARBA ECO ULTIMATE 3	841058057031	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:41.474851	2025-10-19 02:29:41.474851
3ff26893-64f7-4145-b55c-248353ea30e0	CEPILLO INFINITA KIDS DELFIN	7708978593106	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.475172	2025-10-19 02:29:41.475172
04a2ac18-84eb-451a-9bcc-dcd9d4f4096e	CEPILLO JAMOS PORTATIL	7707202227190	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.475433	2025-10-19 02:29:41.475433
0676e328-2fdb-4356-b06a-186e34c91e2c	CEPILLO HAPPY	7709468986569	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.47572	2025-10-19 02:29:41.47572
f855382e-5561-45fd-b3ae-ae15342b3e7a	CEPILLO TOP ORAL ADULTO	7450077019390	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.475973	2025-10-19 02:29:41.475973
c1ac91a2-bc03-4285-bb92-dd0fb5618ece	CEPILLO TOPORAL MAS PROTECTORES	7450077002637	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.476222	2025-10-19 02:29:41.476222
bbde9374-9b3a-46be-9718-848a2975a96f	CAJA DE HUEVOS	452011	t	154000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.476519	2025-10-19 02:29:41.476519
baa7d3fa-5a9b-49eb-808e-67098bb5fb8a	AZUCAR 500GR	451212	t	2000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.476808	2025-10-19 02:29:41.476808
efdc1805-69dd-4f46-8b1d-6ea2352bcec8	SALCHICHON CARNOSAN	45125	t	5500.00	5100.00	5000.00	\N	19.00	2025-10-19 02:29:41.477098	2025-10-19 02:29:41.477098
80d8746b-7ec6-445e-b956-85064e10cf89	GASEOSA POOL X24 400ML	458411	t	23000.00	22500.00	\N	\N	19.00	2025-10-19 02:29:41.477375	2025-10-19 02:29:41.477375
da274f80-17b4-4220-80f2-e1cd920fef7e	JAMONADA CARNOSAN	4615	t	7100.00	6700.00	6600.00	\N	19.00	2025-10-19 02:29:41.477865	2025-10-19 02:29:41.477865
278bd7f4-a374-48b0-92f0-936f4f710740	ACEITE DORADO LITRO	7709881069474	t	8800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.478496	2025-10-19 02:29:41.478496
7742fd76-8e23-434f-ba8b-66ddc36f4ced	SUPERCOCO BARRA X12UNID	7702993035023	t	9400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.478875	2025-10-19 02:29:41.478875
24da722f-5a1e-4ae9-b723-c0f41f533f34	MENTA HELADA 100UNID	7702993035221	t	6700.00	\N	\N	\N	0.00	2025-10-19 02:29:41.479192	2025-10-19 02:29:41.479192
f9874290-f886-4697-8b80-c9d0f007a232	PANELA TRAPICHE	PANELA  TRAPICHE	t	2800.00	\N	\N	\N	0.00	2025-10-19 02:29:41.479427	2025-10-19 02:29:41.479427
7d5b10eb-6e21-4cd6-93bd-67ad9733ded1	SGS	D	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.47995	2025-10-19 02:29:41.47995
0435951a-5797-4b05-8902-c5491fea61e6	MISTOL 1 LITRO	74589	t	2900.00	2800.00	\N	\N	19.00	2025-10-19 02:29:41.480241	2025-10-19 02:29:41.480241
8aed9172-75bd-4daa-86e8-f0ea6008466d	JUGO DEL VALLE	7702535030059	t	1200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.480551	2025-10-19 02:29:41.480551
1d44af48-58c2-4ef9-b6ee-60461ee1e68e	AVENA TOSH HOJUELA 190GR	7702007073058	t	1700.00	1630.00	\N	\N	5.00	2025-10-19 02:29:41.480828	2025-10-19 02:29:41.480828
43b54a72-7196-4836-9f3b-59ca751addbb	COBERTURA CON CHOCOLATE FM 500GR	7707267040024	t	10900.00	10550.00	\N	\N	19.00	2025-10-19 02:29:41.481114	2025-10-19 02:29:41.481114
39accaf0-358d-4cdc-9534-7c32415e099d	CREMA DE PEINA SAVITAL 95ML	7702006404570	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:41.48137	2025-10-19 02:29:41.48137
8a53daaf-3b27-4946-909f-62ef6e233e0b	SALSA DE TOMATE BARY 80GR	7702439968199	t	900.00	767.00	\N	\N	0.00	2025-10-19 02:29:41.481644	2025-10-19 02:29:41.481644
46dca9d3-1277-464d-8da2-d032883f048a	ENJUAGUE BUCAL VALNIS	7709917138297	t	2900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.481903	2025-10-19 02:29:41.481903
2b25dffb-4275-4401-9233-de6c9ae0e805	LAVALOZA MI DIA LIMON 500GR	7700149115254	t	3200.00	3100.00	\N	\N	0.00	2025-10-19 02:29:41.482181	2025-10-19 02:29:41.482181
dee394c0-67c8-449d-9746-825ddaa62ed6	GOMAS TROLLI OINK X100UNI	7702174082983	t	9600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.482455	2025-10-19 02:29:41.482455
234b74e1-bf20-4e37-8278-d7cb0e7e556e	COLCAFE APPUCCINO MOCCA X6UNID	7702032116003	t	6400.00	\N	\N	\N	0.00	2025-10-19 02:29:41.482698	2025-10-19 02:29:41.482698
f35c0e31-b6df-4b16-87cb-307a01b53099	ATUN CATALINA RALLADO 175GR	7709865860868	t	2900.00	2800.00	\N	\N	0.00	2025-10-19 02:29:41.482978	2025-10-19 02:29:41.482978
d128fd64-6cb4-4141-8b2b-9b9c8ca1341f	SUPERCAN CROQUETAS 1KG	7707025802758	t	5100.00	4900.00	\N	\N	0.00	2025-10-19 02:29:41.48351	2025-10-19 02:29:41.48351
32feebf6-07b4-4922-979d-cc347d6c0ecf	COLCAFE CAPPUCCINO LIGHT X6UNID	7702032106813	t	8300.00	\N	\N	\N	0.00	2025-10-19 02:29:41.483966	2025-10-19 02:29:41.483966
7044ae03-534d-4bc7-8a59-43b3033cf88e	RICOSTILLA CALDO COSTILLA X8UNID	7702354949518	t	3500.00	3400.00	\N	\N	19.00	2025-10-19 02:29:41.484302	2025-10-19 02:29:41.484302
f4f1ee3b-5f6c-48b9-b0ef-45876b75bb5f	PROTECTORES ROSE X15UNID	7704269675506	t	1500.00	1400.00	\N	\N	0.00	2025-10-19 02:29:41.484541	2025-10-19 02:29:41.484541
8911aac2-e566-4fe9-9208-847de013f0fd	NUTRIBELA REPARACION INTENCIVA 27ML	7702354948436	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.484821	2025-10-19 02:29:41.484821
67576944-6679-4469-9d66-704bc4fc6c8d	GELA PLAY YOLIS TARRO 2.000GR	7709287925626	t	32000.00	31400.00	\N	\N	0.00	2025-10-19 02:29:41.485217	2025-10-19 02:29:41.485217
99a9becc-ead4-4692-a864-504d8e2467a8	AROMATICAS TOSH X30UNID	7702032117000	t	11500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.485509	2025-10-19 02:29:41.485509
8d17bc6d-ea70-4092-9990-2f9964eb3c29	FLIPS 28GR	7591039505954	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.485783	2025-10-19 02:29:41.485783
8693c30e-f2ee-4d85-9ed1-aabca28c925d	HUEVO JUNIOR BOYS X24	8699462603557	t	61500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.486084	2025-10-19 02:29:41.486084
1341e794-6d9c-48e4-b7b6-e279281bd559	REXONA FRESH	7702006402187	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:41.486321	2025-10-19 02:29:41.486321
2b476ea0-dc81-44df-b054-28b3231e02e0	MIEL LA PRADERA 125GR	7707209120197	t	4800.00	\N	\N	\N	0.00	2025-10-19 02:29:41.486557	2025-10-19 02:29:41.486557
33f6e24d-d620-4545-b2d2-1febe67ba998	GELATINA FRUTIÑO FRESA	7702354950156	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.486792	2025-10-19 02:29:41.486792
b22c8deb-af06-47be-8b7a-4a93c969c21d	JABON INTIMO ROSE 400ML	7704269860148	t	6500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.487028	2025-10-19 02:29:41.487028
d5554ed8-9699-40f6-bea6-de5999c9fd78	YOGOLIN LA MEJOR X12UNID	7705241400987	t	11600.00	10300.00	10200.00	\N	19.00	2025-10-19 02:29:41.487319	2025-10-19 02:29:41.487319
88e87bbc-b590-4064-9d83-57ccbf536fc3	LONJA BOCADILLO COMBINADO	7707337090034	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.487585	2025-10-19 02:29:41.487585
58914a14-68ac-40b8-ade5-c010619de5cb	CONO DE CHOCOLATE X32UNID	77090161867484	t	21600.00	21100.00	\N	\N	0.00	2025-10-19 02:29:41.487837	2025-10-19 02:29:41.487837
efe8794d-16de-4ebf-babf-c74f6be178fc	SHAMPOO SEDAL MICELAR 340ML	7506306210929	t	9500.00	9000.00	\N	\N	0.00	2025-10-19 02:29:41.488182	2025-10-19 02:29:41.488182
119d4a76-6360-4991-acf6-39b8ca001454	CHEESE TRIS X12	7702189057075	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.488444	2025-10-19 02:29:41.488444
97edddec-2786-494f-aa54-a361e41636b0	GELATINA X4 LA MEJOR	7705241110206	t	5000.00	4500.00	4400.00	\N	19.00	2025-10-19 02:29:41.488675	2025-10-19 02:29:41.488675
381fd118-fd9c-4851-bf22-93d237b79af2	BOCADILLO DE HOJA EL REY X18UNID	7709578880641	t	6200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.488894	2025-10-19 02:29:41.488894
f46c826d-5510-4488-a3ff-a348f244ffa1	SALCHICHA DELICHICKS HOT DOG 26UNID	7700506568839	t	20900.00	20700.00	\N	\N	19.00	2025-10-19 02:29:41.489179	2025-10-19 02:29:41.489179
820f50dd-449c-404b-af50-096eb12f026b	QUESO CREMA 230GR LA MEJOR	7705241300423	t	5300.00	4800.00	4600.00	\N	0.00	2025-10-19 02:29:41.489462	2025-10-19 02:29:41.489462
58d0adfc-3023-4905-ac45-aaeb08a89632	SALCHICHA COLANTA X9UNID	7702129011839	t	6500.00	6400.00	\N	\N	19.00	2025-10-19 02:29:41.48972	2025-10-19 02:29:41.48972
2d7b08b6-de63-464a-956a-362df758b58f	NUTRIBELA15	7702354951962	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.489948	2025-10-19 02:29:41.489948
c7b9b6a5-fe81-40ff-9aa8-2c08f5c02025	GELA PLAY YOLLI TARRO X40UNID	7709779816524	t	28600.00	27800.00	\N	\N	19.00	2025-10-19 02:29:41.490333	2025-10-19 02:29:41.490333
aa8b760c-5f19-4de8-8c8c-b6a85fa6f7b2	NUTRIBELA REPOLARIZACION 24ML	7702354951924	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.490657	2025-10-19 02:29:41.490657
108e4608-2e21-4d8e-9f2e-fedeb16b301b	GATARINA 2000 DETALLADA	GATARINA 1	t	2000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.490886	2025-10-19 02:29:41.490886
b4d27881-1113-4023-bb2e-1902a202b594	VICK VAPORUB 50GR	7590002012468	t	4200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.491156	2025-10-19 02:29:41.491156
a79cb4b0-8e2e-4f54-9a37-7e08392a99ee	KIKITOS QUESO 50GR	7700634002854	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.49145	2025-10-19 02:29:41.49145
6afe1cac-c51c-421c-81ee-e65180241162	COCA COLA SIN AZUCAR 1.5LT	7702535011799	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.49167	2025-10-19 02:29:41.49167
c5be266a-27cb-40d0-9662-9c08e534bfec	DSFG	3451	t	3.00	\N	\N	\N	19.00	2025-10-19 02:29:41.491938	2025-10-19 02:29:41.491938
36cc73a8-1ef5-441c-945f-899b80600352	ATUN LOBO DE MAR	7862111870100	t	3800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.492219	2025-10-19 02:29:41.492219
8229a18b-7db2-4c48-82b6-b1fe0e6b2c59	MANTEQUILLA DELICIA X15KG	78457454	t	54000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.492519	2025-10-19 02:29:41.492519
237bbee1-aa60-4361-abd8-08a0d4019354	SPAGHETTI LA MUÑECA 250GR	7702020112017	t	1900.00	1790.00	\N	\N	0.00	2025-10-19 02:29:41.492752	2025-10-19 02:29:41.492752
ba375f0a-6aca-4071-8e4b-05c32d3d4094	ENJUAGUE BUCAL COLGATE KIDS 250ML	7891024030806	t	13200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.492976	2025-10-19 02:29:41.492976
35055d28-39fa-46ac-b9d2-985fffda58df	CABELLO ANGEL LA MUÑECA 250	7702020112055	t	1900.00	1790.00	\N	\N	5.00	2025-10-19 02:29:41.493227	2025-10-19 02:29:41.493227
0c76639f-9b46-4406-94d2-945d8cb3f704	PAPAS MARGARITA POLLO X12  300GR	7702189000200	t	19400.00	\N	\N	\N	0.00	2025-10-19 02:29:41.49348	2025-10-19 02:29:41.49348
eb9585f0-e290-48a0-bcbc-9bb3d50a60f1	MECHERA CLIPER PIEDRA	8412765508905	t	3400.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.493781	2025-10-19 02:29:41.493781
f0debc63-bfc7-4f17-8572-479de2366ec9	JUMBO DOTS X12	7702007044140	t	17800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.494182	2025-10-19 02:29:41.494182
aae41098-bbc3-4874-91b5-2863b3f59159	ELITE MAX X4UNID	7707199348533	t	5400.00	5200.00	\N	\N	0.00	2025-10-19 02:29:41.494462	2025-10-19 02:29:41.494462
596d81d7-0dba-4ec0-99f4-a3c78740b35c	ROSAL ULTRACONFORT X4UNID XG	7702120014198	t	6200.00	6000.00	\N	\N	0.00	2025-10-19 02:29:41.49472	2025-10-19 02:29:41.49472
4f8b4bb5-8df3-499c-8244-fc245a56746d	LAMPIÑA CREMA DEPILATORIA 120GR	7709421569884	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.49501	2025-10-19 02:29:41.49501
d527b0ca-b106-42dd-b5df-3c06ff593d7b	RAMITO X2UNID	7702914598842	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:41.495851	2025-10-19 02:29:41.495851
3728b3ed-87eb-4666-b08e-32dfe2b8aa91	RAMITO X10 RAMO	7702914111508	t	8300.00	8150.00	\N	\N	19.00	2025-10-19 02:29:41.496604	2025-10-19 02:29:41.496604
4bfa341d-3387-4c8f-a16e-a44ef2148661	FRUTIÑO MESCLAS COLOMBIA 2L	7702354950897	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:41.497631	2025-10-19 02:29:41.497631
f11bd96d-3da0-4db1-8a4f-6c01169cc041	AREQUIPE LA MEJOR REPOSTERIA 5GR	7705241700025	t	59000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.498765	2025-10-19 02:29:41.498765
6e54b08e-a684-45ec-8e76-881fea7cf025	ESPONJA BRILLA FACIL	7707303820092	t	600.00	\N	\N	\N	0.00	2025-10-19 02:29:41.499817	2025-10-19 02:29:41.499817
498e37ad-f4f0-4d44-b551-22d27c7f9c30	LASAGNA LA MUÑECA 400GR	7702020115162	t	9900.00	9600.00	\N	\N	19.00	2025-10-19 02:29:41.500917	2025-10-19 02:29:41.500917
f7349b91-25c6-49fe-94c5-14e3b6ed6e34	MATRIMONIO JAMON Y QUESO CHAQTERI 420GR	7700188000504	t	9000.00	8800.00	8400.00	\N	0.00	2025-10-19 02:29:41.502146	2025-10-19 02:29:41.502146
368b58c4-f7e3-42e7-9ee4-d2adcad383b3	COSTAL	7555899	t	1000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.503174	2025-10-19 02:29:41.503174
e63e3c8f-df3d-4487-8a11-93d49324a863	VITAFER.L 10ML	7707285543064	t	2000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.503864	2025-10-19 02:29:41.503864
d4dc252a-a69a-4f1e-bd3d-bdbd8dae8c9a	MANTEQUILLA ECONOMICA TAZA	744447	t	2700.00	2600.00	\N	\N	0.00	2025-10-19 02:29:41.504234	2025-10-19 02:29:41.504234
a716616d-d269-4b9c-bd25-24e496a70001	MANTEQUILLA 500	MANT500	t	2700.00	2600.00	\N	\N	0.00	2025-10-19 02:29:41.504771	2025-10-19 02:29:41.504771
eb7ac2ac-12a6-4e74-a414-a11f1c271743	OKA LOKA FUSION X12UNID	7702993049013	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.505352	2025-10-19 02:29:41.505352
2a7fd879-21ce-45df-ac3b-cdd44f486d0c	TOSH X9 MIEL	7702025148448	t	7400.00	7000.00	\N	\N	19.00	2025-10-19 02:29:41.505701	2025-10-19 02:29:41.505701
d5c65ae4-2487-4908-b702-795341a02368	JABON FREKITOS 75GR FRUTOS	7708977668232	t	700.00	650.00	\N	\N	19.00	2025-10-19 02:29:41.505969	2025-10-19 02:29:41.505969
01d3e2e3-017d-43b8-995d-441ef91e952f	TRULULU LENGUAS 80GR	7702993042397	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.506283	2025-10-19 02:29:41.506283
c763ca37-88f7-4e45-93a9-b4a0c17a2387	MIX NATURAL 20GR	7700634000270	t	900.00	750.00	\N	\N	0.00	2025-10-19 02:29:41.506553	2025-10-19 02:29:41.506553
16232c02-05d6-453b-9bd6-e454d1124716	JABON INTIMO NOSOTRAS 130GR CONTROL OLOR	7702026181789	t	8800.00	8550.00	\N	\N	19.00	2025-10-19 02:29:41.506798	2025-10-19 02:29:41.506798
479bb23a-c663-4d2b-accd-c5a7808bd045	CHICHARRON BAR BQ 50GR SUPER R	7702152106960	t	4100.00	3950.00	\N	\N	5.00	2025-10-19 02:29:41.507035	2025-10-19 02:29:41.507035
7edf8da9-c613-407e-86fb-88020ebf9246	KIKITOS HORNEADOS 20GR	7700634001161	t	1000.00	750.00	\N	\N	0.00	2025-10-19 02:29:41.507284	2025-10-19 02:29:41.507284
f1b02e29-aeae-4647-aabb-472482181102	BUBBALUU FRUTA X70	7622201769987	t	14800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.507499	2025-10-19 02:29:41.507499
da542cc6-8910-4d44-8930-836a1bb297dd	CREMA N4 110GR	7702057087586	t	36500.00	35800.00	\N	\N	0.00	2025-10-19 02:29:41.507729	2025-10-19 02:29:41.507729
bf80cb0c-de73-4e24-8ff2-2582b8d59ec0	SALCHICHON FINO 225GR COLANTA	7702129074414	t	3700.00	3600.00	\N	\N	5.00	2025-10-19 02:29:41.507981	2025-10-19 02:29:41.507981
d740d265-a2e3-4535-a7c4-624d4de44a2e	SOPA DE COSTILLA CON FIDEOS MAGGI 65GR	7702024015307	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.50822	2025-10-19 02:29:41.50822
987585d5-6926-46cc-913b-e685bc4ee415	SUPERCAT 500GR	7707025802710	t	4300.00	4180.00	\N	\N	5.00	2025-10-19 02:29:41.50857	2025-10-19 02:29:41.50857
2639a438-ed94-4ec2-bae6-09212ab5baa6	PAPA OREADAS BBQ 105GR	7706642005016	t	5600.00	5450.00	\N	\N	19.00	2025-10-19 02:29:41.508809	2025-10-19 02:29:41.508809
68928673-8aef-4b98-b26a-3f1d317bc06e	HIT 500ML MANGO PIÑA	7702090029871	t	2500.00	2292.00	\N	\N	5.00	2025-10-19 02:29:41.509026	2025-10-19 02:29:41.509026
32e5a6f0-4241-4994-a479-55bbe20eedc6	MASCARILLA KARITE COFFE	6903072381593	t	3000.00	2800.00	\N	\N	0.00	2025-10-19 02:29:41.509271	2025-10-19 02:29:41.509271
73867c92-7b64-4f05-8d8d-abb8fe868a7e	PANTENE BAMBU NUTRE Y CRECE 30ML	7500435155892	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.509512	2025-10-19 02:29:41.509512
fa1393f8-839f-4b2c-ba09-af65bda9f7b9	SALCHICHON MONTEFRIO 225GR	7702129073691	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.509726	2025-10-19 02:29:41.509726
352cf864-6ac0-4e48-b3b1-2cd2705f18bf	BABYSEC 2X100	7709085938446	t	79500.00	78100.00	\N	\N	19.00	2025-10-19 02:29:41.509944	2025-10-19 02:29:41.509944
fdb9a5bf-d1e8-4b1e-a80a-602b2a0707ca	REMOVEDOR MARIPOSA	7709338238774	t	2500.00	2070.00	\N	\N	19.00	2025-10-19 02:29:41.510201	2025-10-19 02:29:41.510201
918d6d55-ed83-4e44-9144-16075d6c407f	TRATAMIENTO TONO SOBRE TONO	7709990998177	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:41.510417	2025-10-19 02:29:41.510417
7747150e-68cb-481a-86ff-99b2a9e0b9d6	BARRILETE X40UNID	7702993051375	t	9100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.510649	2025-10-19 02:29:41.510649
524bfbed-96bd-45a9-aee4-8c8bb42ede4d	BOKA SALPICON	7702354956677	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:41.510911	2025-10-19 02:29:41.510911
279fe082-9191-4b64-bd7e-cd44db9b4b32	SHAMPOO NUTRIT EMBRION DE PATO 750ML	7702277121480	t	17500.00	17000.00	\N	\N	0.00	2025-10-19 02:29:41.511146	2025-10-19 02:29:41.511146
861f2736-9715-41d6-bb19-40fbbf3a9f18	MASAS LISTA SUPER MASAS X15UNID 600GR	4555489	t	3700.00	3600.00	3500.00	\N	19.00	2025-10-19 02:29:41.511362	2025-10-19 02:29:41.511362
4827f0a4-0f3c-4ff0-9d22-d0516a433cba	POOL UVA 400MLO	7708984708716	t	1200.00	909.00	\N	\N	19.00	2025-10-19 02:29:41.511712	2025-10-19 02:29:41.511712
db286168-6813-4a66-bbd2-8cdc71b35817	COPA DE CHOCOLATE YOLIS X100	7709016186786	t	28000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.51196	2025-10-19 02:29:41.51196
a31db637-f1a3-433d-8ac8-f5d5f3995c9a	SPRITE LIMA LIMON 3LITROS	7702535005910	t	6500.00	5849.00	\N	\N	19.00	2025-10-19 02:29:41.512192	2025-10-19 02:29:41.512192
17b8328b-47cc-40c4-b32b-4634660559ea	LENTEJA  SUIDESPENSA 460	7707309250114	t	3800.00	3700.00	\N	\N	0.00	2025-10-19 02:29:41.512427	2025-10-19 02:29:41.512427
f63b5e37-a25a-4100-8e25-efb929819c54	TOALLIN SCOTT X3UNID ABSORB	7702425809918	t	6600.00	6400.00	\N	\N	5.00	2025-10-19 02:29:41.512655	2025-10-19 02:29:41.512655
592c0bbf-fe6d-40a4-ab04-02e90665013f	LASAGNA LA MUÑECA 200GR	7702020115100	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.512904	2025-10-19 02:29:41.512904
99b4ea02-5f80-4801-922c-1df4a83ae342	MAS FIEL EN BARRA 500GR	7707181392575	t	2800.00	2667.00	\N	\N	19.00	2025-10-19 02:29:41.51313	2025-10-19 02:29:41.51313
c21a88cb-9819-4c07-bb91-a116136a83b0	NUTRIT ULTRA ACONDICIONADOR COCO SIN SAL 550ML	7702277733775	t	18000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.513364	2025-10-19 02:29:41.513364
75f51a9a-2c16-4685-bb3a-abda1a8992e5	SHAMPOO CON CEBOLLA ANYELUZ SIN SAL 500ML	7709022735190	t	37700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.513597	2025-10-19 02:29:41.513597
6d62ecfd-2fda-4214-8a70-c40ac4e815cb	SHAMPOO CON ALEO VERA BIOTINA SIN SAL ANYELUZ 500ML	7709022735107	t	28800.00	\N	\N	\N	0.00	2025-10-19 02:29:41.513878	2025-10-19 02:29:41.513878
82888b64-73e0-47ee-895a-dd5ca952af14	SHAMPOO EGO FUSION ANTICASPA  2EN1 230ML	7702006300216	t	26700.00	\N	\N	\N	0.00	2025-10-19 02:29:41.514129	2025-10-19 02:29:41.514129
f616c1b6-dfbb-4a9c-922b-d4523cdcc885	SHAMPOO CON GUSANO DE SEDA BIOTINA  ANYELUZ SIN SAL 500ML	7709022735138	t	28800.00	\N	\N	\N	0.00	2025-10-19 02:29:41.514403	2025-10-19 02:29:41.514403
45a9fde2-112b-4948-966a-950343b8bd5c	SHAMPOO SCHWARZKOPF RUBIOS 200ML	7702045339833	t	16000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.514643	2025-10-19 02:29:41.514643
41a83a6c-6e0a-44c3-98b4-f5cf226bd2d5	GEL CAPILAR VALNIS 300GR	7709044633726	t	3800.00	3650.00	\N	\N	0.00	2025-10-19 02:29:41.51489	2025-10-19 02:29:41.51489
33aa5fc9-0b68-4cb1-a5f9-b8aeb9eff646	PONDS CLARANT B3 PROTECTOR SOLAR 100GR	7506306216778	t	20900.00	20400.00	\N	\N	19.00	2025-10-19 02:29:41.515103	2025-10-19 02:29:41.515103
915ce592-5e38-457c-98e8-8cc54b689e1d	MEXASANA CLASICO AEROSOL 260ML	7702123011545	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.515327	2025-10-19 02:29:41.515327
3c47d771-664f-4ea5-9e1b-aef7448b22b9	GEL EGO ATTRACTION 500ML	7702006298902	t	13000.00	12500.00	\N	\N	19.00	2025-10-19 02:29:41.515587	2025-10-19 02:29:41.515587
1814507e-4607-418d-9687-852aba87e0d6	DURAMAX MULTIUSO SCOTT X7UNID	7702425552197	t	4200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.515802	2025-10-19 02:29:41.515802
91a19ebe-73db-4dcd-a7e9-87e08eaa3b71	SALSA DE TOMATE FRUCO 1.000GR	7702047038123	t	16200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.516037	2025-10-19 02:29:41.516037
773cb1d1-f863-4108-b04c-472972fc78d7	MAYONESA FRUCO 1.000GR	7702047038116	t	17200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.516265	2025-10-19 02:29:41.516265
afba20e6-eb0a-4d55-96c0-a60c42d39e79	ARVEJA CON ZANAHORIA ZENU 580GR	7701101233122	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.516502	2025-10-19 02:29:41.516502
636c5136-da83-4d8d-b880-ad1a415f2570	SHAMPOO DOVE REGENERACION EXTREMA 750ML	7791293042145	t	29500.00	28800.00	\N	\N	19.00	2025-10-19 02:29:41.516718	2025-10-19 02:29:41.516718
38787e93-bffa-4e5a-b1bb-a4f91c880cda	CHOCOLISTO CHOCOLATE 330GR	7702007064322	t	11900.00	10500.00	\N	\N	19.00	2025-10-19 02:29:41.517119	2025-10-19 02:29:41.517119
81afe948-bff7-45ff-b1ed-e9441ec7c4ce	COLCAFE CAPPUCCINO VAINILLA 18GGR	7702032118465	t	1900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.517427	2025-10-19 02:29:41.517427
b01bd1d7-db37-4dcd-ada4-934186316629	COLCAFE CAPPUCCINO AVELLANA 6SOBRE	7702032116027	t	5400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.51766	2025-10-19 02:29:41.51766
0dfa1917-ff2c-4eeb-b0fa-03c085e41f82	COLCAFE CAPPUCCINO CLASICO X6	7702032115969	t	5400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.51791	2025-10-19 02:29:41.51791
596bd352-c7b1-4564-a9b8-41e3948918d0	TOSH MIEL 2 TACOS 418GR	7702025140879	t	9000.00	8800.00	\N	\N	19.00	2025-10-19 02:29:41.518668	2025-10-19 02:29:41.518668
cdf1080b-9a9d-47cb-b327-64c8e27e1379	CAFE LA BASTILLA 250	7703114201327	t	13800.00	13500.00	\N	\N	5.00	2025-10-19 02:29:41.519337	2025-10-19 02:29:41.519337
dbff26ea-4b33-47f2-818f-8f091611ed1a	CAFE LA BASTILLA 125GR	7703114201228	t	6200.00	6050.00	\N	\N	5.00	2025-10-19 02:29:41.520443	2025-10-19 02:29:41.520443
b024c23c-b673-4119-b513-332c4f89c87b	TUPAN MANTEQUILLA 15KG	778899	t	88000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.520951	2025-10-19 02:29:41.520951
24a3bdd0-2583-49d4-9df2-6af32aacc813	SALCHICHON CIFUENTES	88998	t	6200.00	6050.00	\N	\N	19.00	2025-10-19 02:29:41.521205	2025-10-19 02:29:41.521205
10e33c5f-dd41-4cbb-8d0e-e1a943f83dc9	BOCADILLO LONJA 300GR DM	7707317760094	t	2100.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.521466	2025-10-19 02:29:41.521466
55ffa0e9-a184-47e2-8c3c-83152cd598a4	COLOR AMARILLO LA SAZON 150GR PETPACK	7707767146370	t	3900.00	3750.00	\N	\N	19.00	2025-10-19 02:29:41.521709	2025-10-19 02:29:41.521709
eb5a38c0-62d4-4535-b10b-de8606c9b6c3	BOLOÑA CIFUENTES 900GR	99878	t	7300.00	7000.00	\N	\N	19.00	2025-10-19 02:29:41.521914	2025-10-19 02:29:41.521914
6c2208e7-58db-4332-b917-c41ad40200eb	INDULECHE ENTERA 900GR	7706921000190	t	27000.00	26500.00	\N	\N	19.00	2025-10-19 02:29:41.522159	2025-10-19 02:29:41.522159
c38b7cc4-4721-4a22-a258-03c36dd228cd	VASOZ 22OZ  X25UNID	7703183111220	t	5700.00	5450.00	\N	\N	0.00	2025-10-19 02:29:41.522616	2025-10-19 02:29:41.522616
2b653c51-8a02-428f-948a-684940300fa0	GELATINA GEL FRUTOS FRESA 500GR	7709946544090	t	10400.00	10000.00	\N	\N	19.00	2025-10-19 02:29:41.522852	2025-10-19 02:29:41.522852
0861cc3e-b51e-4312-a452-789fa8c6fc1b	SALCHICHON AHUMADO CARNOSAN 900GR	451656	t	9200.00	8200.00	8000.00	\N	19.00	2025-10-19 02:29:41.523116	2025-10-19 02:29:41.523116
57073c43-949c-43ba-b05a-b3c48b6b290d	PRESERVATIVO DUO RETARDANTE X3UNID	4005800255045	t	3000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.523362	2025-10-19 02:29:41.523362
10416037-8a58-4436-8a0b-20e1c9eaaa09	SALSA BBQ IDEAL 1.000GR	7709392006074	t	8300.00	8150.00	\N	\N	19.00	2025-10-19 02:29:41.523601	2025-10-19 02:29:41.523601
874f3475-3f63-4fb5-b69b-fd32db5b2838	FGJ	478598	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.523852	2025-10-19 02:29:41.523852
667c11b9-ce69-4056-8870-a12ccc23ac0f	MASAS LISTA SUPER MASAS CUADRADA X15UNID 600GR	4455478	t	3700.00	3600.00	3500.00	\N	19.00	2025-10-19 02:29:41.524105	2025-10-19 02:29:41.524105
8a421ab4-98b9-4aee-a863-ae9412a445d2	0	0	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.524353	2025-10-19 02:29:41.524353
3d2ad2ee-850a-44cb-bf3a-582a15f87aac	SALCHICHA TIPO PERRO CARNOSAN X32UNID	778895	t	9000.00	8500.00	8300.00	\N	19.00	2025-10-19 02:29:41.524596	2025-10-19 02:29:41.524596
c7fe3f61-a445-4fab-b76f-476faf526d07	HEAD SHOULDER SHAMPOO X36 PANTENE	7500435202329	t	21000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.524846	2025-10-19 02:29:41.524846
a888f836-5c00-4820-8de3-158d330c45f5	ESPONJA VERDE PLANA	887542	t	300.00	\N	\N	\N	0.00	2025-10-19 02:29:41.525085	2025-10-19 02:29:41.525085
9afbd391-f250-4e2f-80c6-49b6f666cc08	TRULULU CHOCOLORES X12UNID	7702993044070	t	19000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.525331	2025-10-19 02:29:41.525331
6aa67f07-f95b-44a0-9670-5d5bd598dfdf	BUSCAPINA CONPUESTA	7847874	t	1500.00	1400.00	\N	\N	0.00	2025-10-19 02:29:41.525558	2025-10-19 02:29:41.525558
1ab97c85-eee6-4835-a2bf-bf16080bbf8b	IBUPROFENO SOBRE X10UNI	774145	t	2300.00	\N	\N	\N	0.00	2025-10-19 02:29:41.525812	2025-10-19 02:29:41.525812
cbe2b353-34df-4bcf-94dd-14ead32bbf03	JABON INTIMO ELLAS 200ML	7702108207819	t	7700.00	7300.00	\N	\N	0.00	2025-10-19 02:29:41.526059	2025-10-19 02:29:41.526059
fb5e2812-53fe-49ae-bd3a-ba0a2f205f91	CEBADA GRANOS RINCON 500GR	7709062917143	t	2400.00	2250.00	\N	\N	0.00	2025-10-19 02:29:41.526293	2025-10-19 02:29:41.526293
a4628549-dd55-41a5-b8e3-353d49cffc55	MANI KRAKS LA ESPECIAL X12	7702007062595	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.526547	2025-10-19 02:29:41.526547
f65b9a56-b907-4c6d-91d4-260f984be1fa	BIANCHI CHOCOLORES MANI X12	7702993044117	t	19000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.526795	2025-10-19 02:29:41.526795
bed015b2-bc82-486f-bea2-bb464587a3cf	MANI KRAKS LA ESPECIAL 25GR	7702007062588	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.527032	2025-10-19 02:29:41.527032
cba006c1-9d23-4cfe-beec-e7b7a88d0b13	TINTE LISSIA 5.5	7703819304620	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:41.527275	2025-10-19 02:29:41.527275
3a8914b6-45aa-49e1-af92-e76c20448a52	JOHNSONS JABON 110GR	7702031407621	t	2900.00	2800.00	\N	\N	0.00	2025-10-19 02:29:41.527696	2025-10-19 02:29:41.527696
c7207dbf-bf2b-4f53-a8df-070ae35a8dba	MAGGI AJIACO SOPA MI TIERRA 90GR	7702024064794	t	2500.00	2350.00	\N	\N	19.00	2025-10-19 02:29:41.527974	2025-10-19 02:29:41.527974
2857bfd7-e55b-473e-94b9-6db81e4bffed	PROTEX DUO PROTECT 110GR	7702010097966	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:41.52821	2025-10-19 02:29:41.52821
cf4f6a28-fd4e-41ef-a701-f5dd44e5c77c	TRULULU MASMELLO UNICORNIO 60GR	7702993038130	t	2000.00	1890.00	\N	\N	19.00	2025-10-19 02:29:41.528516	2025-10-19 02:29:41.528516
a0154f98-2395-459d-80e8-32b2bb080821	CHICHARRON PICANTE LA VICTORIA 55GR	7706642004804	t	5200.00	5000.00	\N	\N	5.00	2025-10-19 02:29:41.52875	2025-10-19 02:29:41.52875
3e0351f3-2246-4a08-8641-d5599bc81eef	PAPAS OREADAS POLLO 115GR	7706642003753	t	5600.00	5450.00	\N	\N	19.00	2025-10-19 02:29:41.528974	2025-10-19 02:29:41.528974
88596001-768c-4c50-93fd-e2291b4b25ea	DISCO LA JOYA LAVAPLATOS 130	7702088207564	t	1100.00	1000.00	\N	\N	19.00	2025-10-19 02:29:41.529194	2025-10-19 02:29:41.529194
d394fd50-3c77-4081-834c-924138749b38	OKA LOKA NANOS X12 GRANDE	7702993049044	t	21500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.529404	2025-10-19 02:29:41.529404
83ea5787-5f7a-4012-aa13-affa9e68128d	CHORIZO CARNOSAN X15UNID	5445463	t	7800.00	7300.00	7100.00	\N	19.00	2025-10-19 02:29:41.529636	2025-10-19 02:29:41.529636
9c4d26b4-8610-4f50-bc54-366e2b7ee060	SICARIO LIQUIDO VENENO	441402	t	2500.00	2300.00	\N	\N	0.00	2025-10-19 02:29:41.529873	2025-10-19 02:29:41.529873
c73de93d-909e-4cbc-915a-0dfa7037d2e6	SALMON CALIDAD ACEITE 101G	7709747005943	t	3100.00	2950.00	\N	\N	5.00	2025-10-19 02:29:41.530112	2025-10-19 02:29:41.530112
470a47a7-af1d-4c85-9e7f-9c7d91256c63	CHOCLITOS LIMON 210GR	7702189057839	t	7700.00	7450.00	7250.00	\N	19.00	2025-10-19 02:29:41.530351	2025-10-19 02:29:41.530351
541d28d9-31a0-4048-8fbe-973329de19af	TRICOLOR LA RICAURTE X12UNID	7707283880024	t	4600.00	\N	\N	\N	0.00	2025-10-19 02:29:41.530577	2025-10-19 02:29:41.530577
dd8b9e14-60f9-441a-840d-b9e8647e286a	YOGURT LITRO LA MEJOR  X3	7705241400611	t	16400.00	14600.00	14300.00	\N	19.00	2025-10-19 02:29:41.530836	2025-10-19 02:29:41.530836
5ea0c6dc-1273-4c1a-8d5d-d21e8dac6a32	ACEITE DE AGUACATE CAPILAR 70ML	7709753675345	t	2700.00	\N	\N	\N	0.00	2025-10-19 02:29:41.531066	2025-10-19 02:29:41.531066
49cab562-9b8b-4292-90f6-f9113a81fcf4	MAGGI SANCOCHO MI TIERRA 90GR	7702024064770	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.531297	2025-10-19 02:29:41.531297
e9610f95-db35-405f-8cc5-2f112a6c1971	PILAS VARTA TIPO D	4454540	t	4600.00	4400.00	\N	\N	0.00	2025-10-19 02:29:41.531542	2025-10-19 02:29:41.531542
c4756531-cb55-460c-8730-e46bdf64fbac	COLOR REY 500GR	7702175141030	t	9700.00	9370.00	\N	\N	0.00	2025-10-19 02:29:41.531784	2025-10-19 02:29:41.531784
0ae6091e-c1b1-4e00-838b-585e51fe8ccc	PONQUE RAMO NUEZ 230GR X6UNID	7702914110501	t	9000.00	8800.00	\N	\N	0.00	2025-10-19 02:29:41.532124	2025-10-19 02:29:41.532124
a30fe656-6b4e-4f4a-a35b-636b32f758db	PASTA RIOKA CONCHA 1.000GR	7705525092037	t	3400.00	3250.00	\N	\N	0.00	2025-10-19 02:29:41.53235	2025-10-19 02:29:41.53235
60fc2958-afa6-4ff1-bf03-c8478c8d7d85	GELATINA FRUIT JELLY X8UNID	7441163701169	t	4200.00	4100.00	\N	\N	19.00	2025-10-19 02:29:41.532642	2025-10-19 02:29:41.532642
4f2684b2-8ec7-4393-9a94-162437403c58	HIT MORA 1.5L	7702090041514	t	4500.00	4167.00	\N	\N	19.00	2025-10-19 02:29:41.533016	2025-10-19 02:29:41.533016
fd4a705c-c05f-4bcd-9017-e81f20e52be5	SHAMPOO PANTENE 300ML COLAGENO	7500435191425	t	16500.00	16250.00	\N	\N	19.00	2025-10-19 02:29:41.533325	2025-10-19 02:29:41.533325
1a83b0ca-d616-4d59-92cf-c29f8a4ee8b5	SPAGUETI RIOKA 1K	7705525091054	t	3400.00	3250.00	\N	\N	5.00	2025-10-19 02:29:41.533567	2025-10-19 02:29:41.533567
544d7564-3103-4004-805c-a6913fff2e9b	SAZONADOR LA SAZON 120GR PETPACK	7707767148374	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.533828	2025-10-19 02:29:41.533828
0bef3380-7e76-4a8a-8dd7-4bbfe3ed3f4b	AJO REY 55GR	7702175111231	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.534147	2025-10-19 02:29:41.534147
dd96c1e1-2b06-42cc-86a5-24ab241c0938	MAGGI CHOCLO SOPA 90GR	7702024534044	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:41.534856	2025-10-19 02:29:41.534856
4e05a8aa-3703-47f4-b675-27a4e7a14ba3	HOJILLA DORCO X5 HOJAS	8801038200026	t	1200.00	1000.00	\N	\N	19.00	2025-10-19 02:29:41.535116	2025-10-19 02:29:41.535116
46fd27ae-1b17-4698-b903-f42b1faaa2ac	TRULULU MASMELO CHOCO BANANO 65G	7702993043554	t	2000.00	1890.00	\N	\N	19.00	2025-10-19 02:29:41.535386	2025-10-19 02:29:41.535386
98d8fd5e-5e2e-41b7-ab32-d36da5b5e237	AVENA QUAKER HOJUELAS 400GR	7702193100927	t	5200.00	5000.00	\N	\N	5.00	2025-10-19 02:29:41.535636	2025-10-19 02:29:41.535636
5c2be350-c843-4dc1-8f9c-fe50aeb86fc2	AVENA QUAKER MOLIDA 400GR	7702193103102	t	4800.00	4690.00	\N	\N	0.00	2025-10-19 02:29:41.536069	2025-10-19 02:29:41.536069
1531b934-9cfd-4a6b-a8a0-8083aee37644	CREMA DERMOPROTECTORA BUBU 150GR	7704269115255	t	7500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.53637	2025-10-19 02:29:41.53637
79d89df3-45d0-4feb-b608-804842ce0aa1	CHOCOLATE CORONA 500GR VAINILLA	7702007043433	t	15500.00	15000.00	\N	\N	5.00	2025-10-19 02:29:41.536749	2025-10-19 02:29:41.536749
cdae1303-3b93-47c0-b302-64633fe17662	LA ESPECIAL KRAKS LIMON 32	7702007071658	t	1000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.537092	2025-10-19 02:29:41.537092
3aecbf5d-ae28-4e93-ac9b-e9404815e493	LA ESPECIAL PIMIENTA LIMON 40GR	7702007059892	t	1600.00	\N	\N	\N	0.00	2025-10-19 02:29:41.537441	2025-10-19 02:29:41.537441
a8e30226-f1f1-4bf0-8b74-1d6e88efa201	LA ESPECIAL ARANDAMIX 40GR	7702007063899	t	1800.00	\N	\N	\N	0.00	2025-10-19 02:29:41.537736	2025-10-19 02:29:41.537736
2863ab5b-3051-41f9-aa5a-aa6130a1afef	HOJA DE SEN LA SAZON DE LA VILLA 5GR	7707767143621	t	1200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.537965	2025-10-19 02:29:41.537965
cd92dcde-1794-4724-8139-7877a090a4ea	CREMA CHANTILLY ELITE 250GR	7709582770372	t	11700.00	11300.00	\N	\N	0.00	2025-10-19 02:29:41.538429	2025-10-19 02:29:41.538429
f21babb1-a5ea-4c9e-8ccb-94be02f75099	MIRRINGO 1.000GR	7703090732433	t	9500.00	9280.00	\N	\N	0.00	2025-10-19 02:29:41.538728	2025-10-19 02:29:41.538728
ff7203e8-65c5-44f5-b9f8-85fdfd89c088	3D DETERGENTE 3KILOS	7702191161289	t	24400.00	23900.00	\N	\N	19.00	2025-10-19 02:29:41.538964	2025-10-19 02:29:41.538964
7add353b-647d-4678-a494-606cdc26f04a	BIMBIJALDRES CROISSANT 60GR	7705326002150	t	1700.00	1570.00	\N	\N	19.00	2025-10-19 02:29:41.5392	2025-10-19 02:29:41.5392
f80a21ad-b793-4e33-928f-9d5883c9a7b8	PANQUE BIMBO X5	7705326091079	t	9300.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.539444	2025-10-19 02:29:41.539444
9aefc3c8-111d-4d80-bbab-37d20be42d30	TOALLIN FAMILIA ACOLCHAMAX GRANDES 44UNID	7702026177355	t	4300.00	4100.00	\N	\N	0.00	2025-10-19 02:29:41.539685	2025-10-19 02:29:41.539685
cb093bf7-0c21-4a23-9227-443c39bfc3b6	TOALLIN MIA 45UNID	7707151602765	t	1400.00	\N	\N	\N	0.00	2025-10-19 02:29:41.540238	2025-10-19 02:29:41.540238
49d07c1c-25c9-478a-a087-16574c6dd373	LIMPIADOR FACIAL POND X6	7702006403887	t	8200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.540478	2025-10-19 02:29:41.540478
27bfe3e6-362c-4615-83c3-e30eb74b4355	CREMA PARA PEINAR SEDAL MAS ANTITRANPIRANTE	7702006301534	t	12500.00	12200.00	\N	\N	19.00	2025-10-19 02:29:41.540742	2025-10-19 02:29:41.540742
20e518a4-dbc8-431c-b76b-59e710198e8f	LA ESPECIAL MIX YOGURT 35GR	7702007073454	t	1800.00	\N	\N	\N	0.00	2025-10-19 02:29:41.541087	2025-10-19 02:29:41.541087
4a1becc1-8c78-44be-9e09-022abacda01d	AROMATEL MANZANA VERDE 900ML	7702191161425	t	8200.00	8000.00	\N	\N	19.00	2025-10-19 02:29:41.541377	2025-10-19 02:29:41.541377
821d84e7-fbf3-4d82-8fa3-1470bf591e08	JABON BUBU CREMOSO 125GR	7704269488984	t	2400.00	2200.00	\N	\N	19.00	2025-10-19 02:29:41.541616	2025-10-19 02:29:41.541616
0b390eea-f8eb-4b3f-9774-44a2f6e43346	AMBIENTADOR AROMATICAL AEROSOL 400ML	7707738870259	t	7500.00	7000.00	\N	\N	0.00	2025-10-19 02:29:41.541885	2025-10-19 02:29:41.541885
9b604eca-3d01-4dd9-a7af-d1977ff659e5	AMBIENTADOR AROMATICAL AEROSOL 400ML	7707738870280	t	7500.00	7000.00	\N	\N	0.00	2025-10-19 02:29:41.542089	2025-10-19 02:29:41.542089
25cceee2-4aa2-4e69-b6fb-00496e128318	GLADE HAWAI 170GR	046500716935	t	5900.00	5600.00	\N	\N	0.00	2025-10-19 02:29:41.542332	2025-10-19 02:29:41.542332
41096d29-ae85-4212-ac6d-9af01e25effd	DOWNY CONCENTRADO 500ML	7506195143834	t	11500.00	11200.00	\N	\N	19.00	2025-10-19 02:29:41.542572	2025-10-19 02:29:41.542572
46e826bd-bf92-464f-8557-3398c8b36c94	AMBIENTADOR VARITAS BRISHEO 40ML	7704269558281	t	6000.00	5700.00	\N	\N	19.00	2025-10-19 02:29:41.542849	2025-10-19 02:29:41.542849
e1694d0b-5a7f-4980-a022-e488f4f75620	AMBIENTADOR VARITAS BRISHEO VAINILLA 40ML	7704269184992	t	5900.00	5700.00	\N	\N	19.00	2025-10-19 02:29:41.543101	2025-10-19 02:29:41.543101
5b151a5e-fbeb-4e94-a65d-9a25ec7dbb1d	GALLETA CANAMOR PERRO 150GR	7702487004474	t	3500.00	3400.00	\N	\N	0.00	2025-10-19 02:29:41.543332	2025-10-19 02:29:41.543332
036a5b50-dbc3-4bed-98c5-cad4d784cacc	GALLETAS MAGIC FRIENDS PERRO 150GR	7700304642779	t	3400.00	3250.00	\N	\N	0.00	2025-10-19 02:29:41.543577	2025-10-19 02:29:41.543577
bca6c642-6bc5-408b-9805-806762ab8665	GALLETAS MAGIC FRIENDS GATO 75GR	7700304586141	t	2600.00	2450.00	\N	\N	19.00	2025-10-19 02:29:41.543845	2025-10-19 02:29:41.543845
ff70176a-7737-446f-8f63-40a9525d8acc	CANAMOR GALLETA GATO 75GR	7702487003279	t	2600.00	2450.00	\N	\N	0.00	2025-10-19 02:29:41.544146	2025-10-19 02:29:41.544146
68e5649f-5414-404d-8a67-19a145f41bf9	ACEITE DE OLIVA GALERNA VIRGEN 500ML	7704269119710	t	16200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.544877	2025-10-19 02:29:41.544877
cb770a2c-4d92-4d8f-b725-0dbd36b018e1	HOSD ELIMINA OLORES 360ML	7700304925629	t	7000.00	6700.00	\N	\N	19.00	2025-10-19 02:29:41.5452	2025-10-19 02:29:41.5452
a92c7991-789e-4745-8126-f86c7648ed37	CREMA DERMO PROTECTORA LITTLE ANGEL 150GR	7700304514083	t	7400.00	7100.00	\N	\N	0.00	2025-10-19 02:29:41.545482	2025-10-19 02:29:41.545482
092e5fad-3784-496f-9b9d-f577ba526967	PAPEL RENDY X2UNID	7700304880393	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.545834	2025-10-19 02:29:41.545834
70480112-8ce3-4f0e-8f11-e83c6187a535	MESCLA PARA TORTA QUICKSY VAINILLA 400GER	7700304348343	t	6200.00	6000.00	\N	\N	0.00	2025-10-19 02:29:41.546249	2025-10-19 02:29:41.546249
98027f71-2711-40f0-8272-566a12b4f3a6	WHIKAS SABOR A POLLO 85GR	7896029047279	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.546561	2025-10-19 02:29:41.546561
0ac2ac85-30ec-42c0-aefb-95b752cdb7ac	PEDIGREE SABOR A CARNE 100GR	7896029018958	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.546903	2025-10-19 02:29:41.546903
b59497ac-54af-48e8-9c35-0e682a36f2fc	PEDIGREE SABOR A POLLO ASADO 100GR	706460249361	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.547229	2025-10-19 02:29:41.547229
4fb1d4b5-4cf2-499b-b02e-1b9b311f440d	TE VERDE HINDU X10UNID	7702746070325	t	4900.00	4760.00	\N	\N	0.00	2025-10-19 02:29:41.547526	2025-10-19 02:29:41.547526
f2be0972-f181-4b63-b4c0-3eb3d543f73a	POMOS DE ALGODON X50UNID NATURAL	7700304392223	t	3800.00	3650.00	\N	\N	19.00	2025-10-19 02:29:41.548009	2025-10-19 02:29:41.548009
0f3d6279-18c2-445a-a219-7b11c17b6f8c	PRESTOBARBA XEN X2UNID	7700304395316	t	3500.00	3350.00	\N	\N	19.00	2025-10-19 02:29:41.548427	2025-10-19 02:29:41.548427
56959bcd-2ed3-46a5-a200-01dcf0a9364f	JUMBO BROWNIE 18GR	7702007075212	t	900.00	\N	\N	\N	0.00	2025-10-19 02:29:41.549096	2025-10-19 02:29:41.549096
8d669516-ae29-45ea-a89f-a25730d39cb0	SALSA DULCE DE CEREZA TETERO 320GR	7709402221657	t	3200.00	3100.00	\N	\N	0.00	2025-10-19 02:29:41.549535	2025-10-19 02:29:41.549535
34313958-6b1f-4e6a-9a7e-85f44a88846e	SALSA DULCE DE PIÑA TETERO  320GR	7709402221664	t	3200.00	3100.00	\N	\N	0.00	2025-10-19 02:29:41.549808	2025-10-19 02:29:41.549808
26459243-d0f9-4365-8b0d-04231d45249b	SALSA DULCE DE KIWI TETERO 320GR	7709402221688	t	3200.00	3100.00	\N	\N	0.00	2025-10-19 02:29:41.550138	2025-10-19 02:29:41.550138
338ea253-2d2e-419d-ad64-fd9c50902278	AROMAX LIQUIDO MANZANA VERDE 180ML	7702354953249	t	1700.00	1630.00	\N	\N	19.00	2025-10-19 02:29:41.550423	2025-10-19 02:29:41.550423
1be365c2-7bab-4a05-bf0d-b8d808a8293e	CREMA CHANTILLY ELITE 500GR	7709582770365	t	22000.00	21400.00	\N	\N	0.00	2025-10-19 02:29:41.550692	2025-10-19 02:29:41.550692
5122ff30-4147-4160-9510-ab58a5cfa76e	CREMA CHANTILLY ELITE 1.000GR	457845	t	34900.00	34000.00	\N	\N	0.00	2025-10-19 02:29:41.550972	2025-10-19 02:29:41.550972
0bf7192c-6305-437f-87a1-9dd4a067a771	VITAFER L 20ML FRASCO	7707816989873	t	3400.00	\N	\N	\N	0.00	2025-10-19 02:29:41.551199	2025-10-19 02:29:41.551199
00bb9339-1566-4c66-9bbe-c6830a6567bf	VELON SAN JORGE N22	7707159821151	t	27400.00	26800.00	\N	\N	19.00	2025-10-19 02:29:41.551466	2025-10-19 02:29:41.551466
d0e94093-f416-4ab5-a223-3c13f55fd3a5	VELON SAN JORGE N16	7707159822028	t	13500.00	13100.00	\N	\N	19.00	2025-10-19 02:29:41.551952	2025-10-19 02:29:41.551952
c9c547ee-24bb-45a3-99ac-96bd26fdf936	SCOTT DURAMAX REUTILIZABLE X58UNID	7702425809703	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.552328	2025-10-19 02:29:41.552328
cb8dbb4c-0d5a-4944-8310-a2bd1d726e9f	FECULA DE MAIZ EXTRA SEÑORA 70GR	7708345181653	t	1300.00	1200.00	\N	\N	19.00	2025-10-19 02:29:41.552791	2025-10-19 02:29:41.552791
42a165b5-5f6c-4dc1-97f7-de2cd8029e61	RAYOL INSECTICIDA VOLADORES 230ML	7702532863131	t	8900.00	8600.00	\N	\N	0.00	2025-10-19 02:29:41.553105	2025-10-19 02:29:41.553105
3bf19194-7f45-4a77-ad79-428bb4801313	FAMA BEBE X3UNID 250GRCD	7701018065557	t	8400.00	\N	\N	\N	0.00	2025-10-19 02:29:41.553399	2025-10-19 02:29:41.553399
386d6f30-bd3c-4397-87e2-a0c20183d174	JABON FAMA COCO X3UNID	7701018065434	t	9100.00	\N	\N	\N	0.00	2025-10-19 02:29:41.553779	2025-10-19 02:29:41.553779
23fdfa94-6260-485c-a775-8c224bf77194	CANELA ESTILLA	45821	t	600.00	\N	\N	\N	0.00	2025-10-19 02:29:41.554682	2025-10-19 02:29:41.554682
f8cfab53-1d53-4f7a-b82a-ed6268007d41	SHAMPOO HEAD SHOULDERS 2EN1 375X2	7500435126847	t	34600.00	34600.00	\N	\N	19.00	2025-10-19 02:29:41.55539	2025-10-19 02:29:41.55539
5fdd713d-85b2-456c-82c8-a31ffd13134f	BESO AMOR NESTLE X28	7702024179627	t	23900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.555918	2025-10-19 02:29:41.555918
46dc1a2e-c63b-4ac9-ac1f-c6aa5757879b	TRULULU DURAZNOS 50GR	7702993043974	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.556325	2025-10-19 02:29:41.556325
a68ef7cb-50ab-4d18-ae82-dfa6b1e9ec10	GRANOLA 500GR HOLA DIA	7709990071238	t	6600.00	6400.00	\N	\N	19.00	2025-10-19 02:29:41.557025	2025-10-19 02:29:41.557025
7a36d038-6c88-41ee-8699-729cd1cf35d1	VASOS 5.5 OZ MARPLAT X50	7709198543698	t	2300.00	2200.00	\N	\N	19.00	2025-10-19 02:29:41.557735	2025-10-19 02:29:41.557735
d48448a8-10ad-4ee5-9710-c0e49e54493e	GELA PLAY YOLIS X25UNID 412GR	7709393325426	t	6900.00	6700.00	\N	\N	0.00	2025-10-19 02:29:41.558238	2025-10-19 02:29:41.558238
e0aa963c-ca28-47b3-884d-8b4090100350	ANIS ESTRELLADO	445745	t	600.00	\N	\N	\N	0.00	2025-10-19 02:29:41.558689	2025-10-19 02:29:41.558689
09cba643-14b8-43c9-bcff-56d15833d920	CLAVOS	4454472	t	600.00	\N	\N	\N	0.00	2025-10-19 02:29:41.559043	2025-10-19 02:29:41.559043
e835cea7-7a2f-4b41-b6b7-29c529ac1ef4	MISTOL PEQUEÑO	778475	t	1400.00	1300.00	\N	\N	0.00	2025-10-19 02:29:41.559371	2025-10-19 02:29:41.559371
c0338bab-f81e-495e-a5be-bf374a8c8738	CALDY GALLINA X12UNID	7707359310318	t	3700.00	\N	\N	\N	0.00	2025-10-19 02:29:41.559742	2025-10-19 02:29:41.559742
a6bcbfe0-f8f6-49f1-bbd0-097d6da9ae13	NESQUIK CHOCOLATE 200GR	7702024040040	t	5700.00	5545.00	\N	\N	0.00	2025-10-19 02:29:41.560015	2025-10-19 02:29:41.560015
6d966ebb-e5dc-42c8-b5fd-10d3871abda4	OKA LOKA REVOLCON CHICLE X50UNID	7702993028414	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.560381	2025-10-19 02:29:41.560381
37d29529-0c67-4eb6-b3e4-a3e97439c900	TRIDENT TROPICAL X18UNID	7622201776534	t	23500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.56065	2025-10-19 02:29:41.56065
a67597d1-7a3d-4ccd-884b-439f6ce8674c	TRIDENT SANDIA X18UNID	7622201776626	t	23500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.560954	2025-10-19 02:29:41.560954
7ebb4bbf-0725-4c57-b3d6-eff4942f6c7e	TRIDENT X18UNID FRESH HERBAL	7622201776503	t	23500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.561241	2025-10-19 02:29:41.561241
1e69f700-767f-42f7-900e-823f587b4906	CALDY GALLINA X60	7707359310714	t	19200.00	18700.00	\N	\N	19.00	2025-10-19 02:29:41.561506	2025-10-19 02:29:41.561506
72505d7c-0e68-499e-abb2-32c9cab414de	AZUCAR CARMELITA 1K	732064793184	t	4300.00	4240.00	\N	\N	0.00	2025-10-19 02:29:41.561792	2025-10-19 02:29:41.561792
05e482ff-c8aa-4890-9b4f-f298226e64dd	CRONCH FLAKES 240GR	7702807846463	t	6700.00	6500.00	\N	\N	19.00	2025-10-19 02:29:41.562111	2025-10-19 02:29:41.562111
eeaf97dd-468f-4db6-878a-ae0592feda0c	POOL PIÑA 400ML	7709004927759	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.562563	2025-10-19 02:29:41.562563
d0688b25-0b91-4c95-9d52-96d0eae86b97	DETODITO FLAMIN HOT 50GR	7492189057419	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.562873	2025-10-19 02:29:41.562873
30c3059f-bfa3-4b95-854a-9d02ba264d06	DETODITO FLAMINN HOT 50GR	7702189057419	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.563175	2025-10-19 02:29:41.563175
e10bf59e-0954-4737-99e7-a4da119bc60f	SUAVITEL ORQUIDEA 180ML	7509546676159	t	1500.00	1380.00	\N	\N	19.00	2025-10-19 02:29:41.563519	2025-10-19 02:29:41.563519
52c2465c-8f6a-44d8-b08f-57514a03bf51	GEL VALNIS CAPILAR 700GR	7709413484218	t	7600.00	7400.00	\N	\N	19.00	2025-10-19 02:29:41.563777	2025-10-19 02:29:41.563777
f4ea6bfd-4149-427f-9674-9473173683f8	CHOCOLATE CORONA TRADICIONAL 500GR	7702007064780	t	14600.00	14300.00	\N	\N	19.00	2025-10-19 02:29:41.564742	2025-10-19 02:29:41.564742
b6a8bfa9-a83b-43dc-ac70-cca8c93899af	STIME MENTAS X100UNID	7702011141132	t	8200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.565303	2025-10-19 02:29:41.565303
2c63c12e-2452-4005-8d7a-46264c4d01f2	TROLLI ANA CONDA 35GR	7702174083188	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.565571	2025-10-19 02:29:41.565571
7e7a7d7f-dcfd-4d85-9d70-e21cf4def25d	X RAY DOL ALIVIA DOLORES	45145	t	1700.00	1400.00	\N	\N	0.00	2025-10-19 02:29:41.565906	2025-10-19 02:29:41.565906
2b25efa5-70bc-4a5a-bd56-83eac3a323fa	PASTILLA PARA CUAJAR	4575214	t	700.00	\N	\N	\N	0.00	2025-10-19 02:29:41.566179	2025-10-19 02:29:41.566179
1b934172-8cf9-48e4-90de-53333aa43810	TUTTI FRUTTI SALPICON 400ML	7702090070033	t	1000.00	933.00	\N	\N	19.00	2025-10-19 02:29:41.566594	2025-10-19 02:29:41.566594
2f3c496b-767a-40f9-9bf5-40d598f71004	DISPLEY CUAJO X50	7707243922498	t	34500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.567288	2025-10-19 02:29:41.567288
73823969-6883-425d-92e2-ba95242e53f8	TRIDENT 8.5GR	7622201776633	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.567721	2025-10-19 02:29:41.567721
a98ab05d-ceb2-48c4-9b4e-e0e93b5c7564	LA ESPECIAL MANI PIMIENTA LIMON 180GR	7702007055269	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.568148	2025-10-19 02:29:41.568148
6989e5a1-1bee-4fef-a0d4-7e9bdb92eee5	FLIPS CHOCOLATE X6UNID	7591039504940	t	9200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.568814	2025-10-19 02:29:41.568814
86b576ff-c649-409a-aa53-b2cb1b6631a0	SHAMPOO SAVITAL 100ML ANTICASPA	7702006207928	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.570635	2025-10-19 02:29:41.570635
5f11a2f6-0df1-4cda-94e4-da6492211bc6	QUAKER BABY MULTICEREAL 25GR	7702193600212	t	800.00	700.00	\N	\N	19.00	2025-10-19 02:29:41.571607	2025-10-19 02:29:41.571607
b9c4333e-1773-44aa-b0e7-1059d4423fa8	GAVASSA CARACOLES 125GR	7707047400802	t	1000.00	900.00	\N	\N	5.00	2025-10-19 02:29:41.572114	2025-10-19 02:29:41.572114
24e92e65-abe1-4171-8c6e-ac0dcac682f6	ESPONJA PINTO OLLAS Y PARRILLA MULTIUSOS	7707112330560	t	4600.00	4400.00	\N	\N	0.00	2025-10-19 02:29:41.572475	2025-10-19 02:29:41.572475
5e7fefb5-1044-4f07-a12a-b74fdbb12230	ACEITE RIQUISIMO 900ML	7701018076256	t	9900.00	9584.00	\N	\N	19.00	2025-10-19 02:29:41.572728	2025-10-19 02:29:41.572728
3ae69172-7a1b-4c3b-8aa8-0bd82e971a0e	GAVASSA CODOS 125GR	7707047401106	t	1000.00	900.00	\N	\N	5.00	2025-10-19 02:29:41.573026	2025-10-19 02:29:41.573026
555bf833-2e6e-4034-941c-c54c3b2316e1	COOL A PED MENTOL 250ML	7708851548445	t	6800.00	6500.00	\N	\N	0.00	2025-10-19 02:29:41.573344	2025-10-19 02:29:41.573344
ca3c2f2b-73cc-4a58-bb9e-003bdc961f0c	TALLARINES 250GR	7707210026679	t	3100.00	2950.00	\N	\N	5.00	2025-10-19 02:29:41.573591	2025-10-19 02:29:41.573591
92c968d3-9859-4f42-9af0-ade9497c0163	WINNY 5X50	7701021116031	t	71000.00	70300.00	\N	\N	19.00	2025-10-19 02:29:41.573937	2025-10-19 02:29:41.573937
879beb46-685d-4389-b1b8-6231ab3eec93	FRUTY AROS KARIMBA 500GR	7702807378650	t	12300.00	11900.00	\N	\N	19.00	2025-10-19 02:29:41.574251	2025-10-19 02:29:41.574251
3feb2fac-becd-4819-94eb-e181320ece6e	ALUMINIO TUC CAJA 13MT	7702251057736	t	6300.00	6150.00	\N	\N	19.00	2025-10-19 02:29:41.574554	2025-10-19 02:29:41.574554
4b997ed7-04ae-4bec-a8cc-d80744c1e12b	CREMA CORPORAL NATURAL FEELINGS BOTANICALS COCO 500ML	7700304364268	t	9600.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.57489	2025-10-19 02:29:41.57489
a0d3c472-50f9-4e95-9ae9-e7715a548183	ESPONJA PELUSA EL REY	7707178731189	t	1400.00	1250.00	\N	\N	19.00	2025-10-19 02:29:41.575231	2025-10-19 02:29:41.575231
109e56b1-8271-44b1-9118-31f09f584226	OREO 12X4 CHOCOLATE 432GR	7750168000581	t	11000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.575697	2025-10-19 02:29:41.575697
bd96a3d0-766a-482f-93d8-dc5e06ae62dd	FROOT LOOPS KELLOGGS 250GR	7591058016110	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:41.576108	2025-10-19 02:29:41.576108
3c9680e2-91eb-4e99-b8e8-81faf7f48415	TOSH AJONJOLI 9X3	7702025148578	t	7400.00	7000.00	\N	\N	19.00	2025-10-19 02:29:41.576395	2025-10-19 02:29:41.576395
08e367d9-f806-405f-8532-e2f662c9ce18	MILO NESTLE SANDWICH 12X4	7702024067849	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.576797	2025-10-19 02:29:41.576797
5952d616-e191-466b-9180-ef7f6e0f8dab	ESENCIA LEVAPAN COCO 60ML	77088529	t	4900.00	4740.00	\N	\N	19.00	2025-10-19 02:29:41.577024	2025-10-19 02:29:41.577024
3b1baff1-2ed7-4552-bf52-15803e3be66a	COMPOTA SAN JORGE MELOCOTON 113GR	7702014566017	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.577324	2025-10-19 02:29:41.577324
a175a5aa-e667-4246-9bb1-af3b7e11f388	SALERO MUNDI UTIL	7709134320420	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.577649	2025-10-19 02:29:41.577649
f5313e87-698c-4382-bd4e-377f3b72e748	FLAN GELHADA PIÑA 60GR	7702014525120	t	3400.00	3285.00	\N	\N	19.00	2025-10-19 02:29:41.578008	2025-10-19 02:29:41.578008
4887ae94-5779-46cf-b08a-1df887d2957c	JUMBO MANI X24UNID 960GR	7702007512496	t	58700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.578351	2025-10-19 02:29:41.578351
d8383485-8699-4ef2-8ce3-0df6bd9d08b1	JUMBO MANI MINI X24UNID 432GR	7702007080346	t	32000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.578694	2025-10-19 02:29:41.578694
1265f4bd-1a23-40fa-b7af-5fb758a05f4d	CREMA DE LECHE COLANTA 175GR	7702129009102	t	3800.00	3700.00	\N	\N	0.00	2025-10-19 02:29:41.579305	2025-10-19 02:29:41.579305
cbda4ee4-542e-48b6-bac9-e54ee6a2ed8f	MOSTAZA COLMANS 200GR	7708001730898	t	4400.00	4250.00	\N	\N	19.00	2025-10-19 02:29:41.579618	2025-10-19 02:29:41.579618
1fd31656-3370-4e9e-bae0-947a931ed5c1	BOCADILLO COMBINADO 400GR	457582	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.579911	2025-10-19 02:29:41.579911
4ccc1b6b-37d8-49ab-9c19-9bc70d95a501	MACARRON RIOKA 1K	7705525090354	t	3400.00	3250.00	\N	\N	5.00	2025-10-19 02:29:41.580226	2025-10-19 02:29:41.580226
09dcaa11-17b5-40e8-89a5-9a50e2d9aa89	GEL VALNIS CAPILAR 150GR	7709044633788	t	2200.00	2050.00	\N	\N	19.00	2025-10-19 02:29:41.58052	2025-10-19 02:29:41.58052
176408ea-1d4d-46e2-a669-98f5cd3c1d00	ARIEL REVITACOLOR 800GR	7500435149631	t	10500.00	10200.00	\N	\N	19.00	2025-10-19 02:29:41.581011	2025-10-19 02:29:41.581011
6625127e-5aa6-4168-b31b-ecfc0f6e5319	CARACOLES MARYPAS 1.000GR	7707047400888	t	4300.00	4167.00	\N	\N	5.00	2025-10-19 02:29:41.581376	2025-10-19 02:29:41.581376
8bc51fe6-b89f-476c-a7f7-2dc2370556cd	MACARRON MARYPAS 1.000GR	7707047400369	t	4300.00	4167.00	\N	\N	5.00	2025-10-19 02:29:41.581702	2025-10-19 02:29:41.581702
6772af2f-302b-494c-b63b-ba3082cef558	AROMATICAL SACHET DE AROMA	7707738873410	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.581986	2025-10-19 02:29:41.581986
16cef148-6bb6-47d6-aba7-4bcffe9fbbb3	LEFRIT MANTECA 500GR	7701018004556	t	8200.00	8000.00	\N	\N	19.00	2025-10-19 02:29:41.58228	2025-10-19 02:29:41.58228
35c3308c-30d7-45c9-bdf1-3604f122686e	NECTAR VITTA MANZANA 200ML	7707262683936	t	1200.00	1000.00	\N	\N	19.00	2025-10-19 02:29:41.582549	2025-10-19 02:29:41.582549
0cd194cc-0475-42a7-8ff4-b2d2e75ec565	AROMATEL MANZANA 2.5L	7702191161340	t	19600.00	19200.00	\N	\N	19.00	2025-10-19 02:29:41.58282	2025-10-19 02:29:41.58282
e8b7a9a5-e453-40d2-adb5-3e2e00e4e00e	SALCHICHON FINO MONTEFRIO 450GR	7702129073684	t	7300.00	7200.00	\N	\N	5.00	2025-10-19 02:29:41.583088	2025-10-19 02:29:41.583088
6d13c141-dcba-4961-8ff7-d23ff4150165	GOMITAS BARRILETE 50GR	7702993046869	t	1400.00	1100.00	\N	\N	19.00	2025-10-19 02:29:41.583366	2025-10-19 02:29:41.583366
e713c87f-a4c4-400b-8e73-ce12e9b049b6	MARGARITA POLLO X12	7702189008916	t	19400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.583928	2025-10-19 02:29:41.583928
ca4a64b9-ca31-4d07-bee9-58c3e0986ea7	OREADA MAYONESA	7706642004422	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.584344	2025-10-19 02:29:41.584344
ff0aa1dc-0e40-4f8f-9089-436b2bc9b072	TRUÑUÑU GOMITAS DINO 90GR	7702993030646	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:41.584683	2025-10-19 02:29:41.584683
006767b0-2b66-41f6-9a58-fc3aa7fbed9f	JABON INTIMO FRESH Y FREE 300ML	7700304302222	t	5000.00	4600.00	\N	\N	19.00	2025-10-19 02:29:41.584934	2025-10-19 02:29:41.584934
e0e16f18-5d6f-4c5d-bc87-5d6edfd53362	BEBEX   XXG 5  X30UNIDE	7707199345594	t	35200.00	34600.00	\N	\N	19.00	2025-10-19 02:29:41.585156	2025-10-19 02:29:41.585156
d4daeaa8-08ab-4ba5-b298-a35dc08ed78c	BICARBONATO	44775548752	t	600.00	\N	\N	\N	0.00	2025-10-19 02:29:41.585425	2025-10-19 02:29:41.585425
f17188da-834d-4b51-8568-ee46ddd1c6e0	JET COOKIES AND CREAM X2UNID	7702007042290	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.585726	2025-10-19 02:29:41.585726
eb1b0035-9539-4655-b875-22d2fd1c75e1	MAYONESA BARY 80GR	7702439950286	t	900.00	767.00	\N	\N	19.00	2025-10-19 02:29:41.585936	2025-10-19 02:29:41.585936
c183b88b-c2e1-466b-af2e-461cd549e7c0	PETYS SHAMPOO REPELENTE 235ML	7702026184506	t	20800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.586229	2025-10-19 02:29:41.586229
0be4f27b-30e9-4066-a97e-556cebc11c2a	MOSTAZA OCAÑERITA 4.000GR	7709025282431	t	12500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.586493	2025-10-19 02:29:41.586493
f905bd77-1f79-4a19-bddc-790d23a7f28c	LISTERINE CONTROL CALCULOSARRO 500ML	7702035432445	t	23400.00	22800.00	\N	\N	19.00	2025-10-19 02:29:41.586756	2025-10-19 02:29:41.586756
26e7da01-e5e0-463f-aa1b-77d6bfe4d601	LISTERINA CUIDADO TOTAL MENTA FRESCA 500ML	7702035833839	t	22500.00	22500.00	\N	\N	19.00	2025-10-19 02:29:41.586998	2025-10-19 02:29:41.586998
b2a29e6e-2abf-4492-93f8-f95082b59b5a	HOJAS DE SEN	45475	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.587241	2025-10-19 02:29:41.587241
c0644e7b-f7fa-452e-b1f2-d86cd1d252cd	JUMBO DOTS 30GR	7702007044133	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.587495	2025-10-19 02:29:41.587495
7fecc61d-33c2-4914-82e4-56a6c4c26fe7	SALTIN NOEL X4 UNID MAS 2 TACOS DE MANTEQUILLA	7702025148264	t	8800.00	8600.00	\N	\N	19.00	2025-10-19 02:29:41.587747	2025-10-19 02:29:41.587747
464e72e5-a5cc-4c70-ac7d-174aa93b92d0	MINICHIPS FESTIVAL X8UNID	7702025142903	t	11500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.587996	2025-10-19 02:29:41.587996
e2951633-9c88-416b-a4d3-ebe8113b2f1a	CHOCOLISTO CHOCOLATE 1.160 BOLSA	7702007050974	t	33700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.588277	2025-10-19 02:29:41.588277
6ab299d7-9220-4c9c-9a4b-bc866aeee7f1	CEPILLO ORAL B MACIA SUAVE X3UNID	3014260846800	t	15800.00	15200.00	\N	\N	19.00	2025-10-19 02:29:41.588512	2025-10-19 02:29:41.588512
9ba31b1f-71fe-425a-b7bd-620e4d37291d	CREMA CHANTILLY ELITE 1K	7709582770341	t	34900.00	34000.00	\N	\N	19.00	2025-10-19 02:29:41.588769	2025-10-19 02:29:41.588769
9ad4ac31-2923-4b39-afb3-d1aad7c8ee53	ACEITE GOURMET FAMILIA MULTIUSO 2.600ML	7702141986054	t	49200.00	48800.00	\N	\N	19.00	2025-10-19 02:29:41.58906	2025-10-19 02:29:41.58906
f02b15fa-fe8e-415b-800c-c5533bae51b2	ACONDICIONADOR SEDAL CERAMIDAS 340ML	7506306237902	t	11500.00	10800.00	\N	\N	19.00	2025-10-19 02:29:41.58931	2025-10-19 02:29:41.58931
66622bd4-f812-4cc0-a753-315adc1b6054	ACONDICIONADOR SEDAL KERATINA CON ANTIOXIDANTE 340ML	7506306237940	t	13800.00	13300.00	\N	\N	19.00	2025-10-19 02:29:41.589685	2025-10-19 02:29:41.589685
6633b664-9e6e-4001-a9e2-7acd6e2ad775	PAÑITOS LIMPION X10UNID	7703731324140	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.589971	2025-10-19 02:29:41.589971
fa4f064f-1727-44cf-86c4-f617a7d62c06	SHAMPOO GOHNSONS FUERZA Y VITAMINA 400ML	7702031293620	t	21800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.590288	2025-10-19 02:29:41.590288
4ee9f782-d7fa-4448-8aca-a4e43a62177e	MANTECA FRITURA 2.000GR	7706649065945	t	27000.00	26600.00	\N	\N	19.00	2025-10-19 02:29:41.590594	2025-10-19 02:29:41.590594
49314b05-bb96-4286-aa6c-6892d381268c	LISTERINE WHITENG EXTREME 473ML	7702031618744	t	21700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.590882	2025-10-19 02:29:41.590882
fc76131a-fbb1-41ca-b898-987b5b8be4dd	TERAPIA CAPILAR ANYELUZ 300ML	7709022735183	t	35000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.59113	2025-10-19 02:29:41.59113
dd37ab7f-c348-4763-a7dc-403fd13925c1	SHAMPOO CON ACONDICIONADOR MON AMI PET 250ML	7702158956545	t	15700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.591427	2025-10-19 02:29:41.591427
fbfac798-2239-4e14-9da1-2c56daa4fd21	CHOCOLISTO GALLETA MASMELO 180GR	7702007074109	t	4300.00	4100.00	\N	\N	19.00	2025-10-19 02:29:41.591785	2025-10-19 02:29:41.591785
200ce623-97c8-4020-aabe-63418421b428	LA ESPECIAL ARANDAMIX X9UNID	7702007050493	t	13700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.592009	2025-10-19 02:29:41.592009
153a3326-e448-4f96-aac4-1bb5712be566	SALSA DE AJO NORSAN 1.000GR	7709609979566	t	6400.00	6200.00	\N	\N	19.00	2025-10-19 02:29:41.592234	2025-10-19 02:29:41.592234
c79c017b-35aa-4394-8423-8c49f6dc39f6	ALOKADOS X100UNID	7707014902407	t	6900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.592451	2025-10-19 02:29:41.592451
3e430511-999e-43a8-9630-5b196b275241	SUPERCOCO TURRON X50UNID	7702993030639	t	7800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.592708	2025-10-19 02:29:41.592708
3d9d6e93-7b63-40e9-9d5a-a5d43fad09a6	PAPAS ONDITAS SUPER RICAS 1050GR	7702152118987	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.592917	2025-10-19 02:29:41.592917
82b3a4e5-3c21-4a9f-bf9c-9f3d2d0a2a1a	PRESTOBARBA XEN X2UNID	7700304868186	t	3500.00	3350.00	\N	\N	19.00	2025-10-19 02:29:41.59327	2025-10-19 02:29:41.59327
b3c37073-fa11-4595-a6e3-594a05ed168d	GALA TRADICONAL X5UNID	7702914597999	t	9700.00	9600.00	\N	\N	19.00	2025-10-19 02:29:41.593495	2025-10-19 02:29:41.593495
c27069c9-3988-4f7b-83db-d710f124ddea	CHOCORAMO MITI X5UNID	7702914601665	t	9000.00	8800.00	\N	\N	19.00	2025-10-19 02:29:41.593709	2025-10-19 02:29:41.593709
e6a43e84-ff47-4e40-ae62-901571ee1792	CHOCORAMO BROWHINE X6UNID	7702914600446	t	16800.00	16600.00	\N	\N	19.00	2025-10-19 02:29:41.593929	2025-10-19 02:29:41.593929
52e63a58-3d17-4a3e-82c8-1f361c0fc732	CHOCORAMO MINI BROWHINE X12	7702914602310	t	10800.00	10600.00	\N	\N	19.00	2025-10-19 02:29:41.594179	2025-10-19 02:29:41.594179
d22b227c-6233-4272-9cc0-870731ed9fed	ROSAL ULTRACONFORT XXG X12	7702120014174	t	17500.00	17000.00	\N	\N	19.00	2025-10-19 02:29:41.594396	2025-10-19 02:29:41.594396
ca0e9260-a0ab-47e0-b28c-2dffe8626a64	PIMIENTA MOLIDA EL REY 60	7702175108101	t	2800.00	2400.00	\N	\N	19.00	2025-10-19 02:29:41.594606	2025-10-19 02:29:41.594606
7de8aa2a-48f6-40db-82b4-fb6e7a1ba0ad	MANI MOTO 528GR X12UNID	7702189057747	t	15900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.594827	2025-10-19 02:29:41.594827
460cf86f-6eec-4f90-bff4-1348ba4d434c	MANI MOTO 44GR	7702189057730	t	1500.00	1325.00	\N	\N	19.00	2025-10-19 02:29:41.59507	2025-10-19 02:29:41.59507
8699f099-2b4a-4222-8c9d-a32064f7b41e	FRUTICAS CARAMELO BLANDO X100UNI	7702011125880	t	7900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.595292	2025-10-19 02:29:41.595292
6766d1e2-a647-4f14-84bf-e0c65f7705a6	JET SABORES SURTIDOS X35UNID 1.050GR	7702007052879	t	54000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.595521	2025-10-19 02:29:41.595521
16b9fbc7-116e-4d39-8e37-a3096c21dc63	AZUCAR RISARALDA 1K	7707197483427	t	4300.00	4240.00	\N	\N	5.00	2025-10-19 02:29:41.595734	2025-10-19 02:29:41.595734
9b13dd31-3f00-47c1-be2f-eb50d12a149d	BLANQUEADOR BONAI CON FRAGANCIA 2000ML	7707426917440	t	4000.00	3850.00	\N	\N	19.00	2025-10-19 02:29:41.595968	2025-10-19 02:29:41.595968
6039cb9c-ea22-41a3-826e-2fb2cbca0562	TROMPOS MALLA X15	7709120645896	t	6400.00	6100.00	\N	\N	19.00	2025-10-19 02:29:41.596196	2025-10-19 02:29:41.596196
74f48e4b-2218-4a03-ab3e-04aee6f5906e	APRONAX	45786	t	1500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.59645	2025-10-19 02:29:41.59645
3350f545-72dd-4e13-8747-4a3705b6fcef	CREMA DE LECHE PARMALAT 1.100ML	7700604045348	t	19400.00	19000.00	\N	\N	0.00	2025-10-19 02:29:41.596696	2025-10-19 02:29:41.596696
bf123e9f-fb88-42a1-98b3-a84d0627f5d5	AROMAX LIQUIDO 500ML	7702354953232	t	4100.00	3950.00	\N	\N	19.00	2025-10-19 02:29:41.596977	2025-10-19 02:29:41.596977
c34b682d-3fea-4a5d-98c0-c9681ba8bc18	FIDEOS RIOKA 1K	7705525093089	t	3400.00	3250.00	\N	\N	5.00	2025-10-19 02:29:41.597189	2025-10-19 02:29:41.597189
cff19937-ad79-48b8-8d88-385403cbd125	CEPILLO CORONA ENBASE	7707202223826	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:41.59742	2025-10-19 02:29:41.59742
8662c0ab-840e-4c6e-905c-40177cef5d0e	2000	ANITA PRINCESS CHOCOLATE	t	1900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.597638	2025-10-19 02:29:41.597638
74abecdb-2779-4a2f-b3c7-3968ab5a134f	SHAMPOO JOHNSONS GOTA BRILLO 1000ML	37702031293644	t	38000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.597863	2025-10-19 02:29:41.597863
16d81b42-1c6c-4532-8678-5e7ce840490a	SHAMPOO JOHNSONS GOTA BRILLO 1000ML	7702031293644	t	36000.00	35770.00	\N	\N	19.00	2025-10-19 02:29:41.598084	2025-10-19 02:29:41.598084
5ddf9716-55ce-40b0-b213-fcac525f8d0d	GALA RAMO 60GR	7702914597968	t	2300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.598306	2025-10-19 02:29:41.598306
b3855af7-5c66-462c-ae03-d24e29d716a9	PROTEX MACADAMIA 110GR	7702010420917	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:41.598532	2025-10-19 02:29:41.598532
07797af3-4fd5-436d-ae4a-18bf162e42fd	ENJUAGUE BUCAL VALNIS 180ML	7709044633764	t	2900.00	2800.00	\N	\N	19.00	2025-10-19 02:29:41.598753	2025-10-19 02:29:41.598753
2907f94b-0a48-4bba-8ed3-c6eb56a087bc	JABON INTIMO ROSE MANZANILLA 400ML	7704269629790	t	6500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.598969	2025-10-19 02:29:41.598969
19f0bef9-0501-4575-951a-b52db9d79ccb	PRESTOBARBA BIC AZUL	703307175340	t	2200.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.599169	2025-10-19 02:29:41.599169
61d86170-34d5-4d57-8e0a-bd398a28ea34	MANTECA DE CACAO LABIAL	7707271202401	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:41.599389	2025-10-19 02:29:41.599389
5d4cb06a-5f89-432e-9b53-a1e0a745bd1d	SHAMPOO TIO NACHO ACLARANTE 1LITRO	650240029202	t	33500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.599602	2025-10-19 02:29:41.599602
25d4be03-0756-4183-9391-659074789bc6	ARROZ PALACIO 1.00GR	7709990854275	t	3500.00	3400.00	\N	\N	0.00	2025-10-19 02:29:41.599803	2025-10-19 02:29:41.599803
50deb28b-ce05-4e40-8fff-af43f6a76914	GEL ROLDA BLACK 500GR	7592871003554	t	12700.00	12300.00	\N	\N	19.00	2025-10-19 02:29:41.600127	2025-10-19 02:29:41.600127
8cd213ba-5318-4bae-acfa-cbaca1080e06	COPITO PETETIN X100	7890266281007	t	3000.00	2850.00	\N	\N	19.00	2025-10-19 02:29:41.600359	2025-10-19 02:29:41.600359
a47eeb66-e416-43ac-8363-290c723e7457	HEAD SHOULDERS DERMO 1.000ML	7500435184540	t	39800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.600868	2025-10-19 02:29:41.600868
54de29bc-e4ef-437c-abd3-65681c7023f0	HEADSHOULDERS LIMPIEZA Y REVITALIZACION 1.000ML	7500435202688	t	39800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.601221	2025-10-19 02:29:41.601221
8d439250-1756-46f2-927e-dcf68632a992	CREMA PARA PEINA SAVITAL RIZO  275ML	7702006206044	t	13000.00	12700.00	\N	\N	19.00	2025-10-19 02:29:41.601537	2025-10-19 02:29:41.601537
1e6c5c86-6ca3-4478-a4cf-46b8c7a6e1a3	HEAD SHOULDERS ACEITE DE COCO 300ML	7500435142588	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.601823	2025-10-19 02:29:41.601823
b137a675-63ff-4423-bd44-5096c625ed06	CREMA PARA PEINAR PANTENE 300ML	7500435155915	t	17500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.60206	2025-10-19 02:29:41.60206
eb59d0c5-40bb-4160-a140-f94a245adf92	SHAMPOO ACONDICIONADOR CREMA  MUSS	7702113620689	t	34500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.602385	2025-10-19 02:29:41.602385
f0015f75-bd62-402c-9643-4c2166f93a98	REXONA CLINICAL MEN AEROSOL 150ML	7791293037141	t	17500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.602648	2025-10-19 02:29:41.602648
e0770f78-bb31-40a1-90c7-5f904f1f8660	SPEED STICK CLINICAL AEROSOL 150ML	7509546074009	t	14500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.602858	2025-10-19 02:29:41.602858
f24852fe-df69-4534-b506-31c4b6af5a02	SPEED STICK STREME ULTRA AEROSOL 150ML	7509546063706	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.603098	2025-10-19 02:29:41.603098
8836897f-5e6e-47e0-96f8-4a432da577ec	KINDER BUENO X2UNID	80052760	t	6700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.603432	2025-10-19 02:29:41.603432
5b884655-dfad-43e7-88c7-5dc08a6be7c0	CHOCO EGGS X30UNID	7709287925695	t	22000.00	21600.00	\N	\N	19.00	2025-10-19 02:29:41.603716	2025-10-19 02:29:41.603716
2c5cca1d-ef4b-4494-89b7-1e394a8501de	SUAVIZANTE MI DIA 1000ML	7705946684293	t	5000.00	4900.00	\N	\N	19.00	2025-10-19 02:29:41.604045	2025-10-19 02:29:41.604045
57cfaec3-e974-4e94-8c2d-e7e648ec70f9	SHAMPOO RECAMIER SALON IN 1LITRO	7702113003338	t	25000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.604349	2025-10-19 02:29:41.604349
2d307edc-03d6-4d2a-80ab-416faadec518	ROCIO DE ORO RENE 150ML	7709947068687	t	16500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.604582	2025-10-19 02:29:41.604582
90e13731-cf5a-4552-b330-adfe715ed072	ROCIO DE ORO SHAMPO ACLARADOR 500ML	7709947068670	t	19000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.604813	2025-10-19 02:29:41.604813
3ec1b6b3-c725-4a18-9c62-5177be9f3dfc	SHAMPOO SALOME DUO 400ML MAS 200ML	7707188220314	t	24500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.605014	2025-10-19 02:29:41.605014
6bcf615b-b2d0-4d43-b532-fe98a4b7fe50	SALSA DE AJO DELSAZON 1LITRO	7704412186057	t	7900.00	7680.00	\N	\N	19.00	2025-10-19 02:29:41.605406	2025-10-19 02:29:41.605406
16aaaa32-79bd-4f43-994a-37a69c619f4c	ANITA PRINCESS CHOCOLATE	8690481023012	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:41.605625	2025-10-19 02:29:41.605625
1512f69d-9660-4dcd-a9b2-b5d2b63cd22c	MOSTAZA LA CONSTANCIA 150GR	7702097163486	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:41.605824	2025-10-19 02:29:41.605824
2a66870c-16de-4438-a881-fa314d1c19ae	MOSTAZA LA CONSTANCIA 85GR	7702097148605	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:41.60609	2025-10-19 02:29:41.60609
5f430820-f86a-4ac3-b60f-ac415d2d2968	PALILLOS CHEVERE 125UNID	7707339930949	t	1400.00	1260.00	\N	\N	19.00	2025-10-19 02:29:41.606321	2025-10-19 02:29:41.606321
da018cbb-d2bb-4771-a685-2c65a61bd437	PALILLOS DE DIENTE EL SOL	7707015506093	t	800.00	675.00	\N	\N	19.00	2025-10-19 02:29:41.606534	2025-10-19 02:29:41.606534
bc6813c7-56d8-4d44-90fc-35a59d749ca0	ATUN LA SOBERANA AHUMADO	7862910032396	t	6000.00	5870.00	\N	\N	19.00	2025-10-19 02:29:41.606747	2025-10-19 02:29:41.606747
c1c744b8-84cd-477c-a06f-33b6a2deca36	PILAS EVEREADY CARBON	74587	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:41.606984	2025-10-19 02:29:41.606984
0b3d1693-03c1-4b4f-bde1-7b71bce5f8b5	ADOBO NATURAL LA SAZON VILLA 50GR	7707767141368	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.60721	2025-10-19 02:29:41.60721
10240df0-f7d6-4ffd-af67-bf0e96746923	SKALA DONA SKALA 2EN1	7897042013180	t	29500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.607438	2025-10-19 02:29:41.607438
ae45a690-52df-4c53-b864-c6eb168e46ab	ARVEJA SUDESPESA 460GR AMARILLA	7707309250022	t	2100.00	2000.00	\N	\N	0.00	2025-10-19 02:29:41.607752	2025-10-19 02:29:41.607752
fc6cff03-82d8-4b81-92c0-a2839e960207	CAREY AVENA CALENDULA 110GR	7702310022385	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.607945	2025-10-19 02:29:41.607945
36e72483-2d18-4792-b8b5-8e4f314caf1b	PROTEX CARBON 110GR	7509546680422	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:41.608143	2025-10-19 02:29:41.608143
b608d738-08ec-49e5-a1cd-de8642d2a055	BABY QUAKER AVENA BABABA 100GR	7702193605132	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.60838	2025-10-19 02:29:41.60838
a25576c2-d897-479f-868c-027d3b9aa90c	FRESCAVENA QUAKER 180GR	7702193502257	t	4300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.608577	2025-10-19 02:29:41.608577
6c041dc0-c964-40be-bc7f-d8140fdc8907	MANI KRAKS CHILE LIMON X12UNID	7702007074666	t	11500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.608807	2025-10-19 02:29:41.608807
19565635-28f9-4c49-8c0f-222716c3e454	MANY CON SAL BARY 180GR	7702439225773	t	5100.00	4950.00	\N	\N	19.00	2025-10-19 02:29:41.609061	2025-10-19 02:29:41.609061
541f65aa-843d-491b-ba16-4030ef0a8ba0	BARBIE MIX STEEL ROLLO X6UNID	7703888579790	t	15400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.609284	2025-10-19 02:29:41.609284
99703b8c-28e4-492f-a08c-9269dedcc58c	SHAMPOO CON ROMERO ANYELUZ 500ML	7709252169536	t	36000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.60949	2025-10-19 02:29:41.60949
2bbef359-dd74-47bf-9579-0a26f09d4f97	PAPEL ALUMINIO CAJA 16M SUPER BLUE	734191236190	t	5400.00	5180.00	\N	\N	19.00	2025-10-19 02:29:41.609698	2025-10-19 02:29:41.609698
c5006a61-73bc-4c94-a374-bfc145112d6e	RINDEX MULTI BENEFICIOS 2KG	7500435150583	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.609939	2025-10-19 02:29:41.609939
5145651b-8284-4fb0-9d04-e1abeeb6126c	CHAMPIÑONES TAJADOS ZENU 230GR	7701101360224	t	7600.00	7350.00	\N	\N	19.00	2025-10-19 02:29:41.610144	2025-10-19 02:29:41.610144
1e2d275c-bfef-4705-92ac-6be43034cf7d	AROMATEL COCO DOY PACK 1.4	7702191521243	t	10800.00	10400.00	\N	\N	19.00	2025-10-19 02:29:41.610373	2025-10-19 02:29:41.610373
cf8cfcc4-a82c-4de6-87db-ae2af19109b8	AROMATEL COCO TARRO 2 5 LITROS	7702191164228	t	19600.00	19200.00	\N	\N	19.00	2025-10-19 02:29:41.610585	2025-10-19 02:29:41.610585
7a7d6622-76ec-4b72-ad89-1b112e5e7fc0	LIENZO ULTRA  SEC X70UNID	7709659686254	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.610824	2025-10-19 02:29:41.610824
a3dda010-48b6-4162-a8e4-64cffd3b1ce1	CERAMIEL 120GR	7707271600061	t	11600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.611041	2025-10-19 02:29:41.611041
623c04e8-bdbe-4525-b2a3-77a521aaee37	CERAMIEL 240GR	7707271600047	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.611265	2025-10-19 02:29:41.611265
29280aaf-ae2a-486f-a0e8-c6c499a6fd1d	CERAMIEL 500GR	7707271600023	t	29500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.611454	2025-10-19 02:29:41.611454
df92ebd0-ac96-4620-9c75-f192f3118781	LIENZO MAS PALETA	0303030	t	3200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.611662	2025-10-19 02:29:41.611662
84575206-786b-4fd8-ad2f-d277517458f5	DOÑA GALLINA X24UNID	7702354949778	t	9400.00	9100.00	\N	\N	19.00	2025-10-19 02:29:41.611866	2025-10-19 02:29:41.611866
03d6f128-1ab6-4180-a188-dde2ee638da7	HARINA DEL SOL 1.000GR	781100165799	t	3500.00	3400.00	\N	\N	5.00	2025-10-19 02:29:41.612107	2025-10-19 02:29:41.612107
73eb5e1f-6c33-4148-9a9d-34b46a979859	SASONES TRISASON 20GR	7702354024819	t	1000.00	892.00	\N	\N	19.00	2025-10-19 02:29:41.612335	2025-10-19 02:29:41.612335
214cb610-7061-465e-a5ed-40fa69de1d30	RICOSTILLA X24UNID	7702354949549	t	9400.00	9100.00	\N	\N	19.00	2025-10-19 02:29:41.612533	2025-10-19 02:29:41.612533
11826d24-87bd-4669-8ed0-f170aa752b64	FORTIDENT X3 UNID 128CU	7702006404877	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.612734	2025-10-19 02:29:41.612734
9a9aa3f4-c607-4706-ab52-a17e7daa2676	ARANDAMIX LA ESPECIAL	7702007050486	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.613086	2025-10-19 02:29:41.613086
a31eaf6b-25a5-414e-ac98-ba11153be26f	SPAGHETTI GRUESO GAVASSA 250GR	7707047400062	t	2000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.613318	2025-10-19 02:29:41.613318
fcaac6da-5d7f-44c8-8da1-828896c9bd0c	FIDEOS DE SOPA GAVASSA 250GR	7707047400512	t	2000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.613516	2025-10-19 02:29:41.613516
ed710fba-ae3a-4e5a-865b-3a1ebda1110e	MANZANITAS X25UNID	4543	t	6800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.613734	2025-10-19 02:29:41.613734
ab86ad23-d6e0-4e33-b70a-1d7bffb0885d	ACEITE ORO SOYA 1LITRO	7709901244133	t	6900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.613962	2025-10-19 02:29:41.613962
55d4efc9-2eb8-40e0-b656-7b4aff74ddb1	ACONDICIONADOR DOVE EXTREME 400ML	7791293042282	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.614255	2025-10-19 02:29:41.614255
2721113b-4a18-45c1-97f4-b81c1643172c	NUTELLA 15GR	80751151	t	1400.00	1067.00	\N	\N	19.00	2025-10-19 02:29:41.614514	2025-10-19 02:29:41.614514
7d723bff-685e-49f7-a159-182e6b48d336	AZUCAR PALACIO 2.5K	7709990134193	t	9900.00	\N	\N	\N	5.00	2025-10-19 02:29:41.614782	2025-10-19 02:29:41.614782
935e7de2-e4b7-44ac-8cd7-08bb74b639e8	BOMBILLO PHILIPS DUO 10W	7702081994393	t	11400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.615077	2025-10-19 02:29:41.615077
f30b1bcb-9491-47c2-8e9f-9cc547d142d0	MASCARILLA RUBIO NATURALEZA Y VIDA 300ML	7702377462377	t	22000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.615314	2025-10-19 02:29:41.615314
4449c91f-0013-4df4-8342-49048ecb4486	WOOLITE DETERGENTE ROPA OSCURA 900ML	7702626217079	t	17000.00	16500.00	\N	\N	19.00	2025-10-19 02:29:41.615546	2025-10-19 02:29:41.615546
7cd03694-0c2b-4782-b321-eada6837b558	SAVITAL CREMA PARA RIZOS 270ML POTE	7702006299350	t	13000.00	12700.00	\N	\N	19.00	2025-10-19 02:29:41.615781	2025-10-19 02:29:41.615781
792fab7a-534f-4d32-a927-ef44ee384ddc	ESENCIA VAINILLA BLANCA600ML	77071385	t	4900.00	4740.00	\N	\N	19.00	2025-10-19 02:29:41.615972	2025-10-19 02:29:41.615972
08f6249b-0ccc-47fb-b837-a805d4523663	DUCALES 3X9	7702025133123	t	6400.00	6250.00	\N	\N	19.00	2025-10-19 02:29:41.616221	2025-10-19 02:29:41.616221
a70382ea-234a-4a01-a175-a340f78ee405	CEPILLO NIÑO	HL9520	t	3800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.616424	2025-10-19 02:29:41.616424
3908d51b-5503-4250-8752-bbe5dd6588e8	SPAGHETTI GAVASSA 1000GR	7707047400086	t	6000.00	5800.00	\N	\N	5.00	2025-10-19 02:29:41.61702	2025-10-19 02:29:41.61702
63a1a8e0-5404-402d-90f8-4ea8a95654ad	PIMIENTA MOLIDA LA SAZON 25GR	7707767140781	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.617405	2025-10-19 02:29:41.617405
2ebd3025-a6e5-437a-a32f-a3d844cb1798	CAFE AROMA INSTANTANEO X25 1.5G	7702088343620	t	3900.00	\N	\N	\N	0.00	2025-10-19 02:29:41.617733	2025-10-19 02:29:41.617733
5c3c6f7d-d58d-4478-a3ea-0ea664ba00ac	MEGARROLLO FAMILIA ACOLCHAMAX X12UNID	7702026196097	t	23000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.618066	2025-10-19 02:29:41.618066
9ed7755f-a17e-49ef-a93d-948fdb6144ca	CAREY NUTRICION NATURAL 110GR	7702310022392	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.618498	2025-10-19 02:29:41.618498
8d801dbf-4d4b-431b-81dc-707b5bf1e8e9	ARROZ CAMPEGUSTPO 1K	7709285392130	t	4200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.618759	2025-10-19 02:29:41.618759
0d4dbe3a-3a56-48b4-b5f8-ee790b26d811	MANI CROCANTE BARY 120GR	7702439476472	t	3400.00	3250.00	\N	\N	19.00	2025-10-19 02:29:41.619012	2025-10-19 02:29:41.619012
8cbe510a-cf81-4467-81b8-d6dbbc3d0a94	GASEOSA POOL MANZANA 1LITRO	7709836686275	t	2200.00	1917.00	\N	\N	19.00	2025-10-19 02:29:41.619351	2025-10-19 02:29:41.619351
1728b65f-ca42-432a-b5b0-e96e772d1f6f	GILLETTE HYDRA GEL 45GR	7500435140928	t	10500.00	10000.00	\N	\N	19.00	2025-10-19 02:29:41.619604	2025-10-19 02:29:41.619604
87491672-7975-4a09-9095-bc3518b1f1b5	PAPEL ALUMINIO TUC REPUESTO 40MTS	7702251042534	t	14800.00	14300.00	\N	\N	19.00	2025-10-19 02:29:41.619884	2025-10-19 02:29:41.619884
af011ab8-40e7-47a1-939c-df220de6e5da	TRULULU DRAGONES	7702993041185	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.620133	2025-10-19 02:29:41.620133
340cad30-5a82-4c2d-bb59-d9c6c3e65f56	ACONDICIONADOR SAVITAL 530ML	7702006301732	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.620415	2025-10-19 02:29:41.620415
5bf42489-33e2-4681-81c2-d4a6923e9f80	CHICHARRON PICANTE LA VICTORIA X10	7706642003401	t	18000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.62068	2025-10-19 02:29:41.62068
e7af8434-56fd-4abf-8246-c96fa224eb08	TROLLI PULPO MINI	7702174082655	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.621127	2025-10-19 02:29:41.621127
888150f9-ab71-450e-8968-aed560918342	ENJUAGUE PLAX GLACIAL COLGATE 250ML	7891024033050	t	10800.00	10500.00	\N	\N	19.00	2025-10-19 02:29:41.621473	2025-10-19 02:29:41.621473
b72007ab-1dc1-41de-aa75-450fead8e659	GELA PLAY YOLIS 1.650GR	7709084349861	t	26000.00	25400.00	\N	\N	19.00	2025-10-19 02:29:41.621774	2025-10-19 02:29:41.621774
d21f0bc5-f338-4718-b4da-1baf040a0dba	CEPILLO TIPO PLANCHA PARA ROPA TIDY HOUSE	7700304312641	t	3300.00	3160.00	\N	\N	19.00	2025-10-19 02:29:41.622176	2025-10-19 02:29:41.622176
5b101d55-3ebc-47c9-8e8e-1b00c5d6ad47	TRIBARY BARY 50GR	7702439957049	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.622563	2025-10-19 02:29:41.622563
8beaa376-0a16-440f-a548-1516bfc4f8dd	AROMATICA TOSH MANZANILLA ANIS 200UNID	7702032115075	t	6300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.622788	2025-10-19 02:29:41.622788
faeefaba-4fe7-4baf-a7a0-a5650f08f339	AROMATICA TOSH TE NEGRO 20UNID	7702032116126	t	4600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.623064	2025-10-19 02:29:41.623064
73d38585-4c60-4844-8281-39cb02b80039	HIPER CLORO 1 LITRO	47544D	t	2600.00	2460.00	\N	\N	19.00	2025-10-19 02:29:41.623344	2025-10-19 02:29:41.623344
3febd408-8025-46f8-bf5a-81ad9d5a1ef2	BIG BOM XXL 48	7707014902551	t	15700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.623714	2025-10-19 02:29:41.623714
85c92053-6f98-4dc9-98e3-43c7ae68838a	PALMOLIVE SUAVIDAD 120GR	7702010410857	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:41.623955	2025-10-19 02:29:41.623955
9a288f47-8d9f-4fd7-9293-aa5b9090d516	SHAMPOO ARRURRU MANZANILLA 800ML	7702277157380	t	28700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.624248	2025-10-19 02:29:41.624248
f0c2d5bc-d719-4ee2-ad37-045a676fd0c5	VASOS 3.3 OZ MIX	799192354359	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.624515	2025-10-19 02:29:41.624515
da03f67c-0428-4290-9d92-05dbd07578ba	WOOLITE BEBE DETERGENTE 900ML	7702626217765	t	14900.00	14500.00	\N	\N	19.00	2025-10-19 02:29:41.624791	2025-10-19 02:29:41.624791
bd942bfd-8f5f-454a-be8e-119c1c161b59	BOMBILLO SANTA BLANCA LED 24W	7707822757572	t	11000.00	10500.00	\N	\N	19.00	2025-10-19 02:29:41.625024	2025-10-19 02:29:41.625024
46456c12-bee5-4fdb-b978-1dda3369eb04	TRATAMIENTO DOVE HIALURONICO 270ML	7702006208093	t	12800.00	12500.00	\N	\N	19.00	2025-10-19 02:29:41.625456	2025-10-19 02:29:41.625456
e4149d7b-7629-4511-8700-38ce98129b3c	SHAMPOO KONZIL RESTAURACION 340ML	7702029444591	t	14300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.625709	2025-10-19 02:29:41.625709
ae1fafb6-a3ef-4d07-9c61-fdc6ebbe1ae5	COMBO SHAM HEAD Y CREMA PEINAR	7500435146746	t	31000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.625914	2025-10-19 02:29:41.625914
57171819-28db-4a34-beed-03b098d5c63b	LA ESPECIAL MANI CHILE LIMON 180GR	7702007077506	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.626148	2025-10-19 02:29:41.626148
e22888e1-78ce-4e4b-b7af-471e8464edd0	TOSH MANZANILLA JENGIBRE X20UNID	7702032115099	t	7200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.626355	2025-10-19 02:29:41.626355
f8bec488-5c1d-4c9f-ad96-4219585e61bc	JUMBO PISTACHO 180GR	7702007075960	t	7600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.626614	2025-10-19 02:29:41.626614
c44b167b-963f-426f-a37d-b9e6a1e32851	ANCESTRAL DORIA QUINUA 300GR	7702085003473	t	7200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.626811	2025-10-19 02:29:41.626811
497bfafa-11b8-41d6-8715-ad75dd155915	SERVICIO DE ENERGIA ELECTRICA Y ALUMBRADO PUBLICO	SERVICIO DE ENERGIA ELECTRICA	t	757540.00	\N	\N	883522.00	0.00	2025-10-19 02:29:41.627029	2025-10-19 02:29:41.627029
958f3b2c-40ff-400d-8251-10728e9f93e7	CEPILLO INFINITO ADULTO	7708416000760	t	1200.00	1050.00	\N	\N	19.00	2025-10-19 02:29:41.627269	2025-10-19 02:29:41.627269
537aa382-bb12-4849-af59-42f7da887640	BOCADILLO COMBINADO X12 GUAYABA	7707337090126	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.627487	2025-10-19 02:29:41.627487
d1f22a1b-7280-4a32-a07b-196118e06e96	GARBANZO GRANOS RINCON 500GR	7709062917174	t	3300.00	3140.00	\N	\N	0.00	2025-10-19 02:29:41.627718	2025-10-19 02:29:41.627718
c40d6f30-7f8d-4823-bf38-eaec9062d679	AREQUIPE LEVAPAN ESPARCIBLE 250GR	7702014594027	t	6200.00	6000.00	\N	\N	19.00	2025-10-19 02:29:41.627972	2025-10-19 02:29:41.627972
13dfcb8a-3f78-4c72-9cc7-97bb692265da	SALSA DE AJO SAN JORGE 110GR	7702014626926	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.628223	2025-10-19 02:29:41.628223
a66aad62-b269-4336-989c-bd70c447fdc1	LOZACREAM BLANCOX 850GR	7703812406574	t	11000.00	10700.00	\N	\N	19.00	2025-10-19 02:29:41.628443	2025-10-19 02:29:41.628443
f1202900-8526-4743-a17b-acfa4f9a6189	GELATINA FRUTIÑO SABOR A CEREZA 35GR	7702354950095	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.628665	2025-10-19 02:29:41.628665
41bc7dcc-b5a4-48e7-afe7-07e3bc16222c	DETODITO MIX 45GR	7702189019677	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.628951	2025-10-19 02:29:41.628951
235bf83b-44c6-44ce-8d9a-1fc944c0a7dc	LIMPIA YA HOGAR X3	7702037873093	t	4100.00	3950.00	\N	\N	19.00	2025-10-19 02:29:41.629257	2025-10-19 02:29:41.629257
21960b44-64fd-4bdc-8275-b44fda024ef4	SHAMPOO SAVITAL 100ML MULTIVITAMINA	7702006202831	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.629498	2025-10-19 02:29:41.629498
6462f5c0-7fb5-447a-9794-4f9cc2709ee6	TRULULU NUGGETS 54GR	7702993036792	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.629724	2025-10-19 02:29:41.629724
19c9e179-c23a-4451-90ab-2f1a7c4fc4f1	ELITE MAX X18UNID	7707199346935	t	20300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.629959	2025-10-19 02:29:41.629959
480b889b-aef1-429c-90e0-b529da6d1b54	BIANCHI CHOCOSNACK 55GR	7702993043943	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.630184	2025-10-19 02:29:41.630184
1d3570c7-fe8e-47ee-a0be-237cc4b817e8	OREO ROLLITOX12 CHOCOLATE	7622201760328	t	2700.00	2590.00	\N	\N	19.00	2025-10-19 02:29:41.630383	2025-10-19 02:29:41.630383
4caea4a7-f2b5-4eee-9d81-562bb32d9b30	FESTIVAL SURTIDA X16UNID	7702025142125	t	11900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.630611	2025-10-19 02:29:41.630611
66a96948-dd65-457b-ae10-5e4586662344	COLCAFE INTENSO GRANULADO 200GR	7702032117185	t	23800.00	\N	\N	\N	5.00	2025-10-19 02:29:41.630817	2025-10-19 02:29:41.630817
e220702a-f3d6-4db5-a4ef-4bfcddcd9e28	AJO BARY 50GR	7702439908607	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.631042	2025-10-19 02:29:41.631042
60b3a5a1-6d4b-42fb-bbe0-c3a9c25972dc	TRICOLOR X16UNID	7707283881144	t	9800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.631274	2025-10-19 02:29:41.631274
de259908-6503-4bdb-83de-508facbbac92	MANJAR BLANCO PANELITA X8UNID	7708967233730	t	5800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.631546	2025-10-19 02:29:41.631546
7ef790b4-7b27-4c4d-8525-4a62e2c7d397	CORTADOS X8UNID	7708977346994	t	8500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.631784	2025-10-19 02:29:41.631784
7b934413-af68-44dc-ad7f-a8bd1fe65c1f	BANDEJA HUEVOS DE CODORNIZ X24	HUEVOS CODORNIZ	t	5200.00	4950.00	\N	\N	0.00	2025-10-19 02:29:41.632013	2025-10-19 02:29:41.632013
5743b8e7-d88b-4f6b-9456-0b2c6b0949ab	JUMBO MANI X12UNID	7702007512403	t	57400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.632273	2025-10-19 02:29:41.632273
3f5bb3a2-c2d0-41e7-a638-b441106c0c70	HARINA DIANA 1.000GR	7702511081457	t	3200.00	3075.00	\N	\N	5.00	2025-10-19 02:29:41.632477	2025-10-19 02:29:41.632477
78e5ac26-a654-4ad1-8f59-e0d775c31546	SUNTEA DURAZNO	7702354955373	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:41.632693	2025-10-19 02:29:41.632693
8e09bb3e-2e9d-45bf-a9cd-c1b25176d1ad	DISPLEY IBUPROFENO	7703763270859	t	2300.00	\N	\N	\N	0.00	2025-10-19 02:29:41.632907	2025-10-19 02:29:41.632907
6bbc06f0-fe47-423f-8259-e066f856d585	CHOCO LYNE 25GR	7702007077575	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.63314	2025-10-19 02:29:41.63314
2aca2a32-a608-4230-84a4-ee2a9a176296	HUGGIES TRIPLE PROTECCION M/2 X25UNID	7702425295537	t	15300.00	14900.00	\N	\N	19.00	2025-10-19 02:29:41.633426	2025-10-19 02:29:41.633426
a382f160-193e-4a82-88e4-55b5440941b1	DETERGENTE AK1 MANZANA 1800ML	7702310048118	t	17400.00	17000.00	\N	\N	19.00	2025-10-19 02:29:41.634414	2025-10-19 02:29:41.634414
0cbdd434-99ca-4eee-a092-bd8a2c2782b7	CABAS DE ICOPOR 5LITROS	45784S	t	10000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.634839	2025-10-19 02:29:41.634839
acfd1b89-b743-4d26-aa00-59949707df81	HABAS MIX 25GR	7702007064407	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.635477	2025-10-19 02:29:41.635477
fabca922-2968-4977-a4ff-244a9190350f	AZUCAR RISARALDA 1K	7707197483380	t	4300.00	4240.00	\N	\N	5.00	2025-10-19 02:29:41.635864	2025-10-19 02:29:41.635864
e6200e02-dfaa-4bcf-9cf0-d45c7f794b8f	LECHE CONDENSADA TUBITO 320GR	7707226113172	t	8100.00	7900.00	\N	\N	0.00	2025-10-19 02:29:41.636114	2025-10-19 02:29:41.636114
75e66d24-eb0a-4e4b-b609-c1bde5d6cb49	AROMAX MANZANA VERDE LIQUIDO 1 LITRO	7702354953225	t	8800.00	8500.00	\N	\N	19.00	2025-10-19 02:29:41.636479	2025-10-19 02:29:41.636479
1efcc651-4ffb-4cb8-9fc1-e8da3e5dd527	DOVE HIDRATACION HIALURONICO 22ML	7702006208123	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.636747	2025-10-19 02:29:41.636747
5faac477-a2be-43f1-9f79-269aabd9a8c7	AXE ANTITRANSPIRANTE 152ML	7791293025919	t	14200.00	13900.00	\N	\N	19.00	2025-10-19 02:29:41.637047	2025-10-19 02:29:41.637047
4c46bd43-af65-4adb-af20-7e236615b164	TRULULU MONSTRY 75G	7702993042403	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.637309	2025-10-19 02:29:41.637309
394afc73-9992-434b-bb8f-b06be1f64f7d	BOCADILLO COMBINADO X12UNID	7707337090102	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.6376	2025-10-19 02:29:41.6376
97f851ac-fe48-40a3-aae3-e4aa47709f5f	SALSA NEGRA IDEAL 975ML	7709913154376	t	4800.00	4550.00	\N	\N	19.00	2025-10-19 02:29:41.637832	2025-10-19 02:29:41.637832
09a91542-0e77-4195-8887-34fdbb474461	SUAVITEL CUIDADO COMPLETO 2.3LITROS	7509546667683	t	18000.00	17600.00	\N	\N	19.00	2025-10-19 02:29:41.638057	2025-10-19 02:29:41.638057
eca757ff-960a-4de2-9353-96b7d93e906d	COLGATE TRIPLE 300ML	7509546652016	t	25000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.638302	2025-10-19 02:29:41.638302
062a32e2-b1fa-4b6e-b5d7-0b96211aa76c	SNACKY X12UNID	7702011011282	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.638767	2025-10-19 02:29:41.638767
657a062d-5805-480e-a364-a878b4c041f0	SPARTAN LATA	7702354951160	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:41.638979	2025-10-19 02:29:41.638979
3691a548-5417-4a61-b393-8b227fed1893	Articulos Sin Registrar	arsinreg1	t	5300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.639288	2025-10-19 02:29:41.639288
3c81dbad-bd4d-4181-b903-562de059cb01	LECHE CONDENSADA COLOMBINA 90GR	7702097148483	t	2700.00	2580.00	\N	\N	0.00	2025-10-19 02:29:41.639648	2025-10-19 02:29:41.639648
e82e84f2-1889-4c4d-a814-ef444dbff4bf	DORITOS MEGA QUESO X10 43GR	7702189050182	t	17500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.639916	2025-10-19 02:29:41.639916
8f009635-4ad0-477f-a906-fb142676c1d2	VASOS DE CARTON HOUSE 4 ON 50U	7707320620835	t	3400.00	3250.00	\N	\N	19.00	2025-10-19 02:29:41.640193	2025-10-19 02:29:41.640193
f3ded102-6f4c-439b-be07-fae04f6583a9	PAPEL ALUMINIO X100METROS	7709767003103	t	22000.00	21300.00	\N	\N	19.00	2025-10-19 02:29:41.64053	2025-10-19 02:29:41.64053
366c17bf-74c4-470c-90fe-971fd48bf49e	PAPEL PARAFINADO X50METROS	5401S	t	9900.00	9600.00	\N	\N	19.00	2025-10-19 02:29:41.640908	2025-10-19 02:29:41.640908
2348c23f-ab3b-4aa8-b154-43b73c944055	TAPAS DE VASOZ X50UNID	54214S	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.641131	2025-10-19 02:29:41.641131
ff077659-7eb1-4230-b52c-c7859aa4204f	AVENA DON PANCHO MOLIDA 600GR	7702193103119	t	6400.00	6200.00	\N	\N	5.00	2025-10-19 02:29:41.641357	2025-10-19 02:29:41.641357
82170686-b582-43e8-bb6e-13b986b67083	EXTROCITOS X12UNID	564S5	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.641593	2025-10-19 02:29:41.641593
6761c2e0-b60c-4e80-a4d4-8f45544be35e	ACEITE GOURMET FAMILIA 1800ML	7702141509864	t	31400.00	30800.00	\N	\N	19.00	2025-10-19 02:29:41.641842	2025-10-19 02:29:41.641842
b452ecb8-c35a-4cf7-8a80-dd5e70e39d30	BIANCHI MANI MINI 12U	7702993035160	t	9800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.642063	2025-10-19 02:29:41.642063
eb54b461-c50a-4b50-bbf9-0e7e32524fa7	JET BURBUJA COOKIES CREAM 10 U	7702007072556	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.642298	2025-10-19 02:29:41.642298
10a41bc6-7e7f-4799-9e49-9b97ec67f15a	GRAGEAS DE CHOCOLATE LEO	GRAGEAS CHOCOLATE	t	3500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.642529	2025-10-19 02:29:41.642529
97ca679f-c280-463f-9f6e-20911a56b00d	NUTRIBELA 15 HIALURONICO	7702354953669	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.642858	2025-10-19 02:29:41.642858
270a1c2a-310c-4fc1-ada9-665d6ef9314c	MIXTO FAMILIAR 75GR	7706642001391	t	3500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.643129	2025-10-19 02:29:41.643129
c33458cf-bfad-4af3-80cd-0c7a91922661	MIXTO FIESTA FAMILIAR 140GR	7706642009090	t	6500.00	6350.00	\N	\N	19.00	2025-10-19 02:29:41.643397	2025-10-19 02:29:41.643397
edf4b56c-5b73-4180-b8b0-330620af5f63	POWER ADE 500ML RED	7702535009987	t	3400.00	3084.00	\N	\N	19.00	2025-10-19 02:29:41.643642	2025-10-19 02:29:41.643642
550465fd-9981-46f1-ad6e-ba5da5e54e09	POWER ADE 500ML BLUE	7702535009994	t	3400.00	3084.00	\N	\N	19.00	2025-10-19 02:29:41.643925	2025-10-19 02:29:41.643925
19824627-ad94-455f-b0dc-18a3e74db574	MAGISTRAL 52GR	7702700019469	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.644208	2025-10-19 02:29:41.644208
b83fd62b-e0b6-4b42-837b-828c882ced96	ESPONJA ARCOIRIS EL REY	7707178731196	t	1400.00	1250.00	\N	\N	19.00	2025-10-19 02:29:41.644506	2025-10-19 02:29:41.644506
359ba48c-e60c-4446-8aa0-a276c98f252c	GALLETA TOSH X6UNID	7702025100279	t	5700.00	5550.00	\N	\N	19.00	2025-10-19 02:29:41.644809	2025-10-19 02:29:41.644809
a81e9396-7e9f-4199-8afc-2600e68560d7	CHOCOLATINAS LINE X12UNID 300GR	7702007077599	t	22600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.64513	2025-10-19 02:29:41.64513
4ac72131-de22-4d35-a6b3-e4b0d700dd59	CHISSTOZO L VICTORIA	7706642002671	t	2300.00	2200.00	\N	\N	19.00	2025-10-19 02:29:41.645397	2025-10-19 02:29:41.645397
e30f789a-2021-47fd-94c3-1f8d787da702	SHAMPOO SAVITAL FUSION PROTEINA 100ML	7702006301657	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.645685	2025-10-19 02:29:41.645685
828ddd72-4177-4ac6-95cc-d63730843233	TOLLAS NOSOTRAS CANAL PLUS X10	7702027041761	t	3900.00	3750.00	\N	\N	0.00	2025-10-19 02:29:41.645979	2025-10-19 02:29:41.645979
e84e03ad-f746-4f0f-8374-412236d2549f	GOLO CHIPS FESTIVAL X24UNID	7702007058963	t	33300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.646235	2025-10-19 02:29:41.646235
066f3597-0765-42b0-93d2-fa2642e2a9e4	DUCALES X8 UNID	7702025136308	t	19000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.646506	2025-10-19 02:29:41.646506
5f95fb27-69c3-4769-a986-909f32776e50	VASOS 7OZ X50UNID	7709141813359	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.646719	2025-10-19 02:29:41.646719
ec7a5af0-cc5f-4afd-a662-4d2903fe7445	MANI TRITURADO ELITE 500GR	7708730121158	t	9800.00	9500.00	\N	\N	19.00	2025-10-19 02:29:41.646975	2025-10-19 02:29:41.646975
7e22d100-cf47-4528-85c0-f94d72229b6a	GRANOLA HOLA DIA 250GR	7709990071214	t	3800.00	3600.00	\N	\N	19.00	2025-10-19 02:29:41.64723	2025-10-19 02:29:41.64723
fcfb15ff-fb0f-4c4e-a740-cf23cd0c97a3	BURBUJET COOKIES AND CREAM 4UND 50GR	7702007061161	t	20900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.64745	2025-10-19 02:29:41.64745
a400215d-3ffd-4616-b24f-447e97441836	CORONA COCOA SUPERIOR 100GR	7702007031560	t	9000.00	8900.00	\N	\N	19.00	2025-10-19 02:29:41.647707	2025-10-19 02:29:41.647707
d8f06309-85ad-4289-9ac7-aabacddd7849	CHOCO MIX SNACK BARY 160GR	7702439964788	t	6500.00	6300.00	\N	\N	19.00	2025-10-19 02:29:41.647924	2025-10-19 02:29:41.647924
4eddf4ad-78c8-4b7a-8d86-6275d05db49a	COMINO BARY 50GR	7702439730314	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.648329	2025-10-19 02:29:41.648329
a6b1bb60-4f00-46d0-8183-6dbb0442f7b0	TRULULU MASMELO LIMON 65GR	7702993036839	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.648572	2025-10-19 02:29:41.648572
527bc30b-aec1-4b9f-bfa8-b88b5df7c97d	ARRURRU PAÑITOS X100UNID	7702277305170	t	10600.00	10200.00	\N	\N	19.00	2025-10-19 02:29:41.648836	2025-10-19 02:29:41.648836
b75c680a-07ef-43bc-928d-ac638010a3b3	COLADOR EXTRA GRANDE	SD4S545	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.649087	2025-10-19 02:29:41.649087
f27a4f54-be69-4d6d-a811-46b573e9f77a	AZUCAR PALACIO 500GR	7709990134186	t	2000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.649331	2025-10-19 02:29:41.649331
5f09ff98-535c-4703-802b-be7c184b30e0	SERVICIO DE INTERNET	SERVICIO DE INTERNET	t	50000.00	\N	\N	50000.00	0.00	2025-10-19 02:29:41.649574	2025-10-19 02:29:41.649574
050f75de-84d6-4473-bc7c-2497b907b4b9	CARGO FIJO ACUEDUCTO Y ALCANTARILLADO	ACUEDUCTO Y ALCANTARILLADO	t	22535.00	\N	\N	22535.00	0.00	2025-10-19 02:29:41.649834	2025-10-19 02:29:41.649834
468b761c-ef9c-4027-814c-41afad7c488f	SHAMPOO NUTRIT JALEA REAL 750ML	7702277120162	t	17500.00	17000.00	\N	\N	19.00	2025-10-19 02:29:41.650536	2025-10-19 02:29:41.650536
c1642b11-040a-4f70-9ed5-17f41bae1569	COMPOTA BABYFRUIT SABOR A PERA  113GR	7707262682595	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:41.650854	2025-10-19 02:29:41.650854
d5da96c8-f2c1-40ee-835c-acb0a3ed1562	AROMAX LIQUIDO FRUTOS ROJOS 180ML	7702354951665	t	1700.00	1630.00	\N	\N	19.00	2025-10-19 02:29:41.651236	2025-10-19 02:29:41.651236
158639fd-0937-4fe2-b45f-13a1c379c852	FORTIDENT 76GR	7891150086722	t	2700.00	2584.00	\N	\N	19.00	2025-10-19 02:29:41.651795	2025-10-19 02:29:41.651795
ae52165c-6263-4ebb-8ecd-0b2a261fafd8	ROSAL MORADOO ULTRACONFORT	7702120013030	t	1300.00	1167.00	\N	\N	19.00	2025-10-19 02:29:41.652325	2025-10-19 02:29:41.652325
e8b78b65-e80f-4094-9b6c-6795c37ba9af	SUAVITEL LAVANDA 360ML	7509546658810	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:41.652833	2025-10-19 02:29:41.652833
87024d83-65a6-43b3-a4fe-ec017ad17c4b	MANI BARY SABOR A POLLO X8UNID	7702439734855	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.65334	2025-10-19 02:29:41.65334
d219350f-31be-4f36-af4c-6e25c2be99e2	MANTECA FRITURA 3.000GR	7702028014207	t	38000.00	37000.00	\N	\N	19.00	2025-10-19 02:29:41.654037	2025-10-19 02:29:41.654037
ac18e632-528d-4dc8-a3d6-5b253313c6f0	PROTECTOR SOLAR DE ARROZ BIOAQUA SPF50 150ML	6942349739019	t	8500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.654676	2025-10-19 02:29:41.654676
082afc00-a37e-4bd3-8005-0ac39b608ed2	SALSA SOYA NORSAN	7709702316022	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.655268	2025-10-19 02:29:41.655268
1ae3874e-2854-407e-b29e-4a5c0d11274f	SALSA DE AJO NORSAN 165GR	7709990793628	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.655865	2025-10-19 02:29:41.655865
f4de1d6e-9364-4e02-ba9e-b9570759ca63	VINAGRETA BARY 200GR	7702439008352	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:41.656416	2025-10-19 02:29:41.656416
6b14280d-6d33-4bd6-afa5-0088d051598c	VASOS 10OZ X50UNID	7709198543629	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:41.656972	2025-10-19 02:29:41.656972
dca2a151-a83d-4e3b-b901-7d72481886b8	KOTEX ESENCIAL X8UNID	7702425152540	t	2800.00	2680.00	\N	\N	0.00	2025-10-19 02:29:41.657631	2025-10-19 02:29:41.657631
51524586-9442-4a62-8acd-29c202ffba98	MANI BARY SABOR A LIMON X8UNI	7702439255169	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.658394	2025-10-19 02:29:41.658394
a01ffe2e-a581-446a-94db-d960e1e22a3c	NOVALECHE 900 LECHE ENTERA MAS ARROZ	7703312400799	t	23500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.658942	2025-10-19 02:29:41.658942
4fe64561-92e9-4546-9160-d93b9608cafb	SERVILLETA NUBE X300UNI	7707151601003	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:41.659539	2025-10-19 02:29:41.659539
48e7d32d-cdeb-4a85-a21f-534404615e8d	GUANTES ETERNA CALIBRE 25 TALLA 8	7702037502757	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.660163	2025-10-19 02:29:41.660163
8ebb83e3-c7a8-4e6e-bdcc-32cfd8cbb63a	GRAGEAS ITALO 125GR	7702117007769	t	2900.00	2730.00	\N	\N	19.00	2025-10-19 02:29:41.660608	2025-10-19 02:29:41.660608
0d9ffc9f-cc09-414a-8832-f9b47b1422cb	BOKA PANELA LIMON	7702354956813	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:41.661167	2025-10-19 02:29:41.661167
590196ff-eb81-4ca4-b0b7-70f274da1d1b	TODORICO 140GR	7702152119069	t	5400.00	5250.00	\N	\N	19.00	2025-10-19 02:29:41.661568	2025-10-19 02:29:41.661568
2002a589-367b-4263-820d-65935d98ffba	SAZONADOR 50GR	7707767146950	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.662562	2025-10-19 02:29:41.662562
232a2d54-49af-4220-a4b0-7dbd40111a2e	FESTIVAL LIMON 12X4	7702025103829	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.663329	2025-10-19 02:29:41.663329
1ef211da-3e86-48d7-aec5-e4aacc1d0ea9	PANELA EMPACADA	7709950486270	t	1900.00	\N	\N	\N	0.00	2025-10-19 02:29:41.663794	2025-10-19 02:29:41.663794
7c6d647e-f474-420b-9bb3-6cb6977624e5	SALTITACOS TACO	7707323130065	t	1400.00	1320.00	\N	\N	19.00	2025-10-19 02:29:41.664314	2025-10-19 02:29:41.664314
1c79451b-7385-4434-8bfc-888968c677a6	CHIPIRRINES X30U	6939343200171	t	19700.00	19300.00	\N	\N	19.00	2025-10-19 02:29:41.664901	2025-10-19 02:29:41.664901
2f41a271-6d95-4851-90fe-90fee593a15b	CHICHARRON SUPER RICAS 50GR NATURAL	7702152007038	t	4100.00	3950.00	\N	\N	5.00	2025-10-19 02:29:41.665234	2025-10-19 02:29:41.665234
fd8c05a6-fc65-45a8-9bd1-f0ee82ba72e0	LECHE CONDENSADA TUBITO X6UNI	7707226000212	t	10700.00	\N	\N	\N	0.00	2025-10-19 02:29:41.665474	2025-10-19 02:29:41.665474
6f6e2a19-0fb6-4a2c-a43d-cbc773d9feca	AZUL KLEAN MAGIA BEBE 950ML	7702310042444	t	6000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.665719	2025-10-19 02:29:41.665719
b193f61e-d737-4787-bf38-6c0a70084872	DON GUSTICO 18GR	7702354929930	t	1000.00	892.00	\N	\N	19.00	2025-10-19 02:29:41.665947	2025-10-19 02:29:41.665947
eabd6fd6-c205-4328-8d29-9984059fdbd4	FABULOSOS LAVANDA 500ML	7702010225147	t	4700.00	4600.00	\N	\N	19.00	2025-10-19 02:29:41.666252	2025-10-19 02:29:41.666252
bfffb569-3893-4adf-8e86-d690efc3a276	SCOTT RINDEMAX X18UNID	7702425088207	t	18500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.666551	2025-10-19 02:29:41.666551
25cef684-3ad6-43c6-8743-cbff16d08039	TINTE KERATON AZUL CELESTE	7707230996297	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.667028	2025-10-19 02:29:41.667028
73a34461-54be-4a9b-a819-051779ac362c	AVENA EXTRASEÑORA 500GR HOJUELA	7709220129388	t	2900.00	2800.00	\N	\N	5.00	2025-10-19 02:29:41.667525	2025-10-19 02:29:41.667525
d300d7dd-5d70-4538-b616-da34e8471b4b	BOMBILLO ECONOMICO	130646145206	t	1200.00	1100.00	\N	\N	19.00	2025-10-19 02:29:41.667955	2025-10-19 02:29:41.667955
b9505fc5-b122-4d6c-b421-9284c6059068	BOMBILLO FULGORE 16W	7506487802029	t	8000.00	7600.00	\N	\N	19.00	2025-10-19 02:29:41.668185	2025-10-19 02:29:41.668185
7a0d82c1-d8e9-4dc8-b182-8387dbc2e594	PAÑITOS DE MANO GOLD 50UND	7702120005707	t	4000.00	3850.00	\N	\N	19.00	2025-10-19 02:29:41.668407	2025-10-19 02:29:41.668407
6c3d58ce-21cd-4297-afc9-fc191b036bf3	TALCO REXONA 180GR MAS 55 GR	7702006404297	t	18300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.668601	2025-10-19 02:29:41.668601
5cc42633-a120-45c5-ab4c-3e27c775f54c	FAB LAVADO COMPLETO 1KG	7702191163917	t	9600.00	9250.00	\N	\N	19.00	2025-10-19 02:29:41.668811	2025-10-19 02:29:41.668811
32e50726-7469-4fe3-8ff1-cad5a3ef9fb3	TRAPERO ESCOBA NORSAN 500	7707274603083	t	8600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.669059	2025-10-19 02:29:41.669059
849b0f34-b0ef-4449-a341-ea5bb8e70671	COFFE STAR X50UNID	7707014903312	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.66929	2025-10-19 02:29:41.66929
b472e065-1d7f-4e68-8050-26de46284db8	AXION BARRA 120GR	7509546652573	t	1200.00	1120.00	\N	\N	19.00	2025-10-19 02:29:41.669495	2025-10-19 02:29:41.669495
4c4dc5fe-4309-42e6-b7cf-50b789624888	NOSOTRAS INVISIBLE CLASICA MULTIESTILO X10UNID	7702026179908	t	4700.00	4550.00	\N	\N	0.00	2025-10-19 02:29:41.670274	2025-10-19 02:29:41.670274
a6170aa5-5cfa-46cf-986d-efb06feba35b	EFECTO LUNAR MATIZANTE	703980775103	t	3400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.670512	2025-10-19 02:29:41.670512
33ad3ba1-3f26-4035-b81c-95b91aee56da	PRESTOBARBA SCHICK XTREME  ULTIMATE X2	7502214739903	t	5400.00	5150.00	\N	\N	19.00	2025-10-19 02:29:41.67077	2025-10-19 02:29:41.67077
00bcfded-59cb-4ff1-bda2-2022ae8c6974	PRESTOBARBA SCHICK SENSIBLE X2UNID	7502214734762	t	5400.00	5150.00	\N	\N	19.00	2025-10-19 02:29:41.671083	2025-10-19 02:29:41.671083
39079df8-03e0-45c3-b818-1e430c2ca934	CARGADOR DE PILAS ENERGIZER MAS PILAS	4891138941039	t	43200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.671335	2025-10-19 02:29:41.671335
59c2d1d4-e8a7-49c7-b74e-56cd0d1431d7	EASY-OFF BANG MAS REPUESTO 500ML	7702626218472	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.671768	2025-10-19 02:29:41.671768
f75a3402-c3da-4b8b-b395-3868ffa14757	SEÑORIAL X4 ROLLOS	7707016103727	t	5900.00	5750.00	\N	\N	19.00	2025-10-19 02:29:41.672073	2025-10-19 02:29:41.672073
d0d8382d-35c6-44a9-839e-0b3e17f10b32	MECHERA SWISS	7707822753031	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.672368	2025-10-19 02:29:41.672368
da90c8a6-fddd-4b10-ad3a-8dac58b02f4c	PANELA DIANA	7709049825980	t	800.00	\N	\N	\N	0.00	2025-10-19 02:29:41.672612	2025-10-19 02:29:41.672612
88122e93-cab4-4f66-8a42-22d4d786446d	SALTIN NOEL 5T 500GR	7702025136988	t	7900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.672949	2025-10-19 02:29:41.672949
f9f3b44e-ebe0-47a7-8d2a-818189f87a60	BOLSA PAPEL 1/2 X100UNID	45SD	t	2600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.673255	2025-10-19 02:29:41.673255
c89dc888-7d72-4cd4-afd5-0dae12c2f4be	BOLSA PAPEL 1  X100UNID	4S4D5S	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.673575	2025-10-19 02:29:41.673575
427b46c2-1032-4e7d-b2c8-8c2942d78c4c	MAYOCHULA LA CONSTANCIA 80GR	7702097162236	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:41.673912	2025-10-19 02:29:41.673912
ec137f10-e0d1-4e9e-8e44-a3e1d1f620d5	BILAC LECHE ACHOCOLATADA 200ML	7702090061024	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:41.674187	2025-10-19 02:29:41.674187
ed62e623-8094-4098-9044-702cecc789d8	MANJAR DE COCO 12 UND	7707317761107	t	7600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.67445	2025-10-19 02:29:41.67445
088609e5-5305-441f-b23d-bd68a22c0b06	PAPEL FAMILIA EXTRA GRANDE X12UNID	7702026148331	t	19500.00	19100.00	\N	\N	19.00	2025-10-19 02:29:41.674739	2025-10-19 02:29:41.674739
5a5a92f0-a9d4-4035-9a3c-3e5e947100f7	VANISH POLVO BLANCO 30GR	7702626204642	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:41.675043	2025-10-19 02:29:41.675043
4e6aff20-e565-42e1-b217-7db462301e03	COOL A PED EXTRACTO DE MANZANILLA 250ML	7708851548247	t	6800.00	6500.00	\N	\N	0.00	2025-10-19 02:29:41.675501	2025-10-19 02:29:41.675501
9ff78fdd-294a-4d09-9be7-0bafb081c39f	COPITOS REDONDOS	7709468986552	t	3000.00	2700.00	\N	\N	19.00	2025-10-19 02:29:41.675892	2025-10-19 02:29:41.675892
9ab6aef4-c8c3-4578-b37d-3faeaf11e125	AXION XTREME 850GR	7509546684314	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.676256	2025-10-19 02:29:41.676256
8ed92e4d-c766-47b3-91ec-728e4c3c3fce	VASELINA BABY X20GR	7709753675314	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.676558	2025-10-19 02:29:41.676558
6cb29d6f-1c89-4aed-ae45-1652192a5dbb	POMADA DE MARIHUANA	7701223459769	t	5700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.677033	2025-10-19 02:29:41.677033
5f343773-9073-4bf6-8cc1-62bdf11c782a	BEBIDA DE ARROZ DIANA 46GR	7702511781111	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.677249	2025-10-19 02:29:41.677249
242a3fe9-894a-407f-ad73-a00bbee58092	DOWNY PERFUME COLLETION 900ML	7500435160070	t	19500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.67752	2025-10-19 02:29:41.67752
5f6ccf53-6cef-4cb6-90a1-9592eaebbbb2	DESMANCHADOR EN CREMA FROTEX 500GR	7705790226151	t	15800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.677846	2025-10-19 02:29:41.677846
8d80b528-345f-417b-b6f5-d27f1936ff50	ACIDO MURIATICO 150CC	7707325448021	t	1600.00	1450.00	\N	\N	19.00	2025-10-19 02:29:41.67813	2025-10-19 02:29:41.67813
73a33074-1504-4209-8ed6-1838732640cf	ACIDO MURIATICO 410ML	7707325448014	t	3400.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.678419	2025-10-19 02:29:41.678419
54d3a09a-4e26-426b-9464-118f2a781350	PANCAKES CORONA 100GR	7702007069747	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:41.678722	2025-10-19 02:29:41.678722
ae992f55-050b-4b36-a604-5af0f4956467	MONT BLANC BAILEYS X6UNID	7702007072990	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.678995	2025-10-19 02:29:41.678995
f482c96f-b916-4889-bfaf-a4819ce000c6	PASTA MONTICELLO PENNE RIGATE 500GR	7702085021149	t	8000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.679324	2025-10-19 02:29:41.679324
68031088-cb59-4eab-9e0c-aab3a00f6018	VELAS SAN BENITO X8UNID	7707269190284	t	6200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.679713	2025-10-19 02:29:41.679713
0b83d271-7ba7-4bb6-aa4f-af58afdf1029	VELAS SAN BENITO X8UNID	7707269198006	t	3500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.68016	2025-10-19 02:29:41.68016
a2641742-adc1-4b6e-a428-850ed274990d	VELAS SAN BENITO X8UNID	7707269191007	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.68049	2025-10-19 02:29:41.68049
689feefd-04a5-4c2e-90aa-cd2783184d40	SHAMPOO SILVESTRE 200ML	7707594901258	t	4000.00	3750.00	\N	\N	19.00	2025-10-19 02:29:41.680756	2025-10-19 02:29:41.680756
1e246a87-58db-481e-b83c-1285d891a490	POOL MANZANA 3LT	7709836686251	t	5700.00	5167.00	\N	\N	19.00	2025-10-19 02:29:41.681006	2025-10-19 02:29:41.681006
50cf76ed-2e94-4b9d-b1c9-b83ae2ad4f38	TINTE KERATON 7.34	7707230996112	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:41.681253	2025-10-19 02:29:41.681253
fd158fe8-2bf7-4d4e-8bdf-5afd58d064e9	CORTA UÑAS NIÑO CARITA	DXS4F5	t	2000.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.681535	2025-10-19 02:29:41.681535
03e3e686-5b7e-442f-b7f0-b7d5c04b629e	ACEITE GOHNSONNS BABY 70ML	65SD	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.681815	2025-10-19 02:29:41.681815
57c47955-0db7-445d-8a37-e8faf95fed55	CLORO YES 1.800 MAS 450ML	7702560033025	t	8500.00	8250.00	\N	\N	19.00	2025-10-19 02:29:41.682213	2025-10-19 02:29:41.682213
ee2e6923-c46d-4208-8de7-418a4dcf68ae	CHICHARRON LA VICTORIA 18GR	7706642003395	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.682488	2025-10-19 02:29:41.682488
624030b8-c824-4806-819e-220bc023eb3c	BOMBILLO FULGORE 14W	7506487802012	t	5600.00	5300.00	\N	\N	19.00	2025-10-19 02:29:41.682744	2025-10-19 02:29:41.682744
1249efc1-7109-4a42-a615-2fd578047ad3	TROLLI RATATON 45GR	7702174082662	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.682995	2025-10-19 02:29:41.682995
eaa1eeda-6852-48f4-a80e-d1bf123ba349	AREQUIPE DE HORNO LA MEJOR 5.000GR	7705241700018	t	62000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.683301	2025-10-19 02:29:41.683301
145a0da9-e3e6-4d0a-8c42-470a72f70ac2	ADVIL MAX	4AS5	t	2200.00	2050.00	\N	\N	0.00	2025-10-19 02:29:41.683585	2025-10-19 02:29:41.683585
bc485652-c495-4cb9-887e-4ad2a6341167	CEPILLO INFINITA KIDS	7708416000777	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.683807	2025-10-19 02:29:41.683807
1f100372-46db-430b-9907-c726117b8d04	CEPILLO TORNADO KIDS	6948031100952	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.684287	2025-10-19 02:29:41.684287
1552f3e3-311b-420a-a0d7-2507b74ac002	CEPILLO TOP ORAL KIDS	7450077002712	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.684763	2025-10-19 02:29:41.684763
4b205231-a82e-44e2-9bfe-a9b04dd1b5b3	TOSH BARRA 23GR	7702007063639	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.685092	2025-10-19 02:29:41.685092
89af389b-b4e7-4f5f-ba0a-0c84635b8d2d	QUESO DOBLE CREMA GRANDE	5S4DAD	t	10000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.685536	2025-10-19 02:29:41.685536
39d4e993-241a-407f-803a-8107e2b118c9	JABON FRESKITO AVENA 75GR	7708977668256	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.685831	2025-10-19 02:29:41.685831
b50770d2-c349-4874-bd39-71d4e9ecf7cc	ELITE DUO X6UNID	7707199343699	t	10900.00	10900.00	\N	\N	19.00	2025-10-19 02:29:41.686064	2025-10-19 02:29:41.686064
0f0151be-0918-4fcf-abe2-564edf4f2b59	JUGO HIT FRUTAS TROPICALES VIDRIO 237ML	7702090027853	t	1700.00	1542.00	\N	\N	19.00	2025-10-19 02:29:41.686303	2025-10-19 02:29:41.686303
67ceb4e4-137c-49ff-9c7b-3d8920d92166	REDONDITAS VAINILLA 12X4	7707323130409	t	7400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.686524	2025-10-19 02:29:41.686524
a871237b-e996-4460-9311-546a3a2ee47a	SHAMPOO KOLORS 400ML	7700304306398	t	8400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.686808	2025-10-19 02:29:41.686808
212d0167-33f9-4f89-94c0-c704627d4b4e	ARROZ GELVEZ 5.000GR	7707197472070	t	20000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.687121	2025-10-19 02:29:41.687121
7dc4f361-16e8-4ef0-9f57-4bf23dada1c1	AROMATEL 1.4L	7702191521229	t	10800.00	10400.00	\N	\N	19.00	2025-10-19 02:29:41.687383	2025-10-19 02:29:41.687383
e267beb1-b230-450c-b2b1-c070d0fc3eaf	JUGO HIT MANGO VIDRIO 237ML	7702090014914	t	1700.00	1542.00	\N	\N	19.00	2025-10-19 02:29:41.68772	2025-10-19 02:29:41.68772
79cc0030-a912-4540-a0af-e680610cb667	SUTEA FUSION FRUTAS	7702354950798	t	1300.00	1184.00	\N	\N	19.00	2025-10-19 02:29:41.688007	2025-10-19 02:29:41.688007
4497d2b5-c64a-42e7-aaf9-40403e5a0293	MORTADELA ZENU TRADICIONAL 450GR	7701101270349	t	11300.00	11000.00	\N	\N	19.00	2025-10-19 02:29:41.688337	2025-10-19 02:29:41.688337
4fcef9bc-0cc9-47c8-aadf-c41a008a8486	PAPEL ELITE MAX X12UNID	7707199342739	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.68863	2025-10-19 02:29:41.68863
b2107906-8f62-4be3-a3f3-f02a75658233	ELITE MAX RESINTENTE X12	7707199349691	t	12300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.688887	2025-10-19 02:29:41.688887
c7db6d52-26db-4d1d-9231-6e3cef428152	KARYMBA CHOCOBITZ 500GR	7702807200265	t	12300.00	11900.00	\N	\N	19.00	2025-10-19 02:29:41.689138	2025-10-19 02:29:41.689138
c36bd760-ba47-463f-8c48-27d0d9c874c8	JUGO DEL VALLE 1.5 LITRS	7702535022061	t	3900.00	3584.00	\N	\N	19.00	2025-10-19 02:29:41.689394	2025-10-19 02:29:41.689394
2eb37547-5f1b-4d61-bbaf-d84a05d1187f	CREMA DE ARROZ POLLY 450GR	7591112004435	t	6800.00	6550.00	\N	\N	19.00	2025-10-19 02:29:41.689621	2025-10-19 02:29:41.689621
58ad66e0-9ffc-4fe2-b3d7-afa28dc00a20	ARENA PARA GATOS KELCO 4KG	7709116758210	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.69014	2025-10-19 02:29:41.69014
16c0e492-67df-41a9-858e-6832ace81335	PAPEL FAMILIA MEGARROLLO X12	7702026148492	t	21500.00	21000.00	\N	\N	19.00	2025-10-19 02:29:41.690498	2025-10-19 02:29:41.690498
277ab152-437f-473e-ab2e-3cf1e5330dfc	PAN TAJADO PEQUEÑO	4AS51	t	2300.00	2250.00	\N	\N	0.00	2025-10-19 02:29:41.69088	2025-10-19 02:29:41.69088
a92b8473-ae2e-47c2-ac14-fb32b35d1a28	IBUPROFENO AG 800MG 50UND	7706569000385	t	11000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.691354	2025-10-19 02:29:41.691354
bf1a56ff-2144-4b34-9042-4b8a19e5afca	MUU MAX CHOCO 12X4	7702011271075	t	8400.00	\N	\N	\N	0.00	2025-10-19 02:29:41.692041	2025-10-19 02:29:41.692041
585b66a8-70ae-4e7d-b76d-8e150ead3108	FESTIVAL GOLOCHIPS UND	7702007058970	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.692692	2025-10-19 02:29:41.692692
9a1821b2-46ec-432f-9995-c8f9d243d19c	7 CEREALES EXTRA SEÑORA 60GR	7708624784919	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.693366	2025-10-19 02:29:41.693366
0eb04456-8f7f-4a52-bcbb-db20eb6ec6cf	SHAMPOO CHILDERN 80ML	7709268662946	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.693793	2025-10-19 02:29:41.693793
51dca97a-24e0-41c1-9ab5-8cc049295f80	CHOCORAMO ESQUINAS 50GR	7702914602761	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.694562	2025-10-19 02:29:41.694562
810c3235-0576-4ce2-83a6-9d0799480d25	TAZA DARNEL 16 ONZ 25U	7702458285918	t	13500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.695377	2025-10-19 02:29:41.695377
5cca9d62-67e6-4e5a-aad5-b77998e44224	SHAMPOO SILVESTRE 1000ML	7707594900206	t	11500.00	10900.00	\N	\N	19.00	2025-10-19 02:29:41.695816	2025-10-19 02:29:41.695816
b9130bbb-5610-4bca-8abf-5bddae71bbd9	SUAVIZANTE BONDI 6LITROS	7707633430879	t	28000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.696663	2025-10-19 02:29:41.696663
2fe5bbba-2e3d-40dd-a16f-0343a73c64e3	PAPA CALDO	PAPA CALDO	t	2000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.697298	2025-10-19 02:29:41.697298
5570f0eb-b8c2-45a4-9b4a-f3ba6e983f9a	SIXPACK LECHE ENTERA 900ML	7705241100658	t	21000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.697795	2025-10-19 02:29:41.697795
6fbc02f4-ccc6-49b1-8027-8590773c6301	JABONERA MUNDI UTIL	7709134320475	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.69862	2025-10-19 02:29:41.69862
8c20cc15-f331-4c98-a42e-cbab2db4d4f2	ESCOBA LEOMAR	7709205216294	t	5100.00	4950.00	\N	\N	19.00	2025-10-19 02:29:41.699086	2025-10-19 02:29:41.699086
ffe2f361-78c7-4da4-8259-c7f2ed791be7	NUCITA 18 UND	7702011021915	t	11000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.699592	2025-10-19 02:29:41.699592
b164e070-9170-4079-ba2b-d2d10630a605	GALLETAS MI DIA 5 TACOS 470GR	7705946257787	t	6000.00	5850.00	\N	\N	19.00	2025-10-19 02:29:41.699911	2025-10-19 02:29:41.699911
c7c566bf-25b3-41a0-bf06-a198b7d41576	GALLETA TOSH 4CEREALES 2 TACOS 388G	7702025148363	t	9000.00	8800.00	\N	\N	19.00	2025-10-19 02:29:41.70026	2025-10-19 02:29:41.70026
bd663880-391b-4c1c-a6e8-133f8c09cce7	MAYONESA NATUCAMPO PREMIUM ORIGINAL 900GR	7709990058109	t	20700.00	20200.00	\N	\N	19.00	2025-10-19 02:29:41.700521	2025-10-19 02:29:41.700521
8f08e02a-b515-4f93-b9fd-f53e5517e774	POOL 1.7ML PIÑA	7709696985914	t	3200.00	2938.00	\N	\N	19.00	2025-10-19 02:29:41.700806	2025-10-19 02:29:41.700806
052a45be-69de-43d2-b32e-632ee52ce382	HUESO DE CERDO PARA PERROS LOPETS	7709489699752	t	5900.00	\N	\N	\N	0.00	2025-10-19 02:29:41.701059	2025-10-19 02:29:41.701059
99838d26-fd4e-48a6-ba50-236e53fb1d19	PAÑITOS TOTITOS PAGUE 25 LLEVE 35	7709990128130	t	3500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.701378	2025-10-19 02:29:41.701378
59483e7d-6e41-48aa-92bc-b7d832103f68	PINGUINO LECHE ACHOCOLATADA 180ML	7705326082008	t	3300.00	3140.00	\N	\N	19.00	2025-10-19 02:29:41.70161	2025-10-19 02:29:41.70161
cac90600-a85e-4c24-939f-133bbfa1fe40	LAVALOZA FASSI 230GR	7702230662128	t	2900.00	2800.00	\N	\N	19.00	2025-10-19 02:29:41.70184	2025-10-19 02:29:41.70184
64f8f579-4469-4c0e-b0a4-48bc3e8a1ec3	COMPOTA BABYFRUIT MANZANA SOBRE 90GR	7707262680102	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.702108	2025-10-19 02:29:41.702108
4db0e894-bd57-4325-81ac-80cd45d7f727	LADY SPEED STICK CLINICAL 70GR	7509546665221	t	8000.00	7650.00	\N	\N	19.00	2025-10-19 02:29:41.702622	2025-10-19 02:29:41.702622
afbcb762-4fde-4495-982a-bf45e394d6fb	SALCHICHA AMERICANA CIFUENTES 10XUNID	548SDSD	t	18300.00	18000.00	\N	\N	19.00	2025-10-19 02:29:41.702937	2025-10-19 02:29:41.702937
6177a4d0-15b2-4cb2-80c7-89dc158fb65d	GRAGEAS ELITE 500GR	7880705483482	t	5400.00	5200.00	\N	\N	19.00	2025-10-19 02:29:41.70323	2025-10-19 02:29:41.70323
ab135532-ea34-4a0c-8b92-456dae6061ab	LADY SPEED STICK CLINICAL 100GR	7509546668673	t	13200.00	10600.00	\N	\N	19.00	2025-10-19 02:29:41.703528	2025-10-19 02:29:41.703528
395568b9-d3a6-41bb-9d5f-d24dcba22b26	RICATO CARANELO SUAVE LECHE X50	7702993027745	t	7700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.703835	2025-10-19 02:29:41.703835
cc92115b-71b4-4a98-97c6-b11960cabe54	COMINO MOLIDO LA SAZON DE LA VILLA 50GR	7707767149883	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.704242	2025-10-19 02:29:41.704242
99b564e3-29ae-4025-9d57-c9c2a92c032d	COMPOTA BABYFRUIT PERA SOBRE 90GR	7707262687064	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.704562	2025-10-19 02:29:41.704562
1b72f4a3-66a7-4dd1-b55f-2f54f2eaf55d	BOMBILLO BRILLA LUZ 60W	6935787900158	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.704857	2025-10-19 02:29:41.704857
0b49044d-ee6b-4938-93e0-49773e505526	AROMATEL SUAVITEL LIQUIDO PRO 5L	7702191163832	t	32800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.705097	2025-10-19 02:29:41.705097
a9285d52-1a36-4ca5-8730-9d34efada0e8	MENTHUS CORPORAL 110GR	7709855906897	t	4400.00	4200.00	\N	\N	19.00	2025-10-19 02:29:41.705405	2025-10-19 02:29:41.705405
73cbe390-b43b-4991-9c97-faf3061ee246	MENTHUS CORPORAL 110GR	7709518580266	t	4400.00	4200.00	\N	\N	19.00	2025-10-19 02:29:41.705935	2025-10-19 02:29:41.705935
a0c7e2e8-1d37-4e53-8fe8-135b447acde2	TIJERAS OFFI-ESCO	7709990457643	t	4800.00	4600.00	\N	\N	19.00	2025-10-19 02:29:41.706245	2025-10-19 02:29:41.706245
ad9a9c75-b981-49ce-97e3-a99f40cd68f3	ACEITE DE ARGAN SPRAY	7709154396597	t	5200.00	4800.00	\N	\N	19.00	2025-10-19 02:29:41.706541	2025-10-19 02:29:41.706541
8d79f527-b215-4e4b-8af5-43c86bf78c7c	DURAZNO SUDESPENSA 425GR	7707309250657	t	6000.00	5800.00	\N	\N	19.00	2025-10-19 02:29:41.70692	2025-10-19 02:29:41.70692
0c472c7c-826f-4df4-ae48-0fc236fe5b71	CHORIZO JALAPEÑO X8UNID	SD5SD	t	12800.00	12600.00	\N	\N	19.00	2025-10-19 02:29:41.70728	2025-10-19 02:29:41.70728
1f82786a-e7de-4bfc-9e86-75edb0602e18	SALCHICHA ZENU TRADICIONAL X9UNID	7701101261071	t	8400.00	8300.00	\N	\N	19.00	2025-10-19 02:29:41.70768	2025-10-19 02:29:41.70768
0acb7ff7-6782-4656-b882-8f23c5b4aca5	SALCHICHA ZENU LING X10UNID	7701101261170	t	13500.00	13300.00	\N	\N	19.00	2025-10-19 02:29:41.708064	2025-10-19 02:29:41.708064
f486fa07-a770-4379-9c16-dbbc971d1524	MORTADELA DELICHICKS 250GR	7700506003774	t	5600.00	5500.00	\N	\N	19.00	2025-10-19 02:29:41.708352	2025-10-19 02:29:41.708352
827fae1f-6ec0-4a62-b0d9-f83636c54fe5	MORTADELA DELICHICKS 450GR	7700506004580	t	9600.00	9500.00	\N	\N	19.00	2025-10-19 02:29:41.708645	2025-10-19 02:29:41.708645
8bc72e5c-d55b-4b11-a037-7704350ae39f	LECHE CONDENSADA TUBITO 17GR	7707226110447	t	700.00	\N	\N	\N	0.00	2025-10-19 02:29:41.70893	2025-10-19 02:29:41.70893
389e6aca-c0e0-45fe-93eb-349be162f435	MIRAMONTE LECHE ENTERA 400GR	7707228547937	t	9800.00	9400.00	\N	\N	0.00	2025-10-19 02:29:41.709214	2025-10-19 02:29:41.709214
f7204432-80d8-4aaa-9290-ce05e34b25fd	SHAMPOO NUTRIT MAS ACONDICIONADOR KERATINA	7702277155713	t	35000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.709445	2025-10-19 02:29:41.709445
995f3f40-4757-4cfc-9fdd-cc6cefbaf357	SHAMPOOO NUTRIT MAS ACONDICIONADOR REPARAMAX	7702277155720	t	35000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.709682	2025-10-19 02:29:41.709682
908a4b2d-3916-4519-8873-a50a6777c636	SHAMPOO NUTRIT MAS ACONDICIONADOR RESTAURAMAX	7702277844181	t	35000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.709876	2025-10-19 02:29:41.709876
cf2b8c88-2c59-4db3-9ffd-42943cd568f0	SERVILLETA ELITE PRACTICA X100UNID	7759185397278	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:41.710187	2025-10-19 02:29:41.710187
3236a34f-a080-4e23-b9eb-140ebd50e0f0	SHAMPOO ARRURRURU AVENA 2 EN 1800ML	7702277157427	t	30500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.710433	2025-10-19 02:29:41.710433
238c3ba2-621f-4dc4-8929-5d5fb6d74113	KOTEX CUIDADO AVANZADO 6 MAS 6	7702425800861	t	5300.00	5150.00	\N	\N	19.00	2025-10-19 02:29:41.710656	2025-10-19 02:29:41.710656
fe45702c-9875-4a38-8904-2dbbf6b12b08	SUPERCAN CACHORROS 1.5KG	7707025802109	t	9000.00	8800.00	\N	\N	19.00	2025-10-19 02:29:41.710868	2025-10-19 02:29:41.710868
3bbf37d6-8290-4b28-a830-4a66c0180507	FABULOSOS LAVANDA 1LITROS	7702010225123	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.711087	2025-10-19 02:29:41.711087
63a35f9f-b02a-44ce-adbc-c3f1da65d7c1	FLUO CARDENT KIDS SIN FLUOR 96GR	7702560043840	t	11000.00	10650.00	\N	\N	19.00	2025-10-19 02:29:41.711324	2025-10-19 02:29:41.711324
7e07b2f1-2837-451e-8e11-f87c22baa8cb	PAÑITOS ARRURRU DE AVENA X100UNID	7702277395256	t	11300.00	10900.00	\N	\N	19.00	2025-10-19 02:29:41.711587	2025-10-19 02:29:41.711587
07609018-1db3-41dc-b734-ea6bcee06d62	MERMELADA PIÑA LA CONSTANCIA 80GR	7702097148582	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:41.711777	2025-10-19 02:29:41.711777
1b0f7d96-8d3e-44e3-9ead-934c5565668b	PAPAS MARGARITA POLLO 105GR	7702189053770	t	6600.00	6500.00	6400.00	\N	19.00	2025-10-19 02:29:41.712026	2025-10-19 02:29:41.712026
a070ed84-38af-477d-818f-8bd58d0a21e4	TRAPERO NUMERO 500	SD5453	t	4200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.712343	2025-10-19 02:29:41.712343
6462c089-9513-4ae7-b813-7dce3583370b	BIMBOLETE BIMBO 27GR	7705326080189	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.71254	2025-10-19 02:29:41.71254
0904094d-e194-4c96-b129-b8f6887585ee	BOKA SALPICON 18GR	7702354947231	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:41.712778	2025-10-19 02:29:41.712778
ba5c4ca3-e482-40fe-8659-317e9c5be939	PALO TRAPERO LARGO	ASD345	t	3700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.713022	2025-10-19 02:29:41.713022
a995979f-5516-4ad9-bb4f-9bdcd5ac4cb3	PLATANO MADURO	PLATANO MADURO	t	4000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.713311	2025-10-19 02:29:41.713311
b442d919-f6e5-4f74-bc26-9c7591bd2e69	VERDURAS TOTAL	VERDURAS TOTAL	t	10000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.713624	2025-10-19 02:29:41.713624
5936c0a9-c282-4519-8fc6-b92fb8d47393	SALSA SABORES TROPICO	7709274748719	t	3200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.713853	2025-10-19 02:29:41.713853
07504f9c-16bb-4a55-81d2-d385f394d619	SPEED STICK XTREME NIGHT TARRO 100GR	7702010231513	t	10700.00	10300.00	\N	\N	19.00	2025-10-19 02:29:41.714098	2025-10-19 02:29:41.714098
acba39e3-6ab5-4936-8938-f31d0da55efb	LADY SPEED STICK TARRO 100GR	7702010231506	t	10700.00	10300.00	\N	\N	19.00	2025-10-19 02:29:41.714395	2025-10-19 02:29:41.714395
38b659ae-837f-4738-a5a4-4e2060caa969	TARRITO ROJO KOLA GRANULADA FRESA 135GR	7702560046230	t	10000.00	9800.00	\N	\N	0.00	2025-10-19 02:29:41.714937	2025-10-19 02:29:41.714937
d28c1ef5-4fb1-4f6e-9d7c-7b9b3f78e424	CEPILLO KIDS DINOSAURIO	7700304175895	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:41.715167	2025-10-19 02:29:41.715167
8b5170a7-2110-4fd0-b87c-dcb97f20891a	RAID MAX MATA CUCARACHAS Y CHIRIPAS 285ML	7501032926199	t	12300.00	11900.00	\N	\N	0.00	2025-10-19 02:29:41.715435	2025-10-19 02:29:41.715435
d0a78add-b465-419e-98ff-86d4da7f8fa6	WHISKAS GATICOS 85GR	706460000641	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.71571	2025-10-19 02:29:41.71571
75948cf7-39e8-4fe3-aade-0a35930ee624	CREMA DE MANOS DELIA	5901350485231	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:41.71592	2025-10-19 02:29:41.71592
43b03f9e-caeb-443e-82a8-e39ce058be90	SHAMPOO HIDRATANTE NATURAL FEELING 400ML	7700304026807	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.716181	2025-10-19 02:29:41.716181
4e101d6f-d621-4939-a855-d4a2ff2b42d0	SHAMPOO NATURAL FEELING 400ML	7700304836413	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.716426	2025-10-19 02:29:41.716426
4dfc4875-3865-439a-824b-8ddf8916caf0	REMOVEDOR DE ESMALTE NATURAL FEELING 250ML	7700304333462	t	6300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.716645	2025-10-19 02:29:41.716645
db6b867e-2aa0-4453-98eb-329162eb624a	DESODORANTE ANTITRANSPIRANTE  DAMA 1500ML	7704269962514	t	8400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.71687	2025-10-19 02:29:41.71687
e40294da-e073-4277-8c1b-3865086d8a6f	MIEL DE ABEJA 350GR	7700304110445	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.71719	2025-10-19 02:29:41.71719
66437680-510b-436a-b86e-155d353e83a7	ESPUMA DE AFEITAR SKINO MEN 200ML	7704269818606	t	5300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.7174	2025-10-19 02:29:41.7174
5e1f591b-8c31-4882-9128-f48f0d1e2999	DESODORANTE AEROSOL COOL 150ML	7704269153226	t	8400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.717604	2025-10-19 02:29:41.717604
2b35350b-d716-4662-a6cd-47404e0711f2	BONAROPA AROMATEL DE COCO 1LITRO	7700304346851	t	6000.00	5750.00	\N	\N	19.00	2025-10-19 02:29:41.717838	2025-10-19 02:29:41.717838
0efef191-6522-4b77-85a0-9ee75a520627	POLVO ABRASIVO BRILLAKING 500GR	7700304046942	t	2600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.718063	2025-10-19 02:29:41.718063
a8c423fd-2e8d-49ed-92e6-f8a18e226055	AJO MOLIDO LA SAZON 120GR PETPACK	7707767147971	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.718282	2025-10-19 02:29:41.718282
2b7f0716-db91-4bb4-8823-5e8a73cb51d6	GRANOLA HOLA DIA 1KR	7709990548280	t	12000.00	11700.00	\N	\N	19.00	2025-10-19 02:29:41.718487	2025-10-19 02:29:41.718487
4c83b1fe-7009-4018-adad-ec48976f8095	NUTRIBELA 15 REPARACION INTENSIVA 24ML	7702354951979	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.718717	2025-10-19 02:29:41.718717
8afd374c-058c-4d6f-9794-a87ff9c1a638	TOALLA DE PAPEL NOVA CLASICA 60HOJAS	7707199347758	t	2200.00	2050.00	\N	\N	19.00	2025-10-19 02:29:41.718951	2025-10-19 02:29:41.718951
b1f532c7-72ed-4aed-a9a8-5a0c31bc06df	VELON SAN JORGE DE CITRONELA	7707159821533	t	6500.00	6300.00	\N	\N	19.00	2025-10-19 02:29:41.719218	2025-10-19 02:29:41.719218
1c081657-6718-4cf3-af4b-1b0215b28a55	NATUREY 50GR	7702175958713	t	2200.00	2050.00	\N	\N	19.00	2025-10-19 02:29:41.719443	2025-10-19 02:29:41.719443
9de93ccb-81c1-456e-b640-56912cd3727a	NORAVER GRIPA CALIENTE NOCHE15GR	7702057160968	t	2700.00	\N	\N	\N	0.00	2025-10-19 02:29:41.719796	2025-10-19 02:29:41.719796
a55ba428-b262-4efb-bb26-920558c2c61e	GEL EGO ULTRAINTENCIDAD 110ML	7702006207850	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.720066	2025-10-19 02:29:41.720066
ab799963-9a9e-4ff3-bd0b-1c2f83eee1be	AROMATICA JAIBEL YERBABUENA	7702807482203	t	3100.00	2980.00	\N	\N	19.00	2025-10-19 02:29:41.720302	2025-10-19 02:29:41.720302
cc723d1f-13a3-4b27-97db-3f9660615378	SALSA CON PIÑA OCAÑERITA 200GR	7709025282417	t	1800.00	1650.00	\N	\N	19.00	2025-10-19 02:29:41.720561	2025-10-19 02:29:41.720561
e80043cc-2e8a-4658-aafa-2e5d61a485c2	SALCHICHON FINO COLANTA 450GR	7702129074360	t	7000.00	6900.00	\N	\N	19.00	2025-10-19 02:29:41.720779	2025-10-19 02:29:41.720779
dd7b95ba-dbbe-446e-8257-7427aee01b5d	NUTRIBELA TERMOPROTECCION 24ML	7702354951948	t	1500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.721044	2025-10-19 02:29:41.721044
2850c374-5b0e-4093-b114-745566799144	TAKIS FUEGO 45GR	7500810001295	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.721329	2025-10-19 02:29:41.721329
301a1635-e5ec-4302-877b-7953c7c4848b	JET AREQUIPE CHOCOLATINA 30GR	7702007212174	t	3700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.721555	2025-10-19 02:29:41.721555
3d90362a-f3aa-4b4d-a480-fe1ec14ce967	JET MORA CHOCOLATINA 30GR	7702007052923	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.721794	2025-10-19 02:29:41.721794
35e415cd-8e56-4da7-b059-0a99848a7cc9	CLUB SOCIAL MANTEQUILLA 26GR	7622300758943	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.722012	2025-10-19 02:29:41.722012
17f330aa-9c40-4c79-82ff-48ed49d1c7ad	TOSH MIEL 27GR	7702025148455	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.722284	2025-10-19 02:29:41.722284
a1ceae7f-0408-4f33-a410-785550d4ff4f	ORIGAMI CRUNCH 45GR	7702993045909	t	1200.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.722506	2025-10-19 02:29:41.722506
523b1c22-a255-4b98-9f5d-78ab59201b2f	FESTIVAL RECREO 54GR	7702025142033	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.722782	2025-10-19 02:29:41.722782
42eb5a95-e5fd-4bd5-9ca4-0b93cd0ae773	CHIDOS CHILE DULCE 38GR	7702152119458	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.722974	2025-10-19 02:29:41.722974
0c5621aa-c618-4921-a421-5a65efc25d93	MERMELADA BARY FRESA 200GR	7702439269296	t	4100.00	3950.00	\N	\N	19.00	2025-10-19 02:29:41.723362	2025-10-19 02:29:41.723362
183230dc-a7b2-418e-a310-4d1ab278641f	MERMELADA BARY MORA 200GR	7702439269302	t	4100.00	3950.00	\N	\N	19.00	2025-10-19 02:29:41.723626	2025-10-19 02:29:41.723626
0709a5c2-498a-4ce1-9d3a-1e314a20a606	MERMELADA BARY PIÑA 200GRR	7702439269319	t	4100.00	3950.00	\N	\N	19.00	2025-10-19 02:29:41.723875	2025-10-19 02:29:41.723875
ab8975d4-be2c-40d1-abb9-cd305f25d6e2	VANISH QUITAMANCHA BLANCO GEL 800ML	7702626217000	t	7500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.724148	2025-10-19 02:29:41.724148
7bf99329-55d5-401d-a09b-c12e135fbc5f	VANISH QUITAMANCHAS GEL 1800ML	7702626219400	t	16200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.724395	2025-10-19 02:29:41.724395
b6830d33-8034-4d31-aa97-8b7cb9952f23	VANISH QUITAMANCHA 1800ML MAS 800ML	7702626219844	t	22800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.724635	2025-10-19 02:29:41.724635
c8a2c2e0-b897-4beb-9dbb-5f693729c64d	CHOCOVETEADA JET X6UNID	7702007075090	t	42800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.724965	2025-10-19 02:29:41.724965
259d8c5c-80c1-41b3-a3e2-467f640a8122	SHAMPO CAPIBELL CEBOLLA Y BIOTINA 950ML	7703819018633	t	18900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.725212	2025-10-19 02:29:41.725212
12ce64c6-0daa-472b-acda-f1fa4aef8b6a	INDULECHE ALIMENTON LACTEO 380GR	7706921000251	t	9800.00	9300.00	\N	\N	19.00	2025-10-19 02:29:41.725461	2025-10-19 02:29:41.725461
f9b892ac-781a-4cd1-97c6-2dace94de07b	VINAGRE SABOR A FRUAS 500ML	7702439007850	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.72567	2025-10-19 02:29:41.72567
ebfafd4e-47fa-41fd-bb42-f86955522a40	BUSETAS DE CHICLES	7707301040355	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.725881	2025-10-19 02:29:41.725881
98ec06db-6d51-49d7-b337-cb10155e79c1	BISCOLATA MOOD 11GR	8699141057060	t	8400.00	8100.00	\N	\N	19.00	2025-10-19 02:29:41.726106	2025-10-19 02:29:41.726106
c0fcdd49-92a7-4b22-92b2-2905deb9c0b6	NUZART CREMA DE CACAO 350GR	7700304314300	t	11500.00	11000.00	\N	\N	19.00	2025-10-19 02:29:41.726335	2025-10-19 02:29:41.726335
b9ceaf88-7587-4f4f-a9c1-5072a0547ec2	CHUPETAS SURTIDA X48UNI	7707266911332	t	5400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.726551	2025-10-19 02:29:41.726551
c9388609-9e7b-4a7a-9e1a-c05e1ac7fa28	LONCHERAS YOLIS X14UNID	7707337520906	t	6800.00	6400.00	\N	\N	19.00	2025-10-19 02:29:41.726806	2025-10-19 02:29:41.726806
cbe85036-2cfd-43da-8af6-617c065dfeb7	TOALLA SUAVE DELGADA X10UNID	7702120012415	t	2900.00	2750.00	\N	\N	0.00	2025-10-19 02:29:41.727015	2025-10-19 02:29:41.727015
b9318a45-2a89-437a-aeee-87d8bf157733	GUPIZ FRITO LAY 28GR	7702189045379	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:41.727274	2025-10-19 02:29:41.727274
b6198677-5d34-4b7f-b3db-0f21e599d193	ORAL B KIDS 50GR	7500435137737	t	5800.00	5600.00	\N	\N	19.00	2025-10-19 02:29:41.727532	2025-10-19 02:29:41.727532
dd3fa33e-81bc-4997-aeba-6aaacefe265c	PAPA MARGARITA LIMON 105GR	7702189053794	t	6500.00	6350.00	\N	\N	19.00	2025-10-19 02:29:41.727761	2025-10-19 02:29:41.727761
35241c87-d2d3-4135-9cd6-254ac4321064	MIXTO FAMILIA X400GR	7706642002077	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.72803	2025-10-19 02:29:41.72803
9b4b69cd-54af-4c4e-9405-78b57e718ed2	FUZETEA DURAZNO 400ML	7702535014233	t	3100.00	2834.00	\N	\N	19.00	2025-10-19 02:29:41.728263	2025-10-19 02:29:41.728263
af34f635-a1a5-44c2-b1db-b2b4f97d2b3c	AMOXICILINA	5S5A	t	2900.00	\N	\N	\N	0.00	2025-10-19 02:29:41.72848	2025-10-19 02:29:41.72848
bea103c6-f468-4009-b098-f95960196d16	SUAVIZANTE ULTREX 205ML	7707839188048	t	1200.00	1140.00	\N	\N	19.00	2025-10-19 02:29:41.728695	2025-10-19 02:29:41.728695
52163554-b4cd-4704-b764-8765e3bb8ede	PASTA MONTICELLO FUSILLI 500GR	7702085243480	t	6600.00	\N	\N	\N	5.00	2025-10-19 02:29:41.728912	2025-10-19 02:29:41.728912
cc5850b0-7501-44f2-bfb0-5132537b69c2	AZUCAR INCAUCA 1KG	7702059502025	t	4300.00	4240.00	\N	\N	5.00	2025-10-19 02:29:41.729119	2025-10-19 02:29:41.729119
7df1981e-daff-4f92-83ab-96aa4eae09b5	JABON LUX X3UND	7702006205054	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.729338	2025-10-19 02:29:41.729338
8454651d-5b51-4234-a33a-b115d671b3a5	SALTIN NOEL TIPO LECHE X21UNID	7702025118311	t	8200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.729548	2025-10-19 02:29:41.729548
13ac640f-95a0-4302-9e0b-1cdd13e9f264	PAPA OREADAS MAYONESA 105GR	7706642008055	t	5400.00	5300.00	\N	\N	19.00	2025-10-19 02:29:41.729751	2025-10-19 02:29:41.729751
1e8dbb76-7c20-42b3-8909-111e7d6a7ebb	PASTILLA DESIFECTANTE TASK 50GR	7703147000119	t	4700.00	\N	\N	\N	0.00	2025-10-19 02:29:41.72996	2025-10-19 02:29:41.72996
deba146c-bc2b-4a81-8533-3a2365990ec1	TENEDOR BICHE X20UNID	7707355925110	t	1400.00	1350.00	\N	\N	0.00	2025-10-19 02:29:41.730281	2025-10-19 02:29:41.730281
7a779463-d93e-4b5b-b0c6-6dddb939f35f	SPAGHETTI LA MUÑECA MAS TOMATE LA CONSTANCIA	7702020120470	t	5600.00	5500.00	\N	\N	5.00	2025-10-19 02:29:41.73051	2025-10-19 02:29:41.73051
a774eba5-0b7d-4412-aae9-7b5219d66841	GEL ESCARCHADA MARIPOSA 120ML	7709107341872	t	7500.00	7400.00	\N	\N	19.00	2025-10-19 02:29:41.730721	2025-10-19 02:29:41.730721
8344d1db-52ab-4855-bcf9-f319dd41181d	COLOR AMARILLO LA SAZON DE LA VILLA 50GR	7707767147353	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.730956	2025-10-19 02:29:41.730956
d4a38a8d-2944-42ec-b75a-9adc81eb5573	TINTE BARCELO PROFESIONAL NEGRO	7707324825526	t	8500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.73117	2025-10-19 02:29:41.73117
5b7dc79e-19b5-470c-a864-5889c270109f	DONKAN CACHORRO 1KG	7702084000084	t	6700.00	6500.00	\N	\N	5.00	2025-10-19 02:29:41.731493	2025-10-19 02:29:41.731493
cbe21af5-6652-405a-b26d-d373357f89ee	RAMO TRACION SELECTO FRUTOS SILVESTRE 230GR	7702914602372	t	8000.00	7900.00	\N	\N	19.00	2025-10-19 02:29:41.731818	2025-10-19 02:29:41.731818
0fea49c7-ea9d-4fc2-980a-ef27564a8dfa	VARSOL410ML	S5DF3	t	6000.00	5830.00	\N	\N	0.00	2025-10-19 02:29:41.732166	2025-10-19 02:29:41.732166
1c4562f5-d043-4a66-80ca-92645102f447	MANTECA FRITURA 1.000GR	7706649262320	t	13700.00	13300.00	\N	\N	19.00	2025-10-19 02:29:41.732483	2025-10-19 02:29:41.732483
ac3d5d52-834f-4760-96be-dd192ad02401	MANTEQUILLA NATURA X4UNID 450GR	7701018002019	t	5900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.732792	2025-10-19 02:29:41.732792
30cfc26e-04a0-44da-83f4-f949918060fd	MANTEQUILLA NATURA 125GR	7701018002002	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.733185	2025-10-19 02:29:41.733185
11925627-5597-41de-8047-fa4a0a11790f	ORAL B KIDS 37ML	7500435129503	t	5800.00	5600.00	\N	\N	19.00	2025-10-19 02:29:41.733574	2025-10-19 02:29:41.733574
dc55d687-6af7-4457-a019-f71c1bf436bc	DETERK MULTIUSOS MANZANA 1.1KG	7702310045490	t	7500.00	7400.00	\N	\N	19.00	2025-10-19 02:29:41.733863	2025-10-19 02:29:41.733863
4096208c-ae8c-46f1-9b6f-8aca082e33e4	DETERK MULTIUSOS MANZANA 3KG	7702310045506	t	20500.00	20000.00	\N	\N	19.00	2025-10-19 02:29:41.734197	2025-10-19 02:29:41.734197
1e7ab8d8-e143-4a18-9607-995cb6a6d8bb	CHOCO KRISPIS KELLOGGS 250GR	7702103873552	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:41.734952	2025-10-19 02:29:41.734952
1e8a2f02-d01a-4256-bd2f-9ebb6026923d	MIEL DE ABEJA NORSAN 250ML	7707349859469	t	5900.00	5700.00	\N	\N	0.00	2025-10-19 02:29:41.735642	2025-10-19 02:29:41.735642
67ef3747-913d-4046-8ffd-a1a80c184199	CERA DEPILADORA AZULENO 120GR	7707271602034	t	13200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.735951	2025-10-19 02:29:41.735951
9c2dccf7-a215-47c6-9a54-4a2c4b5f4830	ACEITE IDEAL 800ML	7709385952852	t	6000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.736381	2025-10-19 02:29:41.736381
2bf5cf5c-185e-493a-9e0e-a6d86c26c101	PAPAS MARGARITAS ONDULADAS MAYONESA 105GR	7702189053831	t	6600.00	6500.00	6400.00	\N	19.00	2025-10-19 02:29:41.736789	2025-10-19 02:29:41.736789
cbb9d271-ec85-4c0f-9f4a-7f21793b048e	TALCO ESIKA 500ML	DS453F13	t	25000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.737366	2025-10-19 02:29:41.737366
5c30d6d0-93bb-49e3-8a45-fd813ac7173a	PRESERVATIVO SUPER SEX	6912176300881	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.73771	2025-10-19 02:29:41.73771
169d1529-e751-401d-811b-240286eac6ac	UNICO PLUS LAVANDA 220GR	7701018075525	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:41.738081	2025-10-19 02:29:41.738081
bb33fa54-c672-42a9-ac55-3a0f8a758253	DETERK MANZANA MEGA LIBRA 550GR	7702310045483	t	3800.00	3700.00	\N	\N	19.00	2025-10-19 02:29:41.738487	2025-10-19 02:29:41.738487
50107bd7-b47e-4b83-83b3-90942930384d	AROMATICA TOSH MANZANILLA JENGIBRE X30UNID	7702032115235	t	8800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.738845	2025-10-19 02:29:41.738845
5671711b-5232-4bdb-bfe8-79af8d756a3e	CREMA DE LECHE PARMALAT 400ML	7700604054654	t	8300.00	8080.00	\N	\N	0.00	2025-10-19 02:29:41.739201	2025-10-19 02:29:41.739201
20324143-d1ea-4e69-9473-fb7c5c405149	JUMBO TURBO EDICION ESPECIAL X3	7702007080100	t	24300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.739553	2025-10-19 02:29:41.739553
4b9e67de-67b1-430f-8de7-3f5cfeaeb5b9	PAN EL MEJOR	999ASFD4	t	2400.00	\N	\N	\N	0.00	2025-10-19 02:29:41.739927	2025-10-19 02:29:41.739927
3fe0781b-5c12-4d7b-8bef-4378cdac4bee	CASERO VAINILLA CHOCOLATE 220GR	7705326075963	t	6100.00	6000.00	\N	\N	19.00	2025-10-19 02:29:41.740241	2025-10-19 02:29:41.740241
41e6fbda-3b6d-497e-a6a0-b8c9fdd77352	CLUB SOCIAL INTEGRAL X9	7622201720056	t	6500.00	\N	\N	\N	5.00	2025-10-19 02:29:41.740687	2025-10-19 02:29:41.740687
03304f48-570e-49db-bdb7-2574c378add4	MORTADELA ZENU DE POLLO 450GR	7701101270332	t	11300.00	11000.00	\N	\N	19.00	2025-10-19 02:29:41.741256	2025-10-19 02:29:41.741256
eb96b173-68af-4225-b163-58fd561b0ee8	LAPIZ EXTRA JUMBO	7709733652083	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.741557	2025-10-19 02:29:41.741557
92d58743-8e31-4d33-bb0f-03ae925c4873	CEPILLO DE LAVAR CON HARAGAN	5S34FDA	t	6700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.741855	2025-10-19 02:29:41.741855
bb1d4020-21d0-4c85-998a-95d1fc9f1370	BOMBILLO PHILIPS 6W	8718699765439	t	4200.00	4080.00	\N	\N	19.00	2025-10-19 02:29:41.742223	2025-10-19 02:29:41.742223
b224861e-33dd-43b6-b8af-e9eeb8c1a195	SILICONA LIQUIDA SEGEL 30ML	7707706295541	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.742551	2025-10-19 02:29:41.742551
7f9faf53-91ce-4d46-805b-b13a79acc07d	GALLETA RUEDITAS CHOCOVAINILLA 12X4	7707014927271	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.743043	2025-10-19 02:29:41.743043
220181fa-dd89-4cce-9e2e-6225993c6d75	COMARRICO CORBATA 250	7707307962385	t	1800.00	1700.00	\N	\N	5.00	2025-10-19 02:29:41.743499	2025-10-19 02:29:41.743499
ad5da362-f4b5-4626-8112-bb7f346e93d0	SALCHICHA DELICHICKS 10UNID	7700506016286	t	7300.00	7200.00	\N	\N	19.00	2025-10-19 02:29:41.743976	2025-10-19 02:29:41.743976
e9a5194c-3b48-4642-99fe-2470ba142c5a	SALSA DE TOMATE BARY 1.000GR	7702439001070	t	13900.00	13600.00	\N	\N	19.00	2025-10-19 02:29:41.744395	2025-10-19 02:29:41.744395
2f11677a-4fb0-4eb0-84f3-0354985c673f	GEL EGO EXTREME MAX 80ML	7702006203760	t	1600.00	1525.00	\N	\N	19.00	2025-10-19 02:29:41.744722	2025-10-19 02:29:41.744722
7493f48c-59a1-45fc-9ade-020ac48f9d2c	AZUCAR PROVIDENCIA 500GR	7702059501028	t	2000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.745032	2025-10-19 02:29:41.745032
b6c44682-5fec-4e74-80ce-9de5256c56c7	PAN TAJADO GRANDE	SAD54F3A	t	4200.00	3950.00	\N	\N	0.00	2025-10-19 02:29:41.74539	2025-10-19 02:29:41.74539
915ef0e4-63cd-44ab-a11d-3ca6d5549dbf	SKALA BOTANICA 2EN1   1000GR	7897042004966	t	24500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.745763	2025-10-19 02:29:41.745763
16e66378-ed92-45a5-8cf4-eed9504076f9	ACETAMINOFEN JARABE LAPROFF 90ML	7703038065630	t	3500.00	3250.00	\N	\N	0.00	2025-10-19 02:29:41.746046	2025-10-19 02:29:41.746046
3a359dbf-895e-4db0-8d98-c5b7a518382a	CEPILLO CON COPA PARA BAÑOS ANDECOL	7708304267961	t	4500.00	4350.00	\N	\N	19.00	2025-10-19 02:29:41.746456	2025-10-19 02:29:41.746456
ed0b9e27-13c8-4ab6-9efb-7d814929feff	CONTENEDOR 24OZ X20UNID DARNEL	7702458019940	t	9800.00	9450.00	\N	\N	19.00	2025-10-19 02:29:41.74679	2025-10-19 02:29:41.74679
7c6ef5ee-e3ed-431d-9f99-61665cd84bb9	DSVS	5DS34GF35DS	t	1000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.747076	2025-10-19 02:29:41.747076
fb2a15e5-fa92-4242-ab2c-04a879176fc7	LECHE CONDENSADA PARMALAT 100GR	7700604046727	t	3000.00	2900.00	\N	\N	0.00	2025-10-19 02:29:41.747328	2025-10-19 02:29:41.747328
f9ecfde5-fa4f-4833-8d64-910ebce29e44	NUTELLA ESPARCIBLE 200GR	80135463	t	14700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.747582	2025-10-19 02:29:41.747582
b5d48607-901a-4ba6-ba7b-6080f1fb73c0	NUCITA CREMA CON AVELLANAS 350GR	7702011021953	t	15600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.747823	2025-10-19 02:29:41.747823
2ae73b48-c29c-4121-8591-4344b86991ae	ATUN DE LOMO EN ACEITE XOE 175GR	7708580487688	t	3700.00	3450.00	\N	\N	19.00	2025-10-19 02:29:41.748087	2025-10-19 02:29:41.748087
bd2f214d-f12d-47a4-91ca-9fe5404c00e0	FABULOSO LAVANDA 360ML	7509546655796	t	3700.00	3600.00	\N	\N	19.00	2025-10-19 02:29:41.748355	2025-10-19 02:29:41.748355
5c474db9-bf65-4685-898d-b4aea43afe01	RESTAURADOR CUBRE RASGUÑO BUFALO 360ML	7702377011667	t	16100.00	15700.00	\N	\N	19.00	2025-10-19 02:29:41.748623	2025-10-19 02:29:41.748623
be574133-8a33-4a64-8caa-73bf45293fd5	BETUM BUFALO MARRON 15GR	7702377000074	t	2100.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.748905	2025-10-19 02:29:41.748905
bad989f7-f53b-4d7d-a8b7-602a9828504b	CERA BUFALO ROJA 400CM	7702377005109	t	8500.00	8150.00	\N	\N	19.00	2025-10-19 02:29:41.749165	2025-10-19 02:29:41.749165
70782c97-f68a-42e8-af9c-372a7b929531	CERA BUFALO EMULSIONADA BLANCA 400CM	7702377005000	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:41.749399	2025-10-19 02:29:41.749399
db7d1766-141d-4868-81b3-380b510e6ac9	CHOCODISK DANDY 16GR	77024343	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.749706	2025-10-19 02:29:41.749706
1d4b8706-d658-4938-a9eb-af19173eaed8	SHAMPO HEAD SHOULDER MAS PANTENE 36UNID	7500435218672	t	24000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.749957	2025-10-19 02:29:41.749957
ad423d14-ca1c-4d77-8a9d-1fea3f2f04a6	LETRAS LA MUÑECA 250GR	7702020112062	t	1900.00	1790.00	\N	\N	5.00	2025-10-19 02:29:41.750305	2025-10-19 02:29:41.750305
e1140956-41df-46b9-96ba-9a4aa4519218	LECHE CONDENSADA PARMALAT 300GR	7700604046734	t	8000.00	7800.00	\N	\N	0.00	2025-10-19 02:29:41.75074	2025-10-19 02:29:41.75074
32a9f3d3-f64e-4cbd-a20e-47092590f1e3	ACEITE OLEOCALI VEGETAL 3000ML	7701018005072	t	26100.00	25600.00	\N	\N	19.00	2025-10-19 02:29:41.751029	2025-10-19 02:29:41.751029
b4b2a237-64b9-4ec2-bf1e-db85529fd172	BIG BEN CLASICO X50UNID	7702993046340	t	7400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.751354	2025-10-19 02:29:41.751354
920138a5-58e2-48a7-9c9d-da519c078861	TALCO REXONA EFFIENT 300GR MAS 85GR	7702006404358	t	25000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.751776	2025-10-19 02:29:41.751776
f5277907-7ea8-41e2-acb8-d34c5c3affe7	ALMENDRAS ITALO JORDANIA 50GR	7702117007912	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.752097	2025-10-19 02:29:41.752097
e9626be5-f982-4788-99a0-b7fb6951eb19	ALMENDRA ITALO SONORA 50GR	7702117008322	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.752366	2025-10-19 02:29:41.752366
d82f9331-38e4-4996-9e43-8ae2476b2e24	ALMENDRAS ITALO FRANCESA 135GR	7702117008193	t	5900.00	5750.00	\N	\N	19.00	2025-10-19 02:29:41.752714	2025-10-19 02:29:41.752714
06c66ba8-9724-416b-8f9d-936517602d05	ALMENDRA ITALO FRANCESA 250GR	7702117008179	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.753035	2025-10-19 02:29:41.753035
c3ee6f15-1581-40b8-8e67-ce84d5d0c23c	CHOCOLATE SAN JOSE TRADICIONAL 500GR	7707342420277	t	8200.00	8000.00	\N	\N	5.00	2025-10-19 02:29:41.753359	2025-10-19 02:29:41.753359
673d3210-f82c-4cff-a032-94fbbc93da8d	CHOCOLATE SAN JOSE VAINILLA 500GR	7707342420291	t	8200.00	8000.00	\N	\N	5.00	2025-10-19 02:29:41.753824	2025-10-19 02:29:41.753824
bc8b13c0-ab3e-43a7-aed4-bd7f05a694b8	CHOCOLATE SAN JOSE VAINILLA 250GR	7707342420307	t	6200.00	6050.00	\N	\N	5.00	2025-10-19 02:29:41.754107	2025-10-19 02:29:41.754107
99ec2a03-a2ce-4fef-a235-6d97e7d0224e	CHOCOLATE SAN JOSE TRADICIONAL 250GR	7707342420284	t	6200.00	6050.00	\N	\N	5.00	2025-10-19 02:29:41.754371	2025-10-19 02:29:41.754371
a3881cb8-99fa-463a-bbeb-df5d309c46dc	PASTILLA	ASF45A	t	1500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.754746	2025-10-19 02:29:41.754746
3124a58a-60a7-41e7-a19b-e90fc0694416	FUZE TEA	7702535016688	t	3100.00	2834.00	\N	\N	19.00	2025-10-19 02:29:41.755123	2025-10-19 02:29:41.755123
6b0c1069-9c39-49a9-9247-85d184ef28e1	ADOBO COMPLETO LA SAZON PETPACK 120GR	7707767144123	t	4400.00	4250.00	\N	\N	19.00	2025-10-19 02:29:41.756238	2025-10-19 02:29:41.756238
aaccdae2-6d5a-493e-848e-0cb05f1419d5	AGUA POOL X20UNID	115D54F35DS0	t	12500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.757854	2025-10-19 02:29:41.757854
eca842a3-464d-461f-8060-0046fb2774ca	DETERGENTE LIQUIDO AK1 1.8L	7702310048132	t	17400.00	17000.00	\N	\N	19.00	2025-10-19 02:29:41.762596	2025-10-19 02:29:41.762596
596d088a-62f6-4307-8490-cb332a0dcf40	SOPAS DORIA PACK X6 UNID	7702085003084	t	14200.00	\N	\N	\N	5.00	2025-10-19 02:29:41.764257	2025-10-19 02:29:41.764257
50628317-8ba8-4647-a9bf-1d23cb8931e2	HARINA PAN AMARILLA 800GR	7702084138046	t	3700.00	3600.00	\N	\N	5.00	2025-10-19 02:29:41.7667	2025-10-19 02:29:41.7667
c6d0dff4-a517-4c79-b254-9a50d50b4fb3	KOTEX PROTECTORES X15 IDICADOR PH	7702425864221	t	1800.00	1700.00	\N	\N	0.00	2025-10-19 02:29:41.76888	2025-10-19 02:29:41.76888
183775b0-d1f4-4bdf-a8af-e342c3d01009	PILAS TIPO D VARTA	SD456	t	4600.00	4400.00	\N	\N	0.00	2025-10-19 02:29:41.769923	2025-10-19 02:29:41.769923
23055190-18e3-4687-96a0-81e52ec79c7e	JET FRESA CON CREMA X12UNID 348GR	7702007079524	t	35200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.771618	2025-10-19 02:29:41.771618
1961d8ad-3777-4943-b081-23f4d5354a3c	JET FRESA CON CREMA 29GR	7702007079517	t	3100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.77262	2025-10-19 02:29:41.77262
ffd7c62d-80b5-4dff-a7c3-7ececbcd8c89	NOXPIRIN CALIENTE NOCHE 10GR	7707355054346	t	2200.00	2000.00	\N	\N	0.00	2025-10-19 02:29:41.773703	2025-10-19 02:29:41.773703
7371af2c-ae13-4bef-a7e2-e29e66213b8a	CONDON DUO 3G	4005800041495	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.774471	2025-10-19 02:29:41.774471
cff24010-5262-4fdd-b593-c55b300bae67	AGUA OIGENTA 20 VOL	7702615719911	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.775557	2025-10-19 02:29:41.775557
342915c3-af66-405b-8088-2622c1a6e52a	SPEED STICK CLINICAL 70GR	7509546665214	t	8200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.776132	2025-10-19 02:29:41.776132
6cd9f113-a384-4935-904d-ed1ad89f6716	GALLETAS DULCE NAVIDAD 180GR GAMESA	7702189039484	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.776837	2025-10-19 02:29:41.776837
08305640-66c9-4051-b53f-96e4b0c344fb	JOHNSONS SHAMPOO 400ML HIDRATACION	7702031293194	t	19500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.777797	2025-10-19 02:29:41.777797
4ebf3dc1-cdff-41d1-b7c8-ead76df65892	TODO RICO BAR BBQ 150GR	7702152109701	t	6000.00	5880.00	\N	\N	19.00	2025-10-19 02:29:41.778627	2025-10-19 02:29:41.778627
7dafc803-e669-4f05-a47e-71bac53c7580	ALOKADOS COFFE X10UNID	7707014953218	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.779181	2025-10-19 02:29:41.779181
9976418c-efff-4eb7-a1f7-867d228757da	ACEITE IDEAL 710ML	7709385952814	t	5800.00	5600.00	\N	\N	19.00	2025-10-19 02:29:41.780292	2025-10-19 02:29:41.780292
ad47f07f-1a0e-4346-af69-b26fbb2b71a0	LOCION CORPORAL VIT HUCMENTANTE 1LITROS	7702044265157	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.784899	2025-10-19 02:29:41.784899
ab45e279-683c-494b-a9a8-3dc00549edbd	WAFER ITALO X24UNID	7702117008452	t	5900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.79259	2025-10-19 02:29:41.79259
320d0b8b-2faf-4c46-9c70-94b52e051806	MASA PASABOCAS X30UNID	3D4F3	t	3200.00	3000.00	\N	\N	0.00	2025-10-19 02:29:41.794445	2025-10-19 02:29:41.794445
3fc830cb-fd47-4cd7-9f9a-efc314257e56	PONKY PONKECOLOMBINA 33GR	7702011201065	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.795339	2025-10-19 02:29:41.795339
c3a4a116-b7f9-4bf0-bd21-771839425c3a	PONKY LONCHERA X5UNID	7702011200983	t	6500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.795991	2025-10-19 02:29:41.795991
0ad043b8-0b1f-4ffc-a1de-ce1755892991	PEINE MOJARRA	5D4F3SD	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.797022	2025-10-19 02:29:41.797022
333e0de1-e5f2-492f-87e9-4155b634634f	JET BURBUJET X6UNID 300GR	7702007055979	t	31200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.797833	2025-10-19 02:29:41.797833
511193ee-9bf2-4292-a84a-9df8d13bba12	SALSA DE SOYA IDEAL 975ML	7709912927889	t	4800.00	4550.00	\N	\N	19.00	2025-10-19 02:29:41.798553	2025-10-19 02:29:41.798553
eada9f4f-ecd0-432d-822f-0481510c722f	AGUA POOL 300ML	7709237598566	t	600.00	438.00	\N	\N	0.00	2025-10-19 02:29:41.799105	2025-10-19 02:29:41.799105
6aef6224-a8ef-43e9-93c4-0981b6a9ba20	SALSA BBQ LA CONSTANCIA 80GR	7702097148520	t	1600.00	1540.00	\N	\N	19.00	2025-10-19 02:29:41.799628	2025-10-19 02:29:41.799628
dd6885ea-ca7d-4cd3-be68-31c438dda7f6	QIDA CAN CACHORROS 500GR	7702712003319	t	3400.00	3280.00	\N	\N	5.00	2025-10-19 02:29:41.800238	2025-10-19 02:29:41.800238
482cf159-53f9-4e85-9463-459ff5f75124	NIVEA MEN BLACK WHITTE 9G	4005900820297	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.800746	2025-10-19 02:29:41.800746
8a46adaf-856b-4f70-a576-e8a931dde613	PAPEL ALUMINO HOUSE 7 M	7707320620071	t	2900.00	2800.00	2680.00	\N	19.00	2025-10-19 02:29:41.801446	2025-10-19 02:29:41.801446
8306e75d-4a14-45ac-9875-c671e465f20d	JET GOOL X100UNID	7702007046137	t	32800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.80192	2025-10-19 02:29:41.80192
1fec1b35-ef71-44bc-a196-bd3942dcc660	COMPOTA HEINZ CIRUELA 113GR	608875003241	t	3500.00	3250.00	\N	\N	19.00	2025-10-19 02:29:41.802439	2025-10-19 02:29:41.802439
b9394553-a850-4f53-85ac-1531fbc0bf1a	ESPONJA DE COLORES X12UNID	C65W2	t	4500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.803154	2025-10-19 02:29:41.803154
dfff631a-202f-4e0c-ac00-b70ad199718e	DETERK ANTIBACTERIA BICARBONA 950G	7702310045438	t	5700.00	5550.00	\N	\N	19.00	2025-10-19 02:29:41.803684	2025-10-19 02:29:41.803684
15073b42-9a07-429e-a750-5c708a5c3026	AGUA OXIGENTA 30 VOL	7702615719928	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.804396	2025-10-19 02:29:41.804396
aa6163ec-665a-484f-b3cd-59a685cd94a4	ARROZ GELVEZ 3.000GR	7707197477228	t	12000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.805344	2025-10-19 02:29:41.805344
abdbc6d5-3662-4a7c-a7b1-ff826a8a163a	MECHERA SMAT X25UNID	1795864318307	t	8700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.806245	2025-10-19 02:29:41.806245
6876dcfc-7171-4686-ab29-1904a406ffd7	ROSAL ULTRACONFORT XXG X4UNID	7702120012996	t	7600.00	7350.00	\N	\N	19.00	2025-10-19 02:29:41.807259	2025-10-19 02:29:41.807259
69a78076-7acc-4d8c-b016-fdc9a4dbd0cb	ROSAL ULTRACONFORT XXG X6UNID	7702120014167	t	9000.00	8750.00	\N	\N	19.00	2025-10-19 02:29:41.807971	2025-10-19 02:29:41.807971
e7648f25-dd9d-48c8-b685-c5d73b2c2292	LUX BOTANICALS JAZMIN X 3	7702006205061	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.809168	2025-10-19 02:29:41.809168
aefca2ed-ffe5-4a89-b509-8f82f5b044e3	LAK BEBE X3 UND	7702310020787	t	5300.00	5150.00	\N	\N	19.00	2025-10-19 02:29:41.810756	2025-10-19 02:29:41.810756
8d778326-9376-440f-b385-55e08370cb28	VELAS LA PAZ X10UNID	7707301130636	t	6100.00	5850.00	\N	\N	19.00	2025-10-19 02:29:41.811638	2025-10-19 02:29:41.811638
2fbe184e-8c09-41a1-9a10-a9d3eaf5a3d8	LIMPIADOR MULTIUSO AZUL KLEAN 500ML	7702310042314	t	2600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.812285	2025-10-19 02:29:41.812285
a0e803db-fd9f-4c1e-885c-f1f8b311761e	LIMPIADOR MULTIUSOS AZUL KLEAN 500ML	7702310042321	t	2600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.81271	2025-10-19 02:29:41.81271
014be843-5421-4263-9052-c81f9a999b20	LIMPIADOR MULTIUSO AZUL KLEAN 500ML	7702310042307	t	2600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.813294	2025-10-19 02:29:41.813294
52c4285e-0b6d-45e7-adcc-24a05e7f2bba	DETODITO X12 BBQ	7702189039446	t	29800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.814076	2025-10-19 02:29:41.814076
eb1ee52d-bf66-4bfd-8c7a-791b844b64e3	SALSA VINAGRE NORSAN 170GR	7709990793666	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:41.81479	2025-10-19 02:29:41.81479
1b6fe2cd-c824-42ef-8bcb-5db7f10ff824	CHOKIS 282GR	7702189056252	t	9800.00	9700.00	\N	\N	19.00	2025-10-19 02:29:41.815322	2025-10-19 02:29:41.815322
4d0bf02a-07de-4878-bc80-c90ac3378eed	SALSA HARDYS BARY 200GR	7702439008307	t	4600.00	4450.00	\N	\N	19.00	2025-10-19 02:29:41.815891	2025-10-19 02:29:41.815891
5093a638-c40e-4f03-a24f-325437e853ee	GILLETTE ACTIVE PROTECT TRAINING 82GR	7500435153195	t	17900.00	17400.00	\N	\N	19.00	2025-10-19 02:29:41.816294	2025-10-19 02:29:41.816294
a51f52e0-e687-4b82-8c89-3f4cc197a9c4	CUREBAND X100UNID	7702057648930	t	10000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.816713	2025-10-19 02:29:41.816713
a713a9df-b174-4341-8833-15457d0246a5	CHOCLITOS LIMON X12UNID	7702189050106	t	13900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.817104	2025-10-19 02:29:41.817104
bd02e8f3-fe34-4d70-9e84-9bfc9d99fe05	SALSA BBQ NORSAN 170GR	7709300045782	t	2100.00	1950.00	\N	\N	19.00	2025-10-19 02:29:41.817449	2025-10-19 02:29:41.817449
5b0bcc1f-281b-44c7-ba11-1d146aa02a35	SCOTT CUIDADO COMPLETO X12UNID	7702425915213	t	16800.00	16300.00	\N	\N	19.00	2025-10-19 02:29:41.817734	2025-10-19 02:29:41.817734
f2d7af9b-d830-4673-8c94-77011633b2ce	FIDEOS COMARRICO 1.000GR	7707307962187	t	5600.00	5417.00	\N	\N	5.00	2025-10-19 02:29:41.818131	2025-10-19 02:29:41.818131
3f5348fe-9454-4929-85e9-c08ca68bbd92	LACA CAPILAR LA FIESTA AZUL	8426373005626	t	9500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.818551	2025-10-19 02:29:41.818551
35eea6ff-0851-4ae7-864d-6de89b439685	GEL FRUTO TROPICO GELATINA 250GR	7709946544007	t	5200.00	5050.00	\N	\N	19.00	2025-10-19 02:29:41.818875	2025-10-19 02:29:41.818875
8f34d03a-6ccb-4151-9269-cdb4a166a32d	POOL NARANJA 400ML	7709836686213	t	1200.00	909.00	\N	\N	19.00	2025-10-19 02:29:41.819211	2025-10-19 02:29:41.819211
1dec3e49-5e7e-498f-9329-cd21b268ccfd	TRULULU AROS X100UNID	7702993010648	t	15900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.819554	2025-10-19 02:29:41.819554
6f64085d-545a-434b-b150-0db43cf4767f	PILA ALKALINA TRONEX AA	7707822752515	t	4500.00	4400.00	\N	\N	19.00	2025-10-19 02:29:41.819879	2025-10-19 02:29:41.819879
872bb1a4-0f99-4f0d-ab11-65fa3c3f2e85	OREGANO MOLIDO LA SAZON PETPACK 100GR	7707767143843	t	4200.00	\N	\N	\N	0.00	2025-10-19 02:29:41.820259	2025-10-19 02:29:41.820259
30f17d1b-29d7-4b6c-8231-9e47631b94e1	CHOCOLATE CORONA FLASH 500GR INSTANTANEO	7702007033649	t	12000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.820634	2025-10-19 02:29:41.820634
5fecbb85-97e6-47d4-aabe-67c225a3e029	SALCHICHA VIENA BLONY 150GR	7702160002506	t	3400.00	3250.00	\N	\N	19.00	2025-10-19 02:29:41.82122	2025-10-19 02:29:41.82122
86eca379-fab7-4fc4-bdcb-378122fa33e1	TALCO VALNIS DAMA 200GR	7709413484294	t	3100.00	2850.00	\N	\N	19.00	2025-10-19 02:29:41.821859	2025-10-19 02:29:41.821859
c66e2d38-4ee3-44c6-82a6-cc3148c8d639	TALCO VALNIS FOR MEN 200GR	7709413484232	t	3100.00	2850.00	\N	\N	19.00	2025-10-19 02:29:41.822512	2025-10-19 02:29:41.822512
015aabcd-f0dc-4392-92b8-4f59023a1cf9	TALCO VALNIS FOR MEN 85GR	7709938866506	t	2000.00	1800.00	\N	\N	19.00	2025-10-19 02:29:41.822861	2025-10-19 02:29:41.822861
0b74eaa4-26c1-4d12-b88d-1bd0b66aa8b0	TALCO VALNIS DAMA 85GR	7709413484225	t	2000.00	1800.00	\N	\N	19.00	2025-10-19 02:29:41.823173	2025-10-19 02:29:41.823173
2a8079a3-8a69-441b-ad50-aead96457d61	CEROPISS 60ML	7707296880066	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.824301	2025-10-19 02:29:41.824301
3c28b031-64f9-49f5-bac6-d9bcb7904e60	SHAMPOO COMBO CAPIBELL X3UNID	7703819364693	t	27000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.824928	2025-10-19 02:29:41.824928
4c782e6f-b51d-48f9-8ad9-5feb117b63b6	SONETTO CHOCOLATE X100U	7702174085441	t	8400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.82564	2025-10-19 02:29:41.82564
bfa9d83b-c927-4749-b9c9-fe673a2c2323	TIRA PRESTOBARBA XTREME 18U	7502214734595	t	42000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.826844	2025-10-19 02:29:41.826844
b858fe4c-dfe3-457e-8ef7-b9887248de71	POOL UVA 3.020ML	7709769790889	t	5700.00	5167.00	\N	\N	19.00	2025-10-19 02:29:41.827516	2025-10-19 02:29:41.827516
1656ae88-ad9b-438c-92d4-cd21d2d7c735	BARBIE ANILLO 13GR	7703888964107	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.829033	2025-10-19 02:29:41.829033
b0d10a36-85f6-4310-8452-073d329f0c79	COMARRICO ARGOLLITAS 250GR	7707307962422	t	1800.00	1700.00	\N	\N	5.00	2025-10-19 02:29:41.830112	2025-10-19 02:29:41.830112
fac40de3-3c5c-4c91-835a-40b5cb9bbe99	FLIPS CHOCOLATE 400GR	7702807414112	t	12800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.831014	2025-10-19 02:29:41.831014
71798761-6a38-47e0-a489-1cb92a46ed41	AREQUIPE EL ANDINO 500GR	7709068596670	t	7200.00	6950.00	\N	\N	19.00	2025-10-19 02:29:41.83231	2025-10-19 02:29:41.83231
52a4d107-9ebf-48e1-bf0a-245bf2895c5e	TINTE PASTILLA COLOR 1	7707223660013	t	2200.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.832828	2025-10-19 02:29:41.832828
70e9e1fe-72ab-4106-b5d6-20b439a37e47	JUMBO CHUNCHY X12UNID	7702007063202	t	43900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.833332	2025-10-19 02:29:41.833332
6f2775b6-eff5-4204-9f2b-989eeed2a809	PAPAS MARGARITAS 65GR	7702189056740	t	3700.00	3600.00	\N	\N	19.00	2025-10-19 02:29:41.835014	2025-10-19 02:29:41.835014
f84ad5d5-5ef2-45e3-8d77-93b8203f1e28	SHAMPOO ANYELUZ CON AGUACATE 500ML	7709885135588	t	33000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.8366	2025-10-19 02:29:41.8366
3f1ca674-06dd-4dbd-b955-f0f3f966be1c	SOPA MAGGI SANCOCHO	7702024234135	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.837276	2025-10-19 02:29:41.837276
9eddf684-f769-4ab1-8fa3-06733738864d	AROMATEL MANDARINA 900ML	7702191162125	t	8200.00	8000.00	\N	\N	19.00	2025-10-19 02:29:41.837652	2025-10-19 02:29:41.837652
f860845a-1a93-41c4-ade3-03ad9ea6596c	BIGBOM X48 FUSION	7707014902889	t	15200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.838102	2025-10-19 02:29:41.838102
1c070a85-adc6-403f-b7df-eb26594ea30f	AMPOLLA ANTI CAIDA 12ML	AMPOLLA	t	1800.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.838567	2025-10-19 02:29:41.838567
e1da03f8-9735-41d7-a26c-f184ad98821f	DUCALES X3 315GR	7702025147915	t	8600.00	8400.00	\N	\N	19.00	2025-10-19 02:29:41.838923	2025-10-19 02:29:41.838923
b792cee1-fd83-4a44-b1be-65b6b27c79b5	CAFE SELLO ROJO 1.000GR	7702032102488	t	34000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.839293	2025-10-19 02:29:41.839293
e8cfc9a4-e71b-4e27-8c0a-fb921dfb3013	VELON SANTA MARIA N14	7707297960033	t	21900.00	21300.00	\N	\N	19.00	2025-10-19 02:29:41.839639	2025-10-19 02:29:41.839639
221dd79e-c943-4f9b-a976-7a941183a2e6	FANATICOS SURTIDOS X15UNID SUPER RICOS	7702152127644	t	11000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.839985	2025-10-19 02:29:41.839985
5a6d5fbb-af94-494a-85b3-cdd6b53f808f	CHORIZO TERNERA CIFGUENTESX10UNID	CHORI	t	12800.00	12600.00	\N	\N	0.00	2025-10-19 02:29:41.84032	2025-10-19 02:29:41.84032
ebb6b841-6ef4-41b8-acca-3eb038163d02	SALMON LA SOBERANA ACEITE SOYA 101GR	7702910099732	t	4600.00	4480.00	\N	\N	19.00	2025-10-19 02:29:41.840711	2025-10-19 02:29:41.840711
603b4d4e-861e-4e7f-bd11-f301ff312547	ATUN DOÑA MAGOLA 175GR	658325172317	t	3500.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.841071	2025-10-19 02:29:41.841071
16be2de0-d231-40b9-b336-30e066d72289	KATORI MATA VOLADORES 235ML	7702332012357	t	8400.00	8100.00	\N	\N	0.00	2025-10-19 02:29:41.841428	2025-10-19 02:29:41.841428
b51b0746-38bd-4ab3-9c48-89b7f6c5aeaa	KATORI MATA VOLADORES 360ML	7702332013606	t	11400.00	11000.00	\N	\N	0.00	2025-10-19 02:29:41.841751	2025-10-19 02:29:41.841751
a6172305-f527-40ef-a34a-60e9da8808e8	SORIDERM CHAMPU ANTICASPA 250ML	7707035580233	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.842148	2025-10-19 02:29:41.842148
926ecbbe-513c-47c5-a8ce-4f4ce4b9d68f	AGUA OXIGENADA 60ML  10VOL	7706659500160	t	3100.00	\N	\N	\N	0.00	2025-10-19 02:29:41.84256	2025-10-19 02:29:41.84256
34f77cb6-3162-4236-a8c9-b845fe325a9b	SERVILLETA ELI PRACTICA 300UNID	7709606194184	t	3600.00	3470.00	\N	\N	19.00	2025-10-19 02:29:41.842911	2025-10-19 02:29:41.842911
a02f48c1-f4a0-408b-8e85-bb6419c315fc	ELITE ULTRA X4 MEGA ROLLO X4	7709554623514	t	8200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.843275	2025-10-19 02:29:41.843275
72ac50c4-57b6-4a30-b1f3-edfb04aee24b	MORA 500GR	7709511581130	t	2100.00	\N	\N	\N	5.00	2025-10-19 02:29:41.843575	2025-10-19 02:29:41.843575
96577c9f-4f89-4b00-b34b-36ea46b19672	TRULULU MASMELOS CHOCOVAINILA 65GR	7702993043547	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.843854	2025-10-19 02:29:41.843854
ff332b2f-eae5-4fad-b98b-cfbbe536aef5	CEPILLO VIAJER DENTAL PLUS	6934741706133	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:41.844129	2025-10-19 02:29:41.844129
9cf4a29f-25f6-4cc0-b085-3fae49efa785	PAPEL FAMILIA ACOLCHAMAX X4	7702026148560	t	7900.00	7600.00	\N	\N	0.00	2025-10-19 02:29:41.844432	2025-10-19 02:29:41.844432
33768ccd-5aa6-4a6d-b6a2-e097ae1941db	LIGAS AKARELLA	7708909775298	t	1000.00	792.00	\N	\N	0.00	2025-10-19 02:29:41.844705	2025-10-19 02:29:41.844705
150b7b21-acb6-4101-8ab4-dd203c2fc2a1	AJO MOLIDO LA SAZON 50GR	7707767146769	t	1400.00	1300.00	\N	\N	0.00	2025-10-19 02:29:41.845006	2025-10-19 02:29:41.845006
5e17fca4-fc4a-49ad-b2e8-924fd65c7d1e	PALMOLIVE 110GR OLIVA ALOE 3200	7509546676982	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:41.845338	2025-10-19 02:29:41.845338
288acf26-6eaa-4b60-879d-bf8d7207a554	DOG CHOW ADULTOS MEDIANOS 350GR	7702521013578	t	4000.00	3850.00	\N	\N	5.00	2025-10-19 02:29:41.84569	2025-10-19 02:29:41.84569
8c7c239a-0c31-45c4-b08d-a6ba4a38bea7	OKA LOKKA NANO 40GR	7702993016589	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.846295	2025-10-19 02:29:41.846295
62533459-3fde-485d-8bfa-74b5fbe979b3	CEPILLO ESTUCHE TOP ORAL	7450077031972	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:41.846654	2025-10-19 02:29:41.846654
7a650a10-8a00-4765-9498-61e8bbfce2fb	POLLO CON CHAMPIÑONES AL VINO 160GR	7701101356906	t	11300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.846987	2025-10-19 02:29:41.846987
4b9a072a-3144-4d95-865b-baa6ecdf9508	BOMBONERA SUPERCOCO	7702993016145	t	19000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.847289	2025-10-19 02:29:41.847289
d832041f-9c15-4e94-b238-c67fc26726e4	MIRRGO 8 KILOS	7703090785064	t	70000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.847609	2025-10-19 02:29:41.847609
c9c61342-85f2-4bf4-af69-1f9839d0a8af	TRULULU GOMITAS FEROZ 77GR	7702993045701	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.847911	2025-10-19 02:29:41.847911
c0cd7fa3-0da1-4c60-bff8-6ae2f8791319	JUGO HIT X6UNID	7707133061122	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.848223	2025-10-19 02:29:41.848223
49df6520-1aba-49ae-afab-9e8dd9ec8aaa	TRIDENT 8.5GR	7622201776695	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.848476	2025-10-19 02:29:41.848476
ea0b31f8-35d9-49ca-9d14-1bd0af75daee	AGUA POOL 1000ML CHUPO	7709004927742	t	1800.00	1667.00	\N	\N	0.00	2025-10-19 02:29:41.848759	2025-10-19 02:29:41.848759
ea434d46-ef00-4804-8483-2393b636f842	MAIZ PIRA SUDESPENSA 460GR	7707309250077	t	2600.00	2500.00	\N	\N	0.00	2025-10-19 02:29:41.849066	2025-10-19 02:29:41.849066
3777879b-bf24-4fe5-a5ea-d4ba261bf354	TARRITO ROJO 330GR MAS 80GR FRESA	7702560043499	t	26200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.849311	2025-10-19 02:29:41.849311
aec0096f-ecea-4398-ae29-c4bfb0658253	VARSOL LA JOYA 1000ML	7702088902667	t	11600.00	11400.00	\N	\N	0.00	2025-10-19 02:29:41.849563	2025-10-19 02:29:41.849563
6282c268-f5e6-45a5-9bd8-840331b469ee	TRATAMIENTO PANTENE BAMBU NUTRE Y CRECE 300ML	7500435155908	t	16500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.849861	2025-10-19 02:29:41.849861
e51920cb-90ca-45c6-866d-d55d62e6be5d	WAFER JET COOKIES CREAM 22GR	7702007042481	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.850375	2025-10-19 02:29:41.850375
da0c05e7-1ec3-410f-922a-123b2821fbd0	TRIDENT MENTA X18	7622201776657	t	23500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.850695	2025-10-19 02:29:41.850695
f5856672-9744-4b65-83f4-8b1706bf5437	PROTECTORES SUAVE ACTIVE CARE X15UNID	7702120012446	t	1300.00	1100.00	\N	\N	0.00	2025-10-19 02:29:41.850973	2025-10-19 02:29:41.850973
e86429dd-b2b2-4b39-8e4c-0b43b6df44f9	AZUCAR PROVIDENCIA 1K	7702104010352	t	4300.00	4240.00	\N	\N	0.00	2025-10-19 02:29:41.851256	2025-10-19 02:29:41.851256
3645af15-1fab-4759-b9c7-41ec4afa2b56	SALTIN NOEL QUESO MANTEQUILLA 133GR	7702025139965	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.851567	2025-10-19 02:29:41.851567
5ab95221-252c-43e7-9cbd-aca04356c17a	ARROZ GELVEZ 10K	7707191479525	t	41000.00	\N	\N	\N	5.00	2025-10-19 02:29:41.851822	2025-10-19 02:29:41.851822
790acf86-7f60-4ba7-a682-0a2bf93c9d2b	DOLEX GRIPA	D685	t	1300.00	\N	\N	\N	0.00	2025-10-19 02:29:41.852075	2025-10-19 02:29:41.852075
c66a353f-2d14-49d8-9dc8-c5176a46282f	TARRITO ROJO KOLA GRANULADA 250GR	7702560045066	t	7600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.852311	2025-10-19 02:29:41.852311
f4f91c63-6fbe-4e63-8a5c-421ef89a377d	SHAMPOO VANART COCO KERATINA  600ML	650240039331	t	7900.00	7500.00	\N	\N	19.00	2025-10-19 02:29:41.852533	2025-10-19 02:29:41.852533
85f71d6b-a33d-4c77-b8db-ff01328b5498	SHAMPOO EL VIVE LOERAL REPARADOR 680ML	7509552817348	t	29000.00	28000.00	\N	\N	19.00	2025-10-19 02:29:41.852765	2025-10-19 02:29:41.852765
f2441ee5-edd5-4ccd-8e1a-c2704fcc9f87	SALSA DE HUMO NORSAN	7709834109288	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.853106	2025-10-19 02:29:41.853106
81af0d1c-6ff9-4591-960a-3ea5a77df9f6	DELECHITAS X18 243GR	7703051004340	t	3200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.85332	2025-10-19 02:29:41.85332
4a19e39c-1f16-429c-a7a7-c92de9d3b1bf	FIDEOS DORIA 200GR	7702085001967	t	1400.00	1300.00	\N	\N	5.00	2025-10-19 02:29:41.853554	2025-10-19 02:29:41.853554
01226acf-740e-4e9f-9635-9a038173a4c6	PIN POP POLVO ACIDO X12UNID	7702174083966	t	6500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.853805	2025-10-19 02:29:41.853805
59d8882d-9194-4e5a-8bd7-d5e0d7257c14	BIG BEN X100UNID	7702993012994	t	11300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.854034	2025-10-19 02:29:41.854034
de0c3821-6fbb-4c9a-8e54-8d72ca3566e2	MENTA CHAO XTREME CEREZA X100UNID	7702993045145	t	6000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.854249	2025-10-19 02:29:41.854249
67a7b556-49d8-4a92-a470-f8f24fba0ff4	MENTA CHAO XTREME ORIGINAL X100UNID	7702993045138	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.854505	2025-10-19 02:29:41.854505
0eed7ecf-4f44-43fe-afdd-6fd8fc6c3aaf	BIANCHI MOKA X100UNID	7702993045404	t	8500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.854742	2025-10-19 02:29:41.854742
ebc3c9ef-4cdd-42ec-b4cc-73a535e3405f	HUEVOS NO ME OLVIDES PIKIS 60GR	7702117164240	t	2900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.854984	2025-10-19 02:29:41.854984
84743392-05a3-48d0-9d87-18ca03ff0d6f	SOPA INSTANTANEA AJINOMEN COSTILLA DE RES 80GR	7754487001762	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.855227	2025-10-19 02:29:41.855227
a517e809-b094-4464-b075-4570fa43f0e5	SOPA INSTANTANEA AJINOME GALLINA PICANTE 80GR	7754487001670	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.855471	2025-10-19 02:29:41.855471
85914e35-41db-4619-aa5a-3c43ae10d145	SOPAS INSTANTANEA AJINOMEN CARNE 80GR	7754487001700	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.855709	2025-10-19 02:29:41.855709
40f856ed-27f2-4b0d-9ef2-95ff6f62560b	CEPILLO INFINITA NIÑO	7708320718454	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.855915	2025-10-19 02:29:41.855915
b0bb27b9-7a1d-4ac9-9f15-8f013cf60794	SOPA INSTANTANEA AJINOMEN POLLO CON VERDURA 80GR	7754487001694	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.856158	2025-10-19 02:29:41.856158
bd890904-d9d5-4f69-9f55-82f305cae257	SOPA INSTANTANEA AJINOMEN GALLINA 80GR	7754487001663	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.856427	2025-10-19 02:29:41.856427
db80d981-5c88-4e59-8c4c-735ddff91b5e	MEDICARE PAÑITOS HUMEDOS BABY 150GR	7703252043605	t	12200.00	11750.00	\N	\N	19.00	2025-10-19 02:29:41.85669	2025-10-19 02:29:41.85669
df8e0879-439d-4529-a5e5-5f3736302f74	JET LECHE Y CALCIO MAS LECHE X24UNID	7702007512311	t	25600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.856922	2025-10-19 02:29:41.856922
9bec9bd5-3085-4c80-a92b-b0e1a400f406	PAPAS MARGARITA LIMON BOLSAZA 80GR	7702189059659	t	4200.00	4000.00	3900.00	\N	19.00	2025-10-19 02:29:41.857159	2025-10-19 02:29:41.857159
8628722e-a40d-4a77-894b-9266720b3bc2	ATUN DOÑA MAGOLA	7865936091217	t	3500.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.857359	2025-10-19 02:29:41.857359
d1c55fc8-4dc0-4e58-a5b4-d4fa790cae13	BABYSEC XG/50UNID	7707199340865	t	59600.00	58100.00	\N	\N	19.00	2025-10-19 02:29:41.857588	2025-10-19 02:29:41.857588
85d85e6b-a13c-42c9-a080-53e3a7200c30	SHAMPO DOVE HIDRATACION Y SUAVIDAD 400ML	7702006206617	t	16500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.857815	2025-10-19 02:29:41.857815
1efce61a-95d5-4b97-88b6-d4b0cb48be1d	SHAMPO DOVE RECONSTRUCCION 200ML	7891150008953	t	9000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.858041	2025-10-19 02:29:41.858041
d327bf5f-389b-496e-9e0f-95538deda77d	SHAMPOO SAVITAL ANTICASPA 350ML	7702006207911	t	11800.00	11400.00	\N	\N	19.00	2025-10-19 02:29:41.858375	2025-10-19 02:29:41.858375
b6059739-24b4-4784-9ef4-69a5e44e7b23	SHAMPO DAVO MAS ACONDICIONADO TRATAMIENTO 400ML	7702006405430	t	31500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.858602	2025-10-19 02:29:41.858602
7b414da5-715a-4d36-a7c9-294ab1ffb489	FAB LAVADO COMPLETO 2KG MAS 450GR	7702191001240	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.858847	2025-10-19 02:29:41.858847
31e8debc-9242-4a4d-a231-97c5c6a38ae7	JUMBO ROSCA MITI MITI X6UNID	7702007077681	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.85908	2025-10-19 02:29:41.85908
96db8854-5d51-4029-8517-398e24d6e066	TOSH BARRAS SURTIDOS X10UNID	7702007064186	t	11300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.859334	2025-10-19 02:29:41.859334
f88036cc-2dcf-4904-b3e3-0d0ad3244cf6	DETERK FLORAL 2850GR	7702310045377	t	19500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.859551	2025-10-19 02:29:41.859551
817acb38-b79c-484c-a366-92f0ce8401af	GEL DE BAÑO Y DUCHA AGRADO 750ML	8433295043827	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.85977	2025-10-19 02:29:41.85977
af29ba8f-3946-4f59-97e7-b558b573ae46	JABON HUGGIES EXTRA SUAVE 75GR	7896018704398	t	3400.00	3290.00	\N	\N	19.00	2025-10-19 02:29:41.860002	2025-10-19 02:29:41.860002
5b6768c8-4295-447e-aca9-95e633d214cd	GOHNSON AVENA CREMOSO 110GR	7702031401025	t	4300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.860217	2025-10-19 02:29:41.860217
6945c62a-2fda-44d5-8302-620d41a7cd1b	MACARRON CORTO COMARRICO 454G	7707307963184	t	2800.00	2700.00	\N	\N	5.00	2025-10-19 02:29:41.860448	2025-10-19 02:29:41.860448
08ca3351-9ee9-463e-af05-acad47724893	SPAGHETTI COMA RICO 450GR	7707307963146	t	2800.00	2700.00	\N	\N	5.00	2025-10-19 02:29:41.860684	2025-10-19 02:29:41.860684
394651a5-4d63-46f9-8624-6440342e3a3b	KRYZPO SABOR ORIGINAL 130GR	7802800630318	t	8500.00	8200.00	\N	\N	19.00	2025-10-19 02:29:41.860901	2025-10-19 02:29:41.860901
e17ee2cd-43a1-45b8-8f12-51eb64483613	YOGUETA YOGUE POPS X12UNID	7702174084291	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.861139	2025-10-19 02:29:41.861139
ec5a3632-a356-4cb4-ad71-a41bc4fbd1bb	AVIONCITOS CHOCOLATE	6925374517487	t	2600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.861374	2025-10-19 02:29:41.861374
e342f47e-d455-40fd-bbb9-6b0de54cf36c	MAYONESA IDEAL X12 85GR	7708276981827	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.861614	2025-10-19 02:29:41.861614
1313b655-7e15-4563-9de7-5b082578ebe9	HIT MORA 500 ML	7702090029857	t	2400.00	2150.00	\N	\N	19.00	2025-10-19 02:29:41.861863	2025-10-19 02:29:41.861863
6c3e3552-3a53-45b4-8093-d66eee4f334a	COLOR ACHIOTE 500GR LA SAZON	7707767141610	t	8400.00	\N	\N	\N	0.00	2025-10-19 02:29:41.862247	2025-10-19 02:29:41.862247
6a0dfc84-e4ef-4612-a435-86e2ab595502	JUMBO TURBO 180GR	7702007080094	t	5000.00	4800.00	\N	\N	19.00	2025-10-19 02:29:41.862565	2025-10-19 02:29:41.862565
f7bf159f-c923-4937-aff4-a0d2f326620d	SARDINA DOÑA MAGOLA 425GR	7709496553511	t	4400.00	4200.00	\N	\N	19.00	2025-10-19 02:29:41.862825	2025-10-19 02:29:41.862825
276e0ce6-f5ba-47a3-bda2-10681f730b5c	TOALLAS STAYFREE NORMAL X42UNID	7702031579458	t	13500.00	13000.00	\N	\N	0.00	2025-10-19 02:29:41.863111	2025-10-19 02:29:41.863111
fa426691-0890-4327-9b47-605db7593449	LA MUÑECA CABELLO DE ANGEL 125GR	7702020111119	t	1000.00	880.00	\N	\N	5.00	2025-10-19 02:29:41.863409	2025-10-19 02:29:41.863409
e72b1d18-d21c-4aab-8cea-29a297e324f7	AGUA OXIGNTA 10 VOL	7702615719904	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.863733	2025-10-19 02:29:41.863733
b839fc7b-18f7-42f7-a46b-6cd57713c8b0	KRYZPO SABOR A POLLO 130GR	7802800630998	t	8500.00	8200.00	\N	\N	19.00	2025-10-19 02:29:41.863961	2025-10-19 02:29:41.863961
d0fc24db-86c7-4274-a8c3-41cf45f4b6a0	BABYSEC 3G /50UNID	7707199340858	t	47000.00	46500.00	\N	\N	19.00	2025-10-19 02:29:41.864166	2025-10-19 02:29:41.864166
f7af2c90-eaaf-4a46-8e52-663e3ebfabcb	NOSOTRAS INVISBLE CLASICA X10 UND	7702027415692	t	4600.00	\N	\N	\N	0.00	2025-10-19 02:29:41.864405	2025-10-19 02:29:41.864405
8f059404-2f2f-4d02-ac54-a964cfe6d365	MIRAMONTE LECHE ENPOLVO ENTERA 900GR	7707228548033	t	20400.00	19700.00	\N	\N	0.00	2025-10-19 02:29:41.864635	2025-10-19 02:29:41.864635
cd345b98-ad04-4847-bc92-01ebad7ac528	CODOS DIANA 125GR	7707166100843	t	1100.00	1000.00	\N	\N	5.00	2025-10-19 02:29:41.864849	2025-10-19 02:29:41.864849
10327d5a-eb76-4b7e-9b3f-8478f3cd7dea	CONCHITAS DIANA 125GR	7707166100645	t	1100.00	1000.00	\N	\N	5.00	2025-10-19 02:29:41.865104	2025-10-19 02:29:41.865104
bbb0c6fa-8efb-4ea5-8fcb-f998207fbbca	FORMINANTES DIANA 125GR	7707166100942	t	1100.00	1000.00	\N	\N	5.00	2025-10-19 02:29:41.865334	2025-10-19 02:29:41.865334
ef93ac20-b368-4dc3-86d2-865ac60088f1	SALCHICHAS CIFUENTES MANGUERA	AS5	t	7200.00	7100.00	\N	\N	5.00	2025-10-19 02:29:41.865543	2025-10-19 02:29:41.865543
a02836a5-3af4-4a01-8482-6fc2562bf321	VINAGRE DE MANZANA REGIS DE MANZANA 500ML	700083798671	t	5900.00	5700.00	\N	\N	19.00	2025-10-19 02:29:41.865739	2025-10-19 02:29:41.865739
4e10d98b-d633-4595-9ce8-5aa918fe0699	ENJUAGUE BUCAL ORAL PLUS CUIDADO COMPLETO 180ML	7707860022144	t	7100.00	6850.00	\N	\N	19.00	2025-10-19 02:29:41.865969	2025-10-19 02:29:41.865969
eb37aee1-baaa-4a41-9160-e43e23c102cb	SHAMPOO CAPIBELL CEBOOLA MAS ACONDICIONADOR 470	7703819363887	t	24900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.866182	2025-10-19 02:29:41.866182
1eaf6a38-178c-44c0-a13a-98f1c9a9bf26	JABON CORPORAL AMATIC 750ML	7707291393769	t	11000.00	10660.00	\N	\N	19.00	2025-10-19 02:29:41.86641	2025-10-19 02:29:41.86641
96178123-0fe2-4357-a18a-c97e2a3f2cbf	CREMA HUMEDADA FRESKITOS 800ML	7709586352352	t	8900.00	8400.00	\N	\N	19.00	2025-10-19 02:29:41.866716	2025-10-19 02:29:41.866716
f1a4a05c-096e-468d-92c6-fcd503d28453	ACEITE RIQUISIMO NATURAL SABOR A MANTEQUILLA 5L	7701018004952	t	42600.00	42000.00	\N	\N	19.00	2025-10-19 02:29:41.867367	2025-10-19 02:29:41.867367
788d11d6-f44a-49ec-818c-19484cfa47e7	CORBATIN DORIA 250GR	7702085012178	t	2200.00	2100.00	\N	\N	5.00	2025-10-19 02:29:41.867655	2025-10-19 02:29:41.867655
b548c8c6-a483-4ff4-93f3-5317ccc3508b	TOALLAS SUAVE NOCTURNA X8UNID	7702120012439	t	3500.00	3390.00	\N	\N	0.00	2025-10-19 02:29:41.867889	2025-10-19 02:29:41.867889
839f8e73-8b68-447a-96c3-5482d9c58f55	CEPILLO MATRIX GAFAS	7453078549552	t	3800.00	3650.00	\N	\N	19.00	2025-10-19 02:29:41.86811	2025-10-19 02:29:41.86811
6195c77b-e9b6-4d48-86de-c203e27a0c84	SONETO ROSADO X100	7702174085427	t	7800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.86837	2025-10-19 02:29:41.86837
02ab8d39-dcb7-4636-af72-abe0ef4aab5a	ACEITUNAS VERDES 180GR	5904378640194	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.868632	2025-10-19 02:29:41.868632
b8997ad2-8262-4e01-99bb-5142584215ba	SALCHICHA AMERICANA MIXTA TIPO AMERICANA 1.000GR	734191414215	t	13000.00	12800.00	\N	\N	19.00	2025-10-19 02:29:41.868884	2025-10-19 02:29:41.868884
ab4c4838-89ac-4a95-837f-03094ddd0cb9	CLORO BLANQUEADOR 2L	7707325449929	t	3500.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.869151	2025-10-19 02:29:41.869151
0edb6321-f62d-47c2-acd0-ab1dd1832e7a	MILLOWS COLOMBINA SNACK 35GR	7702011124449	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:41.869391	2025-10-19 02:29:41.869391
87875f31-0b14-4aa1-9729-477dc01184ca	CEPILLO LION GUARD LUZ	070942001823	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.869587	2025-10-19 02:29:41.869587
75a150ae-cc48-4e2e-a0f5-491eec67777e	SUNTEA LIMON 1.5L	7702354948344	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:41.869809	2025-10-19 02:29:41.869809
5ce5fa9f-0008-4623-a73a-c40ed37c02d8	CREMA YODORA 60 MAS 32 GR	7702057089290	t	26000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.870018	2025-10-19 02:29:41.870018
584cc302-6138-4c78-8ac4-20a29c804e82	900	SHAMPO KONZIL SEDA LIQUIDA	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.870264	2025-10-19 02:29:41.870264
440cf86b-36f3-4ac7-a946-9ee6da799276	BARRILETE NAVIDAD X40	7702993043929	t	7900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.87049	2025-10-19 02:29:41.87049
cdce5776-418c-4d61-9dbb-251f153b1ec0	CAFE LA BASTILLA TOSTADO 450GR	7702032103331	t	14700.00	14400.00	\N	\N	5.00	2025-10-19 02:29:41.870765	2025-10-19 02:29:41.870765
838ae9fd-bc8e-4b93-8a7e-de932170144f	PAPEL ALUMINIO CAJA 7M SUPER BLUE	0734191236183	t	3500.00	3400.00	\N	\N	19.00	2025-10-19 02:29:41.87101	2025-10-19 02:29:41.87101
864cf44f-ebb4-4d2a-8aee-fff807a666b3	TOALLAS NOSOTRAS EXTRA PROTECCION 6 MAS 6	7702026189099	t	5900.00	5700.00	\N	\N	0.00	2025-10-19 02:29:41.871269	2025-10-19 02:29:41.871269
8ee8249e-3f9c-4d23-a3f6-15ecbc735fba	MANTEQUILLA MA 250GR	75930868	t	5800.00	5550.00	\N	\N	19.00	2025-10-19 02:29:41.871584	2025-10-19 02:29:41.871584
99f882be-bb60-4312-a9ed-498e9ae4028c	CEPILLO FULLER R392	7702856003923	t	5700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.871906	2025-10-19 02:29:41.871906
342a3089-5edf-4fdb-962b-5251fb2c11d8	CUCHARA BICHE 20U	7707355925066	t	1400.00	1350.00	\N	\N	19.00	2025-10-19 02:29:41.872248	2025-10-19 02:29:41.872248
8ed07c0c-e4d8-40f2-8e4c-478a037a5622	5400	CEPILLO CON ARAGAN	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.87256	2025-10-19 02:29:41.87256
27eff18c-048d-4c0b-b0fd-3b261dbda0ec	TENENDOR BICHE 20UND	7707355925073	t	1700.00	1590.00	\N	\N	19.00	2025-10-19 02:29:41.87291	2025-10-19 02:29:41.87291
a59c37aa-c3d4-4668-9497-356e00f67757	TRIDENT 60PIEZA	7702133414442	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.87322	2025-10-19 02:29:41.87322
abd8b5f7-7cd8-4472-ba39-18b65bc737b1	LIMAS PARA PIES	7709291929450	t	3000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.873487	2025-10-19 02:29:41.873487
e9d6c7ce-f7e4-4101-a519-8f83fdd401e9	MAYONESA IDEAL 85GR	7708276981377	t	1100.00	1025.00	\N	\N	19.00	2025-10-19 02:29:41.87384	2025-10-19 02:29:41.87384
a1d76434-2ca7-4dbf-ae3d-01ff133d911d	CREMA YODORA 60GR	CREMA YOD	t	17500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.874168	2025-10-19 02:29:41.874168
92d717bb-c913-4a0c-954f-bb9866534675	CREMA YODORA 32GR	CREMAS45	t	10000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.874485	2025-10-19 02:29:41.874485
40ed2ad0-6790-43f0-9f7a-8688213207e5	HEAD SHOULDERS LIMPIEZA Y REVITALIZACION 180ML	7500435202671	t	12000.00	11700.00	\N	\N	19.00	2025-10-19 02:29:41.874751	2025-10-19 02:29:41.874751
8df4e24e-f829-4f1c-b953-529e32058684	HEAD SHOULDERS CARBON ACTIVO 700ML	7500435137997	t	32000.00	31500.00	\N	\N	19.00	2025-10-19 02:29:41.87501	2025-10-19 02:29:41.87501
e2c6fb5f-a7fd-4d8d-a8d0-314da2788c52	HEAD SHOULDER 2 EN 1 700ML	7500435162241	t	32000.00	31200.00	\N	\N	19.00	2025-10-19 02:29:41.875313	2025-10-19 02:29:41.875313
f3904253-3168-4fbf-9476-bf73cc2fbd3c	HEAD SHOULDERS CAFEINA 700ML	7500435108027	t	32000.00	31500.00	\N	\N	19.00	2025-10-19 02:29:41.875704	2025-10-19 02:29:41.875704
98491c2a-17ac-491a-81fe-c182a53751e7	HEAD SHOULDERS MEN 700ML	7500435166249	t	32000.00	31500.00	\N	\N	19.00	2025-10-19 02:29:41.875941	2025-10-19 02:29:41.875941
8ccd08c4-c106-4986-83f4-8bd242bac4a4	SALSERO BARRIL	7707316671377	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:41.876148	2025-10-19 02:29:41.876148
5e501a18-3d96-4a3b-9528-63904b3e9375	SALSERO PEQUEÑO	7707316679441	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:41.876401	2025-10-19 02:29:41.876401
086a88cf-f701-44a1-8282-bb96a1dde022	REJILLA LAVAPLATOS	6911033860551	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.876664	2025-10-19 02:29:41.876664
729f7348-9a36-4b28-8649-6991f26b3f1d	VASOS DE CARTON 7OZ X50UNID	6960708090120	t	7700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.876918	2025-10-19 02:29:41.876918
1e09c25b-8fe3-47c4-a0aa-1aa41ba5dbb9	JABONERA FAMILIAR BISAGRA	7702860115049	t	3600.00	3500.00	\N	\N	19.00	2025-10-19 02:29:41.87718	2025-10-19 02:29:41.87718
cdcc2202-4a3a-44bc-8ded-9e817fbab09d	EXPRIMIDOR MUNDOUTIL	7709424749542	t	4700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.87744	2025-10-19 02:29:41.87744
ea02ef0c-4394-4c11-afd5-8511e414168f	GANCHOS PARA ROPA X25 MUNDO UTIL	7709426485318	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.87767	2025-10-19 02:29:41.87767
de0501b0-2564-4265-95ea-297258917245	COMBO PORTAL MAS TERMO	7709990612820	t	6000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.877946	2025-10-19 02:29:41.877946
29f4eaaa-e68d-42bb-a6b2-e40394efed90	GANCHO PARA ROPAX10INGEPRO11000	GANCHO SAD52F	t	11000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.878169	2025-10-19 02:29:41.878169
f3fbad6d-6c27-41a5-a73c-627135e0627b	LECHE CONDENSADA TROPICO 1300 MAS 130	7709306390268	t	12900.00	12400.00	\N	\N	0.00	2025-10-19 02:29:41.878409	2025-10-19 02:29:41.878409
5168bc68-f074-4fda-89ad-406358b46f78	MIEL TROPICO 150GR	7709057539909	t	2200.00	2050.00	\N	\N	0.00	2025-10-19 02:29:41.878641	2025-10-19 02:29:41.878641
efa9bdef-9308-4c48-b727-bfeb4f897f2e	COLGATE LUMINOUS WHITE 75ML	7509546054650	t	13000.00	12700.00	\N	\N	19.00	2025-10-19 02:29:41.878863	2025-10-19 02:29:41.878863
212213b9-7a29-465d-96e5-b3e3b358c7f1	CHAMPU AGRADO KERATINA 750ML	8433295048280	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.879086	2025-10-19 02:29:41.879086
a32b0f85-58a5-441b-8ec0-c217316b3613	VELON SAN JORGE N7	7707159821076	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.879317	2025-10-19 02:29:41.879317
211b6e45-f6cb-4957-9729-a7c4e317add4	SPAGHETTI DORIA MANTEQUILLA 250GR	7702085035054	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:41.87954	2025-10-19 02:29:41.87954
b011d5db-c79a-4ce7-ba88-294f047b8c44	ARRIVO X2 GALLETA CHOCOLATE	8681038213505	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.879843	2025-10-19 02:29:41.879843
fdd99016-3526-4a62-9b2b-29cb2332c7ab	COLORANTES 10ML PARA TORTAS	COLORANTES	t	2800.00	2630.00	\N	\N	19.00	2025-10-19 02:29:41.880047	2025-10-19 02:29:41.880047
9168c460-65b1-40fc-9bbe-f2d83bef050a	GEL ROLDA MORADA 250GR	7707342220068	t	7300.00	7050.00	\N	\N	19.00	2025-10-19 02:29:41.880285	2025-10-19 02:29:41.880285
42b455fb-5da4-4ea7-a24e-8cec0868c714	GEL ROLDA AZUL 250GR	7707342220075	t	7300.00	7050.00	\N	\N	19.00	2025-10-19 02:29:41.880521	2025-10-19 02:29:41.880521
f967f0aa-9496-413c-b7a8-c95b5a13097d	CEPILLO NIÑO PLATINO CON ENBASE	9780201372427	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.880732	2025-10-19 02:29:41.880732
2a9c465b-3b51-43a9-b393-9b11cb996bd4	MAIZENA INSTANTANEA 14GR	7702047041444	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.880996	2025-10-19 02:29:41.880996
5bf2d02b-f26a-4630-ba3c-09a986e7edd8	GEL ROLDA BLANCA 250GR	7707342220082	t	7300.00	7050.00	\N	\N	19.00	2025-10-19 02:29:41.8813	2025-10-19 02:29:41.8813
4edccc48-a19b-4981-8c6f-2e5a5b452e31	GEL ROLDA BLANCA 120GR	7707342220129	t	4300.00	4200.00	\N	\N	19.00	2025-10-19 02:29:41.881548	2025-10-19 02:29:41.881548
5d2887eb-9c20-4d9b-a6c3-f36c7e082df3	GEL ROLDAN MORADA 120GR	7707342220105	t	4300.00	4200.00	\N	\N	19.00	2025-10-19 02:29:41.881849	2025-10-19 02:29:41.881849
8c4d3b5a-bd12-48e9-a553-d78e8c50bd2d	GEL ROLDA AZUL 500GR	7707342220037	t	12700.00	12300.00	\N	\N	19.00	2025-10-19 02:29:41.88213	2025-10-19 02:29:41.88213
d387c9c0-0051-4e9a-9cce-e1ec49605936	GEL ROLDA ROJA 500GR	7707342220556	t	12700.00	12300.00	\N	\N	19.00	2025-10-19 02:29:41.882441	2025-10-19 02:29:41.882441
7c8d37c4-aa27-4c96-805c-0a9f2ff9704d	GEL RODAL BLANCA 500GR	7707342220044	t	12000.00	11700.00	\N	\N	19.00	2025-10-19 02:29:41.882674	2025-10-19 02:29:41.882674
514b1083-276e-4745-9819-e89a142b593a	CLORO BLANQUEADR 1L	7707220232565	t	2700.00	2570.00	\N	\N	19.00	2025-10-19 02:29:41.882944	2025-10-19 02:29:41.882944
1563a552-8a28-4b26-81f2-57091b7945cd	TRULULU MASMELOS CHOCO VAINILLA 50G	7702993047644	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:41.883164	2025-10-19 02:29:41.883164
b8a4ba1c-0800-4a8c-87f4-bc302283e45e	GELATINA GEL FRUTO 500GR TROPICO	7709989481468	t	10400.00	10000.00	\N	\N	19.00	2025-10-19 02:29:41.883642	2025-10-19 02:29:41.883642
76e5dd28-ae72-4244-9741-cde8a29aeba1	LENTEJA BOGOTA 460GR	7707193910323	t	3800.00	3700.00	\N	\N	0.00	2025-10-19 02:29:41.88424	2025-10-19 02:29:41.88424
5b1268de-ef49-49b7-8e52-f375c548461d	YOGUETA BONBOM X24	7702174085687	t	7600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.884779	2025-10-19 02:29:41.884779
516ad4bb-c1bb-4f5b-96ef-083e1bf5760e	ARROZ SONORA 5.000GR	7700798030243	t	19900.00	\N	\N	\N	0.00	2025-10-19 02:29:41.885429	2025-10-19 02:29:41.885429
5f78e2da-70cb-405c-8c49-2237c84ce50e	BOCADILLO LONJA EL PRINCIPE 300GR	7707337090386	t	2100.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.885847	2025-10-19 02:29:41.885847
0713c4e2-2d34-4174-a1bf-6eadcc60f487	VELON SAN JORGE 10 AZUL	7707159821106	t	7200.00	7050.00	\N	\N	19.00	2025-10-19 02:29:41.886154	2025-10-19 02:29:41.886154
a288d3da-03b7-4be3-be87-6cf74002496e	SHAMPO NATUVITAL SILVER 300ML	7702377302802	t	18500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.886412	2025-10-19 02:29:41.886412
eda2f6bc-85fe-4e32-9944-dff93f8daf81	MACARRON LA MUÑECA 1K	7702020120524	t	4800.00	\N	\N	\N	5.00	2025-10-19 02:29:41.886732	2025-10-19 02:29:41.886732
3f46c2e6-3ec7-4729-be58-beb5f71a7f3b	ESCOBA MEGADALIA	DS584GFDS	t	5500.00	5125.00	\N	\N	19.00	2025-10-19 02:29:41.887016	2025-10-19 02:29:41.887016
027d4fdc-84cf-417c-b814-9be0929aaea2	TRULULU GUSANOS GOMITA 90GR	7702993025123	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.887328	2025-10-19 02:29:41.887328
df0602b3-8e4d-469a-985c-01f7e06dbbb6	JABON FRESKITO 75GR	7708977668201	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.88758	2025-10-19 02:29:41.88758
c5ce7e19-e463-4064-9961-a61468bbfb53	SHAMPOO SAVITAL COMPLEJO HIALURONICO 100ML	7702006406000	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:41.88782	2025-10-19 02:29:41.88782
e321afad-477b-4823-8cbb-1dc2721caad6	MIRRINGO GATICOS 1KG	7703090552024	t	9700.00	9350.00	\N	\N	19.00	2025-10-19 02:29:41.888063	2025-10-19 02:29:41.888063
2f99a0ec-c31b-41e9-b2e4-f60fe9414aaa	FABULOSO ALTERNARIVA CLORO 200ML	7702010311604	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:41.888319	2025-10-19 02:29:41.888319
aa62a06d-07eb-4ef2-84cf-a836981db12b	CLORO BLANQUEADOR 3.75ML	7707220231940	t	7100.00	6850.00	\N	\N	19.00	2025-10-19 02:29:41.888594	2025-10-19 02:29:41.888594
31d3bf45-21d0-43ad-a872-1a956b90c921	LECHE CONDENSADA TUBITO 45GR	7709104318426	t	2000.00	1884.00	\N	\N	0.00	2025-10-19 02:29:41.888821	2025-10-19 02:29:41.888821
79c2d580-1933-4548-b6ef-9870185bd9d1	RECOGDOR CON PALO	RECOGEDOR	t	2500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.889037	2025-10-19 02:29:41.889037
716d32e6-70be-4ba1-bac0-dbe3fa00582f	CHOKIS CLASICA X6 222GR	7702189056221	t	9800.00	9700.00	\N	\N	19.00	2025-10-19 02:29:41.889414	2025-10-19 02:29:41.889414
42fb9ccb-856b-47ff-93c5-fe80bdad4f7e	HIT FRUTOS TROPICALES 1L	7702090038095	t	4200.00	3817.00	\N	\N	19.00	2025-10-19 02:29:41.889638	2025-10-19 02:29:41.889638
9ff5af7f-f059-46c5-a844-aa554744e563	CAFE SELLO ROJO 212GR	7702032117826	t	13000.00	12600.00	\N	\N	5.00	2025-10-19 02:29:41.889859	2025-10-19 02:29:41.889859
1b55d408-e58b-42f7-9b86-974673d761ad	SUPERCOCO BARRA CHOCOLATE 25GR	7702993035016	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.89011	2025-10-19 02:29:41.89011
bfba48f8-9bfb-4caa-8eea-4fce7a845c8b	COLORANTE DE ALIMENTON	4sa1d56	t	2800.00	2630.00	\N	\N	19.00	2025-10-19 02:29:41.890439	2025-10-19 02:29:41.890439
12b56cf5-1f53-4e95-9f89-14d76eb3e7df	AMBIENTADOR REPUESTO ELECTRICO BON AIRE FRUTOS ROJOS	7702532312448	t	9600.00	9400.00	\N	\N	19.00	2025-10-19 02:29:41.890667	2025-10-19 02:29:41.890667
9a66c817-1d0a-4ef6-8017-b25328905e15	BON AIRE NATURAK FRUTAS DEL CARIBE 170GR	7702532992077	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:41.890866	2025-10-19 02:29:41.890866
395e5f1b-592d-443c-9f69-a3871f6cf765	BON AIREGEL CANELA 30GR	7702532350518	t	4500.00	4370.00	\N	\N	19.00	2025-10-19 02:29:41.891113	2025-10-19 02:29:41.891113
2cfa65ea-1f4c-4cd0-8141-d9e6ac894543	CHICLE EN POLVO OKA LOKA X12UNID	7702993026793	t	5400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.891316	2025-10-19 02:29:41.891316
d508d820-1e93-471b-886f-9396dd3fa931	MILLOWS COLOMBINA FRESA 35GR	7702011141255	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.891506	2025-10-19 02:29:41.891506
3a142e02-5fcd-4426-886d-123028129b4c	SHAMPOO PANTENE MAS ACONDIONADOR 400ML	7500435134699	t	33000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.891691	2025-10-19 02:29:41.891691
aa4ac6c4-2d62-4dca-bf35-3111a442dc46	SHAMPOO NUTRIT RESTAURAMAX	7702277702245	t	35000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.891942	2025-10-19 02:29:41.891942
714dc2b1-8f8e-4817-af8e-f520bad1dcde	SHAMPOO NUTRIT KERATINAMAX MAS ACONDICIONADOR	7702277264217	t	35000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.892168	2025-10-19 02:29:41.892168
4afaffca-b322-43ba-a337-9e0d4ee1f8ab	AREPA REPA AMARILLA 1.000GR	7702910002053	t	2900.00	2800.00	\N	\N	5.00	2025-10-19 02:29:41.892402	2025-10-19 02:29:41.892402
5fab7be3-b96c-400a-a1ac-4645302a25e8	FRUTIÑO TAMARRINDO 18GR	7702354952921	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:41.892627	2025-10-19 02:29:41.892627
7c84dcea-bb16-40c3-a543-2eeb8cab1ffd	SUNTEA LIMON MANDARINO 2L 12GR	7702354955434	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:41.892832	2025-10-19 02:29:41.892832
21e01753-ec01-405c-a786-32fd70ca71cc	CHORIZO CAMPESINO CIFUENTES	CHORIZO CI	t	11700.00	11500.00	\N	\N	19.00	2025-10-19 02:29:41.893038	2025-10-19 02:29:41.893038
26f60351-5265-4c90-a121-b0217c4a6a4c	JAMON AHUMADO 220GR	JAMON4F	t	4200.00	4100.00	\N	\N	19.00	2025-10-19 02:29:41.893273	2025-10-19 02:29:41.893273
ba19a8a1-a30a-4e35-8e2b-d9822e6d703c	MANTECA FRITURA 3.000GR	7706649443781	t	38000.00	37000.00	\N	\N	19.00	2025-10-19 02:29:41.89352	2025-10-19 02:29:41.89352
4d52ab1b-e910-4cef-99a2-0d41dc2e146a	CAFE FRAGANCIA 500GR	7704781215006	t	13500.00	13180.00	\N	\N	5.00	2025-10-19 02:29:41.893755	2025-10-19 02:29:41.893755
c9e96f3d-3737-4dc9-b0d9-7d1aa40303c9	CAFE FRAGANCIA 250GR	7704781212500	t	7000.00	6800.00	\N	\N	5.00	2025-10-19 02:29:41.893969	2025-10-19 02:29:41.893969
50cdaeba-cf76-49e9-82b6-8019829db541	COLCAFE INTENSO GRANULADO 50GR	7702032104369	t	13900.00	13600.00	\N	\N	5.00	2025-10-19 02:29:41.894218	2025-10-19 02:29:41.894218
cf0927b7-7ebd-481b-aa8a-06b1cfb15f27	FIDEO COMARRICO 454GR	7707307963153	t	2800.00	2700.00	\N	\N	5.00	2025-10-19 02:29:41.89444	2025-10-19 02:29:41.89444
fbdfa2e0-f4a8-462a-8648-3dadf670bf64	GOL MINI CHOCO POWER X24UNID	7702007078725	t	7500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.89467	2025-10-19 02:29:41.89467
b3ed0a41-d80b-499f-b046-b4555572c03a	ATUN DON GABRIEL LOMOS	7862129150720	t	3600.00	3400.00	\N	\N	19.00	2025-10-19 02:29:41.894908	2025-10-19 02:29:41.894908
fd945117-9925-40d3-8834-51b15db6cf4e	ARROZ SAN ANDRES 1.000GR	7709990111446	t	3900.00	3734.00	\N	\N	0.00	2025-10-19 02:29:41.895131	2025-10-19 02:29:41.895131
1a54f15e-afe9-4c35-a340-522c38fbc77b	CEPILLO TOP ORAL	7450077031033	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.895369	2025-10-19 02:29:41.895369
14368396-10ac-4bb8-aacc-42ff60a95899	ELITE DUO X12UNID	7707199348168	t	22000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.895621	2025-10-19 02:29:41.895621
ba9efb74-2e83-40b6-ba86-bcd53a0e5163	CHORIZO ANTIOQUEÑO CIFUENTES	7707907447060	t	12700.00	12500.00	\N	\N	19.00	2025-10-19 02:29:41.895866	2025-10-19 02:29:41.895866
dafc45a9-87c2-4e56-8c91-535ec20a7511	CHORIZO DE COCTEL CIFUENTES	CH5SD	t	12900.00	12700.00	\N	\N	19.00	2025-10-19 02:29:41.896103	2025-10-19 02:29:41.896103
d4c7473a-1b21-4dd3-b47b-ef36e851b823	SHAMPOO TIO NACHO HERBOLARIA MILENARIA 415ML	650240015670	t	30000.00	29000.00	\N	\N	19.00	2025-10-19 02:29:41.896412	2025-10-19 02:29:41.896412
224e8c28-afe8-440d-a1da-08d96ecb8ef0	SHAMPOO TIO NACHO ANTI CANAS 415ML	650240062063	t	30000.00	29000.00	\N	\N	19.00	2025-10-19 02:29:41.896667	2025-10-19 02:29:41.896667
a87c4d03-c9ed-44f6-a420-764e8b526208	SHAMPOO TIO NACHO ACLARANTE 415ML	650240011832	t	30000.00	29000.00	\N	\N	19.00	2025-10-19 02:29:41.896883	2025-10-19 02:29:41.896883
c54b1d9b-dd8d-4b0c-b313-a658eab267fc	SHAMPOO TIO NACHO ANTI EDAD 415ML	650240010736	t	30000.00	29000.00	\N	\N	19.00	2025-10-19 02:29:41.897087	2025-10-19 02:29:41.897087
e336f643-cf93-4864-b14a-510b5f8c754b	LUBRIDERM AYUDA A PREVENIR MANCHA Y ARRUGAS 25ML	7702031571438	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.897321	2025-10-19 02:29:41.897321
bf6e1598-af6d-44a1-aaeb-09d521e7f20b	CEPILLO ORAL B DETOX X3UNID	7500435138703	t	24500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.89755	2025-10-19 02:29:41.89755
54fd8151-a7e5-4fab-a076-3f3232897c8c	CEPILLO ORAL B SALUD 7 BENEFICIO CARBON	7500435170963	t	17800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.897794	2025-10-19 02:29:41.897794
edecf46b-4341-4d27-9852-a87b8819c42c	CHICLE DE AUTO X10 UNID	7707301040553	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.89802	2025-10-19 02:29:41.89802
d1b960b5-04c7-4dd2-928d-76ddf455cc52	MILLOWS COLOMBINA 35GR	7702011124456	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.898256	2025-10-19 02:29:41.898256
3d106031-c6f7-447c-be08-a4c9c7c30d10	MARRANETA X12UNID	7709333647809	t	8000.00	7800.00	\N	\N	19.00	2025-10-19 02:29:41.898462	2025-10-19 02:29:41.898462
50df7115-06e1-4889-b6d7-1d6155e17eee	WAFER ITALO 77 X24UNID	8681863146009	t	30000.00	\N	\N	\N	0.00	2025-10-19 02:29:41.898682	2025-10-19 02:29:41.898682
2c5717c1-14fd-47f0-9e1d-acf959b3d006	MASMELOS ANGELITOS 60GR	760203014869	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:41.898907	2025-10-19 02:29:41.898907
eea71287-10bc-46e8-b4bf-9286d3419bee	MAMELO CRISMELO MALVISCO 150GR	760203009391	t	3500.00	3400.00	\N	\N	19.00	2025-10-19 02:29:41.899111	2025-10-19 02:29:41.899111
384df517-24b9-44bd-95ef-739ed6781fed	COLCAFE CAPPUCCINO 13GR	7702032115990	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.899337	2025-10-19 02:29:41.899337
cbdd3e61-c976-4ab4-962b-3ff01bf3bd0d	KOLA GRANULADA TARRITO ROJO 330GR	7702560043369	t	22800.00	22400.00	\N	\N	19.00	2025-10-19 02:29:41.899533	2025-10-19 02:29:41.899533
12bf2e90-0713-4da7-94e4-da69fda590f1	TOALLITAS PEQUEÑIN X60MANZANILLA	7702026147891	t	5800.00	5450.00	\N	\N	19.00	2025-10-19 02:29:41.899759	2025-10-19 02:29:41.899759
c02adfdf-bc65-41e5-81de-5c46e003b28b	GUANTE NEGRO LIMPIA YA T 8	7702037567923	t	3900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.900244	2025-10-19 02:29:41.900244
e3fa17c5-bcbb-4d8f-aa57-25bfdc94a8b1	TOALLAS ANGELAS NOCTURNAS 8 MAS 8	7707324641133	t	6700.00	6400.00	\N	\N	0.00	2025-10-19 02:29:41.900742	2025-10-19 02:29:41.900742
b048cd21-7312-4dc8-8093-888af5b7c800	CAFE SELLO ROJO 425GR	7702032117833	t	24400.00	23700.00	\N	\N	5.00	2025-10-19 02:29:41.901341	2025-10-19 02:29:41.901341
de07db39-b594-470c-9489-2a0907e3cc37	CARACOL COMARRICO 250GR	7707307962248	t	1800.00	1700.00	\N	\N	5.00	2025-10-19 02:29:41.901878	2025-10-19 02:29:41.901878
635fa1f3-6fdc-4b7c-9ff3-e7a14f9583b4	MONTICELLO LINGUINE 500GR	7702085021576	t	6500.00	\N	\N	\N	5.00	2025-10-19 02:29:41.902169	2025-10-19 02:29:41.902169
8f425db8-9fba-458a-ab01-08d71bb04136	CAMPI SAL 250GR	7702109999980	t	6800.00	6600.00	\N	\N	19.00	2025-10-19 02:29:41.90242	2025-10-19 02:29:41.90242
f2a19458-05d4-4da3-99d2-47440d45589e	TORNILLOS CON VERDURA DORIA 250GR	7702085012499	t	2500.00	2300.00	\N	\N	5.00	2025-10-19 02:29:41.90264	2025-10-19 02:29:41.90264
d976f9cb-3668-470b-ad09-88fcce2c4fb9	JABON INTIBON SALVIA Y CALENDULA 120GR	7702277641131	t	8300.00	8000.00	\N	\N	19.00	2025-10-19 02:29:41.902874	2025-10-19 02:29:41.902874
80dd754b-50ec-4dbd-93c4-9f25433b7730	COBERTURA CHOCOLATE D LUCHY 500GR	788070548331	t	9900.00	9650.00	\N	\N	19.00	2025-10-19 02:29:41.903097	2025-10-19 02:29:41.903097
545ee1ac-6262-4168-82b4-059737a86aa2	CEPILLO PROO 425	6927236613214	t	2500.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.903318	2025-10-19 02:29:41.903318
ed190eba-8408-4048-a80d-1fa1c337c5fa	UNICO 3 PODERES 180GR	7701018075297	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:41.903558	2025-10-19 02:29:41.903558
fcd3b33c-85c1-49b6-8c30-857df443cda9	CHOCORAMO MITI 40GR	7702914594431	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.903778	2025-10-19 02:29:41.903778
f107683c-cde6-400f-a6ee-b8c944646705	ARIEL TRIPLE PODER 5KG	7500435140669	t	46500.00	46000.00	\N	\N	19.00	2025-10-19 02:29:41.904014	2025-10-19 02:29:41.904014
552afba3-6095-46b6-a29c-13f9bab3ebf6	BARBIE X12UNID	7703888873539	t	16800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.904327	2025-10-19 02:29:41.904327
4446461c-469b-49f2-a8be-d16d1a8b009a	FLIPS CHOCOLATE 28GR	7591039504957	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.904684	2025-10-19 02:29:41.904684
4796dd33-ecf5-42dd-980c-314b801e4b07	HYDRATADE POOL 500ML	7709117323660	t	1700.00	1542.00	\N	\N	19.00	2025-10-19 02:29:41.904962	2025-10-19 02:29:41.904962
1f8ffa35-a1ee-4038-889b-e77862fb9116	MAREOL	45DF	t	700.00	\N	\N	\N	0.00	2025-10-19 02:29:41.905203	2025-10-19 02:29:41.905203
4dda5eb8-7d87-4075-8ad8-a861f4ce7f47	BONFIES	S46DF	t	2900.00	\N	\N	\N	0.00	2025-10-19 02:29:41.905512	2025-10-19 02:29:41.905512
06583c54-8904-4ea6-8823-447cf4e1cbfe	DURAFLEX	5SD34F	t	2600.00	\N	\N	\N	0.00	2025-10-19 02:29:41.905759	2025-10-19 02:29:41.905759
a4c0b19c-1785-4201-b4ff-3061d254e2de	ESCOBA ETERNA BASICA SUAVE	A4S53D	t	10700.00	10300.00	\N	\N	19.00	2025-10-19 02:29:41.905997	2025-10-19 02:29:41.905997
d0aea494-9305-4266-9d39-1e1b25df3117	VELAS SANTA MARIA 10X8	7707297960163	t	4300.00	4200.00	\N	\N	19.00	2025-10-19 02:29:41.906269	2025-10-19 02:29:41.906269
179feabf-5cf8-4809-837b-030d1d8b1cd2	flips dulce leche 400gr	7702807395596	t	12800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.906546	2025-10-19 02:29:41.906546
27bd6f64-8202-4d13-b5ec-465de31a4b42	DE TODITO BOLSAZA BBQ 80GR	7702189059260	t	4200.00	4000.00	3900.00	\N	19.00	2025-10-19 02:29:41.906766	2025-10-19 02:29:41.906766
7361a067-d3ae-4b3e-9374-b3a8fa94f6b6	ROSAL XXG ULTRACONFORT	7702120013009	t	1900.00	1834.00	\N	\N	19.00	2025-10-19 02:29:41.90701	2025-10-19 02:29:41.90701
6dff6555-6eb6-4b5f-bf25-8f871563cffb	CHOCOVETEADA JET 150GR	7702007075106	t	7500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.907242	2025-10-19 02:29:41.907242
2a2463e3-bc8f-400e-aa1a-4da9714651a4	HILOS CON AGUJAS MEDUSA	7453010020156	t	2500.00	2300.00	\N	\N	0.00	2025-10-19 02:29:41.907486	2025-10-19 02:29:41.907486
17fcf78f-0d3c-4916-a986-6ab60487ac92	SHAMPOO EGO BLACK 230 ML	7702006300285	t	12800.00	12400.00	\N	\N	19.00	2025-10-19 02:29:41.907718	2025-10-19 02:29:41.907718
15365a04-d615-41b4-a519-41678c88b27e	PROTECTORES CAREFRRE X150UNID	7702031503361	t	14000.00	13500.00	\N	\N	19.00	2025-10-19 02:29:41.907945	2025-10-19 02:29:41.907945
82db41a8-82fc-4993-9c8f-a5c9cac43cb8	ELITE MAX RESISTENTE X4UNID	7707199344184	t	5400.00	5250.00	\N	\N	19.00	2025-10-19 02:29:41.908155	2025-10-19 02:29:41.908155
fac9fba6-8934-4a61-85cf-634450d95f3f	COPITOS REDONDO VITAL	6984789527054	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.908374	2025-10-19 02:29:41.908374
a4b85eeb-52c8-44f5-99e6-e34269440075	ALCANFORINA PAQUETE 100GR	6923481801116	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.908602	2025-10-19 02:29:41.908602
9082dfad-cc94-48d7-a518-72839bc3473f	PAQUETE DE HILOS AGUJAS SEWING KIT	7453105020627	t	5000.00	4600.00	\N	\N	19.00	2025-10-19 02:29:41.908811	2025-10-19 02:29:41.908811
219e0048-aef5-40b1-8822-89ca39c1aa2e	PALILLO CON PALILLERO	6931575111232	t	1000.00	900.00	\N	\N	0.00	2025-10-19 02:29:41.909014	2025-10-19 02:29:41.909014
3cd63417-39f6-4b83-9bd6-3862663ed4a1	MYM MINI POTE 30GR	040000002376	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.909249	2025-10-19 02:29:41.909249
7fa87041-89eb-4d16-8513-20f9c5a911d6	VINAGRE REYES 500ML BLANCO	7708811486299	t	1000.00	900.00	\N	\N	19.00	2025-10-19 02:29:41.909474	2025-10-19 02:29:41.909474
2268f883-878f-489a-9f31-5d06beb1482c	GALLETAS DULCE NAVIDAD BANDEJA GAMESA 220GR	7702189050618	t	6600.00	6400.00	\N	\N	19.00	2025-10-19 02:29:41.909708	2025-10-19 02:29:41.909708
4841e379-f903-49b6-9333-0a9d258a9fa7	CHOCOLATE CORONA DELICATTO 142GR	7702007069730	t	6200.00	5950.00	\N	\N	5.00	2025-10-19 02:29:41.909909	2025-10-19 02:29:41.909909
b77a0d68-416a-4d22-a6f8-1b76ef092f8d	PALO HELADO CORTO EL SOL 1.000UNID	7707015507038	t	15200.00	14800.00	\N	\N	19.00	2025-10-19 02:29:41.91011	2025-10-19 02:29:41.91011
87bf9be8-afea-48c8-9da4-de1c20928d14	PA MI GENTE ROSQUILLAS 15GR	7705326081889	t	1200.00	1150.00	\N	\N	19.00	2025-10-19 02:29:41.91035	2025-10-19 02:29:41.91035
aa589a8e-a144-4e6c-b0f1-6b730cadeb76	CERA NEUTRA NETTUNO 350ML	7702377582617	t	5300.00	5150.00	\N	\N	19.00	2025-10-19 02:29:41.910579	2025-10-19 02:29:41.910579
d7280e98-3f91-4685-8c15-7b2c3d39e478	DE TODITO BOLSAZA MIX 80GR	7702189059284	t	4200.00	4000.00	3900.00	\N	19.00	2025-10-19 02:29:41.91082	2025-10-19 02:29:41.91082
bed4172e-40c3-4945-8461-696db5b4cac7	PRESTOBARBA SCHICK XTREME 3 ECO	841058000693	t	2800.00	2667.00	\N	\N	19.00	2025-10-19 02:29:41.911042	2025-10-19 02:29:41.911042
d2067c16-9efb-4277-a1f4-f08f9f88d346	REPUESTOS BON AIRE VARITAS	7702532119962	t	5200.00	5000.00	\N	\N	19.00	2025-10-19 02:29:41.911295	2025-10-19 02:29:41.911295
909e00f6-8f1e-422c-8ed6-9ac743083b1b	LAVALOZA LIQUIDO SKAAP 500ML	7707371211891	t	3500.00	3360.00	\N	\N	19.00	2025-10-19 02:29:41.911599	2025-10-19 02:29:41.911599
95d4232b-a947-475d-9048-9943461fff9b	UNICO PLUS LIMON 280GR	7701018075501	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.911953	2025-10-19 02:29:41.911953
3d2cd550-c495-4734-a102-2ccd4ad8bcad	GILLETTE MACH 3	7500435141536	t	14400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.912221	2025-10-19 02:29:41.912221
f5aba839-e941-48bf-a901-55df31b2954a	VASOS VACAN 7OZ	7709141813304	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.912506	2025-10-19 02:29:41.912506
93d2c0b8-12de-4c4f-ac4b-a8a8e96854a9	SHAMPOO TIO NACHO ACLARANTE JALEA REAL 18ML	650240057540	t	1100.00	1000.00	\N	\N	19.00	2025-10-19 02:29:41.912761	2025-10-19 02:29:41.912761
8a7ae0de-5267-4b1d-9676-bbbda083316c	ARVEJA SAMARA VERDE 500GR	7709094571900	t	2400.00	2300.00	\N	\N	0.00	2025-10-19 02:29:41.913013	2025-10-19 02:29:41.913013
e6028db1-5e86-4a56-8f4e-80b31840491c	CHOCO HAPPY BON BONE CORAZON	4897054140044	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.913292	2025-10-19 02:29:41.913292
fc0528f8-55fc-4671-b15b-61e577f81130	LACA CAPILAR LA FIESTA ROJO	8426373005633	t	9500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.913578	2025-10-19 02:29:41.913578
20b308a3-f0b3-4d12-9e83-8f06b6e53bbf	MOPA FRANELA	SD4GF	t	2200.00	2080.00	\N	\N	19.00	2025-10-19 02:29:41.91421	2025-10-19 02:29:41.91421
168ecec4-8f23-4dd1-81d4-3ff706f57513	SOFT KLEAN SUAVIZANTE SUEÑOS DELICADO 450ML	7702310046350	t	3300.00	3150.00	\N	\N	19.00	2025-10-19 02:29:41.914462	2025-10-19 02:29:41.914462
20695b09-82e4-41a0-a4c5-8b99099c016a	SERVILLETA SKAAP 150GR	7707371219231	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:41.914677	2025-10-19 02:29:41.914677
16b1d072-b65e-41f4-8080-27d802a409d4	ACONDICIONADOR SAVITAL HIDRATACION 490ML	7702006406017	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.914931	2025-10-19 02:29:41.914931
77763cd0-3ef0-4dfa-8976-2534ef1425b0	LAVALOZA CREMA MI DIA 500GR	7700149359894	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:41.915165	2025-10-19 02:29:41.915165
7efdd5b2-80eb-4fae-9358-125e2527481e	SUAVIZANYE NORSAN 1L PRIMAVERA	7707291396814	t	4500.00	4250.00	\N	\N	19.00	2025-10-19 02:29:41.915436	2025-10-19 02:29:41.915436
8e550245-51e4-441b-807d-f7ebb097b752	SUAVIZANTE SKAAP MANZANA VERDE 1 LITRO	7707371210207	t	5500.00	5300.00	\N	\N	19.00	2025-10-19 02:29:41.915697	2025-10-19 02:29:41.915697
c180f469-cb8e-4309-8866-332cd0676643	AREQUIPE EL ANDINO X6UNID	SA54D	t	6600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.915907	2025-10-19 02:29:41.915907
2bcadf5f-8257-4132-b1f1-cbc9161d39b2	UNICO LAVANDA 220GR	7701018075532	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:41.916158	2025-10-19 02:29:41.916158
35934616-1ec2-441c-adcd-e3d279efc1dc	SALSA DE TOMATE BARY 400GR	7702439001032	t	7600.00	7350.00	\N	\N	19.00	2025-10-19 02:29:41.916401	2025-10-19 02:29:41.916401
8d1bed9c-a0c7-47c7-bd59-1ed8d8debcb8	LA ESPECIAL MIEL LIMON 180GR	7702007076196	t	5900.00	4660.00	\N	\N	19.00	2025-10-19 02:29:41.916664	2025-10-19 02:29:41.916664
53def226-50c0-406a-84e1-39fcde7353bb	TIC TAC 16GR	78934696	t	1900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.917256	2025-10-19 02:29:41.917256
230c34b3-497c-4428-b5da-cdaaeb803ba7	SALMON MARBONITA	7595122000920	t	2300.00	2200.00	\N	\N	19.00	2025-10-19 02:29:41.917922	2025-10-19 02:29:41.917922
5b99d182-0fa8-46e1-a9e6-32ab9885bbbc	SALCHICHA  RANCHERA	7701101358245	t	6900.00	6800.00	\N	\N	19.00	2025-10-19 02:29:41.918283	2025-10-19 02:29:41.918283
660652a5-7482-4c15-a073-973517c0fa2c	ARROZ VILKY 1.000GR	736372265470	t	3800.00	3734.00	\N	\N	0.00	2025-10-19 02:29:41.918642	2025-10-19 02:29:41.918642
e62b4e3f-45a5-4462-beae-a2fc9947f7a2	SALSA BBQ IDEAL 400GR	7709747919073	t	3900.00	3800.00	\N	\N	19.00	2025-10-19 02:29:41.918971	2025-10-19 02:29:41.918971
8392adaf-7f43-4f2d-b41f-452c3e8b6061	QUESADA AREQUIPE 500GR	7702088209377	t	12400.00	12100.00	\N	\N	5.00	2025-10-19 02:29:41.919505	2025-10-19 02:29:41.919505
be7be8bb-0e51-4392-ba5e-a401a26b438b	PALILLO EXTRALARGO HOUSE X125	7707320620132	t	1200.00	1100.00	\N	\N	0.00	2025-10-19 02:29:41.920025	2025-10-19 02:29:41.920025
e8818671-7ecd-4de7-b7d4-b995a401fc93	DETODITO X6UNID BBQ	7702189011480	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.920521	2025-10-19 02:29:41.920521
2492240f-fb87-4711-b31d-9234a2da23f4	MAMUT BLANCA X42	7702189057990	t	16500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.921008	2025-10-19 02:29:41.921008
67e66f55-2f31-400f-b4f9-17530854947b	CABELLO ANGEL LA MUÑECA 1K	7702020120036	t	4900.00	4792.00	\N	\N	5.00	2025-10-19 02:29:41.9214	2025-10-19 02:29:41.9214
fb44a688-e190-4b5c-a77d-429a5ae5aca9	JABON INTIMO NOSOTRAS AGUA DE ROSA 200ML	7702026184445	t	12500.00	12000.00	\N	\N	19.00	2025-10-19 02:29:41.921738	2025-10-19 02:29:41.921738
8cf7e35c-b86e-43e8-b2c9-739e7e5d0256	CAFE SELLO ROJO PANELA 180GR	7702032117932	t	3900.00	\N	\N	\N	5.00	2025-10-19 02:29:41.922264	2025-10-19 02:29:41.922264
f2522c1d-7f64-46d0-b601-766b871f6d7c	NUTRIBELA PRO HIALURONICO 180ML	7702354953690	t	10400.00	10000.00	\N	\N	19.00	2025-10-19 02:29:41.92267	2025-10-19 02:29:41.92267
cf47a948-5b50-4fc7-a7ee-195e6dda2f29	PAPEL ALUMINIO 7M EL SOL	7707015511219	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:41.9232	2025-10-19 02:29:41.9232
f93a19ce-9900-494a-9b13-3acae0b4a0f2	TRIDENT YERBABUENA X60	7622201800369	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.923628	2025-10-19 02:29:41.923628
907932be-6118-4138-977b-d6fbe8d45abe	AZUCAR PALACIO 900GR	7709990134131	t	3600.00	3520.00	\N	\N	0.00	2025-10-19 02:29:41.924026	2025-10-19 02:29:41.924026
08b5edb7-9175-4f62-9f64-50db3a9888f8	SHAMPOO DOVE MAS ACONDICIONADOR 370ML	7702006653305	t	31000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.924318	2025-10-19 02:29:41.924318
53e7df1e-34cb-4fa9-afc7-d19186a69616	ACONDICIONADOR ANYELUZ CEBOLLA 500ML	7709126197795	t	34000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.924602	2025-10-19 02:29:41.924602
88250ba1-7d70-48ae-84fe-bd2ce6796bd4	TALCO MEXSANA DOU AEROSOL	7702123012146	t	23800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.92491	2025-10-19 02:29:41.92491
74c38e94-703b-47a3-ba3b-b24632c78c9d	TRATAMIENTO EL VIVE COLOR 300GR	7509552903348	t	15600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.92527	2025-10-19 02:29:41.92527
267ed2de-dc18-47aa-a6fb-b18ddcbc0c87	INDULECHE 125GR	7706921024059	t	5300.00	5150.00	\N	\N	0.00	2025-10-19 02:29:41.925687	2025-10-19 02:29:41.925687
153f6453-e773-4f0f-ac0f-75870a41d162	LAVALOZA SKKAAP 50GR	7707311810412	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:41.926046	2025-10-19 02:29:41.926046
43e5f274-70c3-4c71-a8cf-dfcaab4e6c8b	COLCAFE CLASICO SUAVE 50GR	7702032253159	t	12200.00	11850.00	\N	\N	5.00	2025-10-19 02:29:41.926352	2025-10-19 02:29:41.926352
54e8a194-0ade-4b5a-9af9-98606151a851	CEREAL CHOCOLISTO 370GR	7702007074024	t	12600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.926727	2025-10-19 02:29:41.926727
0dfc6933-534c-4eb8-88eb-32b952546bd6	KIT SEDAL RIZO DEFINIDOS 2 CREMAS MAS BOLSA GORRO	7705790663956	t	23500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.92706	2025-10-19 02:29:41.92706
b0c181ec-b42a-4b4a-887e-ffe1b9519aa3	DETERGENTE LIQUIDO BLANCOX ROPA OSCURA	7703812013499	t	10600.00	10400.00	\N	\N	19.00	2025-10-19 02:29:41.927393	2025-10-19 02:29:41.927393
098548af-3e21-4fe8-a1c9-a203fb07dc4d	DETERGENTE ROPA COLOR BLANCOX 1.8	7703812013475	t	9000.00	8800.00	\N	\N	19.00	2025-10-19 02:29:41.927859	2025-10-19 02:29:41.927859
8b6ecbb7-01dc-4cf4-9743-fb56f4512538	TROLLY MORGAN 400GR	7702174083140	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:41.928128	2025-10-19 02:29:41.928128
3c88f3e8-0cd8-4598-9180-6b1ff623c577	CREMA DEPILATORIA FACIAL VEET 30ML	7702626206752	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.928473	2025-10-19 02:29:41.928473
f1972ac4-2f21-4426-9fa1-8c0e49a6d0e9	ESCOBA PEQUEÑAS	ESCOBA	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.92886	2025-10-19 02:29:41.92886
a1f905f7-0d0b-4c32-8f79-7ea9ed6f14c0	FIDEOS DORIA RANCHERO 250GR	7702085002407	t	2700.00	\N	\N	\N	5.00	2025-10-19 02:29:41.929236	2025-10-19 02:29:41.929236
1dd0bd26-4a8c-4be5-882f-900909e43b3a	SHAMPOO SAVITALHIDRATACION 510ML	7702006405980	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.929618	2025-10-19 02:29:41.929618
1ed8b64e-6678-4826-ba81-4418830837db	SHAMPOO SAVITAL ANTICASPA 510ML	7702006302036	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:41.929903	2025-10-19 02:29:41.929903
c5decbf4-ac80-471b-8bc3-323192e094c8	SHAMPOO SAVITAL MULTIOLEOS Y SABILA 510ML	7702006208376	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:41.930306	2025-10-19 02:29:41.930306
8adfd4bd-b6bc-471c-a034-72912645b477	SEMILLAS DE CHIA LA SAZON 100GR	7707767142754	t	4600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.930645	2025-10-19 02:29:41.930645
e2afb9f8-33e0-4e36-8379-e09cca889330	ACEITE VEGETAL IDEAL 2.700	7709926508227	t	18500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.930911	2025-10-19 02:29:41.930911
6a033c70-e4a1-449b-b6ca-76e779e939e2	TRULULU LOVE 8G	7702993048429	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.931254	2025-10-19 02:29:41.931254
6caa6732-1db7-4497-90af-f3fb87214ad9	CREMA CORPORAL DOVE PARA PIEL SECA 1LITROS	7501056346133	t	22000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.931785	2025-10-19 02:29:41.931785
5070453f-b3b0-48ed-bfd8-5fb77ad8b216	FERRERO ROCHER X3UNID	78909434	t	7600.00	7350.00	\N	\N	19.00	2025-10-19 02:29:41.932334	2025-10-19 02:29:41.932334
be65f3a7-6a45-4113-862b-70278d38a8bc	BONBONERA ANIMALITOS X100UNID	8693029201934	t	39000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.932641	2025-10-19 02:29:41.932641
21de2a44-caf2-4ff9-a048-39959c9d0aec	SUAVITEL CUIDADO SUPERIOR 1LITRO	7702010280023	t	8000.00	7800.00	\N	\N	19.00	2025-10-19 02:29:41.933027	2025-10-19 02:29:41.933027
5e9c4480-1c1a-48b2-ab39-961b88344a41	CREMA MAS CEPILLO ORAL PLUS 30GR	7708682913023	t	4100.00	3950.00	\N	\N	19.00	2025-10-19 02:29:41.933436	2025-10-19 02:29:41.933436
1559ca94-372d-4b1c-a72c-c9ab853d970e	CREMA MAS CEPILLO ORAL PLUS 30GR	7708682913962	t	4100.00	3950.00	\N	\N	19.00	2025-10-19 02:29:41.933851	2025-10-19 02:29:41.933851
39572e4c-5086-4d79-8071-135008f380d2	FRUNAS ORIGINALES X32UNID	7702174082051	t	7200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.934384	2025-10-19 02:29:41.934384
171850ba-ea4b-43d4-acb6-3dca6cfac0d8	TOALLAS MOLLIS DELGADAS X8UNID	7707324641072	t	1500.00	1350.00	\N	\N	0.00	2025-10-19 02:29:41.934883	2025-10-19 02:29:41.934883
dda7560f-1ab5-4d8f-aed4-4f5b7488f2fc	MECHERA SWISS LITE	7707822753734	t	6600.00	6450.00	\N	\N	19.00	2025-10-19 02:29:41.935354	2025-10-19 02:29:41.935354
b371d667-13f0-4e49-8d70-4ec551dc5520	CAJA MUG CHOCOLATE	31159	t	17500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.935971	2025-10-19 02:29:41.935971
b0ae202f-83a3-4b60-be2d-1994aa7ccb0f	REPUESTOS GILLETTE STAQR3	7500435221672	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.936341	2025-10-19 02:29:41.936341
2d02c336-a6c5-45a6-b461-76f47d3b68fb	PAPEL GRASO 50MTS	7709133968722	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.936724	2025-10-19 02:29:41.936724
7ed16cac-8448-40cb-bc5a-a45b2a327b66	CHOCO HAPPY BON BON CORAZON	4897054140020	t	7500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.936998	2025-10-19 02:29:41.936998
8d918e48-a2f3-415d-8998-c0b0fbaee51f	CAFE GALAVIS EXTRA 250GR	7702182000030	t	8600.00	8450.00	\N	\N	5.00	2025-10-19 02:29:41.937239	2025-10-19 02:29:41.937239
a66c36f7-086c-46ad-8c98-80744413466c	SALCHICHON AHUMADO CIFUENTES	135DSF	t	13100.00	12900.00	12800.00	\N	19.00	2025-10-19 02:29:41.937477	2025-10-19 02:29:41.937477
37b0f321-28a7-4195-b3a4-c228fbac2325	PAÑITOS PETETIN 100UNID	6940188300056	t	7300.00	7100.00	\N	\N	19.00	2025-10-19 02:29:41.937733	2025-10-19 02:29:41.937733
9c99fbf3-20b1-4092-b0bf-9dd71978e004	ACEITE BEBE JUHNIOS	Z4DF6	t	2100.00	2000.00	\N	\N	0.00	2025-10-19 02:29:41.937946	2025-10-19 02:29:41.937946
764ab806-740a-40e9-b256-57ccbac357b4	ACEITE BEBE JUHNIOS 50ML	5DS7F	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:41.938454	2025-10-19 02:29:41.938454
bc3478bf-dcf8-4289-ae70-53095705275a	CAFE GALAVIS 125GR	7702182000023	t	2500.00	2300.00	\N	\N	5.00	2025-10-19 02:29:41.938658	2025-10-19 02:29:41.938658
8653fccf-6b81-4099-9e3e-28442e94a7eb	SUNTEA MORA 1.5L	7702354948382	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:41.938893	2025-10-19 02:29:41.938893
945cb912-4bef-4ab3-88ef-bc81bfed1cf6	CHOCO HAPPY BON BON CORAZON	4897054140037	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.939118	2025-10-19 02:29:41.939118
ade1588c-2aef-418d-839f-0895bc82c58c	FIDEOS ÑA MUÑECA 125GR	7702020111126	t	1000.00	880.00	\N	\N	5.00	2025-10-19 02:29:41.939369	2025-10-19 02:29:41.939369
5897cb51-17e1-495c-8184-affb966f1bc8	CHOCOLATINA KINDER 12.5GR	80050315	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.939579	2025-10-19 02:29:41.939579
bef7742e-31ac-4b98-8c88-4ed7cf3c0836	CHOCO HAPPY CORAZON	4897054140013	t	5200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.939826	2025-10-19 02:29:41.939826
6917529c-f04b-4d31-b94f-3c74abc5645b	CARAMELOS X4UNID	31025	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.940061	2025-10-19 02:29:41.940061
054fa5dd-ac5f-4a2c-ba54-eaa043515133	CARAMELO X10UNID CAJA	31021	t	6400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.940367	2025-10-19 02:29:41.940367
21811dce-f789-4568-b40e-2b5a5d1a1508	COFRE DREAM REGALO	4897033224000	t	3900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.940614	2025-10-19 02:29:41.940614
f1001743-f497-4797-ad44-9957141fb6c2	CAJA MINI BOTELLA	31161	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.940879	2025-10-19 02:29:41.940879
0258bfc6-4573-45d0-afa0-fe909a486450	MOÑOS DE DULCES	31145	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.94115	2025-10-19 02:29:41.94115
bcff5766-ccc6-45b4-b142-95a291e53041	CAJA PREMIUM CHOCOLATE	31173	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.941378	2025-10-19 02:29:41.941378
9d4dec68-becb-4426-8c6e-026f8d42e0a4	BONBONERA ANIMALITOS X10UNID	8693029200227	t	39000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.9417	2025-10-19 02:29:41.9417
a76d9b68-ea0c-4760-a75e-039e87c0eb46	COLONIA CHICO 220CM	5901234123457	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.942149	2025-10-19 02:29:41.942149
f403b626-b77f-40ad-8ba8-85e8d3c6ca63	ACEITE CORPORAL ALMENRA 100ML	659525178550	t	4200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.942421	2025-10-19 02:29:41.942421
5d941711-ced2-4eba-8e75-dcb21e8637cc	LAK SENSACION	7702310020879	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.942913	2025-10-19 02:29:41.942913
54f2f610-89c4-4ae3-a57b-aca25468a782	LIGAS POTE	3SD54GFW	t	4000.00	3600.00	\N	\N	19.00	2025-10-19 02:29:41.943264	2025-10-19 02:29:41.943264
ef35d855-8000-4a1e-90da-3ad4ca57d98c	TIO NACHO PURIFICANTE CON CELULAS 415ML	650240057489	t	30000.00	29000.00	\N	\N	19.00	2025-10-19 02:29:41.943547	2025-10-19 02:29:41.943547
7ba70325-a755-4248-b910-06cc563a5daf	SCOTT 2 EN 1 SUAVE X12UNID	7702425730151	t	13500.00	13000.00	\N	\N	19.00	2025-10-19 02:29:41.943846	2025-10-19 02:29:41.943846
e5ae4d73-05f6-4eff-888f-4429f9ac6908	ACEITE EXTRA VIRGEN OLIVETTO 250ML	7702109012603	t	20800.00	20200.00	\N	\N	19.00	2025-10-19 02:29:41.944073	2025-10-19 02:29:41.944073
bd1b4372-f0e0-487f-988b-29ee900bf104	TROLLI PUM PUM 60GR	7702174086059	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.944305	2025-10-19 02:29:41.944305
c80468b6-0cff-43c0-b462-cb2fb120fb45	SAVITAL X20S 25ML	7702006202978	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.944576	2025-10-19 02:29:41.944576
fc033eaa-a53e-4b00-8907-08992996b283	AK1 PODER DE LA BARRA 3KILOS	7702310047227	t	24000.00	23600.00	\N	\N	19.00	2025-10-19 02:29:41.944876	2025-10-19 02:29:41.944876
d77a74e2-1099-4d22-b125-ce6b4ed57f6a	3D BICARBONATO 2KG	7702191164181	t	16300.00	15800.00	\N	\N	19.00	2025-10-19 02:29:41.945176	2025-10-19 02:29:41.945176
8cb84df9-b167-463b-b88d-38d600cf1cdd	BOKA MANGO 2L	7702354032029	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:41.945385	2025-10-19 02:29:41.945385
5689abe4-e0b5-46bf-bb74-26f75818dc31	PRUEBA DE EMBARAZO	7708211573322	t	2500.00	2000.00	\N	\N	19.00	2025-10-19 02:29:41.945616	2025-10-19 02:29:41.945616
bb37191a-7a6d-4538-8443-49f88309abb1	RAPIDITAS FAJITAS Y BURRITOS 425GR BIMBO	7705326077844	t	11900.00	11700.00	\N	\N	19.00	2025-10-19 02:29:41.94583	2025-10-19 02:29:41.94583
30da9437-b6c6-4e3a-9da6-507e566636e4	LONCHERA BIMBO X6UNID	7705326081216	t	7100.00	7000.00	\N	\N	19.00	2025-10-19 02:29:41.946024	2025-10-19 02:29:41.946024
4e458ab4-919c-4307-a871-45b1c0c38d4a	ARROZ DIANA  10KILOS	7702511000205	t	42500.00	\N	\N	\N	0.00	2025-10-19 02:29:41.946297	2025-10-19 02:29:41.946297
c8b4c898-9f1e-48c5-896f-a5a4d128a6bd	CERA ROJA NETTUNO 350ML	7702377389605	t	5000.00	4800.00	\N	\N	19.00	2025-10-19 02:29:41.946533	2025-10-19 02:29:41.946533
36c45fe5-fa9c-4b2e-92cf-11c8b4da44f3	SUAVITEL FLORAL 4.8L	7509546693903	t	36000.00	35500.00	\N	\N	19.00	2025-10-19 02:29:41.946748	2025-10-19 02:29:41.946748
f7a381ae-822a-45fb-ad1c-08b6a01ce99f	ESPONJA EL REY ORO PLATA	7707178732704	t	1200.00	1067.00	\N	\N	19.00	2025-10-19 02:29:41.947092	2025-10-19 02:29:41.947092
e2ecb21f-5829-4476-b9aa-4735f20394f8	GUANTES ETERNA TRABAJO PESADO  TALLA 8 MEDIO	7702037502863	t	4100.00	3930.00	\N	\N	19.00	2025-10-19 02:29:41.947301	2025-10-19 02:29:41.947301
19ec7470-9101-4ce1-9ca9-b43281ebfff9	SALTIN NOEL CARAVANA 150GR	7702025141159	t	3300.00	3150.00	\N	\N	19.00	2025-10-19 02:29:41.94752	2025-10-19 02:29:41.94752
b0401064-33cd-4f61-98db-0bbdd8fc6a55	MECHERA CON LINTERNA SMAT X25UNID	1795864312626	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.947733	2025-10-19 02:29:41.947733
136116d1-0c8c-4091-8643-80e7e4f39eea	AJINOMEN ORIENTAL	7754487001731	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.947933	2025-10-19 02:29:41.947933
6ddf3984-e188-4be6-814a-1dc4cbf35e5b	VINO LA GRAN VIÑA MANZANA 750ML	7709806388734	t	4000.00	3125.00	\N	\N	19.00	2025-10-19 02:29:41.948193	2025-10-19 02:29:41.948193
b591742b-cafc-4ecd-9d4c-3e9f86ff5d46	TINTE LISSIA 6.0 RUBIO OSCURO	7703819301858	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:41.948391	2025-10-19 02:29:41.948391
c2a08fb5-34be-463e-8f8e-33b9a2f0f4d0	MANI MOTO 80GR	7702189055903	t	2300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.948615	2025-10-19 02:29:41.948615
ed7d8ead-74b1-47de-89ca-d6f32b960938	CERA BUFALO ESCARLATA 400ML	7702377005208	t	8500.00	8150.00	\N	\N	19.00	2025-10-19 02:29:41.948858	2025-10-19 02:29:41.948858
83dbfb9b-9609-44c3-ad07-65de8d96d08f	SALTIN NOEL CARAVANA CAJA 200GR	7702025141166	t	4000.00	7530.00	\N	\N	19.00	2025-10-19 02:29:41.949215	2025-10-19 02:29:41.949215
23e3e69f-fa23-4571-bd52-3f0ec7e895f0	GOLPE MAYONESA Y ORIGINAL X8UNID	3DS41	t	20200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.94946	2025-10-19 02:29:41.94946
4580e975-ccc9-49c1-8cca-4c190072d96a	SUAVIZANTE ULTREX 900ML	7707839189601	t	4700.00	4500.00	\N	\N	19.00	2025-10-19 02:29:41.949656	2025-10-19 02:29:41.949656
58324919-29e4-4f5b-b0ab-37e5714e3fc1	COLOR 1 5 MINUTOS	7707223660020	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.949903	2025-10-19 02:29:41.949903
3b12ef69-605f-47fb-a5e6-3b1a2f855a7e	CEPILLO COLGATE ZIGZAG CARBON ACTIVO X3 SUAVE	8718951179912	t	14300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.950229	2025-10-19 02:29:41.950229
c068af8a-6074-4e47-a458-97856c950e06	COLGATE TRIPLE ACCION 100ML	7509546000343	t	9300.00	9050.00	\N	\N	19.00	2025-10-19 02:29:41.950523	2025-10-19 02:29:41.950523
031a913b-6bec-4272-a284-9ae049b8c57f	mamut dulce individual	7702189057983	t	400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.950805	2025-10-19 02:29:41.950805
8100c48d-2a10-4892-9bce-f3b7c3b676d7	PAPAS MARGARITAS ONDULADAS 40GR	7702189058317	t	2400.00	2250.00	2180.00	\N	19.00	2025-10-19 02:29:41.951034	2025-10-19 02:29:41.951034
f89e6c38-c5cf-4272-b87c-6ed9162ea7e9	GOL BARQUILLO  UND 35GR	7702007074376	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.95129	2025-10-19 02:29:41.95129
f0369245-d974-4ba6-8598-6404e12ae474	LACA CAPILAR LA FIESTA ROSADA	8426373005602	t	9500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.951517	2025-10-19 02:29:41.951517
29f38c53-d474-49ba-974b-78a6e97f4617	LACA CAPILAR LA FIESTA VERDE	8426373005664	t	9500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.951744	2025-10-19 02:29:41.951744
23fc67f8-d30f-44c6-a171-7d4bddb292f1	LACA CAPILAR LA FIESTA FUCSIA	8426373005671	t	9500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.951972	2025-10-19 02:29:41.951972
f804e877-1aa6-4e4c-b3d8-77e665541938	LACA CAPILAR LA FIESTA GLITZER	8426373006609	t	9500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.952209	2025-10-19 02:29:41.952209
86b2fbb2-d2f2-416e-9e3a-37ea6c4b6b55	VELAS SANTA MARIA 8	7707297960187	t	2600.00	2450.00	\N	\N	19.00	2025-10-19 02:29:41.952435	2025-10-19 02:29:41.952435
d6b3a298-1ad9-4ba6-af27-3d800161674c	SET EMPANADERA X3UNID	7704331891810	t	8400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.952662	2025-10-19 02:29:41.952662
66bd24bf-1668-4391-b98b-3950f91ee598	VELAS SON JORGE X10UNID	7707159820239	t	7500.00	7200.00	\N	\N	19.00	2025-10-19 02:29:41.952889	2025-10-19 02:29:41.952889
b1a8bfb0-bc01-438e-b761-a01e20ff4ba4	CONCHA DORIA 500GR	7702085013120	t	4000.00	3870.00	\N	\N	5.00	2025-10-19 02:29:41.953214	2025-10-19 02:29:41.953214
384ecd51-5e6a-4d13-a7b4-2d04644f56e4	JUMBO ROSCA MITI MITI 31GR	7702007077674	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.953492	2025-10-19 02:29:41.953492
eb9c1075-f858-40ef-a862-9b1c3b5ce20f	SUAVIZANTE MI DIA 400ML	7705946421577	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:41.953747	2025-10-19 02:29:41.953747
687ec5fe-d638-4965-8eed-a9ab57c0a0e4	1700	CHOCLITO PICANTE 50GR	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.954018	2025-10-19 02:29:41.954018
668e9d8d-9da4-4637-8e10-8139d34afa47	GELATINA X3 DE LA ABUELA	7707287464169	t	3900.00	3750.00	\N	\N	19.00	2025-10-19 02:29:41.954294	2025-10-19 02:29:41.954294
82a6448e-a076-4570-8d69-83b1e33ba140	SUAVIZANTE MI DIA 1L	7705946421560	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.954583	2025-10-19 02:29:41.954583
2c2303c1-e37a-42bc-b8a2-a933fdca1691	HARINA PAN 500	7702084127330	t	1800.00	\N	\N	\N	5.00	2025-10-19 02:29:41.954908	2025-10-19 02:29:41.954908
3b33a4e5-4595-4aec-9ed3-a3872a41eda3	PAPAS MARGARITAS FLAMIN HOT 42GR	7702189058263	t	2400.00	2250.00	2180.00	\N	19.00	2025-10-19 02:29:41.955176	2025-10-19 02:29:41.955176
2a65e33d-0290-497f-9f76-a7dbdea92323	ACEITE BEBE JHUNIOR 50ML	7709385751509	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.955525	2025-10-19 02:29:41.955525
25d83d7d-0721-45b1-8374-dc65f97d0087	JUMBO BROWNIE 35GR X12UNID	7702007075250	t	27200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.955802	2025-10-19 02:29:41.955802
7de7e56c-eb07-4ec1-b116-8ea609942505	GOL MINI X24 UNID	7702007080575	t	17600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.956284	2025-10-19 02:29:41.956284
61180ba2-bcba-4765-9d47-225507fdec90	COLCAFE DESCAFEINADO LIGERO 40GR	7702032117420	t	9400.00	9100.00	\N	\N	5.00	2025-10-19 02:29:41.956606	2025-10-19 02:29:41.956606
4dc2c427-310e-4b2f-94e3-9f62ba672aa6	MANTEQUILLA PICADA	3ASD54F	t	2500.00	2360.00	\N	\N	19.00	2025-10-19 02:29:41.957204	2025-10-19 02:29:41.957204
7cead040-edd1-466a-83a5-b76646199062	CLORO SKAAP BLANQUEADOR 1L	7707371211266	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.957882	2025-10-19 02:29:41.957882
9f7ead30-ae59-4151-9ec1-fb1bf5bd47b9	COLCAFE LIGERO DESCAFEINADO 90GR	7702032117444	t	14800.00	14400.00	\N	\N	5.00	2025-10-19 02:29:41.959771	2025-10-19 02:29:41.959771
30aeb1c2-030e-414b-83e2-c6ad363cd89d	MACARRON INSTANTANEO DORIA CON QUESO 53GR	7702085048108	t	3500.00	3400.00	\N	\N	19.00	2025-10-19 02:29:41.960468	2025-10-19 02:29:41.960468
1960d610-3fe6-41a9-ad13-9b970162ead0	JUMBO MIX 60GR	7702007009989	t	4900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.960895	2025-10-19 02:29:41.960895
b8935285-66ff-4480-8d45-bf71fbf10606	OKA LOKA GOMITAS CRUNKY 55GR	7702993044315	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.9612	2025-10-19 02:29:41.9612
49996987-9962-4cf1-aac7-bcbfa6e22482	JUMBO BROWNIE	7702007071689	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.961436	2025-10-19 02:29:41.961436
7f4e2094-1e19-4402-87b5-58048509eb94	CHOCLITO PICANTE 50GR	7702189058386	t	2200.00	2100.00	2000.00	\N	19.00	2025-10-19 02:29:41.961693	2025-10-19 02:29:41.961693
f69925ef-08c1-465d-a8ab-6253455b3601	AJI BARY 165GR	7702439000059	t	3100.00	2950.00	\N	\N	19.00	2025-10-19 02:29:41.961897	2025-10-19 02:29:41.961897
3ec85018-181b-44d1-a720-1a81ff4befc5	SALSA NEGRA NORSAN 1LITRO	7709259938852	t	6600.00	6450.00	\N	\N	19.00	2025-10-19 02:29:41.962143	2025-10-19 02:29:41.962143
a5afb412-67e9-4a7c-81ff-1f51110b5314	SUAVIZANTE SKAAP 1000ML	7707371211693	t	5600.00	5450.00	\N	\N	19.00	2025-10-19 02:29:41.962389	2025-10-19 02:29:41.962389
489329f4-3304-411c-be84-79b0d1c4c962	DESENGRASANTE NOSAN 500ML	7707291395848	t	3600.00	3500.00	\N	\N	19.00	2025-10-19 02:29:41.962653	2025-10-19 02:29:41.962653
2938fb1c-ae2b-439e-beea-b876b868c825	LIMPIAPISOS SKAAP LAVANDA 900ML	7707371212126	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:41.962932	2025-10-19 02:29:41.962932
c091e27d-c0ca-4baf-a387-54e927358138	LIMPIAPISOS SKAAP BICARBONATO LIMON 900ML	7707371217411	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:41.963234	2025-10-19 02:29:41.963234
75ad8eff-5bd3-4f7d-96d6-d6da9f05ec63	TALCO VALNIS FOR MEN 600GR	7709044633771	t	5000.00	4700.00	\N	\N	19.00	2025-10-19 02:29:41.963473	2025-10-19 02:29:41.963473
f78f0933-8b1d-434b-a878-0df81508642b	HUGGIES XXG /5  X25UNID	7702425113213	t	25500.00	24700.00	\N	\N	19.00	2025-10-19 02:29:41.963711	2025-10-19 02:29:41.963711
e22ccf9f-a940-4d12-b8c7-07fc9a3b5cde	TOSH CREMADA YOGURT Y FRESA X6UNID	7702025125524	t	5700.00	5550.00	\N	\N	19.00	2025-10-19 02:29:41.963929	2025-10-19 02:29:41.963929
27d69a91-b5a4-485d-a3b6-1ec88d213a1a	NUTRE CAN CROQUETAS CACHORRO 500GR	7702712003005	t	4400.00	4250.00	\N	\N	5.00	2025-10-19 02:29:41.964176	2025-10-19 02:29:41.964176
0dd5bcfb-cc8a-43a1-b907-cb14be7c30fa	AROMATICAL PANELA MARACUYA 6GR	7702807857155	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.964422	2025-10-19 02:29:41.964422
f8061875-21fa-422d-b888-d008ca25054b	MAIZ DULCE RICURA DEL CAMPO 185GR	7709577434814	t	3400.00	3290.00	\N	\N	19.00	2025-10-19 02:29:41.964641	2025-10-19 02:29:41.964641
1b13be15-7b2b-46dc-a59e-dc680b9de89c	PALILLOS DE HAMBURGUESAS EL SOL  EXTRALARGO	7707015506475	t	1600.00	1470.00	\N	\N	19.00	2025-10-19 02:29:41.964885	2025-10-19 02:29:41.964885
e1946bc1-2a84-4af6-aff2-89be14819a25	PAÑITOS FRESKITOS 40UNID	7709808402209	t	3200.00	3000.00	\N	\N	19.00	2025-10-19 02:29:41.965173	2025-10-19 02:29:41.965173
ad531147-b477-4ac3-a926-1f8bae5c38be	VASOS DE PAPEL 4OZ X50UNID	7702251043364	t	5000.00	4900.00	\N	\N	19.00	2025-10-19 02:29:41.965419	2025-10-19 02:29:41.965419
785b654d-3844-4bf9-af16-ca4033b501e0	PALILLOS PINCHO BAMBU EL SOL 30CM X100UNID	7707015506314	t	2900.00	2780.00	\N	\N	19.00	2025-10-19 02:29:41.965655	2025-10-19 02:29:41.965655
62e8ac84-1768-44a8-988e-2949c6731f08	JABON LIQUIDO FRESKITOS FRUTOS ROJOS 1LITROS	7709643563851	t	8400.00	8180.00	\N	\N	19.00	2025-10-19 02:29:41.965885	2025-10-19 02:29:41.965885
31395d19-bfab-437f-ae17-9848b8aa06fd	JABON LIQUIDO FRESKITOS AVENA 1LITRO	7709586352369	t	8400.00	8180.00	\N	\N	19.00	2025-10-19 02:29:41.966145	2025-10-19 02:29:41.966145
d4fe165f-19d6-4bab-8d78-39d090050727	JABON LIQUIDO FRESKITO MANZANA VERDE 1LITROS	7709808402223	t	8400.00	8180.00	\N	\N	19.00	2025-10-19 02:29:41.96638	2025-10-19 02:29:41.96638
fc9054e9-a8bd-4918-b8b3-12c4c4ac6138	PAÑITOS PEQUEÑIN ALMENDRAS X100UNID	7702026147631	t	10500.00	10300.00	\N	\N	19.00	2025-10-19 02:29:41.966814	2025-10-19 02:29:41.966814
daa5272c-dc30-459c-958f-adb01c2ebe0f	BUÑUELOS DEL MAIZ 250GR	7708773299623	t	2800.00	2600.00	\N	\N	19.00	2025-10-19 02:29:41.967257	2025-10-19 02:29:41.967257
de2f0c80-ce95-452b-b63a-37b7d533b494	NATILLA DEL MAIZ 250GR	7708773299074	t	2800.00	2600.00	\N	\N	19.00	2025-10-19 02:29:41.967652	2025-10-19 02:29:41.967652
41976223-50f7-4f85-bf33-462a336b2412	CEPILLO ECOLOGICO LIMPIA YA	7702037876186	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:41.968019	2025-10-19 02:29:41.968019
8f65ef3c-79c3-4990-b915-921138344202	LAK 110GR FRECURA EXTREMA	7702310020886	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.968473	2025-10-19 02:29:41.968473
cd4e09f1-a815-42f5-8a88-0e6b9beda326	BOCADILLO COMBINADO MANJAR X12	7707231540253	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.969128	2025-10-19 02:29:41.969128
8721fbfb-2aaa-4f5d-b6ec-b614b133bd67	ADVIL GRIPA	6SD4G4	t	2200.00	2000.00	\N	\N	0.00	2025-10-19 02:29:41.969442	2025-10-19 02:29:41.969442
e34add65-7609-44fe-9785-11010e52d90a	BLANQUEADOR ROPA COLOR SKAAP 1L	7707371212874	t	3000.00	2850.00	\N	\N	19.00	2025-10-19 02:29:41.969745	2025-10-19 02:29:41.969745
4cbc9743-5e99-4e01-a829-9f0c1808fcd9	CHAMPAÑA ESPUMOSO LATIN SPIRIT 750ML	7707357044710	t	10000.00	9400.00	\N	\N	19.00	2025-10-19 02:29:41.970172	2025-10-19 02:29:41.970172
f0f20898-18d4-4224-8117-4673297fd78d	CHAMPAÑA ESPUMOSO LATIN SPIRIT ROSADA 750ML	7707357040415	t	10000.00	9400.00	\N	\N	19.00	2025-10-19 02:29:41.970537	2025-10-19 02:29:41.970537
9a13267c-bd56-4003-ad0e-87e7cb0aac70	VINO LA GRAN VIÑA MSCATEL UVA 750ML	7709095700989	t	4000.00	3125.00	\N	\N	19.00	2025-10-19 02:29:41.97084	2025-10-19 02:29:41.97084
75e6b11d-847c-48dd-a9e5-ea561ea5d11c	ESPUMA DE AFEITAR AMALFI MEN 250ML	8414227691361	t	13700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.971183	2025-10-19 02:29:41.971183
558ff79a-4db5-46c3-b401-626eda9b60c9	POTAL C1	S4DF53	t	300.00	250.00	\N	\N	19.00	2025-10-19 02:29:41.971632	2025-10-19 02:29:41.971632
5848de0a-ff19-4a9e-be10-cda9effc057b	TOSH CREMADA VAINILLA X6UNID	7702025103362	t	5700.00	5550.00	\N	\N	19.00	2025-10-19 02:29:41.971877	2025-10-19 02:29:41.971877
0dee0a22-838f-4f5a-b134-8dd87ae9a73e	FESTIVAL RECREO X12UNID	7702025144266	t	2800.00	2680.00	\N	\N	19.00	2025-10-19 02:29:41.972152	2025-10-19 02:29:41.972152
0e699925-37d8-4062-bf81-df12d83219d6	JET COOKIES AND CREAM X6UNID 50GR	7702007042283	t	30900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.972424	2025-10-19 02:29:41.972424
b46bbaff-9f42-4570-848c-83769e016948	CARAOTA SAMARA 250GR	7709976611946	t	1800.00	1700.00	\N	\N	5.00	2025-10-19 02:29:41.972686	2025-10-19 02:29:41.972686
b4c361e0-3d89-434a-a283-0f3a3614f4cf	ESPONJA LUBA	7460000080144	t	800.00	684.00	\N	\N	19.00	2025-10-19 02:29:41.972893	2025-10-19 02:29:41.972893
0cd72464-e5bc-4ba4-92c0-7b2d15681ce6	ELITE MAX X18 2HOJAS	7707199342579	t	20300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.973159	2025-10-19 02:29:41.973159
fe03146d-76a3-41de-9978-f3d18890920e	DORITOS MEGA QUESO 48GR	7702189059819	t	2600.00	2500.00	2390.00	\N	19.00	2025-10-19 02:29:41.973421	2025-10-19 02:29:41.973421
5534b406-00ea-4c85-98fc-d47cf48f3d87	PAPAS MARGARITAS LIMON 42GR	7702189058287	t	2400.00	2250.00	2180.00	\N	19.00	2025-10-19 02:29:41.973708	2025-10-19 02:29:41.973708
d503b7ea-24b8-4877-b80c-e0b610c90789	NUTRI RINDE EL RODEO 135GR	7702024844587	t	5300.00	5100.00	\N	\N	0.00	2025-10-19 02:29:41.974351	2025-10-19 02:29:41.974351
17234e3a-92b5-4e5e-995e-119bfad752c8	HIT MANGO 200ML	7702090013061	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.974623	2025-10-19 02:29:41.974623
fa912492-bbb2-4307-9640-3d2740ba98b2	CARACOL COMARRICO 454GR	7707307963177	t	2800.00	2700.00	\N	\N	5.00	2025-10-19 02:29:41.974928	2025-10-19 02:29:41.974928
e1b62334-e3f6-41e6-a219-55290d57be3b	SUAVIZANTE ULTREX 4L	7707183660436	t	17400.00	16900.00	\N	\N	19.00	2025-10-19 02:29:41.97521	2025-10-19 02:29:41.97521
8521386b-1484-4271-b2c5-e0483f666e97	GALLETAS DULCE NAVIDAD MANTEQUILLA GAMESA 300GR	7702189057327	t	5100.00	4900.00	\N	\N	19.00	2025-10-19 02:29:41.97547	2025-10-19 02:29:41.97547
8c4bd48d-f350-4274-af3d-ff1201849455	MANI KRAKS X12UNID BOLSA	3F5GJ45	t	9500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.975819	2025-10-19 02:29:41.975819
b0de5caa-36ff-4a1c-a7e9-961c976c7f9d	NATUCAMPO SALSA DE AJO 200GR	7709198253986	t	4400.00	4300.00	\N	\N	19.00	2025-10-19 02:29:41.97606	2025-10-19 02:29:41.97606
8302c1f1-b955-4bdb-9b2a-9b267d4387d1	SYBMARINO X2 AREQUIPE	7705326079114	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:41.976309	2025-10-19 02:29:41.976309
4333552f-a78d-4540-b0e4-fbdc3f4ebdee	BARRA TOSH DE CHOCOLATE	7702007063677	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.976518	2025-10-19 02:29:41.976518
3f01ea5e-3fca-4d11-b4fe-76658545cea9	BARRA TOSH NUECES Y ARANDANOS	7702007063714	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.976796	2025-10-19 02:29:41.976796
4ec337f4-d1a7-49a7-88d4-61a2159c1ae3	TRULULU LENGUAS 70GR	7702993051825	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:41.977122	2025-10-19 02:29:41.977122
2b490a65-c120-4180-b6cc-9dcada6506b8	SHAMPOO SAVITAL FUSION PROTEINAS 510ML	7702006208512	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:41.977429	2025-10-19 02:29:41.977429
fcf3d33e-befc-42a0-8086-cf57b66d4ebe	BRILLO FINO LUA SAN JORGE X6UNID	7707159827054	t	1600.00	1490.00	\N	\N	19.00	2025-10-19 02:29:41.977749	2025-10-19 02:29:41.977749
2b715e13-cd76-476a-9c75-24c4dc946f13	HUEVOS NO ME OLVIDE PIKIS X10UNID	7702117003259	t	27000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.978062	2025-10-19 02:29:41.978062
3d9a9ba9-25a5-40a0-963a-f4597769b2b5	DERSA CON EL POODER LA BARRA 6.000GR	7702166041509	t	41500.00	41200.00	\N	\N	19.00	2025-10-19 02:29:41.978368	2025-10-19 02:29:41.978368
705fbbe4-2570-46f9-a319-644a2548e458	SHAMPOO NUTRIT KERATINMAX 600ML	7702277575764	t	17500.00	17000.00	\N	\N	19.00	2025-10-19 02:29:41.978581	2025-10-19 02:29:41.978581
1572242b-500d-4039-b6b1-4b01e0375bde	TUMIX BANDEJA X400UNID	7703888299124	t	35000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.978855	2025-10-19 02:29:41.978855
2d0f5997-83b9-485f-ab33-4d683973f9ac	SALSA BBQ FRUCCO ARTESANAL 80GR	7702047041277	t	2200.00	2120.00	\N	\N	19.00	2025-10-19 02:29:41.979088	2025-10-19 02:29:41.979088
fc8a04c5-acfe-4620-9fb3-9f457de68702	JAMON DE PIERNA 250GR	7770000900220	t	4400.00	4300.00	\N	\N	19.00	2025-10-19 02:29:41.979299	2025-10-19 02:29:41.979299
c96880b1-4d01-4256-9741-e4953bed155a	SUAVIZANTE ULTREX 425ML	7707183660351	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:41.979536	2025-10-19 02:29:41.979536
03e643ac-5c61-462e-98ce-3f7d745cbab8	MAYOBURGURGER LA CONSTANCIA 190GR	7702097153289	t	6600.00	6350.00	\N	\N	19.00	2025-10-19 02:29:41.979762	2025-10-19 02:29:41.979762
4c63a2b4-6db9-496a-a817-bcadebdfebe3	MAYOGAUCHA LA CONSTANCIA 190GR	7702097153630	t	6000.00	5800.00	\N	\N	19.00	2025-10-19 02:29:41.979969	2025-10-19 02:29:41.979969
27072736-367c-4246-8ece-4143dfb575ff	MAYOCHULA LA CONSTANCIA 190GR	7702097153296	t	6000.00	5800.00	\N	\N	19.00	2025-10-19 02:29:41.980224	2025-10-19 02:29:41.980224
31118d1e-3e50-4633-a87d-0b8aee187b04	VALTRUM ACCION INMEDIATA 50GR	854650003078	t	3200.00	2800.00	\N	\N	19.00	2025-10-19 02:29:41.980505	2025-10-19 02:29:41.980505
b61c6515-f554-4af6-a0cc-b70c96f30a03	BOMBILLO FULLWAT 9W	7707613050882	t	4000.00	3900.00	\N	\N	19.00	2025-10-19 02:29:41.981135	2025-10-19 02:29:41.981135
fb101dfa-75fd-420d-949d-3b6ba3870469	BOMBILLO FULLAR 20W	7707654274339	t	13000.00	12600.00	\N	\N	19.00	2025-10-19 02:29:41.981374	2025-10-19 02:29:41.981374
5dde6672-a161-4f54-9641-dd235f1f2da9	CUCHARA DULCERA TAMI X20UNID	645667318091	t	1600.00	1470.00	\N	\N	0.00	2025-10-19 02:29:41.981614	2025-10-19 02:29:41.981614
6c3b146c-e0ec-4bdd-86d1-a608e9102db4	KINDER YOY NIÑO X2UNID	7708965796909	t	10400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.981916	2025-10-19 02:29:41.981916
54136c55-6b50-47bf-8d7b-03a4fffa00c9	TONO SOBRE TONO CHOCOLATE	7709990417319	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:41.982221	2025-10-19 02:29:41.982221
be990b9a-376b-4be7-83c6-3b32df8a598e	UNI KAT ARENA PARA GATOS 900GR	7702084057415	t	4200.00	4000.00	\N	\N	19.00	2025-10-19 02:29:41.982452	2025-10-19 02:29:41.982452
2bfc4bcf-463c-49d1-8edc-f784dd137d1d	ARIEL TRIPLE PODER 100GR	7500435201315	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.982729	2025-10-19 02:29:41.982729
4b3a27a9-7424-4080-ba48-d835f49129ef	ARIEL REVITA COLOR 125GR	7500435160186	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.983008	2025-10-19 02:29:41.983008
917208c6-b973-45fb-8fb8-20e07a91dffb	ALOKADOS MENTA X100UNID	7707014903404	t	6300.00	\N	\N	\N	19.00	2025-10-19 02:29:41.983531	2025-10-19 02:29:41.983531
7d2700bb-5e48-4a92-ad00-c97391045bb8	CEPILLO INFINOTO X1	7708827478905	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.983949	2025-10-19 02:29:41.983949
72922556-73e1-409c-bf69-ed77dc686ff2	MANTEQUILLA CAMPI X4UNID	7702109018803	t	9100.00	\N	\N	\N	19.00	2025-10-19 02:29:41.984265	2025-10-19 02:29:41.984265
5e1bb2e4-78d0-4936-8e3d-0f20390d3fe2	MCHAS LOKAS RENOVACION X6UNID	7702174073257	t	18600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.984549	2025-10-19 02:29:41.984549
6ab6ad73-f513-4ceb-b662-67857297b83b	LIMPIAPISOS BLANCOX ROSA Y JASMIN 900ML	7703812006897	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.985174	2025-10-19 02:29:41.985174
137d21cb-8d93-41cd-9e8c-fb25639120da	KRYZPO PAPAS CREMA Y CEBOLLA 130GR	7802800630332	t	8500.00	8200.00	\N	\N	19.00	2025-10-19 02:29:41.985761	2025-10-19 02:29:41.985761
b3b17cb9-2c6f-49bf-a77e-9e393664d35d	MANI CON SAL LA ESPECIAL 180GR	7702007065565	t	3600.00	3500.00	\N	\N	19.00	2025-10-19 02:29:41.986401	2025-10-19 02:29:41.986401
bc33b9fb-f589-45df-826f-b12d91cd6b53	DETERK DETEGENTE FLORAL 1L	7702310048262	t	8300.00	8050.00	\N	\N	19.00	2025-10-19 02:29:41.986752	2025-10-19 02:29:41.986752
ba78a944-f456-421d-b217-43d5be1607ee	LA ESPECIAL MIX ARANDANOS 180GR	7702007049176	t	8900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.987091	2025-10-19 02:29:41.987091
2eb46cfa-68bd-450e-bd73-e82fcd0d47d5	TIO NACHO ANTI NACHO JALEA ALOE 415ML	7798140259893	t	23500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.987459	2025-10-19 02:29:41.987459
d2a01a85-e9d6-4f51-a7ce-18a2eacbc3ab	CORTADOS 8 UND LA RICAURTE	7707283881205	t	6700.00	\N	\N	\N	19.00	2025-10-19 02:29:41.987833	2025-10-19 02:29:41.987833
bc310bda-615c-4b24-a03b-0ea2a9170356	BOKA NARANJA 2L	7702354031992	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:41.988191	2025-10-19 02:29:41.988191
dfcf9c28-3a46-4175-8573-71c0fe7f0c17	SUPREMO LAVALOZA 900GR	7708872634387	t	9900.00	9550.00	\N	\N	19.00	2025-10-19 02:29:41.988583	2025-10-19 02:29:41.988583
92efeec6-abd8-40e6-ba88-7c4f61f4e4cc	DETERGENTE 3D BICARBONATO 1K	7702191163535	t	8100.00	8000.00	\N	\N	19.00	2025-10-19 02:29:41.988929	2025-10-19 02:29:41.988929
2f557fe8-0339-4121-944a-d08edd51be16	bon aire natural gel	7702532957922	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:41.989195	2025-10-19 02:29:41.989195
02fbb4cb-a1c3-4b6d-b1c8-59a28c8c4bf1	AROMAX LIQUIDO 500ML	7702354950385	t	4100.00	3950.00	\N	\N	19.00	2025-10-19 02:29:41.989567	2025-10-19 02:29:41.989567
63f92ac1-a161-46fe-a979-4466c163f343	KINDER YOY NIÑA X2UNID	7861002900421	t	10400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.989942	2025-10-19 02:29:41.989942
4d667661-0c86-420c-8fd8-3f650df182b2	AROMAX LIQUIDO 180ML LAVANDA	7702354950378	t	1700.00	1630.00	\N	\N	19.00	2025-10-19 02:29:41.990302	2025-10-19 02:29:41.990302
23feff51-331c-466e-a5c5-d88d358f9098	DESODORANTE OLD SPICE DEFENSE 80GTR	7500435202848	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.990672	2025-10-19 02:29:41.990672
a1f95cce-c5b9-4a9b-8154-0d78ea48abe2	REFISAL PARRILLERA MASTER 246GR	7703812405416	t	9800.00	\N	\N	\N	0.00	2025-10-19 02:29:41.991006	2025-10-19 02:29:41.991006
044db773-0397-4df3-9367-d36ed4fa0475	REFISAL SAL MARINA 800GR	7703812005623	t	5900.00	\N	\N	\N	0.00	2025-10-19 02:29:41.991392	2025-10-19 02:29:41.991392
c42ca306-0e5e-4b0b-99ce-73fda575f5ce	ACEITE GOURMET 2600ML MAS 420ML	7702109494669	t	53000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.991813	2025-10-19 02:29:41.991813
169f979f-7ec8-4f69-9e73-7d85b4ee03a3	LIMPIAPISOS BLANCOX LAVANDA EUCALIPTO 900ML	7703812006729	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:41.992254	2025-10-19 02:29:41.992254
fe0c5494-900b-4e09-8a60-ab338e45bf5a	FABULOSOS FLORAL 500M,L	7702010225222	t	4700.00	4600.00	\N	\N	19.00	2025-10-19 02:29:41.992564	2025-10-19 02:29:41.992564
1d030bde-93ef-4f71-8e27-0dc7bf604f65	PILAS D EVEREADY	35DS4GFS	t	5900.00	5700.00	\N	\N	19.00	2025-10-19 02:29:41.992843	2025-10-19 02:29:41.992843
e875e2dd-25b5-44a9-b791-e7c0f6b74f73	AXE DESODORANTE AEROSOL	7702006404952	t	14200.00	13900.00	\N	\N	19.00	2025-10-19 02:29:41.993086	2025-10-19 02:29:41.993086
fd4fa57e-e5ca-4f33-9024-85dd5d4c314d	JUMBO CRUNCKY 100GR	7702007063196	t	3800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.993301	2025-10-19 02:29:41.993301
04a2e72e-2ec1-4a10-899f-1a49ff609abb	LIMPIAPISOS LAVANDA MI DIA 1L	7705946421553	t	2900.00	2770.00	\N	\N	19.00	2025-10-19 02:29:41.993615	2025-10-19 02:29:41.993615
e564d99e-b05e-42fa-b22e-4b98bd311532	MAGGI CREMA DE POLLO CON CHANPIÑONES 75GR	7702024008217	t	3500.00	3390.00	\N	\N	19.00	2025-10-19 02:29:41.993891	2025-10-19 02:29:41.993891
421d789c-0540-4bc7-9adb-23eede9ad216	MAGGI CREMA DE POLLO 75GR	7702024008118	t	3500.00	3390.00	\N	\N	19.00	2025-10-19 02:29:41.994154	2025-10-19 02:29:41.994154
36eec14e-adb6-4b54-a80e-693d96e7d626	COLOR ACHIOTE LA SAZON 150GR PETPACK	7707767144475	t	3900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.994419	2025-10-19 02:29:41.994419
4b172d78-ecef-476e-a958-f6edaafd3e08	MAGGI CREMA DE TOMATE 76GR	7702024008019	t	3500.00	3390.00	\N	\N	19.00	2025-10-19 02:29:41.994657	2025-10-19 02:29:41.994657
80ee32c6-e718-4923-8850-039b0c577e7a	MAGGI CREMA MATINERA 75GR	7702024007463	t	3500.00	3390.00	\N	\N	19.00	2025-10-19 02:29:41.994949	2025-10-19 02:29:41.994949
8fb634bb-f5bb-418e-a97d-0fcbf426e294	MAGGI SOPA DE GALLINA CON ARROZ 65GR	7702024015185	t	2200.00	2080.00	\N	\N	19.00	2025-10-19 02:29:41.995384	2025-10-19 02:29:41.995384
3df37def-bac4-4560-9cd9-2bae328e5e85	COCOSETTE SANDWICH PG 12 LLV 14	7702024073895	t	10900.00	\N	\N	\N	19.00	2025-10-19 02:29:41.996438	2025-10-19 02:29:41.996438
c8efa7ea-cbb8-416c-a719-66d2fb417d4c	MILO ANILLO PG 12 LLV 14	7702024938712	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:41.997342	2025-10-19 02:29:41.997342
f78ce3df-b0d7-47a4-9db2-a90a522f776f	SAVITAL ACONDICINODOR 100 ML	7702006406024	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:41.998097	2025-10-19 02:29:41.998097
6756b8dc-42dd-4d63-909f-a63bda64bf3f	TRULULU AROS MINI	7702993043967	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.998353	2025-10-19 02:29:41.998353
d09d21bd-7a03-45b6-950c-93329fb3e0d8	WAFER JET FRESA 22GR	7702007224184	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.998594	2025-10-19 02:29:41.998594
d8cd6275-bb40-45c7-82f5-0f516bea5af8	WAFER JET 22GR	7702007224023	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.998822	2025-10-19 02:29:41.998822
c3a2841c-c164-49c3-a32b-13f3d1c6d294	WAFER JET LIMON 22GR	7702007224139	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.999119	2025-10-19 02:29:41.999119
af8fb335-4d11-40a7-b55f-4989ac766dbb	WAFER JET CHOCOLATE 22GR	7702007224160	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:41.999417	2025-10-19 02:29:41.999417
14463196-f94c-4434-8fc0-a6c44a3b6881	PIAZZA AREQUIPE UNIDAD	7702011201270	t	400.00	\N	\N	\N	19.00	2025-10-19 02:29:41.999686	2025-10-19 02:29:41.999686
5434e992-e3e8-473a-b35e-7e0aafe75b77	MECHAS LOKAS	7702174073264	t	3200.00	\N	\N	\N	19.00	2025-10-19 02:29:41.999968	2025-10-19 02:29:41.999968
ccd828ed-03ae-46da-85cc-334691998b0f	ELIMINADOR DE OLORES MASCOTAS 300ML	7707426916597	t	7200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.00045	2025-10-19 02:29:42.00045
923e5ded-76b5-40c9-8680-2ff5a94e55bf	BETUM CHERRY NEGRO 15ML 12GR	7702626102696	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:42.001011	2025-10-19 02:29:42.001011
6eb202f1-014b-41ff-bb48-9da7895f168d	COMINO MOLIDO LA SAZON VILLLA 120GR	7707767142273	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.00142	2025-10-19 02:29:42.00142
6573a1ac-b18f-460b-b42d-6c90b834b844	JENGIBRE MOLIDO LA SAZON VILLA 90GR	7707767140187	t	7100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.001759	2025-10-19 02:29:42.001759
d36c78a9-c6bb-4973-a34b-425dd17bca66	BONICE X10 UNID	7702354954550	t	7300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.002094	2025-10-19 02:29:42.002094
692cbe89-24cb-4dc1-a7c5-ac29af6f2e54	CREMA PROTECTORA AEIOU 150GR	7707265991700	t	7200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.002503	2025-10-19 02:29:42.002503
581e6c5e-dc6f-455c-acb5-9e08f89296e9	TALCO ESIKA 230GR	SD354G	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.002783	2025-10-19 02:29:42.002783
e2f1088b-a4b3-4503-bb55-dca0b7ea7d69	FABULOSO LAVANDA 3L	7702010310324	t	23000.00	22200.00	\N	\N	19.00	2025-10-19 02:29:42.003085	2025-10-19 02:29:42.003085
feae59bd-adcf-4d2f-a943-c98032e6c6fe	FAB ULTRA FLASH 3KG	7702191164341	t	28000.00	27600.00	\N	\N	19.00	2025-10-19 02:29:42.003371	2025-10-19 02:29:42.003371
3240a50a-fb87-48ae-895f-3299d1357363	SALSA BBQ HOT BARY 200GR	7702439008611	t	3800.00	3650.00	\N	\N	19.00	2025-10-19 02:29:42.003639	2025-10-19 02:29:42.003639
7f31f314-f4bc-484f-8218-72f09bac3d33	ACEITE DE OLIVA EXTRA VIRGEN MONTICELLO 1LITRO	7702085004951	t	53000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.003932	2025-10-19 02:29:42.003932
047b868e-ee98-403d-8023-c439615e1f8f	SHAMPOO SAVITAL MULTIVITAMINAS 510ML	7702006208420	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:42.00424	2025-10-19 02:29:42.00424
70a4421e-764a-43b9-88be-44ebfdd2a7df	DETODITO MIX X12UNID	7702189038432	t	29800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.004474	2025-10-19 02:29:42.004474
56c5268f-8845-4439-9c40-ba4b27ad5893	LIMPIAPISOS MI DIA BICARBONATO 960ML	7705946610896	t	3500.00	3350.00	\N	\N	19.00	2025-10-19 02:29:42.004712	2025-10-19 02:29:42.004712
4f15cbfe-d08d-43e2-ae76-09aa3294d6a3	FELIX COMIDA HUMEDA PURINA X6UNID	7702521661366	t	14700.00	\N	\N	\N	5.00	2025-10-19 02:29:42.005024	2025-10-19 02:29:42.005024
a20cd613-ba2e-4def-8a34-cae057cbdd27	DOG CHOW COMIDA HUMEDA X4	7702521822781	t	8600.00	\N	\N	\N	5.00	2025-10-19 02:29:42.005269	2025-10-19 02:29:42.005269
fb5d77a6-c94a-4631-ac3a-5473bda626ca	CHORIZO ARGENTINO CIFUENTES X8UNID	32DS415F	t	14800.00	14300.00	\N	\N	19.00	2025-10-19 02:29:42.005532	2025-10-19 02:29:42.005532
0e2b4b48-4ba8-4c67-af20-0dbffd523d91	UNI KAT ARENA PARA GATOS 4KILOS	7702084057422	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:42.005814	2025-10-19 02:29:42.005814
4a978733-f011-4a6a-86cf-6b3c44f91b6e	NUCITA BEBIDA ACHOCOLATADA 200GR	7702011023889	t	7900.00	7650.00	\N	\N	19.00	2025-10-19 02:29:42.006081	2025-10-19 02:29:42.006081
478b93d6-1f85-4f2a-8bcf-4b0f2a3a9ce8	KINDER BUENOS X3UNID	8000500050897	t	16800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.00633	2025-10-19 02:29:42.00633
8fb90fb7-0499-4825-b42f-6db3d7a905d8	ECOAROMAS VARITAS MANZANA VERDE BON AIRE 40ML	7702532525220	t	6200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.006626	2025-10-19 02:29:42.006626
910f079b-a509-4d5a-a971-3b0b4284cb8c	PIAZZA CHOCOLATE X24	7702011201201	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.006977	2025-10-19 02:29:42.006977
aa533085-8b9a-490f-bbbf-22ab553e6882	DUCALES 204GR	7702025139897	t	5900.00	5700.00	\N	\N	19.00	2025-10-19 02:29:42.007251	2025-10-19 02:29:42.007251
b9d1ff0f-0658-4510-997d-5e41cb0a67ff	SOPA INSTANTANEA LAKY MEN POLLO 80GR	7404001800097	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:42.007533	2025-10-19 02:29:42.007533
20898e63-4b81-46e1-9a47-8bd00200c17e	FAB ULTRA FLASH COLOR 6KILOS	7702191164440	t	49500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.00783	2025-10-19 02:29:42.00783
ed0038ef-c480-440c-9432-0d1f9ecc7985	SEÑORIAL TRIPLE HOJA UNID	7707016140210	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.008048	2025-10-19 02:29:42.008048
b771c79b-2591-4290-a417-aa302a941a2a	LIMPIADOR MULTIUSOS AKAAP BRISA MARINA 200ML	7707371218746	t	1300.00	1250.00	\N	\N	19.00	2025-10-19 02:29:42.008304	2025-10-19 02:29:42.008304
804f3615-7fb2-44a9-8286-2e0aad3b5c36	LIMPIADOR MULTIUSOS SKAAP LAVANDA 200ML	7707371213772	t	1300.00	1250.00	\N	\N	19.00	2025-10-19 02:29:42.008535	2025-10-19 02:29:42.008535
ad7ffa22-77c1-4fd7-be0b-49508733b98a	LIMPIADOR MULTIUSOS SKAAP BICARBONATO 200ML	7707371213550	t	1300.00	1250.00	\N	\N	19.00	2025-10-19 02:29:42.008797	2025-10-19 02:29:42.008797
eb435186-2d67-41c1-971e-23d004cc0de2	CREMA DE PEINAR SAVITAL FUSION PROTEINA 275 ML	7702006301718	t	13000.00	12700.00	\N	\N	19.00	2025-10-19 02:29:42.009044	2025-10-19 02:29:42.009044
0974230b-9ccd-481a-af23-43cf7e209355	ATUNA LOMITOS FRAGATA 170GR	7862127010330	t	3500.00	3300.00	\N	\N	19.00	2025-10-19 02:29:42.009265	2025-10-19 02:29:42.009265
367a9df7-30e3-46e2-b792-19fda185c705	ATUN LA SOBERANA EN AGUA 140GR	7702910037482	t	5400.00	5250.00	\N	\N	19.00	2025-10-19 02:29:42.009548	2025-10-19 02:29:42.009548
891264dc-932b-4f7a-b7f0-3ea83044cb19	DON KAT ADULTOS 350GR	7702084057378	t	4400.00	4250.00	\N	\N	5.00	2025-10-19 02:29:42.00979	2025-10-19 02:29:42.00979
1feeba9d-a061-4187-bd80-b9592c20e621	LAVALOZA LIMPIA YA 450GR	7702037912808	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:42.010019	2025-10-19 02:29:42.010019
fa2fd95c-d829-44ab-ab22-f8b326fa142a	FROTEX DETERGENTE LIQUIDO 900ML	7702210054240	t	8800.00	8600.00	\N	\N	19.00	2025-10-19 02:29:42.010243	2025-10-19 02:29:42.010243
1a6eec06-b6cd-4df7-92c0-892d1de922ad	ACONDICIONADOR SAVITAL FUSION PROTEINAS Y SABILA 490ML	7702006208529	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.010526	2025-10-19 02:29:42.010526
580b7fb3-8ab2-4b73-9aa9-d00a999e20df	SHAMPOO SAVITAL COLAGENO 510ML	7702006208604	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:42.010856	2025-10-19 02:29:42.010856
d5c05f8f-9224-4b3a-b1d0-554132b85b27	SHAMPOO SAVITAL ANTICASPA TE VERDE 510ML	7702006302135	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:42.011187	2025-10-19 02:29:42.011187
3599d39f-7333-4af3-a773-94c8dc2cd0dc	SHAMPOO SAVITAL ACEITE ARGAN 350ML	7702006299237	t	11800.00	11400.00	\N	\N	19.00	2025-10-19 02:29:42.011474	2025-10-19 02:29:42.011474
de6624f1-a194-46a2-9b8c-c955540a6a9d	SHAMPOO SAVITAL BIOTINA Y SABILA 510ML	7702006208567	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:42.011758	2025-10-19 02:29:42.011758
7efe4f7a-5a13-472a-a49f-7f2ac0bd8317	SHAMPOO DVE REGENERACION EXTREMA 370ML	7702006208635	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.012048	2025-10-19 02:29:42.012048
cd9f689f-87bd-4636-94a5-6270b73282f5	FAB 2KG	7702191162651	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.012338	2025-10-19 02:29:42.012338
9bbd5534-9fe7-43bc-a1c5-b3b14b4dcb46	ACONDICIONADOR DOVE REGENERACION EXTREMA 370ML	7702006208642	t	15700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.012617	2025-10-19 02:29:42.012617
e2b70a06-fa93-408d-b69f-c783a88f7897	ASEPXIA EXFOLIANTE PIÑA 100GR	650240062049	t	4200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.012949	2025-10-19 02:29:42.012949
026434bb-6cb0-4ee0-a1e2-739924ae6d3b	PAÑITOS PETYS MASCOTAS X10UNID	7702026183141	t	3200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.013331	2025-10-19 02:29:42.013331
1ad03b92-2f58-4759-bf13-e04e73de0243	LIMPIA PISOS BLANCOX LAVANDA 450ML	7703812006736	t	3600.00	3400.00	\N	\N	19.00	2025-10-19 02:29:42.013648	2025-10-19 02:29:42.013648
2e229123-6702-46b5-a42e-38620c4a2f58	SHAMPOO MILAGROS DE ARROZ CON ACIDO 450GR	7708075180469	t	30000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.013938	2025-10-19 02:29:42.013938
a7cf5096-ec42-4ae4-b2e1-4417c17dc07a	MOSTAZA BARY 180GR	7702439008895	t	2200.00	2000.00	\N	\N	19.00	2025-10-19 02:29:42.014215	2025-10-19 02:29:42.014215
9cd52ae9-1f4e-42c9-aa56-33fddc44d161	PAÑO HOGAREÑO ETERNA PG 4 LLV 6	7702037878180	t	5900.00	5700.00	\N	\N	19.00	2025-10-19 02:29:42.014482	2025-10-19 02:29:42.014482
84e1d38c-a0cf-480b-9fc7-e5ed1735d639	SALSA ROSADA BARY 180GR	7702439008888	t	2900.00	2740.00	\N	\N	19.00	2025-10-19 02:29:42.014752	2025-10-19 02:29:42.014752
d3b8a283-4251-4bcd-82b2-d1c1018a7452	MECHERA PISTOLA	5014874012590	t	6600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.015042	2025-10-19 02:29:42.015042
2be53dd3-2059-43ca-9de6-69054e3b6c59	DORITOS FLAMIN HOT 46 GR	7702189059802	t	2600.00	2500.00	2390.00	\N	19.00	2025-10-19 02:29:42.015302	2025-10-19 02:29:42.015302
38e29843-a5e4-4acb-a6ae-284344059634	GALLETAS SALTIN NOEL OCTAGONAL 273GR	7702025146543	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.015553	2025-10-19 02:29:42.015553
d78d2ac7-c7c8-4cc7-b5a5-f39042b7ee03	MANI KRAKS LA ESPECIAL X24UNID	7702007062724	t	17700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.015806	2025-10-19 02:29:42.015806
29b68aa5-dc94-4d20-9c93-95be9d750458	LIMPIADOR MULTIUSOS SKAAP BICARBONATO 2L	7707371212287	t	6300.00	6150.00	\N	\N	19.00	2025-10-19 02:29:42.016077	2025-10-19 02:29:42.016077
e580bfb3-0f26-4280-a567-6fa4024e4656	CERA ESCARLATQA IMPERIAL ROJA 400GR	7707279809992	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:42.016362	2025-10-19 02:29:42.016362
99b4549e-aa43-46f8-818a-85b71fd2e30a	ACEITE GOURMET MULTIUSOS 420ML	7702141680655	t	8400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.016573	2025-10-19 02:29:42.016573
e6eb9aab-6cd3-447e-a140-1ce51b36427f	CREMA DE LECHE COLANTA 175GR	7702129035538	t	3800.00	3700.00	\N	\N	19.00	2025-10-19 02:29:42.017212	2025-10-19 02:29:42.017212
0a4a10a4-f153-494f-92fe-54a12e019c66	NATILLA AREQUIPE DEL MAIZ 250GR	7708773299982	t	2800.00	2600.00	\N	\N	19.00	2025-10-19 02:29:42.017499	2025-10-19 02:29:42.017499
7f1c7c24-2595-4c64-8b9e-96fa44bd15e4	PAPANETA MIXTO LA VICTORIA 70GR	7706642006853	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.017758	2025-10-19 02:29:42.017758
22268d2d-d170-462d-9744-62fef8da76ea	JAMON DE PIERNA CIFUENTES 500GR	7707907447039	t	7600.00	7500.00	\N	\N	19.00	2025-10-19 02:29:42.018024	2025-10-19 02:29:42.018024
12a7ef7b-1e76-4c50-ae52-5561e8f1fc4d	SHAMPO SAVITA ANTICASPA ACONDICIONADOR	7702006653251	t	30000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.018428	2025-10-19 02:29:42.018428
e1ad6fb2-4ace-4fcb-ade2-b7171ffa83b5	PAPEL ALUMINIO EL SOL 100METROS	7707015511264	t	27000.00	26500.00	\N	\N	19.00	2025-10-19 02:29:42.018736	2025-10-19 02:29:42.018736
e42b176d-63f8-4737-a1bf-2d6970579b50	JABON INTIMO ROSE MANZANIILLA 300ML	7704269441798	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.019019	2025-10-19 02:29:42.019019
57ff217a-cd14-4026-b7e6-a5334757ce31	JABON INTIMO ROSE ALOE VRA 300ML	7704269799714	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.019291	2025-10-19 02:29:42.019291
40968ec9-39a3-4b04-bcb2-4f585ab18982	RODAJAS DE ALGODON PADS EXTRA SUAVE X50UNID	7702208145684	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.019504	2025-10-19 02:29:42.019504
164cda84-ab92-4a10-b38c-266b0ee97a7d	TOALLITAS HUMEDAS ARBORA X10UNID	7704269729056	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.019702	2025-10-19 02:29:42.019702
95f53ec3-121f-4717-b042-ec19c042681f	ECOAROMAS VARITAS BON AIRE FRUTOS ROJOS  400ML	7702532722773	t	6200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.019914	2025-10-19 02:29:42.019914
a645c8bc-ac90-48c0-a977-7a004e3d66eb	ECOAROMAS VARIAS VAINILLA 40ML	7702532129466	t	6200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.020215	2025-10-19 02:29:42.020215
0ba1f1bd-a580-41f4-8962-f7b140ac6e61	AROMATICAL SACHET DE AROMA 25GR	7707738873427	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.020498	2025-10-19 02:29:42.020498
db0139d1-36f7-47f1-bdf6-d3aead8fabfb	TOALLITAS HUMEDAS PARA MASCOTAS X50UNID	7709254815172	t	6000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.020805	2025-10-19 02:29:42.020805
d4063d61-e64f-41fd-b588-fb41c22fc433	ACEITUNAS RELLENAS VERA	5904378640200	t	3300.00	\N	\N	\N	0.00	2025-10-19 02:29:42.021197	2025-10-19 02:29:42.021197
fa649574-f688-42b1-a987-db77e401665f	TARRITO ROJO 25G	7702560042744	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:42.021575	2025-10-19 02:29:42.021575
f78407d0-2018-4a1d-97de-acb495fc30d0	JET COOKIES AND CREAM 11GR	7702007045444	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.021849	2025-10-19 02:29:42.021849
a42b56fe-2a56-4e9e-b74c-2b547fbe8ff3	SUB MARINO FRESA 70GR	7705326053329	t	2600.00	2450.00	\N	\N	19.00	2025-10-19 02:29:42.022197	2025-10-19 02:29:42.022197
b78bc06b-6d9a-418a-b51a-1b074a670b0a	POQUE RAMO VINO X6UNID	7702914599375	t	7500.00	7400.00	\N	\N	19.00	2025-10-19 02:29:42.022464	2025-10-19 02:29:42.022464
f09d16aa-d7b9-4335-8364-5c6930d3dea0	CAFE GALAVIS EXTRA TOSTADO 500GR	7702182000382	t	16700.00	16400.00	\N	\N	5.00	2025-10-19 02:29:42.022727	2025-10-19 02:29:42.022727
e663d822-86ad-4210-9120-ea66b668b340	QUESO COSTEÑO 450GR	3DS584GF	t	11800.00	\N	\N	\N	0.00	2025-10-19 02:29:42.023014	2025-10-19 02:29:42.023014
eb24a06e-fb4e-4ab4-9450-8c7b9fc76bad	PILAS D TRONEX	DS54GF3	t	5200.00	4950.00	\N	\N	19.00	2025-10-19 02:29:42.023297	2025-10-19 02:29:42.023297
06c6fc59-aa93-4575-aad8-9eac4e6b9d57	MASAS LISTAS SUPER MASAS X15UNID 500GR	3514DSAF3	t	3500.00	3300.00	3300.00	\N	0.00	2025-10-19 02:29:42.023627	2025-10-19 02:29:42.023627
c517bed8-b55d-4b7a-b985-6b3de44d7283	PIN POP GIGANTE MORAZUL X24UNID	7702174085588	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.023913	2025-10-19 02:29:42.023913
280ca06d-cc22-4509-8566-8d5f3fa3256d	COLADOR DE CAFE MEDIANO	COLADOR	t	1200.00	1000.00	\N	\N	19.00	2025-10-19 02:29:42.024226	2025-10-19 02:29:42.024226
19c64ffd-5a0a-4456-a9b5-c7ef253acb76	JABON LIQUIDO MI DIA FRUTOS ROJOS 500ML	7705946641036	t	5700.00	5500.00	\N	\N	19.00	2025-10-19 02:29:42.024495	2025-10-19 02:29:42.024495
f0d280d2-dd1c-4953-9849-3feb6960029b	JABON LIQUIDO MI DIA AVENA 500ML	7705946641050	t	5700.00	5500.00	\N	\N	19.00	2025-10-19 02:29:42.024758	2025-10-19 02:29:42.024758
3c718a13-466a-4391-989e-62889c41433c	ACEITE OLEOFLOR 900ML	7707170120325	t	8800.00	8500.00	\N	\N	19.00	2025-10-19 02:29:42.025031	2025-10-19 02:29:42.025031
6b8375da-ed25-4dcb-8826-50cde53e4e3f	JABON BUBU CREMOSO BABY 110G	7704269800403	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:42.02529	2025-10-19 02:29:42.02529
c8777aaa-3258-404e-a834-5435ce1c5bf4	ELIMINA OLORES FAMILIA40ML	7702026180621	t	3400.00	3250.00	\N	\N	19.00	2025-10-19 02:29:42.02561	2025-10-19 02:29:42.02561
5fd06faf-ee0f-4f8b-991f-e43ff94524c3	SALSERO SILINDRO	7707316671285	t	2700.00	2600.00	\N	\N	0.00	2025-10-19 02:29:42.02588	2025-10-19 02:29:42.02588
abc9e83d-ece0-4ffa-afcf-d38877e9f49e	COLGATE LUMINOUS WHITE  50ML	7509546062471	t	10800.00	10300.00	\N	\N	19.00	2025-10-19 02:29:42.026149	2025-10-19 02:29:42.026149
4fdce264-04cd-4248-8e15-269b31ad65d9	ESPONJA VERDE EL REY	3F4D5HH4D53	t	300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.026393	2025-10-19 02:29:42.026393
e333a763-fa45-4ec4-84f7-8650f075e49d	ESPONJA FIBRA DURAMAX EL REY X2UNID	7707178730083	t	3000.00	2850.00	\N	\N	19.00	2025-10-19 02:29:42.026595	2025-10-19 02:29:42.026595
f9eb8c36-b656-4261-9043-a2a5e4fc1079	SEVILLETERO MUNDO UTIL WENGUEN	7709945064957	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:42.026844	2025-10-19 02:29:42.026844
6e22f145-9a0f-4cbd-8af8-8c37d0e261f6	GELATINA DE LA ABUELA X3UNID	7707287464152	t	3900.00	3750.00	\N	\N	19.00	2025-10-19 02:29:42.027092	2025-10-19 02:29:42.027092
3f8af673-271e-4f5a-9310-69846efc81bc	ESPONJA MALA	8584D1SGF35SW	t	500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.027321	2025-10-19 02:29:42.027321
6a9107bc-dd0a-4145-b0b2-db9b129de0df	ESCOBA LIMPIA TELARAÑA	FDSG4385	t	7800.00	7500.00	\N	\N	19.00	2025-10-19 02:29:42.027548	2025-10-19 02:29:42.027548
18d0d60c-4ffd-4e23-b34a-91905f40a4a1	PORTAL J1	35SD41G3	t	400.00	375.00	\N	\N	19.00	2025-10-19 02:29:42.02777	2025-10-19 02:29:42.02777
fe702307-0cd6-4151-a880-0974f6de47ff	LECHE CONDENSADA TETERO EL ANDINO 1L	7709352957163	t	12800.00	12400.00	\N	\N	0.00	2025-10-19 02:29:42.028041	2025-10-19 02:29:42.028041
76f4288e-92e8-4bf1-b7f7-950c78bc9f9a	REDONDITAS BLACK 4X12	7707323130652	t	8300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.028274	2025-10-19 02:29:42.028274
55973ae7-26e4-45ab-a0d0-b8c783f126ad	BOLIGRAFO LAPICERO OFFI ESCO SEMIGEL	BOLI547FSA	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.028499	2025-10-19 02:29:42.028499
74ae7acd-c43e-47bf-b249-0f18fd5e3024	SCOTT 2 EN 1  X2UNID	7702425627635	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:42.028723	2025-10-19 02:29:42.028723
ccd9f237-3fd5-4629-bfd2-77ea158af1e4	LECHE EL RODEO 375GR	7702024402831	t	17300.00	16700.00	\N	\N	0.00	2025-10-19 02:29:42.029001	2025-10-19 02:29:42.029001
8108bcfb-9956-441e-85ec-e9acd19848b3	KLIM CLASICA 120GR	7702024226390	t	7000.00	6800.00	\N	\N	0.00	2025-10-19 02:29:42.029243	2025-10-19 02:29:42.029243
551c9861-77ce-44a5-9a5b-0acac267991a	SALTITACOS X5UNID	7707323130058	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.029474	2025-10-19 02:29:42.029474
64c8800b-371e-40f3-a051-9a1829800c4c	CHORIZO JALAPEÑO COLANTA X20UNID	7702129072014	t	14300.00	14000.00	\N	\N	19.00	2025-10-19 02:29:42.029719	2025-10-19 02:29:42.029719
b334b055-8a67-4b84-8732-a34bff4c8b2e	PRACTIS CON SAL ESPARCIBLE 200GR	7701018006949	t	3900.00	3730.00	\N	\N	19.00	2025-10-19 02:29:42.030004	2025-10-19 02:29:42.030004
01507ce1-ea73-43c3-8a1a-ca6bcd4e1d6d	RAYOL INSECTICIDA CUCARACHA HORMIGAS 400ML	7702532863148	t	14000.00	13700.00	\N	\N	19.00	2025-10-19 02:29:42.030394	2025-10-19 02:29:42.030394
33fdb0a4-c070-4fb5-b0d4-862887e7e7e0	RAYOL INSECTICIDA VOLADORES 400ML	7702532863155	t	12200.00	11750.00	\N	\N	19.00	2025-10-19 02:29:42.030647	2025-10-19 02:29:42.030647
7ce443f8-e251-40d1-a61e-8c1b7babd0aa	RAYOL INSECTICIDA VOLADORES BOTANICAL 300ML	7702532754804	t	12200.00	11750.00	\N	\N	19.00	2025-10-19 02:29:42.030926	2025-10-19 02:29:42.030926
6a8fd3c5-1ee8-48be-905a-b911b9743119	PAPAS MARGARITAS NATURAL 42G	7702189058409	t	2400.00	2250.00	2180.00	\N	19.00	2025-10-19 02:29:42.031214	2025-10-19 02:29:42.031214
b5a188b2-d04d-4b47-b6a9-bc3eb88bc7f9	SUAVITEL MANZANA VERDE 430ML	7509546689043	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:42.031814	2025-10-19 02:29:42.031814
469dfea9-2a5e-449b-a5e8-c70ca1470d15	ARROZ GRANOS LEO 1.000GR	7702948125380	t	3700.00	3667.00	\N	\N	0.00	2025-10-19 02:29:42.032201	2025-10-19 02:29:42.032201
e3e0a1a5-6ba4-4712-8452-9bc59631d333	TOCINETA CIFUENTES AHUMADA 180GR	G34SD3G	t	6700.00	6550.00	\N	\N	0.00	2025-10-19 02:29:42.032621	2025-10-19 02:29:42.032621
be5cd7e3-2fac-444f-a9c5-c6c8abf42dec	GENOVAS DE RES X10	7709210921619	t	6700.00	6600.00	\N	\N	19.00	2025-10-19 02:29:42.032885	2025-10-19 02:29:42.032885
f8e07c69-e896-445c-932c-b30eaf8309ea	SALCHICHON SERVECERO AHUMADO CIFUENTES 500GR	DS6G416S	t	9400.00	9200.00	\N	\N	0.00	2025-10-19 02:29:42.033155	2025-10-19 02:29:42.033155
2a61ff75-709d-4785-a80a-024a66100676	MECHERA SWISS ELECTRICA	7707822756759	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.03364	2025-10-19 02:29:42.03364
f898764f-58f1-47f6-b965-4789f66c58e1	NOSOTRAS INVISIBLE RAPIGEL X10UNID	7702027416330	t	4800.00	4600.00	\N	\N	0.00	2025-10-19 02:29:42.034471	2025-10-19 02:29:42.034471
b2cf1c1d-fc9a-4d97-b158-50dc91f3906d	TOALLITAS PEQUEÑIN ALOE VERA 100UNID	7702026313814	t	11700.00	11350.00	\N	\N	19.00	2025-10-19 02:29:42.035197	2025-10-19 02:29:42.035197
437eb6b7-7b50-4357-a8cf-5297305eaf97	GALLETA COCO 80GR	7708326232183	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.035647	2025-10-19 02:29:42.035647
0c88a9ca-2671-4bae-9c7b-c547a14a3289	SALTIN NOEL INTEGRAL 3 TACOS 415GR	7702025189243	t	9000.00	8790.00	\N	\N	19.00	2025-10-19 02:29:42.03591	2025-10-19 02:29:42.03591
fcd22b57-3c85-4a15-907b-b285845ff7e8	CARNE PARA HAMBURGUESAS CIFUENTES	7707907447268	t	8800.00	8700.00	\N	\N	19.00	2025-10-19 02:29:42.03623	2025-10-19 02:29:42.03623
43134e3e-7ba2-4811-8ed8-e4a467cd2bea	SHAMPOO TIO NACHO MAS ACONDICIONADOR 415ML	650240034176	t	50500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.036553	2025-10-19 02:29:42.036553
5b56e5bd-25bc-43a2-9f40-6a4d9816e4cc	JAMON AHUMADO CIFUENTES 500GR	7707907447596	t	8300.00	8200.00	\N	\N	19.00	2025-10-19 02:29:42.036775	2025-10-19 02:29:42.036775
2e82275c-a6c9-44a6-a207-85e22824990b	SALTIN NOEL QUESO MANTEQUILLA 3 TACOS	7702025148110	t	8500.00	8300.00	\N	\N	19.00	2025-10-19 02:29:42.037064	2025-10-19 02:29:42.037064
82a9f1d4-0e8d-450d-872b-671cdfc59178	COLCAFE CLASICO 170GR MAS CAPPUCCINO X9	7702032117307	t	21000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.037335	2025-10-19 02:29:42.037335
4688131f-4aee-4028-9121-94eb7a9894a5	COLCAFE GRANULADO 170GR MAS CAPPUCCINO X9	7702032117314	t	22000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.037555	2025-10-19 02:29:42.037555
54c77edf-eba7-4f0a-a9d9-e21b5a1e101b	AK1 FLORAL 800GR	7702310047333	t	8200.00	8050.00	\N	\N	19.00	2025-10-19 02:29:42.03782	2025-10-19 02:29:42.03782
25b27e9b-ed15-4f02-b712-8a508872bce3	DURAZNO EN ALMIBAR IDEAL 520GR	7709926508210	t	5100.00	4900.00	\N	\N	19.00	2025-10-19 02:29:42.038143	2025-10-19 02:29:42.038143
6b8b40f1-eddb-4e17-9b8d-6df3f80151d5	TALCO BARBERS 600GR	7708440339034	t	4800.00	4500.00	\N	\N	19.00	2025-10-19 02:29:42.038381	2025-10-19 02:29:42.038381
3127bfc4-69ba-4594-b222-fb0312597993	GALLETAS NAVIDEÑAS MI DIA 210GR	7701023593731	t	3300.00	3150.00	\N	\N	19.00	2025-10-19 02:29:42.038647	2025-10-19 02:29:42.038647
eee78ca6-5c8f-4309-be62-3b98e5ad4e03	VELAS DE VOLCAN	32DSA45FG3	t	1400.00	1200.00	\N	\N	19.00	2025-10-19 02:29:42.038887	2025-10-19 02:29:42.038887
c73b6e82-80ba-4438-aead-44c07054b38a	LINTERNA MILITAR GRANDE	564DS1AA3FG	t	16000.00	15500.00	\N	\N	19.00	2025-10-19 02:29:42.039111	2025-10-19 02:29:42.039111
4a899b13-740d-49d8-8fb0-5a9c768186b4	ACEITE JUHNIOR 50ML	7709257000131	t	3500.00	3200.00	\N	\N	0.00	2025-10-19 02:29:42.039356	2025-10-19 02:29:42.039356
0c5102ba-0c38-4024-b3a3-16c3409267ef	SILICONA SPRAY JUHNIOR 30ML	63SDF41G35R	t	5200.00	4800.00	\N	\N	19.00	2025-10-19 02:29:42.039688	2025-10-19 02:29:42.039688
70bc8e06-7d3f-4db1-8dfb-4a51de828d9b	SHAMPOO JUHNIOS CEBOLLA 30GR	7708621630837	t	1600.00	1480.00	\N	\N	19.00	2025-10-19 02:29:42.039914	2025-10-19 02:29:42.039914
85f67a0a-1706-4f85-a0cb-d6da255a75c1	SHAMPOO JUHNIOS ROMERO 30GR	7708621630431	t	1600.00	1480.00	\N	\N	19.00	2025-10-19 02:29:42.040166	2025-10-19 02:29:42.040166
d8970d66-bff6-470a-8b3b-55039315d27d	SHAMPOO ALMACE PARA NIÑOS GIRASOÑ 900ML	701575315567	t	9800.00	9500.00	\N	\N	19.00	2025-10-19 02:29:42.040416	2025-10-19 02:29:42.040416
a30c45a3-3316-4df1-9e0e-f6904c3595e5	PASTILLA VICK FORT 9 CAPSULA	63S8D41G3	t	2000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.040709	2025-10-19 02:29:42.040709
ca7e3c1c-5de4-4649-b487-f91fc6b66a3d	LAPICERO OFFI ESCO SEMIGEL	5SD1GF3	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.040966	2025-10-19 02:29:42.040966
6e06e7be-9534-4012-83b0-2f0386ef3c14	KOLA GFRANULADA 25GR	7702057737450	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.041252	2025-10-19 02:29:42.041252
1b85708e-c3fe-402a-bce6-84d44b41bb7e	BONAIRE ELECTRICO CON REPUESTO 25ML	7702532312394	t	14700.00	14200.00	\N	\N	19.00	2025-10-19 02:29:42.04151	2025-10-19 02:29:42.04151
8358aca7-61dc-497b-b625-aeb08f4672db	AK1 MANZANA VERDE 800GR	7702310047326	t	8200.00	8050.00	\N	\N	19.00	2025-10-19 02:29:42.041781	2025-10-19 02:29:42.041781
a522f897-bdeb-4757-af8d-735324015d6c	LAK PROTECCION ANRIBAC 110G	7702310020893	t	1800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.042036	2025-10-19 02:29:42.042036
5ae60ea5-314e-4a92-8811-85700753b323	TRULULU ARCOITIS 80GR	7702993045763	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:42.042312	2025-10-19 02:29:42.042312
57c8050c-c71b-4815-ad23-1cb0106cadca	OKA LOKA FUSION 14GR	7702993019573	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.042689	2025-10-19 02:29:42.042689
d1ffff17-158a-4a82-b23e-e720717a8958	JUMBO FLOW 18GR	7702007040227	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.04295	2025-10-19 02:29:42.04295
0206141e-a731-4772-a049-e21bb26df873	BIG BOM YOGUR MORA XXL X48	7707014950392	t	15700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.043227	2025-10-19 02:29:42.043227
3d37df9b-9052-42fe-abb3-3fb2be32af10	POOL COLA 1L	7709769790834	t	2200.00	1917.00	\N	\N	19.00	2025-10-19 02:29:42.043482	2025-10-19 02:29:42.043482
49859be3-3208-4af6-ac35-1be8cff30a98	PALMOLIVE RENOVACION INTENSA 110G	7509546677002	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.043749	2025-10-19 02:29:42.043749
494d73f8-fcfa-4ccf-8267-823937f06630	CHOCOLATE SAN JOSE 500GR	7707342420406	t	8200.00	8000.00	\N	\N	5.00	2025-10-19 02:29:42.044004	2025-10-19 02:29:42.044004
4f5325e3-ec3f-4c7a-b8b4-84df7877fb21	LISTERINE COOL MINT 500ML	7891010974336	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:42.044289	2025-10-19 02:29:42.044289
9586ac80-e4ff-4ccb-acb5-fc5f97d4ffe7	BIANCHI CARAMELO MANI X12 300GR	7702993047996	t	9400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.044544	2025-10-19 02:29:42.044544
b9f04e4f-aefd-4618-8b14-d04a67df623b	BIANCHI CARAMELO CHOCOLATE X12 300	7702993047972	t	9400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.044894	2025-10-19 02:29:42.044894
26ac279d-1176-42a4-8fb2-5bde372d5cc1	PAPAS MARGARITA POLLO	7702189000170	t	1900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.045204	2025-10-19 02:29:42.045204
33c40d5c-54cc-4f91-8dd1-3bc273df97ce	CEPILLO TOP ORAL VIAJERO	7450077031002	t	3500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.04548	2025-10-19 02:29:42.04548
4b4ac8ab-584c-41eb-999c-fecf4694532e	TRIDENT SANDIA 5.1G	7702133862854	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.045761	2025-10-19 02:29:42.045761
4b935b79-fb4c-4931-84f8-f183b5dd1458	NUTRIT RESTAURAMAX SIN SAL	7702277866770	t	17500.00	17000.00	\N	\N	19.00	2025-10-19 02:29:42.045992	2025-10-19 02:29:42.045992
c9afd9ff-37e1-419e-adfa-54dfdf1e7cc0	BON BON BUM BARRA 40UNID	7702011148247	t	8600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.046272	2025-10-19 02:29:42.046272
01391972-a70b-4a52-991b-1c642ae74752	TINTE KERATON 7.66	7707230996143	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.046542	2025-10-19 02:29:42.046542
bd0212eb-a0c2-44f9-80fc-84e550891b57	TINTE KERATON 7.2	7707230996099	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.046838	2025-10-19 02:29:42.046838
1edc3f42-febc-472d-9327-c2f5d8d24106	TINTE KERATON 3.0	7707230995986	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.047126	2025-10-19 02:29:42.047126
65895414-f5bf-47dc-9052-9a5d746c97a2	TINTE KERATON 8.2	7707230996181	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.047413	2025-10-19 02:29:42.047413
1a95dc88-f81c-47ed-bcb3-da68100980f7	TINTE KERATON 1.0	7707230995962	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.047673	2025-10-19 02:29:42.047673
46adec5a-3cc7-4484-bec0-c46a5e4d9388	TINTE KERATON 8.1	7707230996174	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.04799	2025-10-19 02:29:42.04799
3af701db-76bf-4075-8777-7d25e7a87f64	TINTE KERATON 9.1	7707230996211	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.048253	2025-10-19 02:29:42.048253
211b4537-990a-4ba6-ad56-d8340c5cbafb	TINTE KERATON 7.89	7707230996150	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.048494	2025-10-19 02:29:42.048494
13d554cd-6aa9-4fca-a389-d7d45e24644d	TINTE KERATON 7.3	7707230996105	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.048717	2025-10-19 02:29:42.048717
4b2203a2-6759-48e3-be0c-81a1648b06f1	TINTE KERATON 7.1	7707230996082	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.048931	2025-10-19 02:29:42.048931
77dc80c5-d4f1-461e-ad02-5f3a0784a3f0	TONO SOBRE TONO GRIS PLATA	7709990812992	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.049166	2025-10-19 02:29:42.049166
f1237701-f800-4504-bf24-9254e0f53238	TONO SOBRE TONO AZUL	7709990812909	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.049397	2025-10-19 02:29:42.049397
41dcb847-7960-47df-bb95-7609d3435bf5	TONO SOBRE TONO BEIGE PERLA	7709990268485	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.04963	2025-10-19 02:29:42.04963
3971703b-b8b5-4b8a-885d-03878ef01bdf	TONO SOBRE TONO BLANCO	7707197601319	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.04986	2025-10-19 02:29:42.04986
b94158a5-0d64-4d0e-84e7-b559abc14596	TONO SOBRE TONO ROJIZO	7709990812923	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.050215	2025-10-19 02:29:42.050215
861aef0b-fbf8-487e-8d6d-a71761e7de75	TONO SOBRE TONO MAGNETA	7709990218176	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.050745	2025-10-19 02:29:42.050745
80e8c430-daa4-4998-9ad9-3be5af059b8f	JABON INTIMO INTIBON VINAGRE MANZANA 120GR	7702277094692	t	11500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.051056	2025-10-19 02:29:42.051056
c051c368-abfb-43b3-8861-11ea83c495a0	LIMPIA HORNOS Y ESTUFAS FROTEX 150GR	7702210002012	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.051351	2025-10-19 02:29:42.051351
a6420c82-4e70-4d6e-a44e-b96628ae3e2f	SHAMPOO EL VIVE LOREAL PARIS 680ML	7509552843033	t	29000.00	28000.00	\N	\N	19.00	2025-10-19 02:29:42.051683	2025-10-19 02:29:42.051683
ffb64bd4-5757-4aa2-852c-3a0e62d5b239	COLCAFE GRANULADO INTENSO JARRA 100GR	7702032110360	t	14000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.051967	2025-10-19 02:29:42.051967
5279f3ca-8787-40ed-b20e-088eb66aecfb	REPELENTE PARA PERROSPETS	7707370059838	t	11800.00	\N	\N	\N	0.00	2025-10-19 02:29:42.05219	2025-10-19 02:29:42.05219
ab3d1dd3-6b8b-467d-938c-cdb31bb4f8a7	TOSH CACAO EN POLVO 200GR	7702007069686	t	4900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.052436	2025-10-19 02:29:42.052436
dc66c8e2-1fe2-4ca8-8ae7-0a2fefa1135d	FAMILIA MEGA ROLLO ACOLCHAMAX X4UNID	7702026147488	t	9600.00	9300.00	\N	\N	19.00	2025-10-19 02:29:42.052659	2025-10-19 02:29:42.052659
c2de8246-b982-4346-983e-e5e14b35682b	ESTUCHE ARRURRU SHAMPOO CREMA COLONIA JABON	7702277198208	t	44000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.052896	2025-10-19 02:29:42.052896
b4b2db95-8aa3-4d44-840c-58b94c1d8a1f	VITU LOCION CORPORAL AVENA 1L	7702044284318	t	17900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.053108	2025-10-19 02:29:42.053108
9118753d-9948-4c80-abd0-bde851c64011	DUCALES 3TACOS 360GR	7702025126774	t	8500.00	8350.00	\N	\N	19.00	2025-10-19 02:29:42.053323	2025-10-19 02:29:42.053323
a64fe041-ca7a-41dd-9ec4-db55c2f5c8f5	JARABE ACETAMINOFEN KIDS	7704412015036	t	3300.00	3000.00	\N	\N	0.00	2025-10-19 02:29:42.053537	2025-10-19 02:29:42.053537
436d9894-43a6-4119-a8e0-97f3fda06d5b	VINO LA GRAN COSECHA 750ML	7707753252153	t	4000.00	3584.00	\N	\N	0.00	2025-10-19 02:29:42.053765	2025-10-19 02:29:42.053765
04721eae-bb13-470a-bf23-55598fb0862d	CHAMPAÑA LA GRAN COSECHA 750ML	7708727221373	t	5500.00	5000.00	\N	\N	0.00	2025-10-19 02:29:42.053967	2025-10-19 02:29:42.053967
16bbae1e-a346-4cba-b264-111fa52924f6	NAPROXENO	DS634GS	t	400.00	320.00	\N	\N	0.00	2025-10-19 02:29:42.054189	2025-10-19 02:29:42.054189
a42916f9-2bfd-4dcd-a2ce-8dd079335aae	PRESTOBARBA GILLETE MACH3 MAS REPUESTO	7500435141512	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.054421	2025-10-19 02:29:42.054421
a91b122e-7e91-4d4e-a6dc-82928c041068	PONDS LIMPIADOR FACIAL DIARIO 50GR	7702006301480	t	11000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.054648	2025-10-19 02:29:42.054648
2ab0c8af-b14b-4547-a25e-8c6ef9e796d2	CHOCLITO LIMON MINI 27G	7702189058584	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.054847	2025-10-19 02:29:42.054847
ab654afe-3fd6-41fe-a63e-2a20f4fa9ac3	LABIAL MAGICO	SDFGPL	t	1500.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.055085	2025-10-19 02:29:42.055085
7cf1e14b-176f-4f99-833b-976294e1dab9	MOLI ACTIVA GO 50GR	7702024738077	t	2100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.055478	2025-10-19 02:29:42.055478
83666769-1edf-4efe-b0a1-640f7a9a9a4b	LIMPIAVIDRIOS SKAAP 500ML	7707371213987	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:42.055776	2025-10-19 02:29:42.055776
03256b9e-a415-4507-a369-677bfe2f337c	MANJAR BLACO AJEDREZ X16 UND	7707283881601	t	6700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.05601	2025-10-19 02:29:42.05601
eee74aac-97b9-43f8-8d0d-bd59c6f89b7f	MILO ACTIVA GO 20GR	7702024110187	t	1000.00	830.00	\N	\N	19.00	2025-10-19 02:29:42.056302	2025-10-19 02:29:42.056302
6d17adb2-d3e0-4bcf-858d-6aa7c6daea72	ATUN VIKINGO RALLADO EN ACEIE 160GR	7702088209896	t	4400.00	4230.00	\N	\N	19.00	2025-10-19 02:29:42.056581	2025-10-19 02:29:42.056581
8b09ab09-9125-4f8a-b3a4-93b38b91ed7f	ATUN VIKINGO LOMOS ACEITE DE GIRASOL 160GR	7702088204297	t	7300.00	7100.00	\N	\N	19.00	2025-10-19 02:29:42.056827	2025-10-19 02:29:42.056827
c6e703f3-21f9-4964-b9f0-4c4795330139	LAK TOPICAL X3UNID 330GR	7702310020930	t	5300.00	5150.00	\N	\N	19.00	2025-10-19 02:29:42.05706	2025-10-19 02:29:42.05706
6e3f4e46-5271-43ff-b512-393d0eca0314	FRUNAS DUO COLOR	7702174077712	t	6800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.057349	2025-10-19 02:29:42.057349
55077adf-5c49-4a6f-94d0-dfdd17331288	GALLETAS NAVIDEÑAS RICOSTUMBRES 180GR	7707345590267	t	3700.00	3600.00	\N	\N	19.00	2025-10-19 02:29:42.057625	2025-10-19 02:29:42.057625
9fe79bc6-c580-4880-aaa5-139230d21af8	SALSA DE AJO BARY 165GR	7702439006815	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:42.057885	2025-10-19 02:29:42.057885
bdde09f0-d09e-434f-a65f-7b6c7159b1a2	SARDINA LA SOBERANA EN ACEITE 425GR	7702910839000	t	9200.00	8950.00	\N	\N	19.00	2025-10-19 02:29:42.058153	2025-10-19 02:29:42.058153
449fbf03-42dc-4edf-a591-a7d31b41ada7	REDONDITA CHOCOLATE UND	7707323130430	t	600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.058418	2025-10-19 02:29:42.058418
1ba0041d-743b-4b2d-81df-aad9ac3efa6d	TENA SLIP CLASICO L X30UNID	7702026174668	t	74000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.058685	2025-10-19 02:29:42.058685
d85665a5-8fd0-4e2f-a7df-e59bd2ea8be8	ROSAL ULTRACONFORT XXG X3UNID	7702120013894	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.058954	2025-10-19 02:29:42.058954
cdebd5f4-7236-406a-99a0-e1528c4fde4c	VELEÑITA COCOMAR X12U	7707283880437	t	9500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.059224	2025-10-19 02:29:42.059224
1eaec76d-e24c-478b-bd0c-8f574bb5cca2	RIGATONI DORIA 250	7702085012420	t	2200.00	\N	\N	\N	5.00	2025-10-19 02:29:42.059502	2025-10-19 02:29:42.059502
cc712f6c-c1e4-4306-8f9e-290b8c3f35ce	NOSOTRAS NOCTURNAS BUENAS NOCHES X10UNID	7702026149567	t	11500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.059754	2025-10-19 02:29:42.059754
ff790366-9bf2-40d4-93b0-db0cf4d3100e	CREMA DE ARROZ PRIMO 450GR	7591002100117	t	5700.00	5500.00	\N	\N	0.00	2025-10-19 02:29:42.060013	2025-10-19 02:29:42.060013
86efabda-956b-4cad-986d-f5e8e694dca5	COMBO DEVOE SHAMPOO ACONDICIONADOR	DSG65WS8	t	25500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.060309	2025-10-19 02:29:42.060309
d9d20842-9e99-4302-b614-316749224be3	LAK BEBE X3 CON MANZANILLA	7702310020947	t	5300.00	5150.00	\N	\N	19.00	2025-10-19 02:29:42.060516	2025-10-19 02:29:42.060516
1965db53-1ae1-4b1b-8f42-b0986ace718c	DORITOS QUESO 43GR	7702189060549	t	2600.00	2500.00	2390.00	\N	19.00	2025-10-19 02:29:42.060779	2025-10-19 02:29:42.060779
881a4e13-170d-46e3-80f0-4752b9a886e8	MONTE RES BOLOGÑA	734191414437	t	8100.00	7750.00	7500.00	\N	19.00	2025-10-19 02:29:42.061104	2025-10-19 02:29:42.061104
1a41bf63-32b9-4dc4-9966-46994ba34e20	HUEVO SORPRESA	7709225119957	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.06137	2025-10-19 02:29:42.06137
e42cf299-2ca9-4d54-bf78-9c10b1a11f54	ACEITE RIQUISIMO 1 LITRO	7701018007519	t	9400.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.061624	2025-10-19 02:29:42.061624
9ee9f228-00a1-4ff1-b929-32e5f0b5cb3c	MASMELOS ANGELITOS 150GR	760203006000	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:42.062087	2025-10-19 02:29:42.062087
4f33d4f4-2c00-4192-b34e-21751a03d74e	MERMELADA COUNTRY HILL MORA 200GR	7702402057288	t	3500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.062377	2025-10-19 02:29:42.062377
6b5f1a45-1a9e-43eb-9b94-77058ec07957	BOLSA GELATINA JELLY DRINK X3UNIDR	7709990238594	t	1300.00	1250.00	\N	\N	19.00	2025-10-19 02:29:42.062665	2025-10-19 02:29:42.062665
ef91a2d1-4b6c-416d-bf37-e6a080ae41be	ATUN SABOR PACIFICO 175GR	7862119502461	t	3700.00	3550.00	\N	\N	19.00	2025-10-19 02:29:42.062942	2025-10-19 02:29:42.062942
a39ccb94-fd90-47c2-a1cb-b530da641df6	MOSTAZA LA CONSTANCIA 190GR	7702097148612	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.063187	2025-10-19 02:29:42.063187
f7e12512-f3e4-4b01-9021-4af089de18f9	SALSA TARTARA LA CONSTANCIA 190GR	7702097137746	t	6600.00	6450.00	\N	\N	19.00	2025-10-19 02:29:42.063437	2025-10-19 02:29:42.063437
354d8bbc-50d7-4600-a5b7-a39e168a7532	HARINA PAN DE CHOCLO 120GR	7702084138022	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:42.063707	2025-10-19 02:29:42.063707
eec08d1c-1107-4ff9-8e1d-50b9512f9562	ACEITUNAS RELLENAS CON PIMENTON  250GR	7009980000409	t	6000.00	5750.00	\N	\N	0.00	2025-10-19 02:29:42.063975	2025-10-19 02:29:42.063975
bb7d18a0-3bf0-4701-a9fb-40445e69bf92	ALCAPARRA EN VINAGRE 250GR	7009980000430	t	6000.00	5750.00	\N	\N	0.00	2025-10-19 02:29:42.064232	2025-10-19 02:29:42.064232
112d2ac6-a7bb-4bef-b41b-1afbb54e2c3e	ACEITUNAS RELLES DE PIMNTON 500GR	7009980000416	t	10800.00	10350.00	\N	\N	0.00	2025-10-19 02:29:42.064487	2025-10-19 02:29:42.064487
bb70003e-5977-4585-bdbb-fd1678634036	ALCAPARRA EN VINAGRE 500GR	7009980000447	t	10800.00	10350.00	\N	\N	0.00	2025-10-19 02:29:42.064741	2025-10-19 02:29:42.064741
4f1e94ac-5768-4463-b8c3-f1179b8e9802	ALCOHOL MK 120ML	7702057075057	t	2700.00	2550.00	\N	\N	0.00	2025-10-19 02:29:42.064974	2025-10-19 02:29:42.064974
5daf6b45-bdad-4473-b3c0-b0b9c32fb0ad	RAID ZANCUDOS Y MOSCAS 244G	7501032926168	t	13000.00	12500.00	\N	\N	0.00	2025-10-19 02:29:42.065294	2025-10-19 02:29:42.065294
cb099a33-f87d-4228-8217-e1f9873d9bdc	RAID MAX MATA CUCARACHA Y CHIRIPA 339GR	7501032926182	t	15500.00	15000.00	\N	\N	0.00	2025-10-19 02:29:42.065608	2025-10-19 02:29:42.065608
4d2702ec-0859-4369-80f3-89bf55f83251	ARIEL TRIPLE PODER  PODER 3.5GR	7500435140652	t	33400.00	32800.00	\N	\N	19.00	2025-10-19 02:29:42.065947	2025-10-19 02:29:42.065947
93bcaccb-b3ad-45f8-9f26-a1f9509519a2	PRESTOBARBA GILLETTE MACH3 AUA	7702018001071	t	15400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.066467	2025-10-19 02:29:42.066467
7426ee3a-1c17-41e0-bb44-319b0dddec20	FAB DETERGUENTE LIQUIDO 330GR BOTELLA	7702191451700	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.066943	2025-10-19 02:29:42.066943
0827597a-5114-4551-b080-b2a994241a91	SUPREMO JABON LAVAR COCO 180GR	7708669890590	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:42.067314	2025-10-19 02:29:42.067314
6d1c9ec6-21e6-4647-a082-3e1627961fb8	SALMON SABOR PACIFICO 155GR	7862119505806	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:42.067571	2025-10-19 02:29:42.067571
46d15fc0-7868-4a0c-9b8e-f0f7a5d52725	SHAMPOO MUSS KIDS MAS CREMA PARA PEINAR	7702113620559	t	24000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.067841	2025-10-19 02:29:42.067841
971e2cb1-0a11-4da2-9efd-0c99bcb5a207	MORITAS RELLENAS 100UNID	7702011050007	t	5700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.068088	2025-10-19 02:29:42.068088
34b10924-8f59-4ade-8c9e-ddd6dfd9ddfa	BOKA PIÑA	7702354032005	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.068364	2025-10-19 02:29:42.068364
ee82aacc-7514-4b23-8eae-3a8879c8ef1e	AZUCAR MANUELITA 1KG	7702406000143	t	4300.00	4240.00	\N	\N	5.00	2025-10-19 02:29:42.068629	2025-10-19 02:29:42.068629
8d9d0e55-69e6-4313-a4d5-3c6f10f6cac6	NUCITA CHOCOLATINA 240GR X12UNID	7702011126061	t	11600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.068929	2025-10-19 02:29:42.068929
57642d89-d9fb-47e2-9353-fcb534a68a2d	CRAKEÑAS SALTIN TACO 106G	7702011270504	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.069358	2025-10-19 02:29:42.069358
62092a3b-5939-44be-8f1d-fec26463515d	PATAS DE POLLO PARA PERRO LOPETS	2762184675914	t	5900.00	\N	\N	\N	0.00	2025-10-19 02:29:42.069647	2025-10-19 02:29:42.069647
bb260ecc-0ffc-488d-bc31-dc6ac5f5b833	SHAMPOO PARA MUEBLE FROTEX 500ML	7702210050297	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.069887	2025-10-19 02:29:42.069887
1be916b1-29db-4371-80f7-5fe12214c642	JABON INTIMO INTIBON CALENDULA 210GR	7702277532682	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.070325	2025-10-19 02:29:42.070325
1cedbab7-6035-488f-b808-f7cf5c964fad	LA ESPECIAL MIX CHOCOLATE 175GR	7702007052305	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.070575	2025-10-19 02:29:42.070575
8f486931-67ea-4f6b-8f91-28b236c70cf8	SAL REFISAL SALEROS 500GR	7703812002295	t	3600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.070882	2025-10-19 02:29:42.070882
7b70044a-57fe-4dd7-b5df-b1c0560697d3	ESCOBA DALIA EL SOL	SDGWRG	t	4800.00	4650.00	\N	\N	19.00	2025-10-19 02:29:42.071234	2025-10-19 02:29:42.071234
6120cfdd-eb7f-4416-86e7-071503b6c826	LORATADINA	SDGSDV	t	1600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.071624	2025-10-19 02:29:42.071624
f9db0063-e34b-44b3-94be-85a2b025db47	CETIRIZINA ECAR X10UNI	DSGFS	t	1200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.07194	2025-10-19 02:29:42.07194
b5285c07-84c1-425d-8916-e40dad8f8c13	ESPONJA ABRASIVA X3UNID	7707178730045	t	1200.00	1100.00	\N	\N	19.00	2025-10-19 02:29:42.072206	2025-10-19 02:29:42.072206
5f424f36-d734-4bac-b878-c6b2801ff35f	ACEITE MEZCLA VEGETAL Y OLIVA EXTRA OLIVETTO 5000ML	7702141004512	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.072442	2025-10-19 02:29:42.072442
86e5c2ba-55bc-416e-b11a-b56314bf72da	DELIKA PASTA CEBOLLA LARGA 110GR	7709990050790	t	3200.00	3050.00	\N	\N	5.00	2025-10-19 02:29:42.072713	2025-10-19 02:29:42.072713
37e6b952-eb13-4071-95b9-f0810f319139	GALLETA ITALO NAVIDAD 220GR	7702117011544	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.073016	2025-10-19 02:29:42.073016
a144bf86-173f-4eef-b9db-69bc899754b3	TOSH MIEL TACO DIA 209GR	7702025147090	t	3600.00	3500.00	\N	\N	19.00	2025-10-19 02:29:42.073244	2025-10-19 02:29:42.073244
fb57a6ca-9f5e-4d73-92bd-959fbef81cf4	JET WAFER CUDRITOS X12UNID	7702007081114	t	8900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.07352	2025-10-19 02:29:42.07352
b855c2ce-ae5c-4d17-9494-5cf74dde0d97	MONT BLANC BAILEYS X6UNID	7702007080063	t	22000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.07376	2025-10-19 02:29:42.07376
ff442732-6e25-4f78-ad63-e86dba4795d7	MONT BLANC BAILEYS 40GR	7702007080056	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.07399	2025-10-19 02:29:42.07399
ac33a7d1-41a1-4295-bcde-2134d3ac7186	BOM BON ITALO COOKIES I CREAM	7702117017157	t	4000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.074245	2025-10-19 02:29:42.074245
6746d305-a1cb-470f-878b-a934599da9c5	BOM BON COOKIES I CREAM ITALO	7702117117154	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.074518	2025-10-19 02:29:42.074518
c68a87d9-2e29-4c52-aac1-11e57781134b	ACEITE RIQUISIMO 1900ML	7701018056807	t	15000.00	14700.00	\N	\N	19.00	2025-10-19 02:29:42.074803	2025-10-19 02:29:42.074803
8cbb7cc2-b8bb-422e-ac9a-6b5704653375	ELITE MAX X24UNID	7707199344504	t	16800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.075084	2025-10-19 02:29:42.075084
b2808b5d-a48d-4889-936f-a73c8101628f	AGUA CRISTAL 1LITROS	7702090042054	t	1800.00	1625.00	\N	\N	0.00	2025-10-19 02:29:42.075356	2025-10-19 02:29:42.075356
65497fa5-87e8-4046-a5b5-32b26f7ef1fe	SUPREMO MULTIUSOS FRESCURA AZUL 340GR	7708669890842	t	2500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.07568	2025-10-19 02:29:42.07568
6dd9598a-884e-4ec9-b321-82155cb1fd2d	NATILLA MAIZENA TRADICIONAL 300GR	7702047037652	t	5400.00	5200.00	\N	\N	19.00	2025-10-19 02:29:42.075924	2025-10-19 02:29:42.075924
078ca177-403b-4722-bb65-b94391559e64	NATILLA MAIZENA AREQUIPE 300GR	7702047005095	t	5400.00	5200.00	\N	\N	19.00	2025-10-19 02:29:42.076197	2025-10-19 02:29:42.076197
22e04710-85af-40a5-9be3-696a82d165d2	SALTITACOS X3UNID	7707323130164	t	3700.00	3600.00	\N	\N	19.00	2025-10-19 02:29:42.076477	2025-10-19 02:29:42.076477
b60ce80c-f1d8-4a17-af0d-676fedbf9bdf	ALCAPARRAS EN VINAGRE 250GRALFRESCO	7702061402504	t	6600.00	6450.00	\N	\N	0.00	2025-10-19 02:29:42.076744	2025-10-19 02:29:42.076744
ed5abf30-7658-403d-99b1-12f9bdb8a748	ALCAPARRA EN VINAGRE ALFRESCO 500GR	7702061405000	t	11900.00	11550.00	\N	\N	0.00	2025-10-19 02:29:42.077111	2025-10-19 02:29:42.077111
55f8cce1-21bb-474c-b96b-274b17645c1f	ARVEJA  SUDEPENSA VERDE 500GR	7707309250107	t	2400.00	2300.00	\N	\N	0.00	2025-10-19 02:29:42.077355	2025-10-19 02:29:42.077355
e8bc8ac8-0d29-400b-b930-5efb87e0b52f	DSVG	DSGR58	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.077625	2025-10-19 02:29:42.077625
76a22a73-f17c-4047-b4e3-3842f08fb885	TOALLAS HEY LADY X8UNID	7707159835004	t	2100.00	2000.00	\N	\N	0.00	2025-10-19 02:29:42.077886	2025-10-19 02:29:42.077886
7da4615e-0660-41f2-a455-ef1601da5ad8	DESENGRASANTE SKAAP AROMA LIMON 500ML	7707371211877	t	4800.00	4650.00	\N	\N	19.00	2025-10-19 02:29:42.07813	2025-10-19 02:29:42.07813
3b7ab6e0-b394-4984-8715-ccadc0164973	MANJAR COCO X8UNID	7707283881366	t	6500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.078361	2025-10-19 02:29:42.078361
fbfa4ac1-a48f-43ca-b02c-0d7362fc8694	CREMA DE LECHE PARMALAT CAJA 1L	7700604004918	t	13800.00	13500.00	\N	\N	0.00	2025-10-19 02:29:42.078564	2025-10-19 02:29:42.078564
cee9e19c-3190-43c6-982a-3a6379aecb82	AROMATEL FLORAL 4 LITROS	7702191451922	t	23500.00	22900.00	\N	\N	19.00	2025-10-19 02:29:42.078854	2025-10-19 02:29:42.078854
69853554-f5b3-48b7-8e91-7c8bb3d31cbd	SHAMPOO AGRADO 750ML	8433295033187	t	9600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.079108	2025-10-19 02:29:42.079108
af05cec0-becc-48d0-92c0-17a82f09d41a	SUAVITEL VAINILLA 430ML	7702010282638	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:42.079318	2025-10-19 02:29:42.079318
a401e919-09a5-4bc2-a953-c55bacef3ffe	GILLETTE HYDRA GEL 82GR	7500435140591	t	17900.00	17400.00	\N	\N	19.00	2025-10-19 02:29:42.079567	2025-10-19 02:29:42.079567
3cf7527c-3a2d-4a89-bf8f-2990c8b47c7d	AMALFE CARE ROSA MOSQUERA GEL 750ML	8414227038036	t	9500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.07976	2025-10-19 02:29:42.07976
87258fa7-ced3-4eba-9a51-29d803472706	FAB LAVADO PERFECTO DETERGENTE 900ML	7702191661352	t	9000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.080063	2025-10-19 02:29:42.080063
6b715f7e-2e4a-4c35-b395-126bb9dd332c	ACEITE GOURMET FAMILIA 200ML	7702141858603	t	4200.00	\N	\N	\N	5.00	2025-10-19 02:29:42.080305	2025-10-19 02:29:42.080305
2958f35e-fb39-476f-ad81-8dbfa277c7c2	DURACELL COMBO POWER BANK	FG43WSF5	t	42800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.080605	2025-10-19 02:29:42.080605
e585a24f-6387-4388-b455-2ac89d4f9e6f	AZUCAR MORENA PROVIDNCIA KILO	7702104010338	t	4500.00	4320.00	\N	\N	5.00	2025-10-19 02:29:42.080869	2025-10-19 02:29:42.080869
c920e0ee-f3bc-425d-8d5d-68c1afbd30c1	SOBRE VITAMINA C	7703763001477	t	2500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.081117	2025-10-19 02:29:42.081117
9f36fb96-a9c6-4133-b6c5-50be5e2d7654	JUMBO MANI 24 UND X35GR	7702007080391	t	71500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.081381	2025-10-19 02:29:42.081381
939c603d-b5d5-47cc-b5fd-913243fa54c8	JUMBO MANI 12 UND X90GR	7702007080445	t	65000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.081724	2025-10-19 02:29:42.081724
04b7087f-2935-463e-83aa-76a8c863b56c	FRUTILALO ITALO 250GR X100UNID	7702117010196	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.081987	2025-10-19 02:29:42.081987
83331b4e-90c6-40e4-a193-0502a1ddf96d	SUPER RIEL LIQUIDO1.6LITROS	7702310043137	t	10000.00	9700.00	\N	\N	19.00	2025-10-19 02:29:42.082241	2025-10-19 02:29:42.082241
95771a6a-f335-48f3-8db7-28578f6a9043	3D LIQUIDO 1.8 MAS 250GR OFERTA	7702191451847	t	17500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.082542	2025-10-19 02:29:42.082542
e73fecc5-98d6-4d8a-b4bf-0ba279280ca8	TOALLAS ESBELTA X10UNID	7708971288658	t	2900.00	2750.00	\N	\N	0.00	2025-10-19 02:29:42.083132	2025-10-19 02:29:42.083132
f0ff468b-b907-4519-84b6-77fb397e69ec	TOALLAS ESBELTA X30UNID	7708971288641	t	8600.00	8325.00	\N	\N	0.00	2025-10-19 02:29:42.083587	2025-10-19 02:29:42.083587
9a1edaf8-5343-4462-aa2a-2fea82eabccc	DESODORANTE DOVE ORIGINAL 30ML	78931633	t	4000.00	3840.00	\N	\N	19.00	2025-10-19 02:29:42.083999	2025-10-19 02:29:42.083999
67813da5-9c3c-4427-b0a1-59b00b46926f	JABON LIQUIDO AMALFI ALOE VERA 750ML	8414227059833	t	13500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.084356	2025-10-19 02:29:42.084356
f81cc506-b20a-4931-bf6e-67e8aeba061d	SHAMPOO AMALFI 750ML	8414227679901	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.084609	2025-10-19 02:29:42.084609
0900457c-de43-4075-86e6-af623735f85e	LOCION CORPORAL AMALFI ALOE VERA 750ML	8414227059840	t	14500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.084868	2025-10-19 02:29:42.084868
6e75ad29-89da-4423-b46a-7050c59ee6a1	TOSTADO SABOR A MANTEQUILLA BIMBO X20UNID	7705326018694	t	7700.00	\N	\N	\N	0.00	2025-10-19 02:29:42.085175	2025-10-19 02:29:42.085175
937b986f-afae-4c91-9fe4-e756566f3152	TOSTADAS INTEGRA BIMBO X20UNID 300GR	7705326018717	t	7500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.085475	2025-10-19 02:29:42.085475
eda1400c-fb6c-4ccc-87e3-618f762c1f8a	CEREAL KELLOGGS CHOCORRAMO 32GR	7702103710574	t	2200.00	2100.00	\N	\N	0.00	2025-10-19 02:29:42.085795	2025-10-19 02:29:42.085795
d2b066a1-3846-4818-8111-1c49c57b6c5f	ACEITE IDEAL 200ML	7709385952890	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:42.08616	2025-10-19 02:29:42.08616
c7b348f6-b083-449c-a508-b593f8b6636c	ACEITE IDEAL 3 LITROS	7709990145403	t	22000.00	21550.00	\N	\N	19.00	2025-10-19 02:29:42.086497	2025-10-19 02:29:42.086497
5c34edfc-0871-45dd-afb3-3eebe451a43b	SHAMPOO PARA NIÑOS ALMAE 900 ML	701575315574	t	9800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.086812	2025-10-19 02:29:42.086812
31c67875-7a42-4900-bb49-cd6945234a29	AZUCAR MANUELITA 2.500GR	7702406000150	t	9600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.08715	2025-10-19 02:29:42.08715
aa481360-1d2a-4355-b30e-8d371f27019c	NATUMALTA X6UNID 400ML	7702090051612	t	12000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.087746	2025-10-19 02:29:42.087746
44225a2d-21d7-40df-b2a8-cd3132b62786	NATUMALTA 400ML	7707430873848	t	2400.00	2209.00	\N	\N	19.00	2025-10-19 02:29:42.088101	2025-10-19 02:29:42.088101
166839e0-5435-4d45-8d6c-e24eea0bce9e	FRUNAS DUOS 24UNID	7702174085557	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.088326	2025-10-19 02:29:42.088326
48e9dae9-ee1d-4ad7-9da5-7189078e2612	CEPILLO ANDECOL TIPO PLANCHA	7708304268050	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:42.088604	2025-10-19 02:29:42.088604
50952c6c-d32a-46be-83e8-ccbdf8581b14	SERVILLETA NUBE X150UNID	7707151600983	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:42.088925	2025-10-19 02:29:42.088925
d582de54-0f3e-42b5-b6b8-0fe779fce9ea	ACEITE IDEAL GIRASOL 430ML	7709535305187	t	3200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.089332	2025-10-19 02:29:42.089332
a9ddc6f9-5ab6-4575-9ee3-eba186e6d078	VINAGRE DE MANZANA REYES 500ML	7709857739660	t	6300.00	6000.00	\N	\N	19.00	2025-10-19 02:29:42.089669	2025-10-19 02:29:42.089669
a1a9e7dd-1f7a-4e6d-9a17-78b9ff907b28	PONDS REJUVENES 100GR MAS 50GR	7702006402699	t	25500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.089997	2025-10-19 02:29:42.089997
d8ccd055-78ef-4593-b8ed-68b77fab6ac1	GEL EGO ATTRACTION 60ML	7702006204040	t	2200.00	2050.00	\N	\N	19.00	2025-10-19 02:29:42.090366	2025-10-19 02:29:42.090366
f16fe190-7ec6-4a05-a14b-4a099803451c	FLIPS CHOCO AVELLANAS 120GR	7702807327504	t	4700.00	4550.00	\N	\N	19.00	2025-10-19 02:29:42.090637	2025-10-19 02:29:42.090637
c4dababb-38c2-4cef-bb56-77d2c549e7c8	ESCOBA DALIA DUO	DSGFSD5	t	5000.00	4850.00	\N	\N	19.00	2025-10-19 02:29:42.09089	2025-10-19 02:29:42.09089
bfa0edfb-5fed-4f5e-bb9e-8db4ebcf2b9f	CEBOLLITAS MEXICANA 75GR	7706642004330	t	4400.00	4300.00	\N	\N	19.00	2025-10-19 02:29:42.091326	2025-10-19 02:29:42.091326
edeb61ca-b14d-4a8e-8d87-ae7748d9ff97	CEBOLLITA MEXICANA 32GR	7706642008260	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:42.091587	2025-10-19 02:29:42.091587
14a2d634-0649-41da-918c-8a3bfd426743	CHICHARRON CARNUDO LA VICTORIA 75GR	7706642260743	t	8600.00	8400.00	\N	\N	19.00	2025-10-19 02:29:42.09181	2025-10-19 02:29:42.09181
7f006378-c378-49be-bafd-0ce4c51b83d6	CHICHARRON CARNUDO LA VICTORIA 75GR	7706642175573	t	8600.00	8400.00	\N	\N	19.00	2025-10-19 02:29:42.092027	2025-10-19 02:29:42.092027
1afde975-8b84-4151-a9f4-95911accf640	CHICHARRON CARNUDO LA VICTORIA X7UNID ORFERTA	7706642072636	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.092281	2025-10-19 02:29:42.092281
fd00f4cc-812e-4932-b82e-91afb47847b2	EXTRUCITO QUESO 60GR	7706642003128	t	1500.00	1450.00	\N	\N	19.00	2025-10-19 02:29:42.092523	2025-10-19 02:29:42.092523
ea5f0f6b-e4d7-4b17-ada6-fb5a3d7a3f8f	EXTROCITO CARAMELO 60GR	7706642000233	t	1300.00	1167.00	\N	\N	19.00	2025-10-19 02:29:42.092756	2025-10-19 02:29:42.092756
9c7364a9-6928-4f67-8a94-b2ef03bff32f	EXTROCITO PICANTE 60GR	7706642006044	t	1500.00	1450.00	\N	\N	19.00	2025-10-19 02:29:42.093085	2025-10-19 02:29:42.093085
947f6c2d-a0ac-42ed-aa3f-c87776bc4c23	EXTROCITO NATURAL 60GR	7706642025113	t	1300.00	1167.00	\N	\N	19.00	2025-10-19 02:29:42.093295	2025-10-19 02:29:42.093295
fb754094-cdaf-401b-96f4-56e88d4e20e9	REXONA CLINICAL MEN 60GR	7702006208024	t	6400.00	6250.00	\N	\N	19.00	2025-10-19 02:29:42.093506	2025-10-19 02:29:42.093506
9a85223e-57fb-4a52-b8e8-e95591c38f6a	PILAS MAXELL ALCALINA AAA	025215720734	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.093708	2025-10-19 02:29:42.093708
2d3a902c-8f4b-468e-8590-dc9891e54c42	PAÑAL RELY ADULTO L X20UNID	7709943332201	t	54500.00	53900.00	\N	\N	19.00	2025-10-19 02:29:42.093946	2025-10-19 02:29:42.093946
59b458fb-50ad-4f5d-938a-65d3ccdc017a	PLATOS DARNELL X20UNID 26CM	645667223821	t	5200.00	5050.00	\N	\N	19.00	2025-10-19 02:29:42.094173	2025-10-19 02:29:42.094173
fb04740f-ede0-4813-adda-0018754c015c	JABON REXONA 110G LIMPIESA	7702006405690	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:42.094423	2025-10-19 02:29:42.094423
2309ba37-ce5e-4976-8fa4-07d8d44fc027	JABON REXONA AVENA 110G	7702006405669	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:42.094642	2025-10-19 02:29:42.094642
261cc0c2-0fba-48ec-9e95-a8226f577822	GOL COCO UNIDAD	7702007039887	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.094858	2025-10-19 02:29:42.094858
f7e81c2b-d940-4b00-808d-84105947b11b	CHICHARRON LA VICTORIA 18GR	7706642003357	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.095089	2025-10-19 02:29:42.095089
221c927b-e603-409b-979a-4977c53708b4	REXONA CLINICAL MUJER 60GR	7702006208017	t	6400.00	6250.00	\N	\N	19.00	2025-10-19 02:29:42.09529	2025-10-19 02:29:42.09529
babbba28-b07e-4884-8547-4ab52349701f	ESCOBA EXTRA GRANDE	DFG5	t	8200.00	8000.00	\N	\N	19.00	2025-10-19 02:29:42.095512	2025-10-19 02:29:42.095512
52f1cfb2-f225-4f93-8cbf-15c9fce13463	NUCITA BEBIDA INSTANTANEA 220GR	7702011084767	t	7900.00	7650.00	\N	\N	19.00	2025-10-19 02:29:42.095719	2025-10-19 02:29:42.095719
cffe62c5-7d76-443e-95c6-fff5a847608f	HARINA PAN DULCE CHOCLO 850GR	7702084550053	t	8400.00	8180.00	\N	\N	5.00	2025-10-19 02:29:42.095923	2025-10-19 02:29:42.095923
54c32dbc-68df-4311-8bd9-e51ac75ad292	MILLOWS SNACK 35GR	7702011141118	t	1500.00	1380.00	\N	\N	19.00	2025-10-19 02:29:42.096126	2025-10-19 02:29:42.096126
8211bf8a-48b3-4f28-b90e-4eea337f080d	AXION LIMON 450GR	7702010380747	t	5800.00	5700.00	\N	\N	19.00	2025-10-19 02:29:42.09634	2025-10-19 02:29:42.09634
161a6d4d-85af-42b9-8cae-07749e4f2361	QUESO DOBLE CREMA CIFUENTES	7700188000061	t	5200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.096568	2025-10-19 02:29:42.096568
57936889-b533-49b1-a446-d01ddd170769	CLORO BLANQUEADOR 1.8 ML	7707220231308	t	3500.00	3300.00	\N	\N	19.00	2025-10-19 02:29:42.09713	2025-10-19 02:29:42.09713
b07a061c-b618-4b1c-8692-1caa447244b2	KIKITOS CARAMELO 70GR	7700634000379	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.097338	2025-10-19 02:29:42.097338
e1d27c84-5127-45af-8551-94f0c3c9edc2	PAN SUPER BIMBO X6UNID	7705326019318	t	6600.00	6450.00	\N	\N	0.00	2025-10-19 02:29:42.097566	2025-10-19 02:29:42.097566
9993cb4d-099f-4912-9275-78c81dea33b9	TORTILLAS DE LA TIA ROSA X10UNID 250GR	7705326081827	t	5200.00	5050.00	\N	\N	0.00	2025-10-19 02:29:42.097782	2025-10-19 02:29:42.097782
2a30e13f-76c7-459a-ba86-ea101b770f87	CASERO BIMBO TRES LECHE Y MORA 200GR	7705326002136	t	8000.00	7850.00	\N	\N	19.00	2025-10-19 02:29:42.098021	2025-10-19 02:29:42.098021
07d9b293-bf2e-47d1-82a7-15dc7ff95118	TRULU AROS 70GR	7702993051801	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:42.098354	2025-10-19 02:29:42.098354
c0042a59-997e-47af-9f2c-0d8c67b6836b	JUMBO MANI 90GR	7702007080742	t	8200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.098587	2025-10-19 02:29:42.098587
6cea5c41-bf61-4411-a9ba-e2351b82ce67	PAN TAJADO GUADALUPE 450GR	7705326091987	t	4700.00	4600.00	\N	\N	0.00	2025-10-19 02:29:42.098811	2025-10-19 02:29:42.098811
aaea2bd9-7ad4-400d-bf5d-21fec926868e	TOALLAS NOSOTRAS PLUS CANAL X30UNID	7702027417634	t	11800.00	11300.00	\N	\N	0.00	2025-10-19 02:29:42.09903	2025-10-19 02:29:42.09903
cbe77d73-36a2-415e-8ec6-b83958b8b88f	AJINOMEN CAMARON	7754487001748	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.09928	2025-10-19 02:29:42.09928
6115012a-821e-4ae6-91ab-96e68a12edc4	TOALLITAS ARRRURRU AVENA X70UNID	7702277549024	t	8600.00	8300.00	\N	\N	19.00	2025-10-19 02:29:42.099521	2025-10-19 02:29:42.099521
32bef51b-0582-41eb-b3ce-caa1d52566ff	AZUCAR 2.5 ZURAKU	664697052935	t	9600.00	\N	\N	\N	5.00	2025-10-19 02:29:42.099759	2025-10-19 02:29:42.099759
69e3231a-466e-4beb-89b4-352e99c75b32	SHAMPOO NUTRIT NEGROAZABACHE 600ML	7702277970286	t	17500.00	17000.00	\N	\N	19.00	2025-10-19 02:29:42.100126	2025-10-19 02:29:42.100126
11d59613-76ce-4b0b-97e0-1f073d021589	SHAMPOO NUTRIT REPARAMAX SIN SAL 600ML	7702277770428	t	17500.00	17000.00	\N	\N	19.00	2025-10-19 02:29:42.100356	2025-10-19 02:29:42.100356
de206b02-b5ee-4914-bc9f-53cf21e4b3ce	SHAMPOO ARRURRU CABELLO CLARO 750ML	7702277827818	t	33900.00	27800.00	\N	\N	19.00	2025-10-19 02:29:42.100613	2025-10-19 02:29:42.100613
be29c67f-0ca8-487a-969f-b3d1b4066805	CHUPETAS MANGOS LIMON X48UNI	7702174085304	t	6700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.100854	2025-10-19 02:29:42.100854
06cef508-040a-4f6a-b9d5-b65d3f3aad90	CHOCOLATE GALAVIS EXTRA 125GR	7707342420390	t	2200.00	2100.00	\N	\N	5.00	2025-10-19 02:29:42.101128	2025-10-19 02:29:42.101128
dd01f99e-4ef0-4a74-9af4-492fdc6ed2ff	POND PG 10 LLV 12	7702006302128	t	16500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.101386	2025-10-19 02:29:42.101386
8763ad27-a68b-4f8a-b9c6-259fe060cb6c	KIKITO MIX NATURAL 50GR	7700634003585	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.101618	2025-10-19 02:29:42.101618
5a9a1f60-855d-4b03-857f-46ed8427388b	FRUNAS DOBLE COLOR X100UNID	7702174086080	t	8800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.101915	2025-10-19 02:29:42.101915
10c694e3-8725-44b5-ad2c-061a0fcb7d76	JABON MI DIA AVENA 112GR	7702538251963	t	2500.00	2350.00	\N	\N	19.00	2025-10-19 02:29:42.102186	2025-10-19 02:29:42.102186
28725502-87a6-41c3-bf41-a709f908ae7a	TOALLAS ESBELTA NOCTURNA X10UNID	7708971288665	t	3900.00	3800.00	\N	\N	0.00	2025-10-19 02:29:42.102439	2025-10-19 02:29:42.102439
056ada08-44c1-4618-892b-976358b57f5a	ACONDICIONADOR BALSAMO EMBRION DE PATO CAPIBELL 470ML	7703819021916	t	7500.00	7000.00	\N	\N	19.00	2025-10-19 02:29:42.102676	2025-10-19 02:29:42.102676
6da07705-8fb2-4c99-9c01-f248d10c3a15	ROSAL ULTRACONFORT XXG X15UNID	7702120012965	t	21000.00	20800.00	\N	\N	19.00	2025-10-19 02:29:42.102969	2025-10-19 02:29:42.102969
59e09283-4133-491c-be29-6878a671fa75	ACONDICIONADOR CAPIBELL CEBOLLA Y BIOTINA 470	7703819025686	t	7500.00	7000.00	\N	\N	19.00	2025-10-19 02:29:42.103499	2025-10-19 02:29:42.103499
c5df9dc3-eb29-4337-b377-a6926025fee8	CLORO SKAAP 3785ML	DJLDG	t	6800.00	6600.00	\N	\N	19.00	2025-10-19 02:29:42.103865	2025-10-19 02:29:42.103865
f29e826e-b5bc-4dd1-94e4-880c2524e86d	CAREY SURTIDO X6	7702310022439	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.10418	2025-10-19 02:29:42.10418
3ee5cfba-e931-472a-8895-b28eda16860e	PROTEX HERBAL X3	7702010920660	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.104474	2025-10-19 02:29:42.104474
3152fc2e-1e10-42df-b095-4281c56913c2	PROTEX X6 LIMPIEZA PROFUNDA	7501033207457	t	19800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.104814	2025-10-19 02:29:42.104814
8f3c6fdb-920a-4168-99ac-5f999091ab21	PROTEX X6 AVENA	7702010921681	t	19800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.10512	2025-10-19 02:29:42.10512
0b3958fe-156a-4ff5-a49b-18baa413ed3e	PALMOLIVE X3 NATURALS	7702010911583	t	9300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.105416	2025-10-19 02:29:42.105416
bd5d6259-ccf3-41d3-9f96-f504c49e62d3	TRULULU FRESA MASMELO	7702993045329	t	2000.00	1890.00	\N	\N	19.00	2025-10-19 02:29:42.105667	2025-10-19 02:29:42.105667
c434bbaa-dabe-46d6-85ac-31afb392898c	FRUWI GOMITAS 50GR	7702993043998	t	1200.00	1100.00	\N	\N	19.00	2025-10-19 02:29:42.106012	2025-10-19 02:29:42.106012
4edffcb7-d418-4ddc-9e3b-c1c533f6cea0	TRULULU FEROZ 70 GR	7702993051740	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:42.106349	2025-10-19 02:29:42.106349
87f07dba-2d4b-4a78-841f-ecac157318e4	TRULULU MASMELO LIMON COCO	7702993045343	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:42.106632	2025-10-19 02:29:42.106632
8807cf93-87d8-454a-93d7-74f959481cc7	TROLLI OINTOSOS 45GR	7702174086257	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.106881	2025-10-19 02:29:42.106881
d062b428-4f96-4f13-bd58-8430f79a59fa	TRULULU DINOS 70GR	7702993051795	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:42.107126	2025-10-19 02:29:42.107126
deabdd5f-e475-4f39-a185-5b3738c17817	TRULULU SANDIAS ACIDAS 70GR	7702993051818	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:42.107382	2025-10-19 02:29:42.107382
c4014c7c-4d6d-410c-a6ae-90e9429597be	TRULULU GUSANOS 70GR	7702993051733	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:42.107612	2025-10-19 02:29:42.107612
bb03a0bf-c98c-481f-be7e-dc83823604f3	TROLLI DELIIIFINES 37GR	7702174086264	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.107861	2025-10-19 02:29:42.107861
98757753-bbc3-4b28-85b0-80cffcef1cfb	TROLLI ANACONDA 35 GR	7702174086288	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.108089	2025-10-19 02:29:42.108089
9b9a82c1-57e1-4602-a154-4255c01e8995	TRULULU SABORES 70GR	7702993051757	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:42.108298	2025-10-19 02:29:42.108298
a3eea063-b5dc-4bea-b2b1-012a7821d280	BORIFOR TALCO PEQUEÑO	7709294804297	t	2200.00	2000.00	\N	\N	19.00	2025-10-19 02:29:42.108527	2025-10-19 02:29:42.108527
85017484-6b7b-48f4-88c7-392c9c798b84	TRULULU CLASICAS 70GR	7702993051870	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:42.10876	2025-10-19 02:29:42.10876
f72c4f76-4a1a-488a-b828-87c9ded445b1	TRULULU FRESITAS 70GR	7702993051726	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:42.109287	2025-10-19 02:29:42.109287
ae72add4-554c-482e-9ee2-1675550e6966	PILAS ALKALINAS TRONEX AAA	7707822757541	t	4500.00	4400.00	\N	\N	19.00	2025-10-19 02:29:42.109659	2025-10-19 02:29:42.109659
2bc7218e-7cc8-4fe6-9cde-7b4fe0a22b73	CHORIZO ANTIOQUEÑO DUO CIFUENTES	AS3.F54C1ED5	t	3800.00	3700.00	\N	\N	5.00	2025-10-19 02:29:42.110074	2025-10-19 02:29:42.110074
63fc072f-1f9f-4ce2-ad5b-5a05d541152e	LIMPIADOR DE PISOS NORSAN FLORAL 1L	7707291396791	t	2400.00	2200.00	\N	\N	19.00	2025-10-19 02:29:42.110377	2025-10-19 02:29:42.110377
48d24c58-60c3-4eb4-86b7-1ab921ab6e73	SERVILLETA SKAAP X300UNID	7707371215226	t	3500.00	3340.00	\N	\N	19.00	2025-10-19 02:29:42.110772	2025-10-19 02:29:42.110772
179a5c5c-a0b4-47d4-8503-652bacbc03ac	CEPILLO DENTALES SONRIDENT X5UNID	7702314451167	t	6500.00	6300.00	\N	\N	19.00	2025-10-19 02:29:42.111023	2025-10-19 02:29:42.111023
83b52acd-70b5-4e1a-83b9-de9651776b9c	PASPAN TRADICIONAL 1.000GR	7707046940156	t	3200.00	3150.00	\N	\N	0.00	2025-10-19 02:29:42.111266	2025-10-19 02:29:42.111266
1f8817dd-4746-4c21-995f-8f592761bced	VINAGRE NORSAN 1L	7709795161691	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:42.111508	2025-10-19 02:29:42.111508
adfd14bd-3982-4a0e-86ed-f53fa5869fbf	SALSA BBQ BARY 400GR	7702439005504	t	7900.00	7650.00	\N	\N	19.00	2025-10-19 02:29:42.111752	2025-10-19 02:29:42.111752
e40f3bd4-fca4-43d4-8807-fa5ff225a322	FOSFORO HOGAR MADERA EL SOL X2	7707015502316	t	3300.00	3100.00	\N	\N	19.00	2025-10-19 02:29:42.111964	2025-10-19 02:29:42.111964
9097736c-419b-4c44-98c3-45ca3ad19f81	GUANTES LIMPIA YA TALLA 8 2UNID	7702037873048	t	6400.00	6200.00	\N	\N	19.00	2025-10-19 02:29:42.112204	2025-10-19 02:29:42.112204
9495d7ee-a66e-435f-9029-82e794175c54	SONRIDENT TRIPLE ACCION 75	7702314502395	t	2800.00	2600.00	\N	\N	19.00	2025-10-19 02:29:42.112398	2025-10-19 02:29:42.112398
31d91829-c8bc-495c-bd65-c5ca832b1396	SHAMPOO SAVITAL 350ML	7702006405973	t	11800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.112638	2025-10-19 02:29:42.112638
84bf8eec-21a9-41b9-909c-b16ae87c4d78	QUITA MANCHAS BONAROPA 1LITROS	7700304783755	t	4500.00	4300.00	\N	\N	19.00	2025-10-19 02:29:42.112871	2025-10-19 02:29:42.112871
6f090c78-2944-4575-b874-96cc39d1c1a9	GUANTS LIMPIA YA 8 1/2	7702037567930	t	3900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.113086	2025-10-19 02:29:42.113086
057a8a8f-9ecf-4494-b211-4e1a4851dd3d	TOALLAS ANGELA INVISIBLE 12 MAS 2	7707324640068	t	2800.00	2680.00	\N	\N	0.00	2025-10-19 02:29:42.113311	2025-10-19 02:29:42.113311
ab69b635-63a4-49a8-80ec-10b792e513ce	PINZA ROPA	SD354CV	t	7500.00	7350.00	\N	\N	19.00	2025-10-19 02:29:42.113548	2025-10-19 02:29:42.113548
2a088b96-fc9b-450f-acdf-a3ec98910564	JUGO FRUTTSI FRUTOS ROJOS 250ML	7701999000608	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.11376	2025-10-19 02:29:42.11376
700a9076-c6dc-4431-a212-dc3b07a99c8a	MAIZ TIERNO MI DIA 241GR	7700149173698	t	5400.00	5250.00	\N	\N	19.00	2025-10-19 02:29:42.113972	2025-10-19 02:29:42.113972
cfa7b9d6-722f-4f79-9781-d48f5499f8cd	CAFE GIRME CARAMELO RELLENO X100UNID	7702993050576	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.114212	2025-10-19 02:29:42.114212
10f9cdb3-b739-4ae7-93da-e6094e6d0565	TALCO REXONA EFFIENT AEROSOL 210ML	7791293042091	t	10400.00	10000.00	\N	\N	19.00	2025-10-19 02:29:42.114548	2025-10-19 02:29:42.114548
27471160-f8c9-4bcd-9052-5071d4c61340	DOVE TONO UNIFORME 50GR	75034238	t	15400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.114745	2025-10-19 02:29:42.114745
e9c988bf-6eec-46a2-b562-9cbca9a5e09b	ACONDICIONADOR MILAGROS ARROZ Y LINAZA 450ML	7708075180353	t	31000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.114974	2025-10-19 02:29:42.114974
fcf405b7-cf4b-4771-b983-480bb0445c28	DETERK LAVANDA 550GR	7702310045520	t	3800.00	3700.00	\N	\N	19.00	2025-10-19 02:29:42.115198	2025-10-19 02:29:42.115198
7616402f-8c02-466f-832c-54103aa9620a	DERSA BARRA MULTIUSOS 250GR	7702166049000	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.115415	2025-10-19 02:29:42.115415
6db7e39a-1038-4da1-b1d2-2e20d12cd5e4	ALCOHOL MK 350ML	7702057075088	t	4900.00	4650.00	\N	\N	0.00	2025-10-19 02:29:42.115644	2025-10-19 02:29:42.115644
4745b792-a28a-4916-9e68-2362f5611975	JET COOKIES AND CREAM 21GR	7702007052374	t	3700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.115844	2025-10-19 02:29:42.115844
9e7118bb-f1e7-4c9d-bc33-875dc661128d	AVENA HOJUELAS IDEAL 200GR	7708937039232	t	1200.00	1050.00	\N	\N	5.00	2025-10-19 02:29:42.116073	2025-10-19 02:29:42.116073
e531227c-2585-410b-9f53-5479d7745b1b	PAPAS CRUNCH 1.000GR	7709844868694	t	8600.00	8400.00	\N	\N	19.00	2025-10-19 02:29:42.116344	2025-10-19 02:29:42.116344
2f4f8e40-680f-45eb-a9d3-c5d6bb4b905d	VINAGRE IDEAL BLANCO 2790ML	7708957649367	t	3800.00	3600.00	\N	\N	19.00	2025-10-19 02:29:42.116567	2025-10-19 02:29:42.116567
aa978233-a5f8-49ad-a060-c05399ec265a	COCOSETTE SANDWICH UND	7702024066576	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.116848	2025-10-19 02:29:42.116848
9c7a888f-1b3c-45bc-9fbe-f9bb356c8ef2	TENEDO X20UNID	SDC87	t	1200.00	1080.00	\N	\N	19.00	2025-10-19 02:29:42.117133	2025-10-19 02:29:42.117133
bec26db9-8461-4201-a4a5-3552cb7cf53b	TENEDOR PEQUEÑO X20UNID	FVRE45	t	1200.00	1080.00	\N	\N	19.00	2025-10-19 02:29:42.117442	2025-10-19 02:29:42.117442
e225e448-e6d1-400a-a66f-0ef38df423c3	LAK HERBAL X3UNID 330GR	7702310020954	t	5300.00	5150.00	\N	\N	19.00	2025-10-19 02:29:42.117768	2025-10-19 02:29:42.117768
e20ae18f-cf4e-42b3-85e5-2620d4d5b0c4	TARRO SURTIDO LA PICAURTE X40UNID 600GR	7707283881151	t	8800.00	8500.00	\N	\N	19.00	2025-10-19 02:29:42.117984	2025-10-19 02:29:42.117984
4c1c6ec7-0270-45d3-b9b2-f707eb330712	BONBONERA TROCITOS LA RICAURTE X50UNID 2100GR	7707283881236	t	21500.00	21000.00	\N	\N	19.00	2025-10-19 02:29:42.118214	2025-10-19 02:29:42.118214
e8230c37-7c10-416e-a066-386c1960de95	LECHE ENTERA MILK 380GR	7707493559611	t	9000.00	8600.00	\N	\N	0.00	2025-10-19 02:29:42.118467	2025-10-19 02:29:42.118467
0f56b6f9-af22-4530-8e9c-6d1a30d0394b	LECHE ENTERA MILK 900GR	7707493557372	t	20000.00	19600.00	\N	\N	0.00	2025-10-19 02:29:42.118666	2025-10-19 02:29:42.118666
5345cf00-0559-45b0-8584-3e7b7d4df5c0	CAFE TROPICO INTENSO 125GR	7707172840061	t	5300.00	5170.00	\N	\N	5.00	2025-10-19 02:29:42.118901	2025-10-19 02:29:42.118901
5d1ab258-db3a-45d7-90d0-9ff8319e1d16	CAFE TROPICO INTENSO 250GR	7707172846711	t	10400.00	9900.00	\N	\N	5.00	2025-10-19 02:29:42.119146	2025-10-19 02:29:42.119146
d21fa3ef-92b2-4889-abfd-bc9a712a1b13	CAFE TROPICO INTENSO 500GR	7707172847947	t	20000.00	19400.00	\N	\N	5.00	2025-10-19 02:29:42.119377	2025-10-19 02:29:42.119377
31a88794-dff6-4c3f-a5b3-61d4fb23c681	PIMIENTA LA SAZON DE VILLA 120GR	7707767141344	t	6200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.119663	2025-10-19 02:29:42.119663
2aaf0b95-16de-45ba-b9db-b6686bf6efe7	NUTRIBELA X12	7702354952846	t	16200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.119897	2025-10-19 02:29:42.119897
0677fbe0-3253-4933-842d-7cf033ae8be1	SUPER RIEL X3UNID 840GR	7702310010474	t	6900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.120106	2025-10-19 02:29:42.120106
9465bf88-139c-4eb0-9a57-e9b2686a8f35	SUPER RIEL 280GR	7702310010467	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:42.120336	2025-10-19 02:29:42.120336
4a74fa00-6a5b-4db7-b501-fa9bec12f8e2	COLGATE TRIPLE ACCION 150ML X3UNID	7509546652023	t	31000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.120534	2025-10-19 02:29:42.120534
95f7be91-7599-4130-ad17-f28460ff58bc	ELITE ULTRA MEGARROLLO  MORADO X12UNID	7709554623521	t	21700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.120769	2025-10-19 02:29:42.120769
ffcb128f-f3a2-462c-a87a-1151eef0aa28	MASA LISTA CUADRADAS 600GR	SAFC543	t	4100.00	4000.00	\N	\N	0.00	2025-10-19 02:29:42.120988	2025-10-19 02:29:42.120988
a942926b-3c3f-4aed-8230-7643064fd3a9	CEBADA 500GR	7707193910620	t	2600.00	2500.00	\N	\N	0.00	2025-10-19 02:29:42.12121	2025-10-19 02:29:42.12121
a06eb235-fa2d-4237-9c53-e6ff3abb6466	FAB ULTRA FLASH 6 KG	7702191164396	t	49500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.121414	2025-10-19 02:29:42.121414
76d7a0ee-06b6-4586-9873-8c1f1e197e96	NOSOTRAS INVISIBLE RAPIGEL 10 MAS 2	7702026148423	t	5100.00	4900.00	\N	\N	0.00	2025-10-19 02:29:42.121654	2025-10-19 02:29:42.121654
2063eb9c-a2d9-46e6-9e31-c408add75a35	VASOS VBC 7OZ X50UNID	7709174732825	t	2300.00	2200.00	\N	\N	19.00	2025-10-19 02:29:42.121855	2025-10-19 02:29:42.121855
3a1b753e-2c67-46d3-98c2-bbd6bbe53f08	LAVAVAJILLA LAVA 235GR	7861036713301	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.122227	2025-10-19 02:29:42.122227
030a8e27-634a-42c5-b6eb-2c60c7c1d799	HALLS BARRA FRUIT MIX X12BARRAS	7622210427014	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.122501	2025-10-19 02:29:42.122501
0c6a63a7-d4b3-4ac2-aa25-091371ba236b	HALLS BARRA CEREZA X12UNID	7622210426963	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.122809	2025-10-19 02:29:42.122809
2b848cc9-6eab-46fe-a365-3917e016c096	HALLS MENTHO BARRA X12UNID	7622210426970	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.123047	2025-10-19 02:29:42.123047
df1c0f20-906f-4d96-8ab7-c1fd415d294b	MIXTO HOT LA VICTORIA 150GR	7706642008741	t	6800.00	6600.00	\N	\N	19.00	2025-10-19 02:29:42.123333	2025-10-19 02:29:42.123333
a4ba3096-dd9d-4bfe-b53b-cad96d8136d1	MIXTO SUPER FAMILIAR BBQ 240GR	7706642006846	t	9300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.123603	2025-10-19 02:29:42.123603
1c3e8b2f-fd38-4c08-a079-808be278d2b3	AVENA QUAKER HOJUELAS 1.100GR	7702193101313	t	10000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.123866	2025-10-19 02:29:42.123866
aa3c258d-4966-4207-b913-869ede295652	CATALINA LECHE ENTERA 380GR	7709088668456	t	10000.00	9700.00	\N	\N	0.00	2025-10-19 02:29:42.124163	2025-10-19 02:29:42.124163
148260ce-469e-446d-abf5-84b99fa816d6	CATALINA LECHE ENTERA 900GR	7709088668418	t	23000.00	22600.00	\N	\N	0.00	2025-10-19 02:29:42.124402	2025-10-19 02:29:42.124402
0098f1f2-9ffd-45d1-9c11-5035131438a2	SET EMPANADERA X3UNID	7709990627046	t	5500.00	5280.00	\N	\N	19.00	2025-10-19 02:29:42.124695	2025-10-19 02:29:42.124695
4e8a22bb-a8c7-4c77-af20-286a03e3b7a4	DERSA BICARBONATO MANZANA 250GR	7702166049659	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.125118	2025-10-19 02:29:42.125118
fb51d209-21f9-4d86-80fa-7c1306688d7a	FLIPS X12UNID 28GR	7591039505190	t	20500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.125432	2025-10-19 02:29:42.125432
fe29f739-511e-4155-8da7-35f146f24392	VINAGRE IDEAL 500ML	7709747919059	t	1100.00	1000.00	\N	\N	19.00	2025-10-19 02:29:42.125707	2025-10-19 02:29:42.125707
c2139b34-da37-43f6-ae8b-a3af58503140	IBUPROFENO 800MG GENFAR 50 TAB	7702605101511	t	8200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.125981	2025-10-19 02:29:42.125981
78c9cf07-34e1-441a-8351-e03a3ce6d698	PAN DE HAMBURGUESAS BIMBO X4UNID	7705326019288	t	6000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.126452	2025-10-19 02:29:42.126452
6576ac3d-86d4-4a62-90d0-618e9b526340	SHAMPOO EGO ANTICASPA 400ML MAS GEL 110GR	7702006301183	t	18500.00	18000.00	\N	\N	19.00	2025-10-19 02:29:42.126797	2025-10-19 02:29:42.126797
d5379457-f42b-4f26-bfd6-48defcf0b2c9	CREMA PONDS CLARANT B3 100GR MAS 50GR	7702006405645	t	27200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.127528	2025-10-19 02:29:42.127528
222a4936-aa08-4821-bb3a-85191ccf0867	CREMA PONDS CLARANT B3 50GR	7501056330293	t	11500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.128045	2025-10-19 02:29:42.128045
2c37fa71-1c86-4c88-a1e2-6ddd6407416c	CREMA PONDS CLARANT B3 100GR	7501056330309	t	19500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.128408	2025-10-19 02:29:42.128408
57599522-cc03-4c8f-8c2c-cf03f39d1cf5	FAB ULTRA FLASH 3.5KG	7702191164358	t	28500.00	28000.00	\N	\N	19.00	2025-10-19 02:29:42.128715	2025-10-19 02:29:42.128715
3b4077de-ae65-4e47-8471-ba6b278343a4	VAPORUB PEQUEÑO	DC64C	t	2500.00	2400.00	\N	\N	0.00	2025-10-19 02:29:42.128983	2025-10-19 02:29:42.128983
027ac90a-254f-4dc5-8802-558007ce6678	ARIEL TRIPLE PODER 225GR	7500435201322	t	2800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.129229	2025-10-19 02:29:42.129229
ad597957-cdd4-4486-86ab-2d9be5f24b71	SCHWEPPES GINGER ALE 400ML	7702535010273	t	2300.00	2018.00	\N	\N	19.00	2025-10-19 02:29:42.129502	2025-10-19 02:29:42.129502
62f4ad12-d1b9-4599-96f7-67736e0007b0	mano candy	7708250792548	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.129792	2025-10-19 02:29:42.129792
d3931a12-0fd3-47ae-b7d4-dd8217a31273	JET CHOCOLATINA X50UNID	7702007080483	t	54000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.130082	2025-10-19 02:29:42.130082
ee3877ff-c7a0-4a03-a416-8b744a1357ae	GELATINA GELA PLAY YOLI ESTRELLA X20UNID	7708527098977	t	10000.00	9600.00	\N	\N	19.00	2025-10-19 02:29:42.130374	2025-10-19 02:29:42.130374
80180f04-fa96-4739-9023-5133b665a813	GELATINA ESTRELLA FRUIT JELLY BONBONERA X55UNID	7441163702258	t	32500.00	32000.00	\N	\N	19.00	2025-10-19 02:29:42.130668	2025-10-19 02:29:42.130668
e6ff2c7f-1804-47ed-b5f0-ee000e864533	GELATINA BONBONERA GELA PLAY X90UNID	7708527098175	t	27500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.130958	2025-10-19 02:29:42.130958
3bb5fba9-b029-4e4c-8019-71d9e5a870f1	GELATINA FRUIT JELLY X8UNID	7441163702289	t	4500.00	4300.00	\N	\N	19.00	2025-10-19 02:29:42.131196	2025-10-19 02:29:42.131196
48ae526a-4b22-484b-9f5a-f0e18533993f	SHAMPOO MILAGROS ULTRANUTRITIVO 450ML	7708075180957	t	30000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.131455	2025-10-19 02:29:42.131455
196fc7a2-0c7a-4187-8317-8e1b2059815a	JABON INTIMO INTIBON VINAGRE Y MANZANA 210GR	7702277533542	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.131727	2025-10-19 02:29:42.131727
a21a0d1e-51c9-4d55-badb-9e2e6a684aa7	SHAMPOO CANAMOR SIN SAL 30ML	7702487034020	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.132002	2025-10-19 02:29:42.132002
285ab746-1a28-46e3-ba6f-be668a428576	JABON INTIMO PROTEX CUIDADO INTIMOS DELICATE 200ML	7891024023969	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.132273	2025-10-19 02:29:42.132273
acf5486f-3b34-4270-8975-2838d46903ab	SALTIN NOEL X3TACOS 300GR	7702025185344	t	5200.00	5100.00	\N	\N	19.00	2025-10-19 02:29:42.132511	2025-10-19 02:29:42.132511
776fa3cc-87ef-4216-8541-da83a4af8493	TORNILLOS CON VERDURA DORIA 500GR	7702085013496	t	4000.00	3870.00	\N	\N	5.00	2025-10-19 02:29:42.132902	2025-10-19 02:29:42.132902
a129f3c4-c971-4703-888b-378200b4a2aa	SALMON DON SANCHO 155GR	7862119507572	t	2600.00	2450.00	\N	\N	19.00	2025-10-19 02:29:42.133342	2025-10-19 02:29:42.133342
4bff4f9d-ee61-42c0-9d3a-dd45ff08d242	SUERO COSTEÑO 200GR LA MEJOR	7705241665508	t	6300.00	\N	\N	\N	0.00	2025-10-19 02:29:42.133592	2025-10-19 02:29:42.133592
fb888d88-a67c-41c1-8c28-53d40e9177a3	MANI KRAKS LIMON X12UNID	7702007071641	t	19700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.133909	2025-10-19 02:29:42.133909
8135863e-8e34-4a2e-8627-de005b64d9ed	BATU CHIPS PLATANO 135GR	7702189045751	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.134327	2025-10-19 02:29:42.134327
ca3ff12d-16bb-45da-9ea5-f8f482c65ad5	SAVITAL SACHET	7702006202275	t	1000.00	875.00	\N	\N	19.00	2025-10-19 02:29:42.134679	2025-10-19 02:29:42.134679
76a21cef-1811-4f0d-a50d-98285b918911	COMPLETISIMO 30GR	SDFCD2543	t	400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.135032	2025-10-19 02:29:42.135032
ae18b9d8-ea76-44df-af50-e1213f1d9662	CEPILLO ORAL PLUSMEDIA WAVINES	7704631002657	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:42.135453	2025-10-19 02:29:42.135453
7c92f1c3-17e3-4c36-8c5f-4ecfec06eb4a	CEPILLO ORAL PLU FLEX MEDIO	7704631800031	t	1400.00	1290.00	\N	\N	19.00	2025-10-19 02:29:42.135802	2025-10-19 02:29:42.135802
219c493b-9e8f-4d36-ba8b-47c3a7ab0946	AVENA EXTRA SEÑORA INSTANTANEA 180GR	7709761545807	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.136085	2025-10-19 02:29:42.136085
483544fb-49df-4d25-a7e3-53623e77bd00	FRUNAS BARRA X50UNID	7702174076012	t	7200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.136353	2025-10-19 02:29:42.136353
cd9544ab-8167-4434-b8ad-bf69dc859045	PIAZZA COOL CHICLE 24UNID	7702011203380	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.136601	2025-10-19 02:29:42.136601
5d7de578-0867-48cc-a0af-69e05dae8004	PIAZZA COOL HELADO CHICHLE	7702011202697	t	400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.136855	2025-10-19 02:29:42.136855
1983eb35-fc58-4696-9aab-54f1ff418e7b	MUAU NUGGETS POLLO 12GR	7702993047064	t	1000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.137142	2025-10-19 02:29:42.137142
1cae0514-1e62-4b10-944a-a69e1bdf9adf	WUAU GALLETAS SABOR A POLLO 20GR	7702993047149	t	1000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.137392	2025-10-19 02:29:42.137392
2031d4ad-b617-4e95-b311-4eaa52fc17e8	ACEITE OLEOCALI VEGETAL 5LITROS	7701018005089	t	44000.00	43000.00	\N	\N	19.00	2025-10-19 02:29:42.13781	2025-10-19 02:29:42.13781
dabca996-5676-454e-8a54-31d5e521338f	TENEDOR PEQUEÑO LA EUROPEA X100UNID	7755267002481	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.13809	2025-10-19 02:29:42.13809
295717ab-32d4-44d7-96e5-f228eb74c9db	SHAMPOO SAVITAL X2UNID MAS ACONDICIONADOR	7702006653282	t	44500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.138429	2025-10-19 02:29:42.138429
85cd8a87-200b-4b19-9c7d-f0bfa06612e8	SHAMPOO DOVE HIDRATACION INTENSA 400ML	7891150050488	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.138708	2025-10-19 02:29:42.138708
fe279005-ec4c-4b2e-97b1-598b0a29ffeb	ENJUAGUE BUCAL ORAL PLUS 180ML	7708682913689	t	6100.00	5950.00	\N	\N	19.00	2025-10-19 02:29:42.138938	2025-10-19 02:29:42.138938
ad2f9357-d6bb-425d-bc64-2d1da48b9bfe	SALSA DEL SAZON X3 SOYA AJO INGLESA	770676768389	t	6200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.139234	2025-10-19 02:29:42.139234
9c2c3b49-d0e5-4c45-b765-07c80011cf91	AJI DELSAZON 170ML	7707325421406	t	2100.00	1950.00	\N	\N	19.00	2025-10-19 02:29:42.139523	2025-10-19 02:29:42.139523
be56cd9e-4d94-4ce7-acd1-3a71c8f78108	SALSA DE SOYA DELSAZON 170ML	7701094858876	t	2100.00	1950.00	\N	\N	19.00	2025-10-19 02:29:42.139771	2025-10-19 02:29:42.139771
2fef4c2c-0049-454a-b061-d4fa58098927	SALSA SOYA DELSAZON 1L	7701090477231	t	7900.00	7680.00	\N	\N	19.00	2025-10-19 02:29:42.140069	2025-10-19 02:29:42.140069
b678be7f-5c53-4265-ba90-97fd84e49846	SALSA INGLESA DELSAZON 1L	7701096858652	t	7900.00	7680.00	\N	\N	19.00	2025-10-19 02:29:42.140345	2025-10-19 02:29:42.140345
3564c9a3-2141-4157-8ef1-f80f557d70f9	SALSA DE AJO DELSAZON 1L	7708162674789	t	7900.00	7680.00	\N	\N	19.00	2025-10-19 02:29:42.140557	2025-10-19 02:29:42.140557
5ec80794-d3b3-4c67-9205-d83f5e75f6e9	AVENA INSTANTANEA EXTRA SEÑORA CHOCOLATE 400GR	7708624784629	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:42.140778	2025-10-19 02:29:42.140778
b7a8a698-bf9b-4e96-be30-a0892f67f6ac	AVENA INSTANTANEA EXTRA SEÑORA  MORA 180GR	7709761545852	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.141143	2025-10-19 02:29:42.141143
f13961d0-e7a1-48de-ab87-cb8b52428a85	AVENA INSTANTANEA EXTRA SEÑORA CHOCOLATE 180GR	7708942727971	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.141435	2025-10-19 02:29:42.141435
c268ba0f-a483-4441-a85a-97acff6268bd	AVENA INSTANTANEA EXTRA SEÑORA AREQUIPE 180GR	7709761545876	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.141685	2025-10-19 02:29:42.141685
8c7adb7c-7c3d-45e0-8258-7a52a268b5e2	JUGO HIT MORA 1 L	7702090038064	t	4200.00	3817.00	\N	\N	19.00	2025-10-19 02:29:42.141937	2025-10-19 02:29:42.141937
c860f45a-3026-4794-925a-64457d3ef2b0	BIANCHI FRESA	7702993048900	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:42.142163	2025-10-19 02:29:42.142163
4c696097-4685-47b0-bef7-72f92af54735	GARBANZO BB 460GR	7707193910309	t	4000.00	3900.00	\N	\N	0.00	2025-10-19 02:29:42.142482	2025-10-19 02:29:42.142482
133774c1-419e-4402-bee3-e790f2572569	CHOCOLATE ALBA DEL FONCE CLAVOS Y CANELA 250GR	7707185810112	t	4100.00	3950.00	\N	\N	5.00	2025-10-19 02:29:42.142746	2025-10-19 02:29:42.142746
484323e1-5c40-4e74-8db1-3b6738824a6c	CHOCOLATE ALBA DEL FONCE CLAVOS Y CANELA 500GR	7707185810907	t	7800.00	7550.00	\N	\N	5.00	2025-10-19 02:29:42.143004	2025-10-19 02:29:42.143004
b59d6e80-df54-4d1c-9185-63fd3c91d461	CHOCOLATE ALBA DEL FONCE TRADICIONAL 500GR	7707185810990	t	7800.00	7550.00	\N	\N	5.00	2025-10-19 02:29:42.143375	2025-10-19 02:29:42.143375
9ea16cb9-a79d-4310-9aaa-953b7d8f0e4f	CHOCOLATE ALBA DEL FONCE VAINILLA 50GR	7707185810914	t	7800.00	7550.00	\N	\N	5.00	2025-10-19 02:29:42.143685	2025-10-19 02:29:42.143685
3099f443-4bf6-4a97-a67e-83dadd15e052	COBERTURA DE LECHE DLUCHY 500GR	7708730121547	t	10200.00	9900.00	\N	\N	5.00	2025-10-19 02:29:42.143988	2025-10-19 02:29:42.143988
aaf48629-ab2b-4ff1-b42c-bd619bff5a28	COBERTURA BLANCA CHOCOLATE DLUCHY 500GR	7708730121387	t	11000.00	10600.00	\N	\N	5.00	2025-10-19 02:29:42.144248	2025-10-19 02:29:42.144248
9a24ce72-bdf0-4057-882e-1a74dbf4113a	GRAGEAS ELITE 125GR	7708730121936	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:42.144482	2025-10-19 02:29:42.144482
6490a678-d711-4437-9f32-b204d2c94a61	OREO ORIGINAL	7590011251100	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.144697	2025-10-19 02:29:42.144697
66b4a685-7697-46ac-9d8f-ee80c1f70e8c	TRIDENT TUTTI FRUTI 805G	7622202015557	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.144909	2025-10-19 02:29:42.144909
0eaab724-2234-4cc8-b2c6-1661918332ff	MILO ANILLOS X9 390GR	7702024064510	t	10200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.145146	2025-10-19 02:29:42.145146
526f4be3-abbe-432e-8c7d-a69887f84135	AZUCAR RIOPAILA 500GR	7702127107022	t	2000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.145379	2025-10-19 02:29:42.145379
1a4c2c85-eb64-4edd-aa52-f7e88d9b674a	RINDEX 2 EN 1 5KG	7500435170277	t	34500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.14562	2025-10-19 02:29:42.14562
ebce45b4-6893-44dd-a948-5b054c7b23ba	PIN POP GIGANTE X24UNID	7702174082372	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.145851	2025-10-19 02:29:42.145851
b4d6811a-aa47-4682-866b-048257dd84b5	AVENA BJ HOJUELAS 200GR	7709046415580	t	1100.00	1030.00	\N	\N	5.00	2025-10-19 02:29:42.146104	2025-10-19 02:29:42.146104
9dae9a07-daec-4132-acac-cf419f17c36b	SALSA TARTARA IDEAL 200GR	7709483153557	t	2500.00	2390.00	\N	\N	19.00	2025-10-19 02:29:42.146384	2025-10-19 02:29:42.146384
44fab376-c450-4487-be71-58e1b065f645	SALSA TARTARA IDEAL 345GR	7709912927827	t	3900.00	3700.00	\N	\N	19.00	2025-10-19 02:29:42.146611	2025-10-19 02:29:42.146611
5deb1f0b-2a94-467f-9466-2f4be2ed2153	SALSA HABANERA BADIA 155ML	033844003210	t	7300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.146832	2025-10-19 02:29:42.146832
b8cbe755-bc42-48f7-bf69-4ab90254fd0a	ALBAHACA BASIL BADIA 14GR	033844000721	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.147085	2025-10-19 02:29:42.147085
fd478f24-4c58-41fd-8626-54339188ed33	SAZON COMPLETO SEASONING COMPLETO 49GR	033844000998	t	5200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.147337	2025-10-19 02:29:42.147337
b6ec103b-0297-4206-8019-4d29251e1371	OREGANO BADIA 14GR	033844000219	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.147581	2025-10-19 02:29:42.147581
df297e66-4370-4661-bd0b-046aa97a276f	ROMERO BADIA 14GR	033844000585	t	5200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.14782	2025-10-19 02:29:42.14782
fed23ef9-2e6f-45fa-a65c-d3f167be2a30	CHOCOLATE CORONA VAINILLA 250GR	7702007085495	t	6900.00	6750.00	\N	\N	5.00	2025-10-19 02:29:42.148022	2025-10-19 02:29:42.148022
b1fd5962-6c2b-4f71-b0ac-d389eb52ef15	SUERO COSTEÑO 400GR	CC	t	13000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.148276	2025-10-19 02:29:42.148276
ee163942-28b4-4a8c-a7bf-f53adaff557b	SPEED STICK CLINICAL X20UNID 9GR	7509546688299	t	19000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.148505	2025-10-19 02:29:42.148505
67639b7f-683d-4c5e-870d-578f3350e7e6	LADY SPEED STICK CLINICAL X20UNID 9G	7509546688244	t	19000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.148747	2025-10-19 02:29:42.148747
25946839-3a92-4667-b63c-b0636c456aee	SHAMPOO NUTRIT CUIDADO NATURAL SIN SAL 600ML	7702277307389	t	17500.00	17000.00	\N	\N	19.00	2025-10-19 02:29:42.148946	2025-10-19 02:29:42.148946
7ae50ed9-c16a-4415-8575-8ce6ebf692ff	FLIPS X12 UND 28GR	7591039505992	t	20500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.149179	2025-10-19 02:29:42.149179
fc64e51c-2386-4a7e-827c-74585cf2a029	PANELITAS COCADA 40UND	7707317430010	t	5800.00	\N	\N	\N	0.00	2025-10-19 02:29:42.149387	2025-10-19 02:29:42.149387
4693f44a-de49-44de-8937-e86bd19848c9	HIPERLONCH ITALO WAFER X12UNID VAINILLA	7702117002504	t	4300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.14961	2025-10-19 02:29:42.14961
ddbe39b6-e6e3-473c-a9a5-d195cc470cef	FESTIVAL COCO 12X4	7702025141890	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.149958	2025-10-19 02:29:42.149958
4fd2106e-90c6-432e-b21e-1de94d5a0ed8	HIPERLONCH WAFER ITALO X12UNID	7702117002641	t	4300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.150201	2025-10-19 02:29:42.150201
359c9b36-7659-4b3c-8026-bea372cc8683	LECHE ENTERA PARMALAT 1L	7700604051127	t	4200.00	4050.00	\N	\N	0.00	2025-10-19 02:29:42.150437	2025-10-19 02:29:42.150437
06a9d859-0b15-48ac-8832-15ce5ae7dd80	REDONDITAS VAINILLLA X6UNID	7707323130201	t	3200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.150687	2025-10-19 02:29:42.150687
dcf24238-24f0-47ef-b27d-74889fd99d64	DETERGENTE LIQUIDO COCO 900ML	7702191348819	t	16500.00	16200.00	\N	\N	19.00	2025-10-19 02:29:42.150914	2025-10-19 02:29:42.150914
0432d0f9-b328-47d0-92a3-028f29e6fa91	BIG BOM XL SCHOOL X24UNID	7707014902520	t	6200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.151123	2025-10-19 02:29:42.151123
4beb75ee-58e0-47ba-9a77-2f9e03aee515	TIC TAC DETALLADO	78600010	t	1900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.151341	2025-10-19 02:29:42.151341
0e502f88-7e54-4de9-aa82-a1fde7edfa0d	NUTRIBELA 15 EBZIMITERAPIA 24ML	7702354951931	t	1500.00	1408.00	\N	\N	19.00	2025-10-19 02:29:42.151548	2025-10-19 02:29:42.151548
4998b42c-c739-4f60-9973-c3225aaf5fdc	LIMPIAPISOS SKAAP CANELA 900ML	7707371212157	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:42.151819	2025-10-19 02:29:42.151819
0cc007e9-9661-44a9-9439-90cf2c937a15	LIMPIAPISOS SKAAP FLORAL 900ML	7707371212140	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:42.152039	2025-10-19 02:29:42.152039
15cf61bd-ee7e-4ee7-8ed1-53363106c356	LIMPIA PISOS SKAAP CHICLE 900ML	7707371215240	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:42.152247	2025-10-19 02:29:42.152247
da469701-4e12-4a02-aefe-186d13e7eb64	FRUTY AROS KARYMBA 240GR MAS LAPIZ	7702807876248	t	6700.00	6500.00	\N	\N	19.00	2025-10-19 02:29:42.152477	2025-10-19 02:29:42.152477
dce89994-6756-44d7-8f1b-f0af13630e79	DETERGENTE 3D 3K	7702191163566	t	27500.00	27000.00	\N	\N	19.00	2025-10-19 02:29:42.152687	2025-10-19 02:29:42.152687
a470e7e2-0a9f-4309-9b6e-bbc28317037b	ADOBO NATURAL LA SAZON 120GR PETPACK	7707767143386	t	4400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.152925	2025-10-19 02:29:42.152925
126f57dc-1563-49ff-b912-384ec4c4fa97	NORAVER GRIPA PASTILLA	NORAVER GRIPA PASTILLA	t	1700.00	\N	\N	\N	0.00	2025-10-19 02:29:42.153149	2025-10-19 02:29:42.153149
170bfc06-ae74-4e4a-ab57-4c3e46c5723a	IBUFLASH MIGRAM CAJA X6 UND	7702057091965	t	12500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.153438	2025-10-19 02:29:42.153438
e60f62cd-4818-42bf-b185-7840bde4bdbe	AMOXICILINA X50PAST LA SANTE	7703763070237	t	11500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.153661	2025-10-19 02:29:42.153661
d0ac45ac-ccdf-4b20-8be6-804ee38b7616	ACETAMINOFEN AG X100 TABLETAS	7706569020659	t	6200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.153921	2025-10-19 02:29:42.153921
5b00ecde-02b6-4840-bb4e-d541eb370667	HARINA PAN AMARILLA 500GR	7702084137575	t	1600.00	1500.00	\N	\N	5.00	2025-10-19 02:29:42.15417	2025-10-19 02:29:42.15417
ec07ba15-8f40-4a76-8398-2eb1e135d913	TAMPONES NOSOTRAS X3UNID	7702027435362	t	2400.00	2300.00	\N	\N	0.00	2025-10-19 02:29:42.154458	2025-10-19 02:29:42.154458
e37995f1-008c-4950-ae23-6e574b1f91ef	VASOS 7 OZ SICODELICO X50UNID	DCW2	t	1800.00	1660.00	\N	\N	19.00	2025-10-19 02:29:42.154788	2025-10-19 02:29:42.154788
f7fad79f-9ce8-4397-a1fb-28f9ea5c93a2	DERSA AZUL PURO BISCARBONATO 320GR	7702166009134	t	4000.00	3760.00	\N	\N	19.00	2025-10-19 02:29:42.155058	2025-10-19 02:29:42.155058
117620ac-1ca6-4c47-9b7d-cb30a1d2a7a6	BIG BOM XXL BALL X50UNID	7707014903206	t	6900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.155405	2025-10-19 02:29:42.155405
3084be8a-17ee-40f4-894e-d82cbb653ab9	HIPER CLORO 1800ML	CCEC	t	3500.00	3300.00	\N	\N	19.00	2025-10-19 02:29:42.155642	2025-10-19 02:29:42.155642
7d18bb5c-5a70-4fd5-a178-d84edeea5b55	NATUSAL SAL MARINA 1.000GR	7707061202208	t	1300.00	1250.00	\N	\N	0.00	2025-10-19 02:29:42.155868	2025-10-19 02:29:42.155868
e4f89c08-66d8-4a17-b9d4-37afe0cf2af5	JABON DESEO SURTIDO X3 UNID	7702538252212	t	6400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.156117	2025-10-19 02:29:42.156117
0fb0c3ba-2818-44f0-909d-c267fb7a7c7c	CEPILLO ORAL PLUS KIDS	7704631000158	t	1300.00	1150.00	\N	\N	19.00	2025-10-19 02:29:42.156333	2025-10-19 02:29:42.156333
7e5705e6-9182-433c-b0cb-9778fd2f4f69	JABON DISCO TRAS LIMON  130GR	7708669890514	t	1100.00	1000.00	\N	\N	19.00	2025-10-19 02:29:42.156549	2025-10-19 02:29:42.156549
8d602f6d-cba7-4275-b403-7a81cd62343d	ARROZ SAN ANDRES 900GR	7709472003719	t	3800.00	3709.00	\N	\N	0.00	2025-10-19 02:29:42.156782	2025-10-19 02:29:42.156782
0f98c1aa-549d-4126-bf86-a7b0a1f76869	LECHE ENTERA PARMALAT 400ML	7700604051349	t	1800.00	1650.00	\N	\N	0.00	2025-10-19 02:29:42.157132	2025-10-19 02:29:42.157132
cd40e579-6298-4aa0-91b6-c115cd790c94	JABON DE MANO CON DISPENSADOR MI DIA 500ML	SCC56E	t	5400.00	5200.00	\N	\N	19.00	2025-10-19 02:29:42.157338	2025-10-19 02:29:42.157338
dc5834ff-6d63-4c2a-9b9e-ab9bfcfed82c	CREMA DE PEINAR SAVITAL HIALURONICO 275ML	7702006406048	t	13000.00	12700.00	\N	\N	19.00	2025-10-19 02:29:42.157576	2025-10-19 02:29:42.157576
a397ceff-7977-48b7-922a-3478f19ddc76	GUANTES MI DIA NEGROS 8 1/2	7705946486811	t	4100.00	4000.00	\N	\N	19.00	2025-10-19 02:29:42.157807	2025-10-19 02:29:42.157807
4bb64229-ba22-42f8-b57c-0e4848f12d15	GUANTES MI DIA AMARILLOS 7 1/2	7701023035941	t	4100.00	4000.00	\N	\N	19.00	2025-10-19 02:29:42.158039	2025-10-19 02:29:42.158039
ec75dcc0-9541-4a16-80ad-03d23d35e345	GUANTES MI DIA AMARILLO 8 1/2	7701023035958	t	4100.00	4000.00	\N	\N	19.00	2025-10-19 02:29:42.158288	2025-10-19 02:29:42.158288
28922c5b-849e-4a40-bca8-b3b76634b5f5	MOÑITAS X50UNS	6543210193321	t	2500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.158532	2025-10-19 02:29:42.158532
2d436d52-4581-4993-8217-2625103704e4	CLIPPER MINI PIEDRA	8412765513268	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:42.158742	2025-10-19 02:29:42.158742
f031abd9-0da3-46ad-8342-dda1f4fbe6ed	SHAMPOO NUTRIT MAS ACONDICIONADOR REPARA MAX	7702277750987	t	35000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.158947	2025-10-19 02:29:42.158947
75523bf5-af4d-4b58-a5d8-fdd7382bac1d	ACONDICIONADOR CON ROMERO ANYELUZ 500ML	7708928066124	t	33000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.159182	2025-10-19 02:29:42.159182
ab575052-520c-41b7-8431-ba20d34c5ec1	SHAMPOO ANTICASPA ANYELUZ 400ML	7709885135571	t	33000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.159418	2025-10-19 02:29:42.159418
48f2b904-6f0e-4730-b418-cd0c2b3cd6d3	Q-IDA CAT 8KGS	7702712003388	t	69000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.159627	2025-10-19 02:29:42.159627
feae9a2c-747e-48cb-ab1a-fc15b78e42db	CETIRIZINA LA SATE X10UNID	CEDC5874	t	3000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.159852	2025-10-19 02:29:42.159852
b4f63fc2-f96c-4948-bc37-23a053f98231	TRATAMIENTO PANTENE REPARA Y PROTEGE ANTI FRIZZ 300ML	7501006740219	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.1601	2025-10-19 02:29:42.1601
6d3d1187-b5bd-4564-bd60-7a9aea4512db	AXION LIMON 150GR	77044273	t	2100.00	1990.00	\N	\N	19.00	2025-10-19 02:29:42.160326	2025-10-19 02:29:42.160326
9f57e4b5-a96f-4201-bded-a429a600fc84	DOWNY ADORAVEL 450ML	7500435159999	t	6900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.160543	2025-10-19 02:29:42.160543
ea752bab-b535-4f59-9318-9809aa0b5f7a	TROLLI MANIBUU 40GR	7702174085953	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.160759	2025-10-19 02:29:42.160759
9499019f-834d-436f-873a-62c60c4bbb40	FESTIVAL CHIPS UND	7702025144204	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.160994	2025-10-19 02:29:42.160994
6a6ef0d5-cca1-4306-b9db-e4343b759f53	AGUA LA MEJOR X20 UNDS	AGUA LA MEJOR X20 UNDS	t	4000.00	3600.00	3500.00	\N	0.00	2025-10-19 02:29:42.161201	2025-10-19 02:29:42.161201
0f582260-a870-4e6a-96af-50f1318a4528	PAPAS NATURAL MARGARITA 36GR	7702189056030	t	2400.00	2250.00	2180.00	\N	19.00	2025-10-19 02:29:42.161424	2025-10-19 02:29:42.161424
082a1942-997f-40f9-98c5-b1c047e36efc	FRUTIÑO MEZCLAS GELATINA	7702354951139	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.161775	2025-10-19 02:29:42.161775
385c2a27-9ffc-4db3-a9d0-1ba68f3a49d8	tocineta x12 und natural	7706642010096	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.162	2025-10-19 02:29:42.162
1f9cc3f0-14b9-41c6-976e-9f571a025d9b	CAFE LA BASTILLA 390GR	7702032118762	t	19500.00	19000.00	\N	\N	5.00	2025-10-19 02:29:42.162271	2025-10-19 02:29:42.162271
ca9f81d8-cd46-4f66-9935-68098b9d7f09	COLGATE MAXIMA PROTECCION ANTICARIES 150ML	7509546652153	t	11200.00	10900.00	\N	\N	19.00	2025-10-19 02:29:42.162524	2025-10-19 02:29:42.162524
50f4b590-7be3-45e5-bbd6-90f3ec540e9a	MAIZ DULCE ZENU 415GR	7701101360576	t	9300.00	9100.00	\N	\N	19.00	2025-10-19 02:29:42.162755	2025-10-19 02:29:42.162755
eb952032-ffae-4ff7-84c0-39ded9f47b19	ATUN LA SOBERANA PREMIUM 140GR	7702910038700	t	6800.00	6600.00	\N	\N	19.00	2025-10-19 02:29:42.162965	2025-10-19 02:29:42.162965
22434ccf-998a-4f95-a4d5-57201b780cad	NUBE MEGA ROLLO X12UNID	7707151604066	t	14000.00	13500.00	\N	\N	19.00	2025-10-19 02:29:42.163194	2025-10-19 02:29:42.163194
4668b5d9-10c6-408c-8647-8fed2eac3a8f	JUMBO MANI X12UNID 420GR X35GR	7702007080377	t	41200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.163426	2025-10-19 02:29:42.163426
4a8f6dbd-47c0-475c-8d7e-51d338a72095	QIDA CAN ADULTO 1KG	7702712005870	t	4900.00	4750.00	\N	\N	5.00	2025-10-19 02:29:42.163646	2025-10-19 02:29:42.163646
1e447457-d4ac-47c5-a16f-313d22bc6b24	MAIZ PIRA LA SOBERANA 460GR	7702910354251	t	2100.00	2000.00	\N	\N	0.00	2025-10-19 02:29:42.163859	2025-10-19 02:29:42.163859
5dc99391-5071-47d5-980d-2c743d636551	ARVEJA VERDE LA SOBERANA 460GR	7702910354039	t	2200.00	2050.00	\N	\N	0.00	2025-10-19 02:29:42.164083	2025-10-19 02:29:42.164083
24e11f3d-7d81-4a94-929a-4f5870dd5254	SUPPREMO LAVALOZA TAZA 450G	7708872634998	t	5700.00	5500.00	\N	\N	19.00	2025-10-19 02:29:42.164316	2025-10-19 02:29:42.164316
03ca3285-debc-46b0-a5f5-77de9c7763ea	WAFER JET X20UNID 22GR	7702007524024	t	36000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.164523	2025-10-19 02:29:42.164523
84f2099e-de2e-4b6a-872c-505ca0134c75	MAREOL PASTILLA	D4C63	t	800.00	\N	\N	\N	0.00	2025-10-19 02:29:42.164739	2025-10-19 02:29:42.164739
aac3e4cc-5b49-4cdc-a9c7-c1a594d2adc7	CHEETOS HORNEADO MINI 20GR	7702189058591	t	1200.00	1120.00	\N	\N	19.00	2025-10-19 02:29:42.164989	2025-10-19 02:29:42.164989
25c1d459-5e55-43b9-b4cf-af0ead404998	JUGO HIT X24 UNID	DC65	t	22000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.165243	2025-10-19 02:29:42.165243
37ed3835-c984-466f-87cd-39f97055cb35	SABRINA 4 BARRAS 125GR	7706649804261	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.165482	2025-10-19 02:29:42.165482
d023afbc-3549-408b-b9a6-9c6d2ec0eba3	CHEETOS HORNEADOS MINI 15GR	7702189058560	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.165716	2025-10-19 02:29:42.165716
babe7b7e-5969-4d16-900f-8f0b2cb74283	CHEETOS HORNEADOS PICANTE MINI 20GR	7702189058577	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.165953	2025-10-19 02:29:42.165953
c1f97252-e971-4868-bde1-94c76cf9cd0a	PAPAS ONDULADAS DE TOMATE MARGARITA 35GR	7702189057822	t	2400.00	2250.00	2180.00	\N	19.00	2025-10-19 02:29:42.166193	2025-10-19 02:29:42.166193
415207f3-b577-4533-a56e-7b254db4e698	PAPAS CREMA Y CEBOLLA MARGARITA 36GR	7702189056696	t	2400.00	2250.00	2180.00	\N	19.00	2025-10-19 02:29:42.166437	2025-10-19 02:29:42.166437
e2babe82-2fcb-4f49-9af9-a0ace80d6b29	PAPAS POLLO MARGARITA 36GR	7702189056047	t	2400.00	2250.00	2180.00	\N	19.00	2025-10-19 02:29:42.166672	2025-10-19 02:29:42.166672
de6569f5-aa07-414f-ae95-bf28bfd0be80	PAPAS BBQ MARGARITA 36GR	7702189056016	t	2400.00	2250.00	2180.00	\N	19.00	2025-10-19 02:29:42.166892	2025-10-19 02:29:42.166892
1c14fa97-991a-4734-8d17-1d8530415b68	ENJUAGUE BUCAL ORAL PLUS VERDE ZERO 180ML	7708682913702	t	6100.00	5950.00	\N	\N	19.00	2025-10-19 02:29:42.167127	2025-10-19 02:29:42.167127
b6bfb69f-6961-47e1-9dda-cf737029f2d4	SHAMPOO DOVE ANTICASPA 2 EN 1 370ML	7702006208710	t	16500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.167359	2025-10-19 02:29:42.167359
993163c9-bd4e-4b79-ae0e-8ca7cd544478	TROZOS DE ATUN EN AGUA PAN 150GR	7702084900131	t	6100.00	5900.00	\N	\N	19.00	2025-10-19 02:29:42.167664	2025-10-19 02:29:42.167664
9a24a514-dc5f-4f28-b758-13ac08a86659	TROZOS DE ATUN EN ACEITE PAN  150GR	7702084900148	t	6100.00	5900.00	\N	\N	19.00	2025-10-19 02:29:42.167886	2025-10-19 02:29:42.167886
84235858-9938-4f6b-90a5-a49b3b20f48b	TALLARIN DORIA 500GR	7702085013052	t	3800.00	\N	\N	\N	5.00	2025-10-19 02:29:42.168159	2025-10-19 02:29:42.168159
ae4b05fc-2d8d-4020-922a-c09d6a5b7957	JABONERA KENDY	7708284948508	t	1500.00	1380.00	\N	\N	19.00	2025-10-19 02:29:42.168468	2025-10-19 02:29:42.168468
16476eb5-eda6-412f-8375-c2ab28745998	SALERO PALILERO MUNDO UTL	7709945064940	t	1500.00	1450.00	\N	\N	19.00	2025-10-19 02:29:42.168808	2025-10-19 02:29:42.168808
7c9df8d2-10cc-476e-9e32-dc97ac8a7483	ENCENDEDOR MULTIUSOS EL SOL	7707015508509	t	5300.00	5100.00	\N	\N	19.00	2025-10-19 02:29:42.169147	2025-10-19 02:29:42.169147
91833f87-4cee-40a1-933a-7e9207f4456d	DETERK LAVANDA 1.100GR	7702310045537	t	7500.00	7400.00	\N	\N	19.00	2025-10-19 02:29:42.169475	2025-10-19 02:29:42.169475
c62837e0-1c56-4248-8244-bb1c077a3194	DETERK LAVANDA 3.000GR	7702310045544	t	20500.00	20000.00	\N	\N	19.00	2025-10-19 02:29:42.169767	2025-10-19 02:29:42.169767
973de627-4597-459a-93be-ee8e3524a88e	COLGATE LUMINOUS WHITE 75ML X2 MAS EJUAGUE 250ML	7702010611995	t	31600.00	31000.00	\N	\N	19.00	2025-10-19 02:29:42.170038	2025-10-19 02:29:42.170038
f39ef1e3-d9b6-4b8c-9295-878507a47034	AROMA INSTANTANEO 50GR GRANULADO	7707199660376	t	9400.00	\N	\N	\N	5.00	2025-10-19 02:29:42.170317	2025-10-19 02:29:42.170317
ad2fab78-dcf3-4ec8-9d63-f85e1c563bc6	SHAMPOO DOVE RECONSTRUCCION 750ML	7791293002897	t	24500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.170568	2025-10-19 02:29:42.170568
ac6e7d35-bf0e-4bd5-a5df-77b8c6a3a59d	CREMA PARA PEINA PANTENE RIZOS 30ML	7501001170080	t	16500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.170809	2025-10-19 02:29:42.170809
a68ef957-334e-48a5-ac02-eb3d17741218	BILAC X12UNID	CEOKC	t	16500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.17103	2025-10-19 02:29:42.17103
a1fdb043-48ce-491e-a5e1-a4d8974d24cd	CHISSTOZO X12UNID	7706642002046	t	8600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.17128	2025-10-19 02:29:42.17128
de2db20e-dc2c-4943-9b79-6e7942ada120	AGUA DE BOLSA LA MEJOR X20UNID	AGUA	t	4000.00	4000.00	3500.00	\N	0.00	2025-10-19 02:29:42.17153	2025-10-19 02:29:42.17153
c8d83b11-f3cd-4712-b5e2-5378ebe4dd71	AVENA HOJUELA BJ 500GR	7709046415542	t	2600.00	2500.00	\N	\N	5.00	2025-10-19 02:29:42.171814	2025-10-19 02:29:42.171814
81914c38-7634-4ccf-8d14-c250a8682285	PROLECHE ENTERA 380GR	7702130612414	t	7100.00	\N	\N	\N	0.00	2025-10-19 02:29:42.172138	2025-10-19 02:29:42.172138
5b86d730-63cf-4492-bba4-81f624728bbe	MANICERO LA ESPECIAL X12UNID	7702007082975	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.172402	2025-10-19 02:29:42.172402
0f2ce277-61ed-44e4-9d7b-8331b0a48031	JET CARAMEL X18UNID	7702007082593	t	6200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.172657	2025-10-19 02:29:42.172657
3ba76613-8ab5-4259-84b2-e1ae1014b8a5	GOL MELO X20UNID	7702007082685	t	5000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.173034	2025-10-19 02:29:42.173034
6be0f336-f87e-4b86-a117-281fd581c52c	COLCAFE 3 EN 1 19GR	7702032118182	t	1400.00	\N	\N	\N	5.00	2025-10-19 02:29:42.173355	2025-10-19 02:29:42.173355
b53a83b0-8e39-4cfc-98d5-dfc355699043	COLCAFE CAFE CON LECHE 22GR	7702032117802	t	1600.00	1517.00	\N	\N	19.00	2025-10-19 02:29:42.173579	2025-10-19 02:29:42.173579
fc55b784-c1b0-4750-baf3-5e40961f3d63	HEAD SHOULDERS 18ML	002442	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.173806	2025-10-19 02:29:42.173806
ce294454-1e29-4a19-9d7a-bce47ee49cd3	SERVILLETA SKAAP 180HJ	7707371210153	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:42.174174	2025-10-19 02:29:42.174174
95377b1f-143c-4a4f-82a3-aae415f91bcd	LECHE CONDENSADA EL ANDINO TETERO 400GR	7700211072225	t	7200.00	6950.00	\N	\N	0.00	2025-10-19 02:29:42.174384	2025-10-19 02:29:42.174384
ffed6a30-73af-470b-8cd0-4fbb47c2000a	PROTECTORES ELLAS 180 UNID MAS BODY SPASH	7702108206317	t	15000.00	14600.00	\N	\N	0.00	2025-10-19 02:29:42.174581	2025-10-19 02:29:42.174581
bf9d05c2-fbad-4f78-90d8-af35e3c24838	BALANCE MEN CLINICAL X18UNID	7702045453423	t	19300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.174822	2025-10-19 02:29:42.174822
c69cfc9c-89c0-4bb5-bbab-507123fffcde	LADY SPEED STICK CLINICAL 9GR	7501033210785	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.175079	2025-10-19 02:29:42.175079
dd89f55c-3da2-45b7-8bc2-3eb0218f78e4	SPEED STICK CLINICAL 9GR	7501033210778	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.17531	2025-10-19 02:29:42.17531
da32e20d-bbb5-4769-9c65-d731309e9fe2	GOLPE X8 RANCHERO BBQ LIMON PICANTE	CWCERLCOM	t	20200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.175522	2025-10-19 02:29:42.175522
13573a76-d009-4b42-b8f5-f3a0ade66c91	SALSA BBQ BARY 1.330GR	7702439008802	t	14800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.175757	2025-10-19 02:29:42.175757
62e3e945-a6e1-4b90-b82e-fd5e11e75938	SALSA NEGRA BARY 1.1165ML	7702439008840	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.175958	2025-10-19 02:29:42.175958
930c276d-8924-4e92-a876-168f991ffaf4	FRIJOL ZARAGOZA NORSAN 500GR	7709861625829	t	4100.00	4000.00	\N	\N	0.00	2025-10-19 02:29:42.176166	2025-10-19 02:29:42.176166
b20e0904-34af-40c5-b011-ae6a0dc962be	CARAOTA NORSAN 500GR	7709861625850	t	3200.00	3100.00	\N	\N	0.00	2025-10-19 02:29:42.176389	2025-10-19 02:29:42.176389
d56c27bb-79af-4dff-92a1-3d44a69dd926	JUMBO MINIS X32UNID	7702007057744	t	15300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.176606	2025-10-19 02:29:42.176606
32979322-837c-4172-aafc-d83ce8c8a659	ATUN PERLADO LOMO 175GR	7709378111068	t	3900.00	3800.00	\N	\N	19.00	2025-10-19 02:29:42.176855	2025-10-19 02:29:42.176855
46523d8a-e8cc-487b-be20-5b82bec0a051	TRATAMIENTO ANYELUZ BIO TERAPIA  300ML	7708928066155	t	37700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.177085	2025-10-19 02:29:42.177085
75ec5630-cab7-4366-a1d9-6a6069eabbe1	ESPUMA DE AFEITAR CABON ACTIVO 150GR	7500435219754	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.177323	2025-10-19 02:29:42.177323
fcaeab6d-a0cb-49eb-811b-4624e9143ec7	GARBANZO LA SOBERANA 500GR	7702910354282	t	3200.00	3050.00	\N	\N	0.00	2025-10-19 02:29:42.177559	2025-10-19 02:29:42.177559
f14028bf-1664-4815-9336-0a6d5bee6f45	SPRAY DESENREDANTE JOHNSONS GOTA DE BRILLO 200ML	7702031604143	t	15000.00	14500.00	\N	\N	19.00	2025-10-19 02:29:42.177778	2025-10-19 02:29:42.177778
e6dba2a1-f239-49f2-8953-689064c2b35e	LENTEJA LA SOBERANA VERDE 454GR	7702910354213	t	3200.00	3100.00	\N	\N	0.00	2025-10-19 02:29:42.178006	2025-10-19 02:29:42.178006
a62726c1-ca86-4c9d-ac59-f8db45683139	LOCION CORPORAL VITU 1L	7702044255752	t	17900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.178306	2025-10-19 02:29:42.178306
4c9a35d2-86ea-42e5-a7fc-0499cda20246	GEL DE BAÑO AMALFI MORA 750ML	8414227040695	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.178566	2025-10-19 02:29:42.178566
bdbf420f-798c-46dd-9f6e-0611c35a3e89	VINAGRE BALSAMICO MONTICELLO 250ML	7702085003916	t	18200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.178795	2025-10-19 02:29:42.178795
4f966042-73a1-4e82-8147-8121d0bb0e16	DETERGENTE VEL ROSITA 1.8L MAS 2 FAB BARRA 300GR	7702191661291	t	29500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.17903	2025-10-19 02:29:42.17903
1547330c-c324-4cd1-bba8-26592f449f55	GILLETE MACH3 COMPLETE 200ML	7702018013012	t	21500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.179321	2025-10-19 02:29:42.179321
bf21ac14-184f-47e4-afa5-b1f3142a838e	AROMATEL COCO 900ML	7702191451861	t	8200.00	8000.00	\N	\N	19.00	2025-10-19 02:29:42.179564	2025-10-19 02:29:42.179564
e978750e-09ca-4c8e-a0bc-29af4e585997	ALMENDRA CHOCOLATE ITALO 150GR	7702117011056	t	10400.00	10000.00	\N	\N	19.00	2025-10-19 02:29:42.179839	2025-10-19 02:29:42.179839
1023e5b9-474b-432e-9fd7-f6596a25225e	LAPIZ OFFI ESCO OE 150	LAPIZ	t	600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.180101	2025-10-19 02:29:42.180101
0458b7f7-6c8a-47e4-bfc5-575abaa63cdf	JABON INTIMO NOSOTRAS ALGDON 200ML	7702026177546	t	12500.00	12000.00	\N	\N	19.00	2025-10-19 02:29:42.180359	2025-10-19 02:29:42.180359
a1b4a4e7-d838-4545-aba9-2a5b3f76ab8f	VENENO BLANCO 1L	CKLOCE	t	6000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.18066	2025-10-19 02:29:42.18066
e1d5a793-0455-4d51-a495-2a03208aef05	DIABLO ROJO 320GR	7709694849188	t	5400.00	5200.00	\N	\N	19.00	2025-10-19 02:29:42.180881	2025-10-19 02:29:42.180881
43f1ccdf-4d70-4736-965c-d06dbfdb1401	BUCARO MANTECA	7702028015204	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.181144	2025-10-19 02:29:42.181144
16fb92f2-de65-4c4f-9759-3ee154ad4c05	TOSTADO	TOSTADO	t	3500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.181438	2025-10-19 02:29:42.181438
7e44b633-e411-453f-8dd9-0d4283593281	PINGUINOS X3 UND 120GR	7705326080943	t	3500.00	3400.00	\N	\N	19.00	2025-10-19 02:29:42.181674	2025-10-19 02:29:42.181674
67f246ed-c82a-4051-919a-4ab4e5ae3635	TRATAMIENTO TONO SOBRE TONO VIOLET	7709990987270	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.181906	2025-10-19 02:29:42.181906
e16af9c2-a62c-428e-aaad-029ef8570351	TONO SOBRE TONO BEIGE PERLA	7707197608912	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.182109	2025-10-19 02:29:42.182109
984296da-bcc1-4937-837f-f07eccccbcfc	ROCIO DE ORO LOCION ACLARADORA	7709947068625	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.182335	2025-10-19 02:29:42.182335
2512344b-3852-4e51-89e6-bb78ec5087a6	ROCIO DE ORO SHAMPOO ACLARADOR NIÑOS 500ML	7709586163828	t	27600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.182542	2025-10-19 02:29:42.182542
f9b06d60-6c85-483f-9e0b-8864279d6efa	CREMA DE PEINAR SAVITAL 25ML	7702006207782	t	1000.00	900.00	\N	\N	19.00	2025-10-19 02:29:42.182754	2025-10-19 02:29:42.182754
27b5171e-4d52-4017-943f-720fba56a60f	LECHE CONDENSADA TETERO LA SABANA 390GR	7707336380075	t	7200.00	7000.00	\N	\N	0.00	2025-10-19 02:29:42.183021	2025-10-19 02:29:42.183021
bd81fd60-0171-4eb0-8179-70379c95c4e1	zSALCHICHA ZENU 10 UND	7701101260425	t	9500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.183324	2025-10-19 02:29:42.183324
a5ea8542-c959-42d2-9558-fd835137c279	TRIDENT 60UND SANDIA	7622201765156	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.18376	2025-10-19 02:29:42.18376
2377d87f-ea8c-4817-a6de-b1bae8654290	TIC TAC X12 CAJAS	8000500207826	t	20700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.184018	2025-10-19 02:29:42.184018
a2d5f0e5-3c88-483a-8ef4-cc8182451ff6	MERCURY BOMBILLO LED 50W	7707692868385	t	25000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.18428	2025-10-19 02:29:42.18428
24571c84-10e6-4590-8987-c59ae03e0f89	FRUTSSI SIXPACK	7704269111493	t	5500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.184536	2025-10-19 02:29:42.184536
a5603b57-1013-429f-b1b3-0c22efd8e1da	AZUCAR MANUELITA 500GR	7702406001188	t	2000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.18477	2025-10-19 02:29:42.18477
653114ac-fd15-4a9b-b119-36e63a445162	CREMA CHANTILLY CORDILLERA 300GR	7702007081336	t	21800.00	21200.00	\N	\N	19.00	2025-10-19 02:29:42.185013	2025-10-19 02:29:42.185013
ff4cbec7-0f56-4458-9b80-cd0e1633d6a3	NOEL SULTANA X12UNID	7702025188802	t	10700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.185301	2025-10-19 02:29:42.185301
617352dd-0937-4514-95a3-b5ad553725b7	CHEESE TRIS MINI 30GR	7702189058607	t	1200.00	1150.00	\N	\N	19.00	2025-10-19 02:29:42.18553	2025-10-19 02:29:42.18553
b0aff11e-9ccf-4a59-ac41-0805e17f51b9	SHAMPOO ARRURRU CABELLO OSCURO 750ML	7702277233015	t	33900.00	27800.00	\N	\N	19.00	2025-10-19 02:29:42.185771	2025-10-19 02:29:42.185771
400bde0f-f126-473a-b48b-02dc3d6c3a4f	TRULULU ORO 70GR	7702993051771	t	1800.00	1700.00	\N	\N	19.00	2025-10-19 02:29:42.186291	2025-10-19 02:29:42.186291
a16f5afa-9d61-486e-9660-5a555cc74083	FUZE TEA HERBAL 400ML	7702535018651	t	3100.00	2834.00	\N	\N	19.00	2025-10-19 02:29:42.186578	2025-10-19 02:29:42.186578
2d9ee221-5d39-42ee-b886-ed5451ce669d	FAB ULTRA FLASH 5KG	7702191164389	t	47000.00	46200.00	\N	\N	19.00	2025-10-19 02:29:42.186856	2025-10-19 02:29:42.186856
cf0c2bba-4ca3-44a8-8a32-a766e0f7efa8	COMPLETISIMO X36	7702354953799	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.187112	2025-10-19 02:29:42.187112
5dbe1ae0-2e2e-412f-ac26-ab31c8e8a839	POPETAS CARAMELO 165GR	7702354934316	t	4200.00	4050.00	\N	\N	19.00	2025-10-19 02:29:42.187363	2025-10-19 02:29:42.187363
3e7fbaed-828d-4c98-b5b8-8e54ec0c70be	ALUMINIO HOUSE 16M CAJA	7707320620675	t	5300.00	5150.00	\N	\N	19.00	2025-10-19 02:29:42.187573	2025-10-19 02:29:42.187573
09b1c61c-46f3-499e-b196-3e524b81cfcd	AROMATICA TOSH INFUSON DE TORONJIL CALMA 20UNID	7702032114221	t	8300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.187938	2025-10-19 02:29:42.187938
49852be6-c0f8-429b-a98b-4daf29595e70	PAN FRESCO	SCE5	t	3000.00	2900.00	\N	\N	0.00	2025-10-19 02:29:42.188238	2025-10-19 02:29:42.188238
e35f6119-d6cf-4e21-9158-8cd84513b41b	ESCOBA DALIA PEQUEÑA	DE	t	4000.00	3900.00	\N	\N	19.00	2025-10-19 02:29:42.188617	2025-10-19 02:29:42.188617
a78f87f7-2721-42ee-be82-e0c3164783ea	MECHAS DE TRAPERO JG	KCCK	t	6300.00	6050.00	\N	\N	19.00	2025-10-19 02:29:42.189003	2025-10-19 02:29:42.189003
42cef3ed-129b-4992-81b0-e781a82bb130	ATUN RALLADO MI DIA 160GR	7700149005456	t	3000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.189275	2025-10-19 02:29:42.189275
f6917c6c-a9cb-4186-b5f3-2cab237d93c5	RELY TALLA M X8UNID	7709943332256	t	19500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.18958	2025-10-19 02:29:42.18958
5475d44d-1bb9-4381-9e56-8f2e100632d9	RELY TALLA L X8UNID	7709674433468	t	24000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.189879	2025-10-19 02:29:42.189879
d6690027-ed79-45da-b972-507186214cf8	EMBOPLAS 300MTS BUMANGUES	KCE	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.190116	2025-10-19 02:29:42.190116
4e60419d-123d-4496-a827-cd53c3923ef8	ORAL KID PLUS	7707860027606	t	11700.00	11400.00	\N	\N	19.00	2025-10-19 02:29:42.190389	2025-10-19 02:29:42.190389
11c27b69-cdef-44d6-a17b-ee25b042f0f5	PAÑITOS WINY X24UNID	7701021143655	t	3000.00	2850.00	\N	\N	19.00	2025-10-19 02:29:42.190639	2025-10-19 02:29:42.190639
cda7ec46-96b8-4b60-b3b7-f56aef6fd22b	KOTEX ESENCIAL X8UNID	7441008167914	t	3700.00	3500.00	\N	\N	0.00	2025-10-19 02:29:42.19087	2025-10-19 02:29:42.19087
e8a1af0a-6130-4dba-89b4-3110dd69a2f1	GELA PLAY YOLIS FIGURAS X20UNID	7707337520647	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.191151	2025-10-19 02:29:42.191151
0468838f-7d4a-43d7-b6e6-48770009d4c5	BOKA LOKA X20UNID YOLI	7708527098434	t	15800.00	15300.00	\N	\N	19.00	2025-10-19 02:29:42.191465	2025-10-19 02:29:42.191465
30774bc9-f1e9-4adb-b7d5-35e9e200ad30	LINAZA MOLIDA 50GR	7707767143607	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.191816	2025-10-19 02:29:42.191816
5a97c8b8-64e7-457f-b498-3affd7dd8fa5	COCO DESHIDRATADO LA SAZON DE LA VILLA 50GR	7707767148459	t	2100.00	\N	\N	\N	0.00	2025-10-19 02:29:42.192171	2025-10-19 02:29:42.192171
233c4c14-77d2-455b-8e49-46a46b696a33	CUAJO MARSCHALL	CEKÑ	t	800.00	\N	\N	\N	0.00	2025-10-19 02:29:42.192469	2025-10-19 02:29:42.192469
7e7d0d1a-012b-4ea3-8f1f-e313bcedee9e	SALSA DE PIÑA IDEAL 240GR	7709912927834	t	3100.00	2980.00	2860.00	\N	19.00	2025-10-19 02:29:42.19288	2025-10-19 02:29:42.19288
86e82057-d191-4fdc-b742-13ba287e06e1	MOSTAZA IDEAL 225GR	7709912927858	t	2600.00	2480.00	2380.00	\N	19.00	2025-10-19 02:29:42.193141	2025-10-19 02:29:42.193141
c867d98f-3ed6-4d50-9479-d98fc5375b5d	SALSA DE TOMATE IDEAL 225GR	7709912927872	t	2600.00	2500.00	2400.00	\N	19.00	2025-10-19 02:29:42.193401	2025-10-19 02:29:42.193401
94988c40-4120-4d5d-a8da-c10e8051ae28	MAYONESA IDEAL TARRO 200GR	7709392006081	t	2500.00	2380.00	2280.00	\N	19.00	2025-10-19 02:29:42.193644	2025-10-19 02:29:42.193644
b2a9bd47-beca-404f-85e2-b707210f536f	AZUCAR IDEAL 1000GR	7709531779500	t	3400.00	3360.00	\N	\N	5.00	2025-10-19 02:29:42.193874	2025-10-19 02:29:42.193874
b3a2d023-a49a-44a6-8965-6e6744a20ce2	CLAVOS LA SAZON DE LA VILLA 20GR	7707767149142	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.194083	2025-10-19 02:29:42.194083
453eb4da-3df9-4948-a3d4-20c53516a806	SALSA DE TOMATE IDEAL X12UNID X90GR	7708276981957	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.194392	2025-10-19 02:29:42.194392
1de53124-6870-44f5-b21b-852c24475228	NESCAFE TRADICIONAL 170GR MAS MUSS	7702024076513	t	24000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.194694	2025-10-19 02:29:42.194694
7da98308-1ca0-4986-921c-93f82078baea	ARRURRU ESTUCHE VIAJERO AMARILLO	7702277943150	t	29000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.194929	2025-10-19 02:29:42.194929
50ed2f2c-220c-43a4-b3dc-e2795cac8a39	ARRURRU ESTUCHE VIAJERO ROJO	7702277375838	t	29000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.195203	2025-10-19 02:29:42.195203
03dc0890-7945-4eae-b799-49c5fbaf7511	RAMITO X8UNID	7702914603485	t	7500.00	7400.00	\N	\N	19.00	2025-10-19 02:29:42.195518	2025-10-19 02:29:42.195518
af06f502-2ba4-4e04-8fbe-6e1277def507	PAÑITOS PEQUEÑIN ALMENDRAS X24UNID	7702026147594	t	3300.00	3150.00	\N	\N	19.00	2025-10-19 02:29:42.195724	2025-10-19 02:29:42.195724
2246b08c-070c-455d-b1f1-ba13e95073df	MIRRINGO 8KILOS	MIRRI	t	68000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.196015	2025-10-19 02:29:42.196015
45e48ce7-db9a-4e97-8f3c-416b7e3c6f14	FAMILIA EXPERT X4UNID	7702026148522	t	11300.00	10800.00	\N	\N	19.00	2025-10-19 02:29:42.196239	2025-10-19 02:29:42.196239
d4ad2c32-a481-4739-9ffa-887600bfe7ad	MAIZ PILADO EL AGUILA 500GR	7700800224868	t	1500.00	1400.00	\N	\N	0.00	2025-10-19 02:29:42.196444	2025-10-19 02:29:42.196444
7d34a85b-4bad-4ff9-989b-18b59b59036d	LADY SPEED SCTICK REDUCE VELLO 60GR	7509546684741	t	7300.00	7100.00	\N	\N	19.00	2025-10-19 02:29:42.196664	2025-10-19 02:29:42.196664
edeeef43-e3d0-47e1-9b36-c57609978281	FABULOSO BEBE 2LITROS	7702010310225	t	18000.00	17500.00	\N	\N	19.00	2025-10-19 02:29:42.19703	2025-10-19 02:29:42.19703
10e5c48b-923d-487e-b584-0f04237dfdbd	CHOCOLISTO CHOCOLATE 600GR	7702007069396	t	19300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.19729	2025-10-19 02:29:42.19729
8932c546-49dc-4d49-bb8a-fb7a82a3f4f2	CORONA COCOA SUPERIOR CANELA AREQUIPE 120GR	7702007080209	t	4300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.197495	2025-10-19 02:29:42.197495
7009c7e9-7f81-4dcf-b0a9-0ed18bd2aa56	GOL CHOCOLATE X15UNID	7702007080636	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.197696	2025-10-19 02:29:42.197696
ee429b93-0a29-476b-8227-d182140e1be3	BRILLO MATRIX X12	BRILLO 2	t	6300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.197933	2025-10-19 02:29:42.197933
224fdc55-8e2b-4bef-89c6-c48613f9bb1f	PAÑAL  BABY DREAM ETAPA 1 X50	7709513647681	t	29000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.198176	2025-10-19 02:29:42.198176
cab6d60f-502a-44e7-a5fc-09ae906f934e	LAVALOZA DISCO PODER 150GR	7707181393442	t	1000.00	900.00	\N	\N	19.00	2025-10-19 02:29:42.198378	2025-10-19 02:29:42.198378
0f76ea5e-a6f8-43a1-8f11-d2d040bacf49	VASOS TUC 5.5 X50UNID	7702144010541	t	2300.00	2200.00	\N	\N	19.00	2025-10-19 02:29:42.198607	2025-10-19 02:29:42.198607
d6300dc4-3e21-43f9-b383-dc690b2b9839	ARIEL TRIPLE PODER 700GR	7500435245296	t	6700.00	6500.00	\N	\N	19.00	2025-10-19 02:29:42.198841	2025-10-19 02:29:42.198841
17e70e16-6177-4356-b25a-39f6f9a81c1b	COMPOTA HEINZ COCTEL 113GR	608875003272	t	3500.00	3250.00	\N	\N	19.00	2025-10-19 02:29:42.199066	2025-10-19 02:29:42.199066
a4666a51-05af-4301-a3cc-3b3b451902c0	COMPOTA CALIFORNIA PERA 113GR	7702477115289	t	2700.00	2459.00	\N	\N	19.00	2025-10-19 02:29:42.199291	2025-10-19 02:29:42.199291
88299b7c-1c49-47cd-b3c9-51cf2327fcb3	SERVILLETA SARITA X300UNID	7707371212744	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:42.199545	2025-10-19 02:29:42.199545
e266d6ce-1802-45c5-8926-577c0998c287	ARVEJA AMARILLA NORSAN 500GR	7709641345527	t	2100.00	1950.00	\N	\N	0.00	2025-10-19 02:29:42.199796	2025-10-19 02:29:42.199796
d7710e79-c287-456d-8bbc-9980b338c6fc	GUANTES ETERNA COCINA TALLA 8	7702037503259	t	5100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.200027	2025-10-19 02:29:42.200027
96babbc4-3770-434a-89f8-9ea2685c07ae	ELITE SUAVE TRIPLE HOJA 28M	7707199344979	t	1700.00	1625.00	\N	\N	19.00	2025-10-19 02:29:42.200232	2025-10-19 02:29:42.200232
609d01ea-af3d-4661-9b76-4eda48063f19	POOL 250ML BANDEJA X24 UNIDADES	POOL 250ML BANDEJA X24	t	19300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.20046	2025-10-19 02:29:42.20046
71403053-64c9-4504-be34-79114fc1c0fd	HARINA D MAIZ DE MARIA 1000GR	7709301781016	t	2500.00	2500.00	\N	\N	5.00	2025-10-19 02:29:42.200696	2025-10-19 02:29:42.200696
7957089e-0a13-4d77-b72d-ec3d53eb566c	CHOCOLATE IDEAL TRADICIONAL 250GR	7709511768135	t	4200.00	4080.00	\N	\N	19.00	2025-10-19 02:29:42.200916	2025-10-19 02:29:42.200916
d4fb1a75-2892-45da-b21d-9defc67694d6	CHOCOLATE IDEAL TRADICIONAL 500GR	7709511768159	t	8000.00	7780.00	\N	\N	19.00	2025-10-19 02:29:42.201129	2025-10-19 02:29:42.201129
54712f15-c58f-4712-b540-75f2f49e6ca2	PIOLO AREQUIPE 45GR	7705326080776	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:42.201386	2025-10-19 02:29:42.201386
45b2ed00-9cb1-43c5-9a30-d568991c6925	ELITE DUO X4UNID	7709554623590	t	7700.00	7450.00	\N	\N	19.00	2025-10-19 02:29:42.201624	2025-10-19 02:29:42.201624
cdb6ef03-46b0-41d9-a271-e28674d01505	AJO DEL SAZON 170ML	7708508067374	t	2100.00	1950.00	\N	\N	19.00	2025-10-19 02:29:42.201892	2025-10-19 02:29:42.201892
37fa38ac-7e59-4a9b-8e4b-41baf61ab289	SALSA CHINA DELSAZON 170ML	7705465005081	t	2100.00	1950.00	\N	\N	19.00	2025-10-19 02:29:42.20212	2025-10-19 02:29:42.20212
b6096f50-af80-48a2-99ac-e4680fa98279	AGUA OXIGENADA 120ML JGB	7702560000010	t	4600.00	4400.00	\N	\N	0.00	2025-10-19 02:29:42.202376	2025-10-19 02:29:42.202376
ac9a87c1-91f4-4096-a053-84ecf777909c	INDULECHE 125GR X6 UND	0117706921024056	t	30900.00	\N	\N	\N	0.00	2025-10-19 02:29:42.202641	2025-10-19 02:29:42.202641
f25ea8a0-cd0a-4b54-9cf9-2ef396312305	NOSOTRAS NORMAL SIN ALAS X10	7702027040023	t	3600.00	3450.00	\N	\N	0.00	2025-10-19 02:29:42.202918	2025-10-19 02:29:42.202918
e4983ea0-6182-485a-a8a2-6e363d8fc279	BEBEX XG x 30	7709606194177	t	31500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.203195	2025-10-19 02:29:42.203195
079de833-cd75-423f-a9ca-1833f1f0cb98	LIMPIAPISOS 123 LAVANDA 3.7LI	7707839189885	t	9200.00	9000.00	\N	\N	19.00	2025-10-19 02:29:42.203389	2025-10-19 02:29:42.203389
f740a86a-cba2-448b-815a-a32d94797a85	JABON EDEN 2.8 KILOS	7704269112049	t	13800.00	13400.00	\N	\N	19.00	2025-10-19 02:29:42.203661	2025-10-19 02:29:42.203661
d3a0dd76-13cb-4d36-8115-4a9f48f71a40	JABON EDEN LIMON BICARBONATO 1KG	7704269114395	t	5500.00	5300.00	\N	\N	19.00	2025-10-19 02:29:42.203873	2025-10-19 02:29:42.203873
806cb340-153b-48a6-975c-7fbfa317a555	LIMPIAPISOS 123 LAVANDA 1L	7707183660597	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:42.20413	2025-10-19 02:29:42.20413
bacf3ecd-e264-47be-90e4-8d508a838f91	AROMATEL FLORAL 1.8 TARRO	7702191164112	t	16000.00	15600.00	\N	\N	19.00	2025-10-19 02:29:42.204395	2025-10-19 02:29:42.204395
22cd3987-83e1-4696-a3f4-2b0f24e3d2d7	ESCOBA ANDELCO MEGA	SCOEWK	t	4900.00	4750.00	\N	\N	19.00	2025-10-19 02:29:42.204618	2025-10-19 02:29:42.204618
19ff0152-29a8-49e8-9918-8b44100d5e83	FRUTI AROS DELICIOUS 500GR	7709538410666	t	6200.00	6000.00	\N	\N	19.00	2025-10-19 02:29:42.20485	2025-10-19 02:29:42.20485
1c8d4468-733c-412d-8362-35cec1b1a95f	AXE DARK TEMPTATION 152ML	7791293025889	t	14200.00	13900.00	\N	\N	19.00	2025-10-19 02:29:42.205162	2025-10-19 02:29:42.205162
5e60e3bd-390e-4c36-9887-b10b2b93028b	FESTIVAL RECCREO 12X4	7702025142439	t	8600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.205417	2025-10-19 02:29:42.205417
01e4fb52-96df-4669-8afe-984c5ed51d83	TEST	T	t	100.00	\N	\N	\N	0.00	2025-10-19 02:29:42.205685	2025-10-19 02:29:42.205685
7a23004d-16d1-4138-8420-6cc493965b6f	PLUMERO DE COLORES	DCVWR	t	4500.00	4500.00	\N	\N	19.00	2025-10-19 02:29:42.20595	2025-10-19 02:29:42.20595
c63a1243-5492-400d-9a3b-36f50bf00207	ALCOHOL JGB SPRAY	DCCWE	t	2000.00	1600.00	\N	\N	19.00	2025-10-19 02:29:42.206211	2025-10-19 02:29:42.206211
6e7ff5a2-1843-4015-bfa4-898231a157e6	COPITOS MADERA X80UNID	6950616308080	t	1000.00	850.00	\N	\N	19.00	2025-10-19 02:29:42.206468	2025-10-19 02:29:42.206468
ce7f1ea0-7a5b-4038-a61c-de5763a618ca	COOL A PED LIQUIDO 250ML	7708851548964	t	6800.00	6500.00	\N	\N	19.00	2025-10-19 02:29:42.206707	2025-10-19 02:29:42.206707
af8611da-d01a-41b9-a216-b68c826d2345	VAPO PLUS GEL MARIHUANA	7709294804204	t	3500.00	3200.00	\N	\N	19.00	2025-10-19 02:29:42.206971	2025-10-19 02:29:42.206971
298ab935-97f9-457d-bfc0-cf5ae26436c8	CEPILLO BETUM GRANDE	CEPILLCOEC	t	3800.00	3600.00	\N	\N	19.00	2025-10-19 02:29:42.207249	2025-10-19 02:29:42.207249
b8ea9a65-5542-4b75-9437-68db3a8bc7e5	ARCOIRIS TINTE TELAS 9 GR	764451678446	t	1500.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.207509	2025-10-19 02:29:42.207509
0914ff65-c853-413e-9584-3fcefd67c126	COALDOR DE CAFE GRANDE	FWECEWCEW	t	1500.00	1200.00	\N	\N	19.00	2025-10-19 02:29:42.207778	2025-10-19 02:29:42.207778
93abda93-5018-4b2a-a912-04273fcafb89	COLADOR PEQUEÑO	DCM	t	1000.00	800.00	\N	\N	19.00	2025-10-19 02:29:42.207987	2025-10-19 02:29:42.207987
c0d9b11e-c177-4a1e-81b3-ceeaf46b3a50	TALCO MENNEN AZUL 200GR	7501035908130	t	4500.00	4000.00	\N	\N	19.00	2025-10-19 02:29:42.208248	2025-10-19 02:29:42.208248
d70b8b1e-b001-4b2d-9ab7-954009431af7	TALCO MENNEN ROSADO	7501035908147	t	4500.00	4000.00	\N	\N	19.00	2025-10-19 02:29:42.208586	2025-10-19 02:29:42.208586
798543f8-c757-48c0-abc5-e205dbffc4c1	COPITOS CORAZON SUPER	6964200230084	t	1500.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.208969	2025-10-19 02:29:42.208969
728169be-9626-4fd4-b26c-28afecfad949	COPITOS REDONDOS SUPER	6964200230060	t	1200.00	1000.00	\N	\N	19.00	2025-10-19 02:29:42.209434	2025-10-19 02:29:42.209434
f90a4714-2bf8-4955-82eb-f5dd7f987103	CARTON DE HILO AGUJA	CARTON DE H	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:42.209785	2025-10-19 02:29:42.209785
edb11943-1615-4a8c-bcf0-fac8bdd77f18	ACEITE DE AGUACATE CON VITMINA E 45CC	AKMCE	t	1500.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.210016	2025-10-19 02:29:42.210016
3a87fa0a-49c6-4432-baad-4b8589912a55	PISTOLAS TIKETEADORA	PISTOLAS	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.210292	2025-10-19 02:29:42.210292
293a70b2-e135-43c6-95fd-9c339f4be21d	PULPO PARA AMARRAR COLORES	SCP	t	4000.00	3500.00	\N	\N	19.00	2025-10-19 02:29:42.210562	2025-10-19 02:29:42.210562
cc7a2b71-596a-4e3d-808a-092701cac739	ACEITE DE BEBE BABY CARE 50CC	ACEITE	t	1500.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.210791	2025-10-19 02:29:42.210791
78fa0b6b-19eb-45ff-8654-b17c3a8a7216	REMOVEDOR VALMY VIDRIO	REMOD	t	2000.00	1800.00	\N	\N	19.00	2025-10-19 02:29:42.211017	2025-10-19 02:29:42.211017
d3acf046-38fb-4ffe-919c-8fa4d99c462a	GANCHO DE ROPA DE MADERA X20	GANC	t	3000.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.211263	2025-10-19 02:29:42.211263
664c7226-bef8-4f82-8971-e2da685ae784	VENENO CUCARACHA Y HORMIGA POWDER	VENENO	t	700.00	500.00	\N	\N	0.00	2025-10-19 02:29:42.211487	2025-10-19 02:29:42.211487
2c478747-f90f-4183-899b-b0a75f3eded6	GANCHOS PARA ROPA PLASTICOS COLORES X48	GANCHOS	t	7000.00	6600.00	\N	\N	19.00	2025-10-19 02:29:42.211712	2025-10-19 02:29:42.211712
11d30d75-30e6-45a9-9a59-c125e4484896	HOJILLA PARA BISTURI X10UNID	HOJILAL	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.211931	2025-10-19 02:29:42.211931
3a21b394-3bc9-4dd2-979c-e3e723793049	COLONIA MENNEN 50ML	COLO	t	2500.00	2200.00	\N	\N	19.00	2025-10-19 02:29:42.212172	2025-10-19 02:29:42.212172
9653b65d-6e35-4c98-9f9b-ea1b11f2bed6	CORTA UÑAS FIGURAS	CORT	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.212392	2025-10-19 02:29:42.212392
12922b0d-b219-4eea-a66b-51e20192893f	ACEITE 3 EN 1 SUPER 90ML	ACEITE D	t	2500.00	2200.00	\N	\N	19.00	2025-10-19 02:29:42.212589	2025-10-19 02:29:42.212589
c78fa57d-0aca-470b-b946-267c6833a3c0	ACEITE 3 EN 1 SUPER 1	FFC	t	1200.00	900.00	\N	\N	19.00	2025-10-19 02:29:42.212805	2025-10-19 02:29:42.212805
085da359-a655-4e3f-ba5c-e0e22468d817	VARSOL LA CASTELLANA 150ML	CEQM	t	2200.00	1900.00	\N	\N	19.00	2025-10-19 02:29:42.213026	2025-10-19 02:29:42.213026
e63b9962-4679-45e4-954d-fde1be36c7c2	ESCOBA MEGA	CEKMC	t	5500.00	5125.00	\N	\N	19.00	2025-10-19 02:29:42.213261	2025-10-19 02:29:42.213261
2b7c38d6-890e-4fa0-84ed-49155188f1ef	HARINA PAN INTEGRAL 500GR	7702084137902	t	2500.00	2430.00	\N	\N	5.00	2025-10-19 02:29:42.213665	2025-10-19 02:29:42.213665
83c157e4-0081-4233-b123-c555ae6583a6	MAIZ PIRA SAMARA 500GR	7709094571931	t	2500.00	2400.00	\N	\N	0.00	2025-10-19 02:29:42.213895	2025-10-19 02:29:42.213895
7a5c62e7-703d-4fce-b6c6-daa463db3b33	VASOS 1ONZ X100UNID	7707320620576	t	4600.00	4400.00	\N	\N	19.00	2025-10-19 02:29:42.214121	2025-10-19 02:29:42.214121
355093f8-c47a-49cf-b56b-562d2ec79a4a	AROMATEL FLORAL 400ML	7702191161517	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:42.214354	2025-10-19 02:29:42.214354
df24c042-71fd-421d-adf4-32bf2037ff74	PALO TRAPERO	DCD	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:42.214591	2025-10-19 02:29:42.214591
d33c8aaa-25f7-4336-989f-00cbd66a2459	ALKA SELZER X60UNID	ALKA	t	45500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.214827	2025-10-19 02:29:42.214827
dbbb0ec8-110a-41c4-b6da-b541749daebc	BURBUJET COOKIES AND CREAM 50GR	7702007061154	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.215081	2025-10-19 02:29:42.215081
419b6936-1ee3-4d9d-b591-784edb944513	TRIDENT 8.5 GR MENTA	7622201776664	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.215333	2025-10-19 02:29:42.215333
a554da6a-8543-4378-98cf-8ecc9829d392	JET UNID 9GR	7702007080476	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.215583	2025-10-19 02:29:42.215583
0d6424f6-8f1e-48ce-b4e3-2177939bade8	BALANCE NORMAL 30GR	7702045974171	t	4000.00	3850.00	\N	\N	19.00	2025-10-19 02:29:42.215877	2025-10-19 02:29:42.215877
af08c2ef-0769-4d90-9583-ee2a571c61e2	BALDE CON PICO MEDIDOR ANDELCO 12LITROS	BALDE	t	6300.00	6200.00	\N	\N	19.00	2025-10-19 02:29:42.216192	2025-10-19 02:29:42.216192
928903e8-7510-4367-a1cc-f7ba95ee4c5d	LIMPIA POSETAS 500ML	LIMPIA	t	4000.00	3900.00	\N	\N	19.00	2025-10-19 02:29:42.216444	2025-10-19 02:29:42.216444
b88c9ef4-8e16-42e8-b439-51bb313b5c7f	PORTA CEPILLO PROTECTORES	POTA	t	2200.00	2000.00	\N	\N	19.00	2025-10-19 02:29:42.216692	2025-10-19 02:29:42.216692
c97acbc5-5b6d-472a-a1dc-71746b005e16	PAÑITOS HUMEDOS POTE MINI	PA	t	4400.00	4300.00	\N	\N	19.00	2025-10-19 02:29:42.216984	2025-10-19 02:29:42.216984
99ec9ef1-177a-43fe-bc74-4114333d3328	SERVILLETA FAMILIA X150	7702026182854	t	2600.00	2480.00	\N	\N	19.00	2025-10-19 02:29:42.217241	2025-10-19 02:29:42.217241
0c57b827-236f-467c-ade4-5a76a5178d6d	AROMAX DUO MANZANA DUO X24	7702354954888	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.21749	2025-10-19 02:29:42.21749
7130976c-d3aa-4b32-9cff-e8d60cfbcbda	AROMAX DUO MANZANA VERDE	7702354954987	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.217746	2025-10-19 02:29:42.217746
05c2fae8-c5f3-421c-9da0-854c24275dd3	JUMBO MANI X6UNID 90GR 540GR	7702007080421	t	45800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.218017	2025-10-19 02:29:42.218017
94f6684e-fa08-41cd-8dfb-a102c8787182	NOSOTRAS DELGADAS X8UNID	7702026152253	t	2500.00	2380.00	\N	\N	0.00	2025-10-19 02:29:42.218263	2025-10-19 02:29:42.218263
58cde665-69a4-4fb0-b213-dd34f24137d7	PALOS DE PINCHOS HOUSE 25CM X100	7707320620149	t	2300.00	2100.00	\N	\N	0.00	2025-10-19 02:29:42.218501	2025-10-19 02:29:42.218501
eba242c9-09cb-469b-afa7-ad6ba73da59c	ROSAL MAXIMO VERDE X12 ROLLO	7702120014129	t	14400.00	14000.00	\N	\N	19.00	2025-10-19 02:29:42.218739	2025-10-19 02:29:42.218739
a1842659-af70-41d2-915c-b113b34dcd7b	QIDA CAT 8KILOS	QIDACA	t	72000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.218975	2025-10-19 02:29:42.218975
e9300d2b-82a4-4f4f-9732-19f1260a65e1	PILAS TRONEX	PILAS	t	1100.00	950.00	\N	\N	19.00	2025-10-19 02:29:42.219206	2025-10-19 02:29:42.219206
d934f025-2e53-4aa1-b70a-87b3839f39c1	7700	SALSA SOYA LITRO LA SAZON	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.21944	2025-10-19 02:29:42.21944
f173ddee-6b80-47c1-bbac-78579067eafe	ENJUAGUE BUCAL ORAL PLUS CARBON 180ML	7708682913573	t	6600.00	6400.00	\N	\N	19.00	2025-10-19 02:29:42.219669	2025-10-19 02:29:42.219669
15e533fb-dc8d-4441-aa03-f1005b02d6f9	SOPA INSTANTANEA AJINOMEN X3	7709263821225	t	7900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.219928	2025-10-19 02:29:42.219928
80a2f0d3-2248-4542-b236-8dd3f3966265	DURAMAX SCOTT REUTILIZABLE 46HOJA	7702425241855	t	8000.00	7800.00	\N	\N	19.00	2025-10-19 02:29:42.220189	2025-10-19 02:29:42.220189
593cbe55-2b7a-4e09-aa9f-b862ccb2183e	ACEITE SOYA ISA 4800ML	764451916791	t	33000.00	32500.00	\N	\N	19.00	2025-10-19 02:29:42.220457	2025-10-19 02:29:42.220457
3012962a-e109-4fb3-ae47-cbc3e1c9e36b	PAPEL FAMILIA MEGARROLLO	7702026152260	t	2100.00	2000.00	\N	\N	19.00	2025-10-19 02:29:42.220696	2025-10-19 02:29:42.220696
97cdc9bb-8773-4996-baf1-c05529f11225	JET CARAMEL UND	7702007082586	t	500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.220977	2025-10-19 02:29:42.220977
3df53cd8-2ac2-46a4-94d9-905833ba6fa0	HUGGUIES 3X25	7702425351073	t	20700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.221244	2025-10-19 02:29:42.221244
0e99a66b-0c3a-40c3-bde9-8f0851df85a8	SALMON ROBIN HOOD 155GR	7862129150928	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:42.221493	2025-10-19 02:29:42.221493
c2dc6800-7a5b-4034-b412-a7deb7360ca3	GELA PLAY YOLIS X90UNID	7708527098748	t	26900.00	26400.00	\N	\N	19.00	2025-10-19 02:29:42.221912	2025-10-19 02:29:42.221912
804d35af-43bd-4e2a-9c92-0bb8f345a684	SALMON BOCADO DEL MAR TOMATE 155GR	7862910003334	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:42.222221	2025-10-19 02:29:42.222221
b542e1d5-6c5a-4c17-a576-40dba06ae127	ELECTROLIT SABOR A FRESA 625ML	7501125176470	t	7400.00	7180.00	\N	\N	0.00	2025-10-19 02:29:42.222554	2025-10-19 02:29:42.222554
cb086308-528f-4963-a108-66ba6c6e6b5d	LAVALOZA LIQUIDO LIMPIA YA  LIMON  500ML	7702037912723	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:42.222889	2025-10-19 02:29:42.222889
d2b56dac-6c4f-4c8e-b37e-bf8ce3d3a1b2	SUAVIZANTE LIMPIA YA FLORAL 190ML	7702037913997	t	1200.00	1060.00	\N	\N	19.00	2025-10-19 02:29:42.223171	2025-10-19 02:29:42.223171
f871be62-80e6-4e2a-8dfd-02be65933f4c	CARAOTA SUDESPENSA 460GR	7707309251937	t	4000.00	3850.00	\N	\N	0.00	2025-10-19 02:29:42.223462	2025-10-19 02:29:42.223462
5a179dd9-ecfa-43da-8551-54592da57357	LECHE ENTERA COLANTA 400ML	7702129004503	t	2100.00	1900.00	1800.00	\N	0.00	2025-10-19 02:29:42.223778	2025-10-19 02:29:42.223778
0c8c3a79-7da0-4a42-8b55-f6caf3c8666a	ARROZ ZULIA 500GR	7707222299122	t	2000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.224057	2025-10-19 02:29:42.224057
49e0599a-2c1a-4e5e-bd88-72278b24fe4b	TRULULU MASMELO RELLENOS 50GR	7702993044834	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:42.224367	2025-10-19 02:29:42.224367
6bb29227-c609-4946-9df2-188775013797	CHOCOLATE LA ESPECIAL TRADICIONAL 500GR	7702007082609	t	10200.00	9900.00	\N	\N	5.00	2025-10-19 02:29:42.224643	2025-10-19 02:29:42.224643
52cc9ef6-b0e7-478a-b8cb-7e1ebcb0eab8	JET FRESA CON CREMA X6UNID 174GR	7702007079531	t	14500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.224908	2025-10-19 02:29:42.224908
7b00f495-d03f-4c0d-a48f-537b71823026	PACK SOPITAS  X6UNID DORIA	7702086005858	t	14000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.225252	2025-10-19 02:29:42.225252
7c851d32-ef53-44e1-a2ee-340f8430bd2b	ELITE SUAVE RESISTENTE X12	7707199345723	t	14900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.225558	2025-10-19 02:29:42.225558
de016dd4-9418-4d08-8c3e-582f1f2e8f25	JUGO HIT NECTAR 8ONZ MANZANA	7707133037011	t	1900.00	1688.00	\N	\N	19.00	2025-10-19 02:29:42.225956	2025-10-19 02:29:42.225956
48418447-40a3-4ee9-81a3-7a45c1ebf6b0	TARRITO ROJO 330GR MAS CREAM FLUO	7702560049101	t	22500.00	22000.00	\N	\N	19.00	2025-10-19 02:29:42.226497	2025-10-19 02:29:42.226497
4ed795c7-bba8-419c-b1ec-a01d4a5066fc	JUMBO MANI 17GR	7702007080339	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.226899	2025-10-19 02:29:42.226899
e3b28ce8-194a-4d5b-b4f8-268342611287	JUMBO MANI 35GR	7702007080360	t	3700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.227204	2025-10-19 02:29:42.227204
a2593f38-0541-433a-b319-01cc8a4c8926	HEAD SHOULDERS 375ML LIMPIEZA	7500435202695	t	18000.00	17500.00	\N	\N	19.00	2025-10-19 02:29:42.227463	2025-10-19 02:29:42.227463
839b4724-08cd-41cb-8dc1-6a6f3aca9c14	BIANCHI BAR UND	7702993032138	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.227713	2025-10-19 02:29:42.227713
d4e7f3aa-8f73-44c8-9ae0-96c3557703f3	BOKA LIMA LIMON	7702354946623	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.227969	2025-10-19 02:29:42.227969
c353b07c-94fb-4e30-982d-70309e6f58ca	BUCATINI DORIA 250GR	7702085012628	t	2200.00	2050.00	\N	\N	5.00	2025-10-19 02:29:42.228311	2025-10-19 02:29:42.228311
104ff1ff-42bd-4f1a-8cbb-18dc85ac99c6	BOKA MARACUYA	7702354955717	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.228598	2025-10-19 02:29:42.228598
e6927250-2fe0-47bd-82f6-a12fa656ec78	VASELINA UND	7708448461751	t	2400.00	2200.00	\N	\N	19.00	2025-10-19 02:29:42.228885	2025-10-19 02:29:42.228885
677513eb-016b-4e24-983a-869ed3439bbf	BURBUJA UND	7702007062694	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.229153	2025-10-19 02:29:42.229153
506edbc4-7771-4eef-9098-a80634c37b30	SHAMPOO PANTENE MAS ACONDICIONADOR BAMBU 200ML	7500435230377	t	19000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.229631	2025-10-19 02:29:42.229631
e0389966-d4ec-4e34-9f8c-4e1b5cb5485a	CHOCORRAMO BARRITA X5	7702914114608	t	8000.00	7785.00	\N	\N	19.00	2025-10-19 02:29:42.229901	2025-10-19 02:29:42.229901
324862f4-90d4-47b1-b12e-cdfc6030feee	CHOCORRAMO BARRITA UND	7702914114400	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.230164	2025-10-19 02:29:42.230164
25d4814b-3436-4c0e-80b9-e25dd62cffef	GANSITO X6 UND	7702914600859	t	9500.00	9300.00	\N	\N	19.00	2025-10-19 02:29:42.230448	2025-10-19 02:29:42.230448
9d196ed5-767f-4feb-b7bf-aa688c142915	BOCACILLO GUAYABA X18 UND	7707172740682	t	6300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.230733	2025-10-19 02:29:42.230733
1ab37a2b-e1f2-4a2d-aea1-687f62b7bf39	DOGOURMET SALMON Y CARNE 350GR	7702084051055	t	3200.00	3100.00	\N	\N	5.00	2025-10-19 02:29:42.231023	2025-10-19 02:29:42.231023
fa3a1008-a1c7-4a4b-aeb9-98c2505d3e10	HALLS MENTA EUCALIPTO 25G	7622210427076	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.231621	2025-10-19 02:29:42.231621
e6db9f9e-5be7-494d-98a1-e3403e53f8cd	AROMATEL BAMBU 900 ML	7702191163030	t	8200.00	8000.00	\N	\N	19.00	2025-10-19 02:29:42.231991	2025-10-19 02:29:42.231991
c2cb3cbf-92ba-4e9b-ad7d-3141cb7830ab	SKAAP CLORO 3785ML	7707371211280	t	6800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.23243	2025-10-19 02:29:42.23243
2a622889-9406-42c5-81e2-457c5bcc0b93	PIN POP X24 MORA AZUL	7702174085571	t	6600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.23278	2025-10-19 02:29:42.23278
f79a7783-3ea7-4cf6-b492-cf3a37c30327	TRIDENT YERBABUENA 72	7622201800338	t	20700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.233114	2025-10-19 02:29:42.233114
4e9726c9-a19e-48f0-b207-d52dff5dc624	SHAMPOO SAVITAL 25ML	7702006207775	t	1000.00	875.00	\N	\N	19.00	2025-10-19 02:29:42.233498	2025-10-19 02:29:42.233498
f9964cb8-91d3-4d6d-89ae-132253e9ecf2	CREMA DE PEINAR SAVITAL 100ML	7702006406055	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:42.234122	2025-10-19 02:29:42.234122
a1b2f4f1-a000-4f03-8991-f8858efa3c3f	BOKA MANDARINA	7702354034122	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.234803	2025-10-19 02:29:42.234803
a56ec025-41f2-4901-a704-77114496f6f9	EXTRUCITO X3	7706642174354	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.235255	2025-10-19 02:29:42.235255
12bb4017-5220-4425-a811-d5cc625dad53	DON GUSTICO 18GR	7702354955014	t	1000.00	892.00	\N	\N	19.00	2025-10-19 02:29:42.23567	2025-10-19 02:29:42.23567
726f10e3-438b-4b39-920e-b548f0767a40	GELATINA FRUTIÑO X4	7702354957018	t	5900.00	5750.00	\N	\N	19.00	2025-10-19 02:29:42.236026	2025-10-19 02:29:42.236026
fa8a15da-c504-4c08-b381-0af9ca80e45f	MANI MOTO LIMON UND	7702189058508	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.236584	2025-10-19 02:29:42.236584
db221857-5ac6-4e48-ad0b-57232c4b5b48	BOKA LICKI UND	7702354955809	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.237222	2025-10-19 02:29:42.237222
cc1b4cf7-2757-4245-928c-fbf7b1597167	BOKA GUANABANA	7702354956707	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.238339	2025-10-19 02:29:42.238339
2df84521-9ac8-4259-a47d-c9cac8403f5c	DOVE MEN CARE ROLL ON	78931640	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:42.239367	2025-10-19 02:29:42.239367
fa4f6d4d-de1f-4bd5-b0b3-9f300bfec351	FESTIVAL FRESA 6 GALLETA	7702025136773	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.239794	2025-10-19 02:29:42.239794
86c4a613-0ed9-4622-abf5-0e3983f0e2a5	DUCALES PROVOCACION X6UNID	7702025137770	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.240228	2025-10-19 02:29:42.240228
b18d5006-522c-4437-98b3-47d6cf9b4dc5	COLOR ACHIOTE LA SAZON 50GR	7707767146042	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.240717	2025-10-19 02:29:42.240717
c003a139-7b4d-4bad-a3b5-69705045bee7	OREGANO EN ESCAMA LA SAZON 40GR	7707767140859	t	3700.00	\N	\N	\N	0.00	2025-10-19 02:29:42.24141	2025-10-19 02:29:42.24141
f1c4f36c-b69e-4000-8f3d-ec720a8e7465	BALANCE CLINICAL INVISIBLE 30GR	7702045697742	t	4000.00	3850.00	\N	\N	19.00	2025-10-19 02:29:42.24285	2025-10-19 02:29:42.24285
df22d8b2-2388-4197-b7a7-dc9398ec3d61	GOMITAS BON BON BUM 45GR	7702011155399	t	1300.00	1170.00	\N	\N	19.00	2025-10-19 02:29:42.243165	2025-10-19 02:29:42.243165
1ffab162-a93e-4a2f-9468-e9adee65890a	PAÑITOS MANZANILLA PEQUEÑIN X80UNID	7702026152536	t	4700.00	4550.00	\N	\N	19.00	2025-10-19 02:29:42.243524	2025-10-19 02:29:42.243524
3f787924-9d3d-4cb9-8f13-75d4f44e64e0	FIDEO DORIA 500GR	7702085013069	t	4000.00	3870.00	\N	\N	5.00	2025-10-19 02:29:42.244008	2025-10-19 02:29:42.244008
6675c6ec-ce02-41ee-9158-7eff5c951e14	SALTIN NOEL INTEGRAL DOBLE FIBRA 2 TACOS 276GR	7702025149704	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:42.244404	2025-10-19 02:29:42.244404
76825c2d-31be-42db-886c-a12035c1298b	SALTIN NOEL QUESO MANTEQUILLA 2 TACOS 225GR	7702025149711	t	5500.00	5350.00	\N	\N	19.00	2025-10-19 02:29:42.244878	2025-10-19 02:29:42.244878
8816fd4b-3039-463d-b758-01ce7de640a6	CHOCOLATE LA ESPECIAL TRADICIONAL 250GR	7702007082630	t	6100.00	5900.00	\N	\N	5.00	2025-10-19 02:29:42.245161	2025-10-19 02:29:42.245161
4b5a4411-393f-478f-971d-dccb2a1e48f1	TRULULU GUSANOS ACIDOS 100UNID	7702993028346	t	7400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.245484	2025-10-19 02:29:42.245484
0ff39727-3e32-42ce-8da1-a05110dd9453	PURO 280GR BICARBONATO BARRA	7702191163955	t	2500.00	2350.00	\N	\N	19.00	2025-10-19 02:29:42.245788	2025-10-19 02:29:42.245788
ab36f08d-2a92-4651-97c6-d39501f9b915	CREMA DE LECHE PARMALAT 800ML	7700604052704	t	15200.00	14800.00	\N	\N	0.00	2025-10-19 02:29:42.246097	2025-10-19 02:29:42.246097
71f79a99-b92e-4e3b-8f61-0e105af9c824	VELON SANTA MARIA N16	7707297960217	t	46000.00	44800.00	\N	\N	19.00	2025-10-19 02:29:42.246349	2025-10-19 02:29:42.246349
41e6319f-01c3-4fa2-b7e0-ca1ccc918a21	ROPA COLOR BLANCOX 500ML	7703812002035	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:42.246599	2025-10-19 02:29:42.246599
94014137-951b-4230-bb5d-e259a64649d2	7 CEREALES VAINILLA 450GR	7709761545814	t	5100.00	4950.00	\N	\N	5.00	2025-10-19 02:29:42.246863	2025-10-19 02:29:42.246863
e70bee13-b523-45b0-a6fc-32f297a97bd0	VITAFER MINI POTE 20ML	7707816985783	t	3400.00	3200.00	\N	\N	0.00	2025-10-19 02:29:42.247141	2025-10-19 02:29:42.247141
8c1b3e1e-af9a-4d8a-ab66-d4a9bde061d4	KERATINA ROMERO Y QUINA	7709901191529	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:42.247412	2025-10-19 02:29:42.247412
228263d9-4693-4e24-b860-7d61e3d7166d	JUMBO CHOCO AREQUIPE 170GR	7702007083705	t	10700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.247755	2025-10-19 02:29:42.247755
4c3d78a8-e802-4081-92b8-997d487578d4	MECHERA SWISS LITE NEW YORK	7707822750856	t	19300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.248066	2025-10-19 02:29:42.248066
5052fc8f-c50f-4b76-90e1-6a245e19a7d2	MEXANA TALCO 85GR	7702123008842	t	2200.00	1600.00	\N	\N	19.00	2025-10-19 02:29:42.248364	2025-10-19 02:29:42.248364
68a79c3b-f234-401c-9411-b5a695befbee	CRONCH FLAKES 240GR	7702807658615	t	6700.00	6500.00	\N	\N	19.00	2025-10-19 02:29:42.248671	2025-10-19 02:29:42.248671
17c4623a-c311-4c98-8458-6af415759302	GELATINA FRUTIÑO FRESA	7702354955229	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.248952	2025-10-19 02:29:42.248952
c8286acd-828a-413f-977b-b225336d4d5e	IBUPROFENO COASPHAMA 800ML X60UNID	CWEI	t	2200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.249451	2025-10-19 02:29:42.249451
42517acc-ce03-474e-b315-58dc9662a162	PALO PINCHO HOUSE DELGADOS X100UNID 25CM	7707320620262	t	1800.00	1650.00	\N	\N	19.00	2025-10-19 02:29:42.249693	2025-10-19 02:29:42.249693
e5a4b509-3ea0-46b5-9b9d-a644e55fe20b	SALSA ROSADA IDEAL 3350GR	7709747919004	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.250002	2025-10-19 02:29:42.250002
9490ecd8-4b75-4aaa-9a4b-c15a5a412bb2	ACEITE GOURMET FRITO 420ML	7702141339379	t	8000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.250257	2025-10-19 02:29:42.250257
c3e0e511-a66c-40bb-94e1-f72928bf25f8	SARDINA DIAMANTE TOMATE 425GR	7862127010606	t	4700.00	4500.00	\N	\N	19.00	2025-10-19 02:29:42.250911	2025-10-19 02:29:42.250911
d9726c11-b131-4ccc-ae5f-66f97c6976d6	SALSA CHINA DEL SAZON 1LT	7701090477248	t	7900.00	7680.00	\N	\N	19.00	2025-10-19 02:29:42.251207	2025-10-19 02:29:42.251207
e7fe1766-848d-4d9c-a515-4ad69f8202ee	SALSA NEGRA DELSAZON 1LT	7701090477255	t	7900.00	7680.00	\N	\N	19.00	2025-10-19 02:29:42.251521	2025-10-19 02:29:42.251521
d607ba05-76cf-4e09-87ed-451c1ed3ed30	AROMATEL 1.4L	7702191164075	t	10800.00	10400.00	\N	\N	19.00	2025-10-19 02:29:42.25182	2025-10-19 02:29:42.25182
c0d9a60a-e682-4f02-afa0-f18b92ffd17d	PEGANTE DE CONTACTO SUPER AMARILLO	PCEFE	t	2200.00	1900.00	\N	\N	19.00	2025-10-19 02:29:42.252111	2025-10-19 02:29:42.252111
8bec2413-2bc3-4125-8ff8-bca17bd3fb5d	BETUN BRIFFY AUTO BRILLO BLANCO 60CM	7709296703444	t	7000.00	6800.00	\N	\N	19.00	2025-10-19 02:29:42.252402	2025-10-19 02:29:42.252402
a5337146-fde4-4cdf-acbe-791102e30ac3	BETUN BRIFFY AUTBRILLO NEGRO 60CM	7709296703451	t	7000.00	6800.00	\N	\N	19.00	2025-10-19 02:29:42.252699	2025-10-19 02:29:42.252699
82713966-f60b-4f72-871f-6557bf85415d	PEGANTE SUPER AB	9781234567897	t	4000.00	3600.00	\N	\N	19.00	2025-10-19 02:29:42.253204	2025-10-19 02:29:42.253204
7ad834bb-a57d-4b18-a624-23b4b4e27870	CEPILLO DENTAL SUPER	7453096320850	t	1500.00	1250.00	\N	\N	19.00	2025-10-19 02:29:42.25357	2025-10-19 02:29:42.25357
351294db-5a6c-4ba2-ac24-9108b770ef80	PULPO GRANDE DOS COLORES	PULKPDO	t	6500.00	6000.00	\N	\N	19.00	2025-10-19 02:29:42.253923	2025-10-19 02:29:42.253923
604b8503-fbe7-4fa2-85ad-17095296df02	BOKA MORA FRESA 18GR	7702354948788	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.254344	2025-10-19 02:29:42.254344
55811ad8-e62d-4221-9662-33e5a8a10511	BOKA SALPICON DE FRUTAS 10GR	7702354955663	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.254661	2025-10-19 02:29:42.254661
88c1ce96-a16f-4873-903f-c3f0eed2bc5c	BOKA MANDARINA 10GR	7702354955786	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.255036	2025-10-19 02:29:42.255036
d6c9221a-ea61-41c4-abc0-be6077f6be10	BOKA MANGO 10GR	7702354955793	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.255439	2025-10-19 02:29:42.255439
29ff3ee7-c46d-42f4-ac6b-e2cbb73f1d2d	BOKA PANELA LIMON 10GR	7702354955656	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.255769	2025-10-19 02:29:42.255769
b91824ba-e54c-4cd0-b2fb-57442d8e12cc	GELATINA FRUTIÑO FRUTOS ROJOS 14GR	7702354955274	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.256292	2025-10-19 02:29:42.256292
34423c09-8a14-4365-a2e8-7249d3274290	GELATINA FRUTIÑO FRAMBUESA 14GR	7702354955298	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.2566	2025-10-19 02:29:42.2566
2587bd9e-f991-4602-a86a-17d34c990357	GELATINA FRUTIÑO CEREZA 14GR	7702354955236	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.256879	2025-10-19 02:29:42.256879
bf25ffe7-b644-46a2-9760-650f1f478cbb	BIANCHI CHOCOLORES MANI 50GR	7702993048894	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:42.257155	2025-10-19 02:29:42.257155
83f61d32-d23a-4f14-99b8-5dca528bbddf	BIANCHI CHOCO GALLETAS 40GR	7702993046579	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:42.257402	2025-10-19 02:29:42.257402
9da6a6a4-52d4-4bed-87a7-1dae41ceddf3	BIANCHI COOKIES AND CREAM  48GR	7702993048962	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:42.257687	2025-10-19 02:29:42.257687
c80d4835-9d77-4b1b-b187-0a474a2f253b	BIANCHI DOBLE CHOCOLATE 55GR	7702993048924	t	2000.00	1850.00	\N	\N	19.00	2025-10-19 02:29:42.258021	2025-10-19 02:29:42.258021
52d75591-b198-4287-9228-debfed2a5aaf	FESTIVAL VAINILLA X6 50GR	7702025136735	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.258388	2025-10-19 02:29:42.258388
3c7a11da-0dc8-49e3-90f3-4840dc53cf3e	PEGA TAMQUE DUO 67GR	7453092900001	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.258613	2025-10-19 02:29:42.258613
f9ae17d8-eefe-481a-859c-aa4832564624	SPEED STICK GEL 70GR	7509546670522	t	11200.00	10800.00	\N	\N	19.00	2025-10-19 02:29:42.258873	2025-10-19 02:29:42.258873
397b91d1-cb34-4570-a0dd-11ff6b76fc07	GOLPE RANCHERO X8UNID	GOLPE RAN	t	20200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.259146	2025-10-19 02:29:42.259146
4507e4f7-f140-4248-843c-fe6d2a53299d	MAIZ TIERNO GRACOL 185GR	7707493559628	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:42.259387	2025-10-19 02:29:42.259387
1decd149-2415-4f46-8272-6878e50d40a0	DERSA BARRA PURO 230GR	7702166009158	t	2600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.259624	2025-10-19 02:29:42.259624
2fb5adac-5e43-4b7a-8023-fee8f93932d7	ARROZ  JILMERO 1.000GR	713541837164	t	3600.00	3500.00	\N	\N	0.00	2025-10-19 02:29:42.259841	2025-10-19 02:29:42.259841
a669eaeb-9dd4-4147-a52f-b02ee5083e39	CEREAL MILL AROS FRUTALES 250GR	7702555008106	t	3700.00	3550.00	\N	\N	19.00	2025-10-19 02:29:42.260048	2025-10-19 02:29:42.260048
77d4bd60-a5e4-4f35-adbd-d714f5747bd2	CEREAL MILL HOJUELAS AZUCARADAS 250GR	7702555000384	t	3700.00	3550.00	\N	\N	19.00	2025-10-19 02:29:42.260285	2025-10-19 02:29:42.260285
4e12760d-fcf6-4f51-87e2-666f7edd1461	CEREAL MILL CHOCO ARROZ 250GR	7702555001602	t	3700.00	3550.00	\N	\N	19.00	2025-10-19 02:29:42.260499	2025-10-19 02:29:42.260499
d15e33da-feeb-4a96-9b07-0f7af022fb9d	DETERGENTE MAC 1.000GR	7709154421954	t	3800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.260711	2025-10-19 02:29:42.260711
cd071f18-3255-43e3-80c3-8ac811069233	BOMBILLO LED UNIFER 9W	8081511021229	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:42.260927	2025-10-19 02:29:42.260927
01390c69-1116-427b-91dd-f1398a483405	BOMBILLO LED UNIFER 20W	8081511021243	t	9000.00	8600.00	\N	\N	19.00	2025-10-19 02:29:42.261152	2025-10-19 02:29:42.261152
ef78e408-8647-4ced-9adb-31d790bcd6e3	BOMBILLO LED UNIFER 40W	8081511021267	t	18000.00	17500.00	\N	\N	19.00	2025-10-19 02:29:42.261404	2025-10-19 02:29:42.261404
19ffe353-6759-433a-9c8a-9bb93e7e6e10	CETIRIZINA MEMPHIS 10ML	CRVE	t	2500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.26169	2025-10-19 02:29:42.26169
a749a13c-674d-4cce-a016-586258798684	EL MANICERO ARANDAMIX X9UNID	7702007083002	t	13700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.262015	2025-10-19 02:29:42.262015
ccb048e3-c614-43c3-90bc-f8b945130952	SHAMPOO NUTRIBELA REPARACION 18GR	7702354956295	t	1000.00	900.00	\N	\N	19.00	2025-10-19 02:29:42.262321	2025-10-19 02:29:42.262321
c3bc1578-3643-40db-a100-9afa51751a0a	MECHAS LOKAS MANGO BICHE	7702174085625	t	3200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.262622	2025-10-19 02:29:42.262622
ffa0b47b-45d3-4254-944c-47ca8ee61f8b	VITAMINA C MK X10UNID	VITAMINA	t	4600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.262875	2025-10-19 02:29:42.262875
ddcf92c6-07b2-46df-87af-9113319b8489	DESODORANTE DOVE AEROSOL ORQUIDIA 150ML	7506306249714	t	16800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.26311	2025-10-19 02:29:42.26311
a8f231f6-1f95-440c-9108-12297b1acf35	CHOCOLISTO CON STEVIA 180GR	7702007070552	t	3600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.263346	2025-10-19 02:29:42.263346
2405e2ba-1673-4947-9aae-de236d9c6a05	JABON INTIMATE DERELA 500ML	8430055004838	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.263646	2025-10-19 02:29:42.263646
331e3657-7b70-489d-9b06-a0d90a2f4aa2	COLCAFE CON LECHE 132GR X6SOBRE  22GR	7702032117796	t	9100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.263879	2025-10-19 02:29:42.263879
eae5685c-1638-4db8-840c-2b636587053c	COLCAFE CAPPUCCINO VAINILLA X6 SOBRE 18GR	7702032118434	t	11200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.264144	2025-10-19 02:29:42.264144
d9f65a39-ebb3-4932-a517-e11d7c7f34b8	SHAMPOO MILAGROS HERBAL 450ML	7708075180704	t	32000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.264375	2025-10-19 02:29:42.264375
aea3ff26-5f69-462d-8a41-f1af96926690	DESODORANTE DOVE AEROSOL CALENDULA 87G 150ML	7506306241152	t	17500.00	17100.00	\N	\N	19.00	2025-10-19 02:29:42.26462	2025-10-19 02:29:42.26462
34eabd2a-7a78-4bd0-b8d8-72597aefd7e6	CREMA PONDS REJUVENES 50GR	7501056330484	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.264872	2025-10-19 02:29:42.264872
bdf0af7e-be40-43b5-b8e3-3c299d78a34a	CREMA PONDS REJUVENES 100GR	7501056330491	t	19000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.265142	2025-10-19 02:29:42.265142
82a74d7e-7a61-4ffe-b67d-7311f0b80cfc	ESPONJA COLORES	7709990078343	t	600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.26537	2025-10-19 02:29:42.26537
a360ec77-f993-43d4-97f1-374f4726d7e3	SHAMPOO NUTRIBELA ENZIMOTERAPIA 18ML	7702354956301	t	1000.00	900.00	\N	\N	19.00	2025-10-19 02:29:42.265604	2025-10-19 02:29:42.265604
ab82a618-91f7-40b3-a238-e1f7e1046ce5	AJI NO MEN POLLO 80GR	7754487001687	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.265845	2025-10-19 02:29:42.265845
0b82c4ba-f87d-49e1-bdb3-09554c7c66ab	DETODITO BBQ 50GR	7702189055545	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.266087	2025-10-19 02:29:42.266087
237e283c-042a-49f0-8b5c-c061afd3fe0c	SHAMPOO NUTRIBELA HIALURONICO 18ML	7702354956325	t	1000.00	900.00	\N	\N	19.00	2025-10-19 02:29:42.266315	2025-10-19 02:29:42.266315
bd326420-dae5-4ab3-9bac-d15732121a62	SHAMPOO NUTRIBELA CELULAS MADRE 18ML	7702354956318	t	1000.00	900.00	\N	\N	19.00	2025-10-19 02:29:42.266575	2025-10-19 02:29:42.266575
b6391759-477a-4274-ba5a-3ff75ee511b1	SHAMPOO NUTRIBELA CELULAS MADRE 400ML	7702354956233	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:42.266911	2025-10-19 02:29:42.266911
35a73cd0-37fb-44e5-94b3-41c4fb1fbbe6	SHAMPOO NUTRIBELA REPARACION INTENSIVA 400ML	7702354956219	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:42.267176	2025-10-19 02:29:42.267176
737d3277-32ab-417c-97ec-c39eafb380b5	SHAMPOO NUTRIBELA ENZIMOTERAPIA 400ML	7702354956226	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:42.267445	2025-10-19 02:29:42.267445
3009125a-a7d7-4cc4-b6f5-122ddc2b2a51	SHAMPOO NUTRIBELA HIALURONICO 400ML	7702354956240	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:42.267796	2025-10-19 02:29:42.267796
dd58b9e4-a84c-437e-b690-107d39ce667e	NUCITA WAFER 20GR	7702011200877	t	700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.268038	2025-10-19 02:29:42.268038
2419eec1-8bad-4b72-9fff-367f8fd6c971	AROMATEL MANDARINA 400ML	7702191164044	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:42.268453	2025-10-19 02:29:42.268453
95e63166-896b-4d4a-9e8e-d439966ed0f4	BIGBOM XXL X48 WHITE	7707014908751	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.268687	2025-10-19 02:29:42.268687
a7989560-206b-4e4f-931b-ed0560966ff6	GILLETTE SPECIAL GEL 82GR	7500435182553	t	17900.00	17400.00	\N	\N	19.00	2025-10-19 02:29:42.269006	2025-10-19 02:29:42.269006
891d11a0-466d-4984-af51-fdf9700df855	ENJUAGUE BUCAL ORAL BDETOX 500ML	7500435228152	t	18800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.269258	2025-10-19 02:29:42.269258
4413c3da-d0ed-4665-a4e6-d8a2019c402c	TRATAMIENTO SAVITAL NUTRICION 425ML	7702006653480	t	17000.00	16500.00	\N	\N	19.00	2025-10-19 02:29:42.269501	2025-10-19 02:29:42.269501
45b93363-c122-4014-80dc-c7273d205766	TRATAMIENDO SAVITAL RESTAURACION 425ML	7702006653411	t	16000.00	15600.00	\N	\N	19.00	2025-10-19 02:29:42.26973	2025-10-19 02:29:42.26973
b5c49513-bbd9-4816-a19c-83abbb4e775c	TRATAMIENTO SAVITAL HIDRATACION 425ML	7702006653473	t	17000.00	16500.00	\N	\N	19.00	2025-10-19 02:29:42.269951	2025-10-19 02:29:42.269951
abe38f5c-13b1-4654-b635-343cf70d710c	JABON LIQUIDO LIMPIUA YA 1000ML	7702037915311	t	5400.00	5150.00	\N	\N	19.00	2025-10-19 02:29:42.270183	2025-10-19 02:29:42.270183
0bce707c-6878-4b38-8f01-13d00a86bba3	SUAVIZANTE LIMPIA YA 760ML	7702037914000	t	3700.00	3550.00	\N	\N	19.00	2025-10-19 02:29:42.270429	2025-10-19 02:29:42.270429
8f1e7562-0cf5-461d-95fc-85c816f5db1e	DESENGRASANTE LIMPIA YA 500ML	7702037912785	t	3300.00	3140.00	\N	\N	19.00	2025-10-19 02:29:42.270689	2025-10-19 02:29:42.270689
9ec0d0b7-327c-49e6-9cbf-95b1d4c99733	ESPONJA DOBLE USO LIMPIA YA	7702037873062	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.270907	2025-10-19 02:29:42.270907
375e1dbd-468a-43b4-bf1b-bc59a092e800	JABON INTIMO INTIBON 210MAS120	7702277446927	t	25500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.271138	2025-10-19 02:29:42.271138
e4fcf42d-1825-493e-bca0-221621cfd148	BIANCHI MINI BARRA 25GR	7702993035115	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.271364	2025-10-19 02:29:42.271364
3177fda9-1dfb-4d5c-b76b-2c8ac908408f	MIXTON LA VICTORIA 240GR NATURAL	7706642001292	t	9300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.271624	2025-10-19 02:29:42.271624
f002abfc-47d2-4e16-8f04-cd75d7372fce	YOGOLIN MIX AROZ 130GR LA MEJOR	7705241503398	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.271872	2025-10-19 02:29:42.271872
f449b801-cb30-4fad-867c-fb031d7dd214	YOGOLIN MIX CHOCOBIZ 130GR LA MEJOR	7705241860941	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.272116	2025-10-19 02:29:42.272116
68b354a4-5e08-4739-a573-692c5482835a	PIAZZA VAINILLA11.7G	7702011271662	t	500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.272387	2025-10-19 02:29:42.272387
c7ec85b2-f38e-46a2-92aa-65d3fb136df6	MANICERO LA ESPECIAL MANI CON SAL 21GR	7702007082968	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.272657	2025-10-19 02:29:42.272657
54089bcb-2a10-4944-bc36-ed0d03950b0d	MANI MOTO RECUBIERTO 44GR	7702189058515	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.272894	2025-10-19 02:29:42.272894
df523c11-944d-47d3-b9f7-81ddc1d03ba4	CLUB SOCIAL MANTEQUILLA 24GR	7622201720223	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.273113	2025-10-19 02:29:42.273113
bf49f5ce-2a60-4029-aa96-884e4287b5d1	CLUB SOCIAL INTEGRAL 24G	7622201720063	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.273334	2025-10-19 02:29:42.273334
c6990cc7-5846-409c-8f90-74a70121e845	HONY BRAN 33GR	7622300117207	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.273572	2025-10-19 02:29:42.273572
37d4ea66-f54f-4d76-9912-1fea409fb8c1	WAFER CAPRI 12GR	77076052	t	400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.273803	2025-10-19 02:29:42.273803
5bc5be0a-4c76-492c-8feb-e01d84eae200	PAX NOCHE 6G	7706263202627	t	2300.00	2060.00	\N	\N	0.00	2025-10-19 02:29:42.274032	2025-10-19 02:29:42.274032
f49d25a9-dedd-44df-8c96-79853a75f4bc	COMPOTA HEINZ MELOCOTON 113GR	608875003159	t	3500.00	3250.00	\N	\N	19.00	2025-10-19 02:29:42.27444	2025-10-19 02:29:42.27444
fe19d04a-4444-403b-8c9c-7e9db005824a	TRULULU CLASICA 80GR	7702993049662	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:42.274699	2025-10-19 02:29:42.274699
ec824d0f-f36b-43f6-a913-18f34e01f370	AXION X TREME LIMON 235G	7509546684338	t	3200.00	3060.00	\N	\N	19.00	2025-10-19 02:29:42.274963	2025-10-19 02:29:42.274963
d8a9be21-ff47-4998-9704-710d30d5eb4b	SHAMPOO HEAD SHOULDERS 700ML LIMPIESA	7500435162265	t	32000.00	31500.00	\N	\N	19.00	2025-10-19 02:29:42.27528	2025-10-19 02:29:42.27528
e7abe049-34b2-4e7c-86d2-fd250f8e2511	FRUTIÑO MEZCLA DE COLOMBIA 18GGR	7702354954338	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:42.275545	2025-10-19 02:29:42.275545
f352e582-bb73-4b21-b116-9f621c881d96	ESPONJA BRILLO INOXIDABLE PINTO	7707112330553	t	4500.00	4400.00	\N	\N	0.00	2025-10-19 02:29:42.275808	2025-10-19 02:29:42.275808
3594b059-1c4d-4507-947c-4722ca59ac33	ESPONJA METALIZADOS PINTO	7702856998533	t	3200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.276034	2025-10-19 02:29:42.276034
62e837d2-e7ca-4eb4-84c9-204ffc553b8a	SAVITAL X2 SHAMPOO Y ACONDICIONADOR	7702006653237	t	29000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.276344	2025-10-19 02:29:42.276344
33e46457-7917-4136-a882-a199128da0ab	BARQUILLOS PIAZZA X24UND	7702011272751	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.276605	2025-10-19 02:29:42.276605
61790415-82a7-4619-ad2d-983bf66ed256	DETODITO MIX X50GR	7702189055569	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.276857	2025-10-19 02:29:42.276857
6715fad7-652e-436a-831d-b333c7acb4f8	LIMPIADOR MULTIUSOS SKAAP LAVANDA 2L	7707371211136	t	6800.00	6550.00	\N	\N	19.00	2025-10-19 02:29:42.277144	2025-10-19 02:29:42.277144
e5a5403e-6ed3-427e-94ec-f94e517e62ff	DETODITO LIMON 50GR	7702189055583	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.277394	2025-10-19 02:29:42.277394
1f0de709-a110-4417-acc6-ba1c51daab1a	TRATAMIENTO SAVITAL 33ML	7702006406673	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.277626	2025-10-19 02:29:42.277626
a8fa8f2a-bc5e-46e6-bd0c-0770379e1891	ELECTROLIT MORA AZUL  625ML	7501125184277	t	7400.00	7180.00	\N	\N	0.00	2025-10-19 02:29:42.27787	2025-10-19 02:29:42.27787
1f447c9e-ad97-4713-a367-310c4fce61e4	ESPONJA DOBLE USO LIMPIA YA	ECEOW	t	700.00	600.00	\N	\N	19.00	2025-10-19 02:29:42.278268	2025-10-19 02:29:42.278268
c6b6c140-db72-4d98-bfca-1bcc7f06e5d6	CERA SOLVENTE ROJA LIMPIA YA CANELA 400ML	7702037900232	t	4000.00	3900.00	\N	\N	19.00	2025-10-19 02:29:42.278522	2025-10-19 02:29:42.278522
4d35ac5b-0b3f-41c1-9e45-6367ede1d00d	CERA SOLVENTE NEUTRA LIMPIA YA CANELA 400ML	7702037900188	t	3900.00	3750.00	\N	\N	19.00	2025-10-19 02:29:42.27873	2025-10-19 02:29:42.27873
dc9410f1-3e38-4e24-998b-83897f3478db	CERA SOLVENTE ESCARLATA CANELA LIMPIA YA 400ML	7702037900331	t	3900.00	3750.00	\N	\N	19.00	2025-10-19 02:29:42.279	2025-10-19 02:29:42.279
8c7945e6-ea2c-4725-8ea6-99a4cd2950a6	BRILLO ACERO LIMPIA YA X24UNID	7702037876384	t	7200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.27927	2025-10-19 02:29:42.27927
dade6007-01cd-4b7d-8622-a4b362479a67	BRILLO DE ACERO LIMPIA YA	BRILLO	t	400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.279631	2025-10-19 02:29:42.279631
70a72289-d436-4118-ac75-eb2f4aebb012	LIMPIAVIDRIOS LIMPIA YA 500ML	7702037912761	t	3500.00	3400.00	\N	\N	19.00	2025-10-19 02:29:42.280018	2025-10-19 02:29:42.280018
1f308af4-6741-468a-88e1-de8d02d40e47	LIMPIADOR MULTIUSOS LIMPIA YA LAVANDA 1L	7702037913102	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:42.280445	2025-10-19 02:29:42.280445
9deb0d6a-2796-49a8-90e0-4bc984277a2e	ACONDICIONADOR NUTRIBELA PRO HIALURONICO 370ML	7702354956288	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:42.280802	2025-10-19 02:29:42.280802
16dd4463-0137-494c-accf-f3d5a2f9a142	ACONDICIONADOR NUTRIBELA CELULAS MADRES 370ML	7702354956271	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:42.281137	2025-10-19 02:29:42.281137
6d5e3873-d611-4f01-b74e-453c1ebc06f8	ACONDICIONDOR NUTRBELA ENZIMOTERAPIA 370ML	7702354956264	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:42.281427	2025-10-19 02:29:42.281427
0b3b96ca-15ab-4783-9041-1b940ea704ff	ACONDICIOADOR NUTRIBELA REPARACION INTENSIVA 370ML	7702354956257	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:42.28164	2025-10-19 02:29:42.28164
893be46f-7241-48e2-851a-6ec3f734fe67	JABON PURO HURTENCIA CON BICARBONATO 180GR	7702191451342	t	1400.00	1350.00	\N	\N	19.00	2025-10-19 02:29:42.28194	2025-10-19 02:29:42.28194
55184899-0542-4d4c-893e-3c167614ff88	SHAMPO DOVE MAS ACONDICIONADOR ANTICASPA 370ML	7702006302197	t	31000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.282178	2025-10-19 02:29:42.282178
50d0c6fe-1944-4e39-aa52-ebf20e431d15	SHAMPOO DOVE NUTRICION COMPLETA MAS ACONDICIONADOR 170ML	7702006301893	t	30500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.28246	2025-10-19 02:29:42.28246
654538a4-c350-4b48-9617-fdefd8cabf0c	SHAMPOO SAVITAL SERUM DE AMINOACIDOS  350ML	7702006406475	t	11800.00	11400.00	\N	\N	19.00	2025-10-19 02:29:42.282697	2025-10-19 02:29:42.282697
26edccd0-70f4-4400-b902-74fea18d15e1	ACONDICIONADOR SERUM DE AMINOACIDOS 490ML	7702006406451	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.282989	2025-10-19 02:29:42.282989
a2040257-9a16-4b7f-b68b-c5e22d9becbe	SEMAFORO SAMORAN TOYS	7709473429259	t	9000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.283255	2025-10-19 02:29:42.283255
7b7338f6-af34-41e4-b1ba-c06c23afa551	JUGUETE BOXEADOR IMPOCANDY	7708250792753	t	9000.00	8700.00	\N	\N	19.00	2025-10-19 02:29:42.283519	2025-10-19 02:29:42.283519
ca043f2a-d641-4b3e-9551-4e5f35854e3e	RUEDA DE LA FORTUNA	7709321474493	t	8500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.283785	2025-10-19 02:29:42.283785
87088161-f25e-4192-a62b-8bd967473fc5	VACA TAMBORES HIPOCANDY JUGUETE	7708250792227	t	7500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.284043	2025-10-19 02:29:42.284043
131611ac-5a28-4a90-8bbf-1c2dcfe27ef4	CAMARA OSO SAMORAN JUGUETE	7707797205160	t	9000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.284338	2025-10-19 02:29:42.284338
1e673b0e-aaf4-4591-b6cf-79547393e53f	DULCE JAULA PAJARO  X30	6920484018497	t	22000.00	21000.00	\N	\N	19.00	2025-10-19 02:29:42.284589	2025-10-19 02:29:42.284589
ffae8459-5f23-4eb0-95d7-b8b0cd743cb7	TONO SOBRE TONO ROJIZO HIDRO 30GR	7707197608950	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.284899	2025-10-19 02:29:42.284899
ad4634a2-bf90-4dd7-8979-531b7618883c	TONO SOBRE TONO AZUL PLATA HIDRO 30GR	7707197608936	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.28519	2025-10-19 02:29:42.28519
53eada70-c9ef-4b8d-8485-de0ad541c2af	TINTE LISSIA 8-7	7703819302008	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:42.285451	2025-10-19 02:29:42.285451
b2daf0cc-174a-4c68-9905-fadd1bc0cff2	TINTE LISSIA 6-5	7703819304958	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:42.285737	2025-10-19 02:29:42.285737
c0a2f4c5-3bc1-4ed6-a897-4637bc85130e	TINTE LISSIA 8-46	7703819304613	t	8500.00	8200.00	\N	\N	19.00	2025-10-19 02:29:42.285981	2025-10-19 02:29:42.285981
11ceb7af-5ba0-4bd1-b852-263543d27585	TINTE LISSIA 8-3	7703819301971	t	8500.00	8200.00	\N	\N	19.00	2025-10-19 02:29:42.286277	2025-10-19 02:29:42.286277
e3116b2d-2988-4850-9d1d-ceca0d084d32	TINTE LISSIA 5-0	7703819301841	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:42.286534	2025-10-19 02:29:42.286534
777e3f1f-be7a-48e7-b051-3844945433e9	TINTE LISSIA 7-77	7703819304972	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:42.28678	2025-10-19 02:29:42.28678
6d641205-58e9-4bdc-af20-caeed7dc6b3c	BONBONERA PINGUINO YOLIS X90UNID	7708545374763	t	27800.00	27300.00	\N	\N	19.00	2025-10-19 02:29:42.287064	2025-10-19 02:29:42.287064
d6e11886-9530-445c-bbdc-49101496fc8c	TINTE KERATON 10-89	7707230996273	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.287364	2025-10-19 02:29:42.287364
89f5f794-349c-4510-869d-fe17e6716c28	BONBONERA OJOS LOCO SHIFFLIS X50	6920484012921	t	25600.00	25100.00	\N	\N	19.00	2025-10-19 02:29:42.287617	2025-10-19 02:29:42.287617
b20eab00-0595-45c8-b799-c2e343766c3a	PAPAS KRUMER CHIPS 500GR	7709990196054	t	5800.00	5700.00	\N	\N	0.00	2025-10-19 02:29:42.287862	2025-10-19 02:29:42.287862
cc12e1fc-a530-4100-81b7-fd9116324f06	GUMY BALL OJITOS X30UNID	7708527098793	t	14300.00	13900.00	\N	\N	19.00	2025-10-19 02:29:42.288133	2025-10-19 02:29:42.288133
2c793d95-b15d-4bfe-99ae-74d8f1c82cf3	BON BONERA OJOS LOCOS SHIFFIS X50	6975896432461	t	25600.00	25100.00	\N	\N	19.00	2025-10-19 02:29:42.288351	2025-10-19 02:29:42.288351
0ef6ac4d-c6a8-4d7c-8f2b-f8de091b9956	BON BONERA YUMY GOMY EMOLLIS X50UNID	6920484012938	t	38300.00	37400.00	\N	\N	19.00	2025-10-19 02:29:42.288543	2025-10-19 02:29:42.288543
fe01419b-70f3-49f7-9ebd-c52b72c0c598	GELATINA HAPPY JELLY BOLSA X45UNID	6921101241694	t	21800.00	21500.00	\N	\N	19.00	2025-10-19 02:29:42.288795	2025-10-19 02:29:42.288795
5a78147f-ec2b-4cfc-9767-8c9f26e07bf0	SHAMPOO CON GINSENG SIN SAL 500ML	7707957514569	t	38200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.289056	2025-10-19 02:29:42.289056
c1222f9b-552a-4766-aa2a-f37425289288	PINGUINO TRIPLE CHOCOLATE 80GR	7705326020154	t	3900.00	3800.00	\N	\N	19.00	2025-10-19 02:29:42.289358	2025-10-19 02:29:42.289358
d4eea55d-98f1-42cb-ba3e-7ab9226616d9	LAVALOZA LIQUIDO VISTORY 500ML	7707271382370	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:42.289613	2025-10-19 02:29:42.289613
b6c9794a-92d4-4649-9e79-92fedc62d18a	SOPA NISSIN RAMEN 85GR VERDURA	7891079012444	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:42.289833	2025-10-19 02:29:42.289833
0673df49-e6a7-4e15-8e5e-43a61f4468d7	SOPA NISSIN RAMEN POLLO 85GR	7891079014066	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:42.290059	2025-10-19 02:29:42.290059
b5d5eaf5-1c36-4a1e-b659-038f8d18ed34	SOPA NISSIN RAMEN 85GR COSTILLA	7891079013335	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:42.290374	2025-10-19 02:29:42.290374
f41a47de-27ee-4d58-98e9-821f319b121f	BIANCHI BARRA SURTIDO X18UNID	7702993054871	t	14900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.290602	2025-10-19 02:29:42.290602
2a7fcfa1-5d07-4c7c-8e0a-0c916255db6c	DETERGENTE VICTORY FLORAL 1L	7707271382110	t	5600.00	5400.00	\N	\N	19.00	2025-10-19 02:29:42.290832	2025-10-19 02:29:42.290832
d39eeaaa-6b9c-4ca2-b62f-42b1ad5cdb08	DETERGENTE VICTORY FLORAL 250GR	7707271381335	t	1600.00	1450.00	\N	\N	19.00	2025-10-19 02:29:42.291191	2025-10-19 02:29:42.291191
78301ca9-ac07-4c84-ad9d-6c53cfab9cb4	DETERGENTE VICTORY LIMON 500GR	7707271381397	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.291415	2025-10-19 02:29:42.291415
a3347fec-b931-4e9b-9d28-6f5809b562cd	DETERGENTE VICTORY PLUS BICARBONATO 500GR	7707271381342	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.29167	2025-10-19 02:29:42.29167
df9c9eb5-cfe3-45c5-aa00-e803d543aaec	DETERGENTE VICTORY LIMON 1.000GR	7707271381403	t	5800.00	5650.00	\N	\N	19.00	2025-10-19 02:29:42.291892	2025-10-19 02:29:42.291892
3f735649-4784-41bf-aac7-707f64ff4c86	DETERGENTE VICTORY FLORAL 1.000GR	7707271381359	t	5800.00	5650.00	\N	\N	19.00	2025-10-19 02:29:42.292112	2025-10-19 02:29:42.292112
7f35ef76-8701-4903-bf70-eff8cd1d0cee	DETERGENTE VICTORY PRENDA DELICADAS 1L	7707271382011	t	5800.00	5650.00	\N	\N	19.00	2025-10-19 02:29:42.292366	2025-10-19 02:29:42.292366
501445f0-55b5-4969-89e5-24335590c2f7	SUAVIZANTE VICTORY FLORAL 1L	7707271382103	t	4600.00	4450.00	\N	\N	19.00	2025-10-19 02:29:42.292559	2025-10-19 02:29:42.292559
7ec069d6-dbd3-43bf-8629-4f052414cf07	SUAVIZANTE MANZANA VERDE 1L	7707271382318	t	4500.00	4350.00	\N	\N	19.00	2025-10-19 02:29:42.292859	2025-10-19 02:29:42.292859
5859c417-6000-402b-9a2a-42d3e55d5699	DETERGENTE BOW FLORAL 2.7K	7707271382202	t	12300.00	12000.00	\N	\N	19.00	2025-10-19 02:29:42.293144	2025-10-19 02:29:42.293144
7e8e10f8-55f4-456b-8ee6-0ccef82b1128	FAB ULTRA FLASH VIBRA COLOR 800GR	7702191164419	t	8200.00	8050.00	\N	\N	19.00	2025-10-19 02:29:42.293383	2025-10-19 02:29:42.293383
b775e507-48f8-4cd2-aca8-bb1bdad7863a	LIMPIAPISOS VICTORY LAVANDA 1L	7707271382257	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:42.293637	2025-10-19 02:29:42.293637
64d3d2cb-2f3e-45bb-a179-159c4d9da54d	DETERGENTE BOW FLORAL 1.000GR	7707271382462	t	4300.00	4100.00	\N	\N	19.00	2025-10-19 02:29:42.293916	2025-10-19 02:29:42.293916
b0a9899d-1445-48f9-9d05-9aaf628ec2cc	LIMPIAPISOS VICTORY BICARBONATO  960ML	7707271382264	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.294191	2025-10-19 02:29:42.294191
ef695b55-d02f-475e-8c20-ceb1e3bc30d8	SUAVIZANTE VICTORY FLORAL 3L	7707271382271	t	12400.00	12000.00	\N	\N	19.00	2025-10-19 02:29:42.294436	2025-10-19 02:29:42.294436
5422a921-d961-401a-83cb-400424559073	DETERGENTE BOW FLORAL 500GR	7707271382455	t	2200.00	2050.00	\N	\N	19.00	2025-10-19 02:29:42.294717	2025-10-19 02:29:42.294717
853a5f41-9828-4b47-b1d4-ff1fbf7b7c47	DESENGRASANTE VICTORY 500ML	7707271383186	t	3000.00	2850.00	\N	\N	19.00	2025-10-19 02:29:42.294961	2025-10-19 02:29:42.294961
d3df25b4-428e-447f-8e15-b373ba5305f8	JABON DE BARRA LIQUIDO VICTORY 960ML	7707271382363	t	4500.00	4350.00	\N	\N	19.00	2025-10-19 02:29:42.295238	2025-10-19 02:29:42.295238
e1973b0a-a0e7-4b1b-9a38-0c9b9e1ca6ec	AZUCAR ZUCARU 1.000GR	664697052928	t	4200.00	4080.00	\N	\N	5.00	2025-10-19 02:29:42.295508	2025-10-19 02:29:42.295508
a53516b7-1e5b-4a03-8fc4-4ac70add2b08	MAYONESA M 175GR	75971403	t	6900.00	6650.00	\N	\N	0.00	2025-10-19 02:29:42.295814	2025-10-19 02:29:42.295814
fd6bccb2-965e-46bd-ae41-af42eb70ddd9	CAPRI WAFER X24UNID FRESA	7702011200907	t	6100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.296083	2025-10-19 02:29:42.296083
42a2ed5d-623f-4e78-8c1d-3d7978eca2c0	OKA LOKA NANOS 40GR	7702993016558	t	1900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.296348	2025-10-19 02:29:42.296348
fd1e77f3-dac8-4e3f-ab3b-dcc46627b0ba	CEPILLO INFINITO DIENTE ADULTO	7708320718195	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.296615	2025-10-19 02:29:42.296615
2b06cb09-c9c9-47e5-905e-8b18757a33c2	KUMIS 20ML X6	7705241400222	t	7900.00	7100.00	\N	\N	19.00	2025-10-19 02:29:42.296819	2025-10-19 02:29:42.296819
471b9ca2-2907-456e-9658-789a6962ee40	TRIDENT 5.1G YERBABUENA	7622201800345	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.297114	2025-10-19 02:29:42.297114
3acddb86-a61e-48d0-b503-6a039540ab2f	SHAMPOO SAVITAL 350ML FUERZA EXTRAOR	7702006301701	t	11800.00	11500.00	\N	\N	19.00	2025-10-19 02:29:42.297381	2025-10-19 02:29:42.297381
0db574cd-4998-43f1-b8fc-a4a9cecf06f3	GUANTES LIMPIUA YA TALLA 9 AMARILLO	7702037568005	t	3900.00	3770.00	\N	\N	19.00	2025-10-19 02:29:42.297652	2025-10-19 02:29:42.297652
8861c34b-644e-4c2e-8e3e-f4905c8598ec	PAPAS KRUMER CHIPS 1.000GR	7709990399417	t	10000.00	9700.00	\N	\N	19.00	2025-10-19 02:29:42.297934	2025-10-19 02:29:42.297934
69169ed3-c191-488c-ba73-be8e00ab2308	FAB ULTRA FLASH 800GR	7702191164303	t	8200.00	8050.00	\N	\N	19.00	2025-10-19 02:29:42.29823	2025-10-19 02:29:42.29823
c57a8fea-0e75-46ba-90c1-220a9fee8607	NATUCHIPS VERDE 135GR	7702189045720	t	7100.00	6900.00	6750.00	\N	0.00	2025-10-19 02:29:42.298494	2025-10-19 02:29:42.298494
090af3e0-2166-413b-9a26-c9fe61971ce5	BANDEJA DE COCA-COLA 1.5LTS X12 UND	COCA COLA BANDEJA 1.5	t	57500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.298754	2025-10-19 02:29:42.298754
9c62bdcd-5554-4883-b604-ec0b8962e6e0	GUANTES TERNA TALLA8	7702037503266	t	5100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.299013	2025-10-19 02:29:42.299013
022f19ce-1c19-4758-9e00-084ecbf4ced7	ENCENDEDOR MEGA PISTOLA	7707015508158	t	4600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.299288	2025-10-19 02:29:42.299288
1a0d6415-c213-4508-a87b-0f48c0320ef9	BOLSA 10K	BOLSA 10	t	5600.00	5500.00	\N	\N	0.00	2025-10-19 02:29:42.299578	2025-10-19 02:29:42.299578
ffc94b87-c58b-4b68-a9a7-002c546d71a2	TOALLAS ESBELTA 8 NOCTURNA MAS 8 NORMAL	7709952092066	t	5000.00	4850.00	\N	\N	0.00	2025-10-19 02:29:42.299781	2025-10-19 02:29:42.299781
ebf4b1f1-ad11-45dc-a988-f9aa7b96c658	GEL DE DUCHA AGRADO ROSAS 750ML	8433295048303	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.300006	2025-10-19 02:29:42.300006
c7d3b22f-6fbe-400f-bfa2-028b5b10abdb	ENJUAGUE BUCAL COLGATE PLAX KIDS 250ML	7891024136201	t	12500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.30026	2025-10-19 02:29:42.30026
37adcc09-6a4a-4006-b098-d96ab88ca0af	DETERGENTE ARIEL 800ML	7500435172035	t	10500.00	10200.00	\N	\N	19.00	2025-10-19 02:29:42.300507	2025-10-19 02:29:42.300507
f32de80e-6ff8-4582-a7b3-30f5f0c81ecf	JABON INTIMO AGRADO 500ML	8433295047115	t	12200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.300739	2025-10-19 02:29:42.300739
d4845c05-1df7-4d1e-88a4-7cdd4058979e	DUCALES X6UNID 600GR	7702025150922	t	14800.00	14600.00	\N	\N	19.00	2025-10-19 02:29:42.301046	2025-10-19 02:29:42.301046
afa9a579-4de1-40db-bc61-bb4a0c4e55c5	PALO PINCHO GRUESO EL SOL 30CM X100UNID	7707015506338	t	3100.00	2950.00	\N	\N	0.00	2025-10-19 02:29:42.301296	2025-10-19 02:29:42.301296
4b9ff134-b284-4646-b7be-e03fcbfa5796	LOZA CREAM BALNCOX ALOE Y ROSA 850GR	7703812405539	t	10600.00	10300.00	\N	\N	19.00	2025-10-19 02:29:42.301528	2025-10-19 02:29:42.301528
cc2b3b02-1831-45d5-9890-6375e296da6f	SUAVITEL PRIMAVERAL 1.5L	7702010283154	t	11500.00	11200.00	\N	\N	19.00	2025-10-19 02:29:42.301787	2025-10-19 02:29:42.301787
cdd20963-835d-4962-92b9-1e16805cc1ce	BUBBALOO CEREZA X47	7622202222009	t	10300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.302137	2025-10-19 02:29:42.302137
bc6e3723-a443-42a6-8d0c-a14da8b6a844	ESONJA PINTO ARCOIRIS MULTIUSOS	7707112330515	t	2700.00	2500.00	\N	\N	0.00	2025-10-19 02:29:42.302428	2025-10-19 02:29:42.302428
8c9341ab-092a-483b-bb89-e1104d757b20	CEPILLO LAVAR ROPA TIPO PLANCHA ECONOMICO	CÑCE	t	2700.00	2550.00	\N	\N	0.00	2025-10-19 02:29:42.302733	2025-10-19 02:29:42.302733
8bf17421-2da4-49f9-be7e-5b12ec7a3daa	COMBO SHAMPOO Y MASCARILLA NEGRA  300ML NATURVITAL	7702377077731	t	31000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.303033	2025-10-19 02:29:42.303033
ed3a1235-3b9b-4f83-b2d5-c7fcf05380e7	ATUN ZENU ACEITE DE GIRASOL 120GR	7701101361665	t	4600.00	4500.00	\N	\N	19.00	2025-10-19 02:29:42.303359	2025-10-19 02:29:42.303359
27b1d75c-4b77-41e3-a35b-c45c39ecd0c2	EL MANICERO LA ESPECIAL MIX X9UNID	7702007083026	t	13700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.303609	2025-10-19 02:29:42.303609
81315b8c-5065-4855-b034-93a7990c4055	SALTIN NOEL SULTANA 220GR	7702025104741	t	6700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.304024	2025-10-19 02:29:42.304024
a6c9e47c-7e9a-4046-8f39-e4aed030d380	BIANCHI CHOCOMANI RELLENO X100UNID	7702993054550	t	10300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.304262	2025-10-19 02:29:42.304262
7f2ef01f-df96-4433-84e3-34ea173d992c	CREMA DE LECHE PARMALAT CAJA 200ML	7700604019851	t	5300.00	5150.00	\N	\N	0.00	2025-10-19 02:29:42.304488	2025-10-19 02:29:42.304488
9fcc10fb-5fd4-47e9-9aa1-ff7e87ebd08f	SALSA INGLESA DELSAZON 170ML	7701095758946	t	2100.00	1950.00	\N	\N	19.00	2025-10-19 02:29:42.304715	2025-10-19 02:29:42.304715
cd4878e0-a795-4fb2-ae37-402635401ede	SALMON VENFOOD 170GR	7752364789123	t	2200.00	2080.00	\N	\N	0.00	2025-10-19 02:29:42.304936	2025-10-19 02:29:42.304936
5ab32131-fc30-4ab9-8dbc-c50632639e41	GOLPE PICANTE LIMONB 45GR	7703133013208	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.305166	2025-10-19 02:29:42.305166
0210a368-9cae-45c7-b917-b8a04bec4216	AMOXICILINA COMED X50	AMOCXIF	t	10500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.305391	2025-10-19 02:29:42.305391
1831069c-90be-4c31-b2e8-c03a3df9dc14	REVOLCON CHUPETA HIPER ACIDO X12UNID	7702993044162	t	11300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.305626	2025-10-19 02:29:42.305626
14482885-a4af-485d-89a8-26862486ab59	PRESTOBARBA SCHI VERDE 12 MAS 2 QUATRO	7707254797191	t	35500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.305912	2025-10-19 02:29:42.305912
6aed6359-2531-4eb5-898a-e10e44a0fff4	OKA LOKA CHICLE EN POLVO X12UNID	7702993047804	t	8900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.306146	2025-10-19 02:29:42.306146
e202ab0a-8382-4e8b-b0b9-b973d3c60fa2	ATUN LOMITO PERLADO EN AGUA 175GR	7709378111051	t	4400.00	4300.00	\N	\N	19.00	2025-10-19 02:29:42.30645	2025-10-19 02:29:42.30645
26547e11-e0dc-4fda-bb3a-7b915a1922ed	AGUA LA MEJOR 5 LITROS	7705241513311	t	3500.00	3200.00	3000.00	\N	0.00	2025-10-19 02:29:42.306673	2025-10-19 02:29:42.306673
8db6bd3f-5889-4598-9049-1958f5b39ddd	YOGUETA FRUTRALES X24 FRESA	7702174081627	t	7600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.306899	2025-10-19 02:29:42.306899
996cebcc-4310-450f-9afd-f51a8e31c27a	MANI MOTO SALADO X12 432G	7702189056399	t	14400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.307126	2025-10-19 02:29:42.307126
cbb8557a-7278-4ad6-ac9a-3116283bc884	LONCHERITA LA VICTORIA SURTIDA X12 210G	7706642002473	t	7600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.307351	2025-10-19 02:29:42.307351
6b547016-ff08-431b-90a3-8df43451dde9	GLASES TROPICO 1KILO	GEFE	t	6400.00	6200.00	\N	\N	0.00	2025-10-19 02:29:42.307577	2025-10-19 02:29:42.307577
3fb0e303-b307-4072-82b1-003880b1f215	AZUCAR ANGUIE 1.000GR	7709397662954	t	4000.00	3920.00	\N	\N	5.00	2025-10-19 02:29:42.307802	2025-10-19 02:29:42.307802
8afcbe2a-f48e-49f0-be65-deca6a37d956	GUANTES PINTO DOMESTICOS 7 Y MEDIO	7707112350230	t	3900.00	3750.00	\N	\N	19.00	2025-10-19 02:29:42.308031	2025-10-19 02:29:42.308031
29d88f7b-3a0f-4b6f-a679-3bfadaf9ff0e	GUANTES PINTO DOMESTICOS TALLA 9	7707112350261	t	3900.00	3750.00	\N	\N	19.00	2025-10-19 02:29:42.308272	2025-10-19 02:29:42.308272
5bc928d1-a948-4e45-ae18-7dbae9992c4a	PROTECTORES ANGELA X15 X3	7707324640365	t	4000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.308502	2025-10-19 02:29:42.308502
49448016-5ef2-41dd-b9bb-9fb52492b1bf	PROTECTORES ANGELA X15 ALGODON	7707324641218	t	1500.00	1400.00	\N	\N	0.00	2025-10-19 02:29:42.30873	2025-10-19 02:29:42.30873
c0eb1392-4a28-4228-8fc7-98f260430b01	PROTECTORES ANGELA X120 TIPO ALGODON	7707324640440	t	9600.00	9200.00	\N	\N	0.00	2025-10-19 02:29:42.308934	2025-10-19 02:29:42.308934
dbc379e2-5dec-4f2f-a288-6e5f139332d2	VINAGRE IDEAL 1L	7709844868601	t	2000.00	1900.00	\N	\N	0.00	2025-10-19 02:29:42.309184	2025-10-19 02:29:42.309184
ba3e6534-ac52-49d1-9b88-adaa984e39bd	SALSA NEGRA DEL SAZON PEQUEÑA	7701094858838	t	2100.00	2000.00	\N	\N	19.00	2025-10-19 02:29:42.309463	2025-10-19 02:29:42.309463
eea1e40b-775b-4e18-b318-5f6863828108	CERA ESCARLATA NETTUNO 350GR	7702377067756	t	5000.00	4800.00	\N	\N	19.00	2025-10-19 02:29:42.309737	2025-10-19 02:29:42.309737
8e98762a-1ca1-4f81-b609-d205380765fd	POP MITAS X12 240GR	7706642005405	t	10700.00	10500.00	\N	\N	19.00	2025-10-19 02:29:42.310019	2025-10-19 02:29:42.310019
1ba34d29-0b6b-4afe-b272-3ee7bdebe924	DETODITO NATURAL X6 45GR	7702189011473	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.310309	2025-10-19 02:29:42.310309
27088f13-ecd1-45d7-9ee4-680b768a768a	PIN POP GIGANTE X24 CEREZA	7702174085397	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.310575	2025-10-19 02:29:42.310575
e7347eed-7583-47fa-8689-ac2fce04a145	TAKIS FUEGO 50GR	7500810027400	t	3400.00	3350.00	\N	\N	19.00	2025-10-19 02:29:42.310813	2025-10-19 02:29:42.310813
52f12c23-6bb7-4eab-b8d6-8378e1691c3b	LOLAX SURTIDO X6 200ML	7705241383433	t	7600.00	6700.00	6600.00	\N	19.00	2025-10-19 02:29:42.311089	2025-10-19 02:29:42.311089
e2bcf51e-c700-461f-840b-1a82dedca575	TUTTI FRUTTI SALPICON 250ML	7702509856029	t	900.00	834.00	\N	\N	19.00	2025-10-19 02:29:42.311355	2025-10-19 02:29:42.311355
8c1c0fda-05dc-4bd0-832f-8c5c3dca5363	TUTTI FRUTTI FUSION CITRICO 250ML	7702509773951	t	900.00	834.00	\N	\N	19.00	2025-10-19 02:29:42.31167	2025-10-19 02:29:42.31167
8445781a-e19a-498b-9dd4-dee5b544f816	MONSTER MANGO LOCO ENERGY 473ML	070847038764	t	8500.00	8000.00	\N	\N	19.00	2025-10-19 02:29:42.311928	2025-10-19 02:29:42.311928
6ee96bfd-05d9-419f-9a22-6ce883c75486	AGUA CRISTAL 600ML	7702090022711	t	1400.00	1167.00	\N	\N	0.00	2025-10-19 02:29:42.312134	2025-10-19 02:29:42.312134
81ed1e0f-4d32-4dc7-9c6a-febcf103e36b	AGUA CRISTAL 1L CHUPO	7702090069761	t	2000.00	1625.00	\N	\N	0.00	2025-10-19 02:29:42.312351	2025-10-19 02:29:42.312351
a9ca0564-37eb-43cc-a711-4da2914d87d3	MANICERO LIMON 18GR	7702007083019	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.312568	2025-10-19 02:29:42.312568
ae517715-3c75-4457-a711-654b2384079b	COLOMBIANA POSTOBON 1.5L	7702090029505	t	3500.00	3209.00	\N	\N	19.00	2025-10-19 02:29:42.312802	2025-10-19 02:29:42.312802
bb082581-18d9-4e93-888f-3ee6d8dc81a2	AROMATEL FLORAL 180ML	7702191164006	t	1600.00	1450.00	\N	\N	19.00	2025-10-19 02:29:42.313183	2025-10-19 02:29:42.313183
fa94eff6-5def-4c38-8d84-5a4cc2368074	TRIFOGON DEL FOGON X24UNI	7702354955113	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.313426	2025-10-19 02:29:42.313426
c6e69500-0575-4ee4-a3ae-9e3fdf9347ac	BOKA NARANJA 10GR	7702354955731	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.313621	2025-10-19 02:29:42.313621
771961d0-e10a-434a-8d99-0a0c5c09ff8b	BOKA PIÑA 10GR	7702354955779	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.313844	2025-10-19 02:29:42.313844
67234ab7-b9dd-4830-a475-1553d67bebb8	BOKA SANDIA 10GR	7702354956745	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.314029	2025-10-19 02:29:42.314029
34ba9d43-2069-41c3-8450-d8a657a2a74f	BOKA TAMARINDO 10GR	7702354955694	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.314221	2025-10-19 02:29:42.314221
5a6742bd-e624-4b94-9dd9-cd587ab4c46f	BOKA DURAZNO 10ML	7702354956684	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.314463	2025-10-19 02:29:42.314463
334c65c8-c46b-4df3-b015-3c0be29e1146	BOKA LIMA LIMON 10GR	7702354955724	t	800.00	710.00	\N	\N	19.00	2025-10-19 02:29:42.314652	2025-10-19 02:29:42.314652
b40eec64-29e8-4c3b-85c7-55e0635f20f6	PILAS TRONEX 9V	7707822754182	t	4000.00	3900.00	\N	\N	19.00	2025-10-19 02:29:42.31485	2025-10-19 02:29:42.31485
bdb611e2-3fc8-4954-882a-aa967b6cecca	ELITE DUO AMARILLO	7707199344993	t	1800.00	1688.00	\N	\N	19.00	2025-10-19 02:29:42.315044	2025-10-19 02:29:42.315044
de1c843e-f872-4640-bb83-16a8b4db89e9	LOZA CREAM BLANCOX 450GR	7703812003773	t	5900.00	5650.00	\N	\N	19.00	2025-10-19 02:29:42.315332	2025-10-19 02:29:42.315332
1e3307ae-f9a6-45cf-b7f3-0af848ad8325	FULL FRESH LIMPIAPISOS FRUTAL TROPICAL 1L	7707112350728	t	5200.00	5000.00	\N	\N	19.00	2025-10-19 02:29:42.315651	2025-10-19 02:29:42.315651
66877e2d-4a0b-4636-96bc-0bd6c939afcf	FULL FRESH LIMPIAPISOS BRISAS DEL BOSQUE 1L	7702856107683	t	4400.00	4250.00	\N	\N	19.00	2025-10-19 02:29:42.315974	2025-10-19 02:29:42.315974
eb1e37c4-f442-401b-a2ed-e1a9862d7adb	LIMPIAPISOS PINTO FLORAL 1L	7702856952979	t	3300.00	3180.00	\N	\N	19.00	2025-10-19 02:29:42.316329	2025-10-19 02:29:42.316329
c2e09062-4ca1-4469-830c-b5a0a2df7777	LIMPIAPISOS PINTO LAVANDA 1L	7702856952993	t	3300.00	3180.00	\N	\N	19.00	2025-10-19 02:29:42.316756	2025-10-19 02:29:42.316756
baba831e-84e0-4a13-91cd-d19ec677442e	SALMON DIAMANTE EN TOMATE 155GR	7862127010484	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:42.317129	2025-10-19 02:29:42.317129
fe933f1f-abd2-4d22-ab34-ba0ae511da56	CITA MATA MOSCA X4UNID	6970081495016	t	3500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.317542	2025-10-19 02:29:42.317542
c326c14c-62c1-4ead-95b9-a2b0378492c5	AROMATICA MI DIA CIDRON X20UNI	7700149010689	t	2400.00	2250.00	\N	\N	19.00	2025-10-19 02:29:42.317879	2025-10-19 02:29:42.317879
568d9a7d-ffb3-4d2f-8391-52043ba999c0	AROMATICA MI DIA MANZANILLA X20UNID	7700149010818	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:42.318205	2025-10-19 02:29:42.318205
11c21467-0700-4adf-8d16-53dca8343511	AROMATICA MI DIA HIERBABUENA 20UNID	7700149010801	t	2400.00	2250.00	\N	\N	19.00	2025-10-19 02:29:42.318585	2025-10-19 02:29:42.318585
1bb96037-bea1-445e-894f-93b98146531a	AROMATICAMI DIA LIMONCILLO X20UNID	7700149010825	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:42.318952	2025-10-19 02:29:42.318952
309a34f3-7c36-4be3-bf7b-a131f2800ec1	RINGO ORIGINAL ADULTO 1KG	7703090112426	t	5000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.31935	2025-10-19 02:29:42.31935
116738d3-48c4-4345-8154-08a5e6b0d3e7	VINAGRE FULL FRESH LIMPIADOR 500ML	7702856971130	t	4500.00	4400.00	\N	\N	19.00	2025-10-19 02:29:42.319658	2025-10-19 02:29:42.319658
160197fb-53d0-445b-b566-44445dfdfca3	SABRINA ESPACIBLE 125GR	7706649199572	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.319949	2025-10-19 02:29:42.319949
2c4aae24-90f5-40f6-8d0e-675106b537b8	COCA COLA 1LITRO	7702535001721	t	4000.00	3900.00	\N	\N	19.00	2025-10-19 02:29:42.320337	2025-10-19 02:29:42.320337
337e644b-f7f4-42cb-b9e0-bfd620270039	CEPILLO COLGATE FRESH X5 MEDIO	7509546653143	t	25000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.320762	2025-10-19 02:29:42.320762
de255b03-522d-4ae6-8da7-a9db29310ac7	ELLAS NOCTURNAS  8 MAS 8	7702108850794	t	4600.00	4450.00	\N	\N	0.00	2025-10-19 02:29:42.321214	2025-10-19 02:29:42.321214
62454060-7fe4-4da6-a785-1486f077cfcc	DETERGENTE BONAROPA 2.8KG	7700304038718	t	11500.00	11100.00	\N	\N	19.00	2025-10-19 02:29:42.321691	2025-10-19 02:29:42.321691
299a7414-ff83-45f0-950a-498b78470f7d	TAPABOCAS BEGUT X50UNI	7707282990885	t	11500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.322394	2025-10-19 02:29:42.322394
f82ce048-ac38-4324-8b77-5fa3647b3449	COCOSETTE SANDWICH PG 12 LLV 14	7702024946816	t	14200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.322832	2025-10-19 02:29:42.322832
b9fb0387-2ec2-49e6-92cf-9c6b52d39b48	PISTOLA TIKETEADORA	pisto	t	22000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.323412	2025-10-19 02:29:42.323412
860950fa-ecba-4cc4-967f-b2c48f26984d	CEPILLO TRI DENT NEW NIÑOS	7453012373274	t	1200.00	1000.00	\N	\N	0.00	2025-10-19 02:29:42.323803	2025-10-19 02:29:42.323803
4ac8b73f-c776-4316-a42c-b99566340372	ENCENDEDOR DURALIGHT MAS REPUESTO	6938564200571	t	6500.00	6000.00	\N	\N	0.00	2025-10-19 02:29:42.324232	2025-10-19 02:29:42.324232
9b493fd3-d066-4960-bc77-b5325e9388d9	TRAMPA PARA RATON MADERA	6915583687286	t	4500.00	4000.00	\N	\N	0.00	2025-10-19 02:29:42.324662	2025-10-19 02:29:42.324662
a25e27bb-6e52-4e66-9306-78f6f3183def	MAQUINA AFEITADORA PROVAL SAFETY	6971818496924	t	4300.00	4000.00	\N	\N	0.00	2025-10-19 02:29:42.325083	2025-10-19 02:29:42.325083
5e2264df-fba5-4ecb-b979-604bf87d2a20	PEGA AB SUPER MAS 3 MINUTOS	PEGA	t	3800.00	3600.00	\N	\N	0.00	2025-10-19 02:29:42.325471	2025-10-19 02:29:42.325471
8540e056-eec3-4d36-a01b-0c704f1b0225	REJILLA LAVAPLATOS	6925525524104	t	3000.00	2600.00	\N	\N	0.00	2025-10-19 02:29:42.325828	2025-10-19 02:29:42.325828
b7f0b1e9-f178-4e3f-9619-038380aa5404	CORTA UÑAS GRANDE BANDERA PAISES	CORTA U	t	2500.00	2100.00	\N	\N	0.00	2025-10-19 02:29:42.326233	2025-10-19 02:29:42.326233
8cc97ad6-8bdc-4f7e-bba3-bd25542aa9a1	CHOCOLISTO COOKIES I CREAM 160GR	7702007083439	t	7300.00	7100.00	\N	\N	19.00	2025-10-19 02:29:42.326698	2025-10-19 02:29:42.326698
2978de3e-83ce-489e-94cb-8ee83a014130	VASELINA SUPER MAS	CWEV	t	1800.00	1500.00	\N	\N	0.00	2025-10-19 02:29:42.326966	2025-10-19 02:29:42.326966
5ea264d3-6a25-43c9-b603-9fc5db8ca459	PASTILLA ALCANFOR SUPER MAS	PASTI	t	1000.00	900.00	\N	\N	0.00	2025-10-19 02:29:42.327311	2025-10-19 02:29:42.327311
475476c6-f007-443e-bf75-ef1225751227	CEPILLO DENTAL TRY DENT NEW ADULTO	7453012365071	t	1300.00	1100.00	\N	\N	0.00	2025-10-19 02:29:42.327751	2025-10-19 02:29:42.327751
ea6ac973-7c2c-4048-99df-b5e69e6d564c	ACEITE 3 EN 1 SUPER MAS 90ML	ACEQA	t	3500.00	3000.00	\N	\N	0.00	2025-10-19 02:29:42.328112	2025-10-19 02:29:42.328112
540b9f28-7f2a-4bbb-a4f9-a24e9ab9ed19	PULPO PARA AMARRAR PEQUEÑO	PULPO PARA	t	3200.00	2800.00	\N	\N	0.00	2025-10-19 02:29:42.328619	2025-10-19 02:29:42.328619
9eb6a0a8-2fd1-4660-9f44-1ad83030a996	SHAMPOO ANYELUZ CON BANANO SIN SAL 500ML	7707957514804	t	30000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.329065	2025-10-19 02:29:42.329065
139dc807-ca72-495c-9719-5e27223d927a	TRAPITOS X5UNID COLORES	TRAPERO	t	6600.00	6300.00	\N	\N	0.00	2025-10-19 02:29:42.329442	2025-10-19 02:29:42.329442
e5dbdd9d-e0ae-4bc2-b12d-5861e7a4e0ff	ARCOIRIS SUPER MAS TINTE PARA ROPA 9GR	QACEK	t	1000.00	800.00	\N	\N	0.00	2025-10-19 02:29:42.329784	2025-10-19 02:29:42.329784
7f8594f2-1042-45d9-a555-4fe46e98ca73	TALCO REXONA EFFICINT 180GR	7702006207270	t	14500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.330111	2025-10-19 02:29:42.330111
39ce30e4-d9b4-4fcd-a5c2-9688571a20dc	BETUN CHEARY NEGRO	BETUN	t	1800.00	1500.00	\N	\N	0.00	2025-10-19 02:29:42.330416	2025-10-19 02:29:42.330416
ab68b4d0-57f8-4933-a0e2-6c92ea0a0dcc	POTE DE PASTILLA CLORO X50UNID	CLORO	t	23000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.330795	2025-10-19 02:29:42.330795
57717604-8da3-4c8e-87cf-4228c01f5b39	SILICONA CAPILAR SUPER MAS 10ML	7709294804211	t	1200.00	1000.00	\N	\N	0.00	2025-10-19 02:29:42.331119	2025-10-19 02:29:42.331119
e092c320-c8e5-4e0f-91da-4665626b479d	PALILLOS PARA DIENTES TOOTHPICK	PALIL	t	1200.00	1000.00	\N	\N	0.00	2025-10-19 02:29:42.331389	2025-10-19 02:29:42.331389
6cd78fe8-57f1-4abd-8040-172f586d2d3a	CEPILLO ORALB COMPLETE DUO MEDIO	7501006719932	t	10000.00	9700.00	\N	\N	19.00	2025-10-19 02:29:42.331655	2025-10-19 02:29:42.331655
d93fcce2-7608-4a8f-af3a-d0e519f19c26	CEPILLO LIMPIA YA SON MANGO	7702037877671	t	3200.00	3080.00	\N	\N	19.00	2025-10-19 02:29:42.331983	2025-10-19 02:29:42.331983
3adc76c4-851e-4803-a4b2-584dec4d31f3	PEPSI 1.5L	7702192282983	t	4000.00	3667.00	\N	\N	19.00	2025-10-19 02:29:42.332385	2025-10-19 02:29:42.332385
e6ba9fb2-7105-466b-926f-198ce8db1072	MANZANA POSTOBON 1.5L	7702090029512	t	4000.00	3667.00	\N	\N	19.00	2025-10-19 02:29:42.332789	2025-10-19 02:29:42.332789
57afa0be-2cf1-4894-b129-97a0ee93a440	HIPINTO 1.5L	7702090029628	t	3500.00	3209.00	\N	\N	19.00	2025-10-19 02:29:42.333213	2025-10-19 02:29:42.333213
a5a41044-979d-4967-9583-3f5c01be456c	SUAVIZANTE LIMPIA YA FLORAL   2L	7702037912846	t	7600.00	7400.00	\N	\N	19.00	2025-10-19 02:29:42.33352	2025-10-19 02:29:42.33352
87185662-6c32-41c7-bd2c-d8d7b639e2a5	DETERGENTE LIQUIDO LIMPIA YA 2L	7702037912822	t	11500.00	11000.00	\N	\N	19.00	2025-10-19 02:29:42.333903	2025-10-19 02:29:42.333903
27a7b371-bd06-4a01-95c0-7b076c3df55b	SEÑORIAL AZUL FOCA X12UNID	7707016153180	t	14800.00	14000.00	\N	\N	19.00	2025-10-19 02:29:42.33426	2025-10-19 02:29:42.33426
a4977195-1ad7-405d-8932-8d4ceb6c2ff5	GOL AREQUIPE MEGA 46GR	7702007080667	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.334743	2025-10-19 02:29:42.334743
2a22b022-3ec1-4b12-82dc-5a1c2731641d	CREMA DE ARROZ MARY 450GR	7591473006734	t	3500.00	3400.00	\N	\N	19.00	2025-10-19 02:29:42.335103	2025-10-19 02:29:42.335103
8d825e3a-670c-49b5-bd48-b7d7c89748de	VALDE 11L 637	VALDDE	t	5000.00	4800.00	\N	\N	0.00	2025-10-19 02:29:42.335482	2025-10-19 02:29:42.335482
9b2ba74e-020e-4ded-8870-9d96beb28012	ALCOHOL MK 700ML	7702057075101	t	7700.00	7400.00	\N	\N	0.00	2025-10-19 02:29:42.335848	2025-10-19 02:29:42.335848
59019c91-0e5f-432e-9b00-04da85720415	FRUNAS ORIGINAL X26UNID	7702174087582	t	9300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.336136	2025-10-19 02:29:42.336136
12b2b3ba-988d-4021-a731-9e31e2e70304	TOALLA COSINA FAMILIA GRREN X80UNID	7702026151461	t	5100.00	4900.00	\N	\N	19.00	2025-10-19 02:29:42.33658	2025-10-19 02:29:42.33658
b2294b86-2bae-4db3-8593-6d0742003803	PAPEL FAMILIA GRANDE GREEN	7702026152604	t	1800.00	1709.00	\N	\N	19.00	2025-10-19 02:29:42.336944	2025-10-19 02:29:42.336944
ae533369-5552-4029-987e-fc4c79bc94ee	ELIMINA OLORES FAMILIA 300ML BRISA	7702026143404	t	15700.00	15150.00	\N	\N	19.00	2025-10-19 02:29:42.337263	2025-10-19 02:29:42.337263
cda57efb-1902-4ba4-95fe-148f14c54c3f	ELIMINA OLORES FAMILIA 300ML FRESCURA	7702026320157	t	15700.00	15150.00	\N	\N	19.00	2025-10-19 02:29:42.337568	2025-10-19 02:29:42.337568
10fa4c20-8df6-49c0-81b1-f8b036f382ad	CHOCOLATINA JET LECHE CALCIO 12GR	77013323	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.337838	2025-10-19 02:29:42.337838
ffe1e504-5ff9-493d-ac27-9f8a808af18d	GOL MEGA ARANDANOS MORA X8	7702007082746	t	18400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.338647	2025-10-19 02:29:42.338647
a76b3e16-79f6-4f86-872a-817aaecbd565	GOL MEGA ARANDANOS 46GR	7702007082739	t	2500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.339164	2025-10-19 02:29:42.339164
a5752601-7660-436d-8db8-86941ff81060	JET CHOCOLATINA X16UNID 25GR	7702007080698	t	55200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.339676	2025-10-19 02:29:42.339676
df7f087c-03d3-4a79-9769-78561bd1ead6	CHOCOLATINA JET 25GR	7702007080681	t	3400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.339975	2025-10-19 02:29:42.339975
83723f21-19f0-448a-8ba4-cca89edd4121	ARROZ SAMARA 900GR	7709094571986	t	3600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.340248	2025-10-19 02:29:42.340248
f8b7120d-3a27-495e-ad26-adceaea5ad2c	LAVALOZA LIMPIA YA 250GR	7702037915830	t	2100.00	1950.00	\N	\N	19.00	2025-10-19 02:29:42.340548	2025-10-19 02:29:42.340548
69925952-23cc-4c31-8f70-b7d841f1f109	Q IDA CAN CACHORRO 1KG	7702712003326	t	6200.00	6050.00	\N	\N	5.00	2025-10-19 02:29:42.340783	2025-10-19 02:29:42.340783
6c622c11-5487-4b0d-a517-7cc0c5ef1f87	JET CRUJIBLANCA 24GR	7702007001822	t	3500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.341024	2025-10-19 02:29:42.341024
e8ba59fd-2726-4f9a-82a5-4988bbcce79c	TOALLA SUAVE NOCTURNA X34UNID	7702120013245	t	12500.00	12000.00	\N	\N	0.00	2025-10-19 02:29:42.341302	2025-10-19 02:29:42.341302
b1e08944-082a-4dcc-aa90-2d34ceca4d0e	CREMA DE ARROZ EXTRA SEÑORA 450GR	7708624784957	t	5400.00	5150.00	\N	\N	19.00	2025-10-19 02:29:42.341576	2025-10-19 02:29:42.341576
932166af-f752-4ad0-940e-36b97c7f809c	ENJUAGUE BUCAL SIBYLA MENTA 500ML	7702856951866	t	9800.00	9550.00	\N	\N	19.00	2025-10-19 02:29:42.341899	2025-10-19 02:29:42.341899
b6ed3db2-04b7-4379-9292-387178aeec4d	JABON INTIMO SIBYLA CONFORT 400ML	7702856951927	t	8600.00	8400.00	\N	\N	19.00	2025-10-19 02:29:42.342248	2025-10-19 02:29:42.342248
8a973917-7bde-4005-bcad-fd8220008714	LIMPIA POSETAS MAX LITRO	LIMPIA POSE	t	5200.00	5000.00	\N	\N	0.00	2025-10-19 02:29:42.342597	2025-10-19 02:29:42.342597
49a2e978-344a-41e7-8416-21dcd9674987	CEPILLO PARA BAÑOS POISETA PREMIUN	7709694180700	t	5000.00	4800.00	\N	\N	19.00	2025-10-19 02:29:42.342935	2025-10-19 02:29:42.342935
632287c4-3918-43cc-ad3d-81c44d8c54bd	BALANCE WOMEN CREMA X18	7702045980639	t	19300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.343197	2025-10-19 02:29:42.343197
8459d331-4dc0-4e1f-b674-e967efa0d8a6	YOGUETA FRESA POP X24	7702174087865	t	7600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.343478	2025-10-19 02:29:42.343478
7067d8d6-52fe-4a33-8020-b94938ec3866	PIN POP GIGANTE SURTIDO X24	7702174086905	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.344024	2025-10-19 02:29:42.344024
4ad301ba-f79a-4846-9841-6546e01e235e	JERINGA BEGUT 5ML Y 3ML	jerin	t	500.00	400.00	\N	\N	19.00	2025-10-19 02:29:42.344354	2025-10-19 02:29:42.344354
fc62fd15-1c4d-4ee7-9b36-c378ba80a5fe	JERINGA BEGUT 10ML	JER	t	800.00	600.00	\N	\N	19.00	2025-10-19 02:29:42.344636	2025-10-19 02:29:42.344636
bb9e8202-57e2-45f4-9c2a-0c9bc17366ef	BOLSA ASEO 150L	BOLSA	t	3800.00	3700.00	\N	\N	0.00	2025-10-19 02:29:42.344844	2025-10-19 02:29:42.344844
1ba11ea0-a6f9-40ba-baae-332e1cda274a	CEPILLO COLGATE TRIPLE ACCION BLANCURA X3	7702010130663	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.345122	2025-10-19 02:29:42.345122
9ee9490c-0efd-4042-bef6-54c128f4cf71	SHAMPOO HAPPY ANNE ARGAN Y ACAI 340ML	7750075052789	t	9600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.345433	2025-10-19 02:29:42.345433
1207f6e0-f5ec-4164-83bf-273188c5b510	TRATAMIENTO PANTENE INTENSA SELLA PUNTA 300ML	7500435179713	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.345698	2025-10-19 02:29:42.345698
fe00d7ec-23fd-4f9d-9feb-8d47acd71bf3	JUMBO FLOW XS X14UNID 9GR 126GR	7702007083477	t	6800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.345942	2025-10-19 02:29:42.345942
546f458e-ad1c-4d32-9bb7-1fc7ea84d571	DUCALES X10 TACOS 1.000GR	7702025150083	t	22000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.346154	2025-10-19 02:29:42.346154
3c7229b4-94da-40bc-b7e1-5ffef3b4944a	JABON LIQUIDO VITALY 500ML	CEQW	t	5400.00	5100.00	\N	\N	19.00	2025-10-19 02:29:42.346393	2025-10-19 02:29:42.346393
b7607752-ca99-4519-bf53-5a83d0f355da	TUMIX STICK MENTA X100UNID	7703888893582	t	7900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.346625	2025-10-19 02:29:42.346625
ac000860-0f9a-474f-8a91-587ea9376551	BARRILETE MUSIC X50UNID	7702993054543	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.346856	2025-10-19 02:29:42.346856
2be82b6b-c34d-48d4-a1a0-a742b5f2d177	TRAPERO NUMERO 1.000	TRAPEROS	t	5600.00	5380.00	\N	\N	19.00	2025-10-19 02:29:42.347099	2025-10-19 02:29:42.347099
64916077-60b6-40c1-b36a-d872396b14e4	GEL ROLDA AZUL 1.000GR	7707342220150	t	22000.00	21300.00	\N	\N	19.00	2025-10-19 02:29:42.347312	2025-10-19 02:29:42.347312
8fdb4dbe-81b1-4a31-b60d-c45163fe3a93	GEL ROLDA MORADA 1.000GR	7707342220143	t	22000.00	21300.00	\N	\N	19.00	2025-10-19 02:29:42.347535	2025-10-19 02:29:42.347535
e2749ed1-2438-40a2-b71d-3ac1096285a8	GEL ROLDA MORADA 500GR	7707342220020	t	12700.00	12300.00	\N	\N	19.00	2025-10-19 02:29:42.347784	2025-10-19 02:29:42.347784
2c5ebf29-d663-4151-b096-e426fdf9f131	TOCINETA FIDEL EXPRES 250GR	TOCINET	t	6300.00	6200.00	\N	\N	0.00	2025-10-19 02:29:42.347986	2025-10-19 02:29:42.347986
075805c3-67af-446e-9f21-651487808f24	TOCINETA FIDEO  EXPRES 125	TOCINETA	t	3400.00	3300.00	\N	\N	0.00	2025-10-19 02:29:42.348192	2025-10-19 02:29:42.348192
65a6fdee-0806-4f76-b9a1-f6c4dd066bc6	TOCINETA FIDEL EXPRES 500GR	TOCI	t	10900.00	10700.00	\N	\N	0.00	2025-10-19 02:29:42.348403	2025-10-19 02:29:42.348403
e90fefeb-3515-4bad-a1bc-96318db6a81e	TRATAMIENTO SAVITAL AMINO ACIDOS 265ML	7702006406628	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.348633	2025-10-19 02:29:42.348633
04a92f76-edbd-4a55-a06c-6780d8c73600	CREMA N4 PROTEGE 20GR	7702057088835	t	9200.00	8800.00	\N	\N	0.00	2025-10-19 02:29:42.34888	2025-10-19 02:29:42.34888
d48af21e-fa34-451c-83f2-eacc9b55f810	MUU MANTEQUILLA X18	7702011200259	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.349146	2025-10-19 02:29:42.349146
51bd6b8b-9a3c-4eaa-ad8e-38b635a36e56	LUKAFE INTENSO 100GR	7702088214685	t	3700.00	3600.00	\N	\N	5.00	2025-10-19 02:29:42.349383	2025-10-19 02:29:42.349383
2dd9cbec-0d98-44fa-935e-0b0c7c744436	LUKAFE INTENSO 200GR	7702088214333	t	7100.00	7000.00	\N	\N	5.00	2025-10-19 02:29:42.349604	2025-10-19 02:29:42.349604
077676be-4bf0-4dd9-8618-78ee2510d931	LUKAFE INTENSO 400GR	7702088207205	t	13800.00	13600.00	\N	\N	5.00	2025-10-19 02:29:42.349828	2025-10-19 02:29:42.349828
45f29eba-a443-4a55-9a27-5a7adafdef79	FLUOCARDENT 150ML X3	7702560048289	t	27000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.350121	2025-10-19 02:29:42.350121
4d3145ce-4dfa-47fc-8078-18c43b51d152	ACEITE GOURMET VITA PLUS 900ML	7702109217886	t	17900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.350449	2025-10-19 02:29:42.350449
f1847081-7fd3-4c6e-951b-95ac69570871	DETERGENTE BOW 5.000GR	7707271382479	t	21000.00	20200.00	\N	\N	19.00	2025-10-19 02:29:42.350678	2025-10-19 02:29:42.350678
997469e4-6ca1-49c1-88ca-a82263f6b0e2	TOALLAS NOSOTRAS INVISIBLE RAPIGEL 30 MAS 15 PROTEC	7702026155087	t	13900.00	13500.00	\N	\N	19.00	2025-10-19 02:29:42.350901	2025-10-19 02:29:42.350901
6a39bbd8-b280-481d-b842-4e8ed1fdf312	SHAMPOO SIBYLA SIN SAL 400ML	7702856951897	t	9700.00	9500.00	\N	\N	19.00	2025-10-19 02:29:42.351131	2025-10-19 02:29:42.351131
2ebeddeb-4ad1-42e5-b57c-fd5a604b2ca2	RECOJEDOR ECONOMICO	RECOJEDO	t	2700.00	2550.00	\N	\N	0.00	2025-10-19 02:29:42.351353	2025-10-19 02:29:42.351353
c84cb580-6cfa-435c-b27e-6352a897335f	INSECTICIDA EXTERMIN VOLADORES AZUL 400ML	7702158850058	t	11500.00	11200.00	\N	\N	19.00	2025-10-19 02:29:42.351582	2025-10-19 02:29:42.351582
44235db1-74fc-4a73-9e19-811f200e9149	BOLOGNA RES DE CESAR 900GR	BOLO	t	6500.00	6350.00	\N	\N	0.00	2025-10-19 02:29:42.351834	2025-10-19 02:29:42.351834
76f0aa02-4228-43ad-b6e4-414271661d70	LUMBAL	LUMBAL	t	1200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.352057	2025-10-19 02:29:42.352057
98c0905c-e832-4c7d-939f-331389b81bc7	CERA MOLDEADORA  ROLDA WHITE 1.000GR	7707342223700	t	22000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.352403	2025-10-19 02:29:42.352403
0be90163-6b79-43bb-bfe3-48830d8faff6	GEL DE AFEITAR 500GR	7709657400890	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.352789	2025-10-19 02:29:42.352789
3f6c8f7f-99de-4f4a-8b70-549ba6db3b8d	CHOCOLATE CORONA INSTANTANEO 14GR	7702007083125	t	900.00	800.00	\N	\N	19.00	2025-10-19 02:29:42.353096	2025-10-19 02:29:42.353096
fe221dd5-62e0-45a2-9472-78fd1ef9f0cc	FIDEO DIANA 500GR	7707166100027	t	3400.00	3250.00	\N	\N	5.00	2025-10-19 02:29:42.353382	2025-10-19 02:29:42.353382
b1087391-7b09-49aa-bc64-3601f0420d79	JUMBO FLOW BOMBONERA SURTIDA X28UNID	7702007083484	t	11300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.353577	2025-10-19 02:29:42.353577
62be8af7-c976-4192-bc57-95b933ae44f4	DETERGENTE ARIEL DOBLE PODER 400ML	7500435120623	t	8200.00	7980.00	\N	\N	19.00	2025-10-19 02:29:42.353799	2025-10-19 02:29:42.353799
75952beb-a7a5-418b-812b-c90dbabe4199	DETERGENTE ARIEL DOBLE PODER 1.2L	7500435122016	t	22000.00	21600.00	\N	\N	19.00	2025-10-19 02:29:42.354014	2025-10-19 02:29:42.354014
156ebd0e-ebb5-479d-ad1e-400aa0b68f7e	PALO HELADO X100 EL SOL X100UNID	7707015507052	t	1600.00	1500.00	\N	\N	0.00	2025-10-19 02:29:42.354298	2025-10-19 02:29:42.354298
83363987-9b57-4ae0-a46f-e8fb54d4b26c	HEAD SHOULDER 180ML X2	7500435230360	t	23400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.35455	2025-10-19 02:29:42.35455
9f96720d-7779-41b0-8e8d-ac2d55a5c3a8	SHAMPOO SAVITAL SERUM DE AMINOACIDOS 510ML	7702006406444	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.354781	2025-10-19 02:29:42.354781
446f931a-36b0-47c1-9d4b-799418943e45	FABULOSO 2L NARANJA	7509546688763	t	17000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.355018	2025-10-19 02:29:42.355018
4a196a2c-8f81-4e84-9420-fcda88344265	SHAMPOO TIO NACHITO 2 EN 1 X400ML	650240069055	t	32000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.355287	2025-10-19 02:29:42.355287
6618fe48-7c09-4d39-9eaa-2b873293c659	CHOCOLATE CORONA FLASH INSTANTANEO 950GR	7702007083361	t	31500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.355533	2025-10-19 02:29:42.355533
fb233539-00ae-4ea6-a9a5-06510cdba35e	COOL A PED AZUL ROLL ON 80GR	7708851548780	t	2800.00	2500.00	\N	\N	0.00	2025-10-19 02:29:42.3558	2025-10-19 02:29:42.3558
42e20d3f-025e-4f21-8e9b-d7f7b9233d01	COPITOS REDONDO SOFT TOUCH	6954615544982	t	2800.00	2500.00	\N	\N	0.00	2025-10-19 02:29:42.356119	2025-10-19 02:29:42.356119
175c2a80-59d2-4932-b168-7c4a8eedb186	VAPORPLUS MENTOL VERDE O  AZUL  30GR	VAPOR	t	1800.00	1500.00	\N	\N	0.00	2025-10-19 02:29:42.356607	2025-10-19 02:29:42.356607
784c9c8d-dae9-44a7-b7e9-a921c1c775aa	VAPORPLUS GEL MARIHUANA 60GR	7702023060124	t	2500.00	2000.00	\N	\N	0.00	2025-10-19 02:29:42.356956	2025-10-19 02:29:42.356956
d0259859-9a39-4eaf-9825-ae65192cc71c	GEL VERDE MARIHUANA 30GR	7708440339447	t	2000.00	1600.00	\N	\N	0.00	2025-10-19 02:29:42.357319	2025-10-19 02:29:42.357319
3c796496-5c93-4ae4-9ec6-101b6fc6b4e9	AREQUIPE LA SABANA TETERO 390GR	7707336380174	t	7200.00	6950.00	\N	\N	0.00	2025-10-19 02:29:42.357607	2025-10-19 02:29:42.357607
4bde0c09-227b-47d5-b1e6-70b1554fee4a	CARAMELO DE LECHE LESQUISIT X50UNID	7707014915537	t	6800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.357957	2025-10-19 02:29:42.357957
3209dc6f-a1f4-4207-92ff-314e35c872c1	CINTA 100MT OFFI ESCO	CINTA	t	5200.00	5040.00	\N	\N	0.00	2025-10-19 02:29:42.35834	2025-10-19 02:29:42.35834
ba28940a-5bc4-48db-bd24-a5587f96f723	CUCHARA TAMI X20UNID	645667176516	t	2100.00	2000.00	\N	\N	0.00	2025-10-19 02:29:42.358691	2025-10-19 02:29:42.358691
871328cf-6a8c-40ed-840b-bb9c79e1e88c	TENEDOR X20UNID TAMI	645667176455	t	1900.00	1750.00	\N	\N	0.00	2025-10-19 02:29:42.358963	2025-10-19 02:29:42.358963
0fd21d37-1d9f-4d2e-bce1-69ab8e704b0f	CONTENEDOR DARNEL X20UNID 16ONZ	7702458019926	t	7600.00	7400.00	\N	\N	0.00	2025-10-19 02:29:42.359266	2025-10-19 02:29:42.359266
456e048e-38c1-479a-982f-7e16ef3241da	VASOS FORMOSAS 5.5 X50UNID	7707330760309	t	1800.00	1700.00	\N	\N	0.00	2025-10-19 02:29:42.359689	2025-10-19 02:29:42.359689
26819110-be05-4d8e-888f-696eed3829da	PAÑITOS HUMEDOS FRESKITOS X10UNID	7709990840643	t	900.00	800.00	\N	\N	0.00	2025-10-19 02:29:42.360111	2025-10-19 02:29:42.360111
bb737271-196f-4335-afdb-0f15803b3cb5	NECTAR CALIFORNIA MANZANA 1200ML	7702617486538	t	6000.00	5600.00	\N	\N	19.00	2025-10-19 02:29:42.360461	2025-10-19 02:29:42.360461
1fb255b7-59a7-4a3f-8bcd-a73a4892eb1e	LAVALOZA ULTRA LIMPIO 450GR	7701008504899	t	3100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.360797	2025-10-19 02:29:42.360797
d6568358-098e-4868-8e34-4201be3de327	MOSTAZA BARY 200GR	7702439000806	t	4900.00	4780.00	\N	\N	19.00	2025-10-19 02:29:42.361121	2025-10-19 02:29:42.361121
b1e78752-1497-45f9-95aa-2019ceda2de3	SALSA DE TOMATE ECONOBUENA 1KILO	7702439281182	t	6000.00	5700.00	\N	\N	19.00	2025-10-19 02:29:42.361373	2025-10-19 02:29:42.361373
3235202a-f7ee-4ce2-bd7d-22733314b6fd	MAYONESA ECONOBUENA 1KILO	7702439544928	t	6900.00	6700.00	\N	\N	19.00	2025-10-19 02:29:42.361636	2025-10-19 02:29:42.361636
cb4db4ba-07fe-49b2-b3ce-d8c50ead3fdd	MIEL DE ABEJA NORSAN 375ML	7707349859476	t	8800.00	8500.00	\N	\N	0.00	2025-10-19 02:29:42.361867	2025-10-19 02:29:42.361867
166b3425-3ce1-4d7c-9308-7e88b0202f0e	LIMPIA PISOS SKAAP 3785ML	7707371211174	t	10700.00	10400.00	\N	\N	19.00	2025-10-19 02:29:42.362111	2025-10-19 02:29:42.362111
564a5de8-7a49-4b45-a6c2-2266fbd182e1	VELA SANTA MARIA 10X10	7707297960224	t	7500.00	7280.00	\N	\N	0.00	2025-10-19 02:29:42.36238	2025-10-19 02:29:42.36238
800ba8e6-2874-486f-b226-05aedec29da1	CHOCOLISTO CROCANTE 100GR	7702007058024	t	4200.00	4050.00	\N	\N	19.00	2025-10-19 02:29:42.362616	2025-10-19 02:29:42.362616
41da8f69-819b-47df-b614-2e9d8e524fbc	FESTIVAL RECREO 6X6	7702025149773	t	7000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.362874	2025-10-19 02:29:42.362874
e2cce957-7efc-4cf0-9452-2bfac88da787	PAPEL FAMILIA EXPERT X9UNID	7702026148539	t	21000.00	20300.00	\N	\N	19.00	2025-10-19 02:29:42.363118	2025-10-19 02:29:42.363118
54963a28-ebfb-47fc-8888-909b5d0e0721	TAMPON NOSOTRAS CON APLICADOR	7702026175054	t	1000.00	880.00	\N	\N	19.00	2025-10-19 02:29:42.363355	2025-10-19 02:29:42.363355
7f0d870d-dee9-4698-a9ee-c964bcb2d5fc	CHORIZO PAISA GALVISCARNE X8UNID	7709990982442	t	6300.00	5100.00	\N	\N	0.00	2025-10-19 02:29:42.363595	2025-10-19 02:29:42.363595
22148a24-66e9-4ed8-b6f8-d88e1f8838a3	CHORIZO MEXICANO X15UNID RES DEL CESAR	731416424059	t	12600.00	12400.00	\N	\N	0.00	2025-10-19 02:29:42.363827	2025-10-19 02:29:42.363827
0f82eb21-ccbd-4c2b-896d-01e121b84082	SALCHICHA MANGUERA CARNOSAN X6KILOS	SALCHICHA	t	38000.00	37000.00	37000.00	\N	0.00	2025-10-19 02:29:42.36406	2025-10-19 02:29:42.36406
e18d0520-18ed-411b-b0ea-f2f9e4045239	CHORIZO ANTIOQUEÑO CARNOSAN X10UNID	CHORIZO	t	10000.00	9200.00	9000.00	\N	0.00	2025-10-19 02:29:42.364306	2025-10-19 02:29:42.364306
78f0e45e-adbf-420a-962d-d3b6dc01a25e	SALCHICHA MANGUERA POLACA CARNOSA X7	SALCHI	t	11000.00	10800.00	10800.00	\N	0.00	2025-10-19 02:29:42.364546	2025-10-19 02:29:42.364546
de879146-233e-484c-b834-860a97c7b829	SALCHICHA POLACA CARNOSAN X22UNID	SALCHICHA POL	t	12600.00	11300.00	11000.00	\N	0.00	2025-10-19 02:29:42.364776	2025-10-19 02:29:42.364776
20578d80-5380-4c0c-99b5-82be1b906089	CHORIZO COCTEL CARNOSAN 250GR	CHJORIZO	t	5100.00	4700.00	4500.00	\N	0.00	2025-10-19 02:29:42.365111	2025-10-19 02:29:42.365111
bb8f88e5-cad0-496c-beff-e72b70b1bb84	CARNE DE HAMBURGUESA CARNOSAN  KILO	CARNE HA	t	13500.00	12700.00	12700.00	\N	0.00	2025-10-19 02:29:42.365366	2025-10-19 02:29:42.365366
1311a453-cffb-4d54-929a-7f76baa7271e	CHOCOLATINA WAFER DRACULA  X18UNID	7702007085082	t	9100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.365623	2025-10-19 02:29:42.365623
e530bf73-db25-4e64-893d-ded4eeabef44	CHOCOLATINA DRACULA X6UNID	7702007085129	t	13800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.36592	2025-10-19 02:29:42.36592
31501017-72e2-41fe-b317-0bc307f1e6fb	COMPOTA NATURE BABY PERA 113GRHIT	7702439252779	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.366183	2025-10-19 02:29:42.366183
7a7d0417-5ad8-4c00-b0cd-bf03467da194	COMPOTA NATURE BABY 113GR HIT	7702439844264	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.36644	2025-10-19 02:29:42.36644
bb5381e2-06fc-46b4-925a-24d932b0e173	PONY MALTA X6UNID 200CM	7702004025791	t	6700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.366696	2025-10-19 02:29:42.366696
ab4c4f3c-82fa-4edc-aa68-22d28e2508c4	PONY MALTA 200CM	7702004025784	t	1500.00	1367.00	\N	\N	19.00	2025-10-19 02:29:42.367118	2025-10-19 02:29:42.367118
85f6d04a-da97-4edc-92fa-3d28f6d980b1	MANTEQUILLA NE 250GR	75971816	t	4700.00	4500.00	\N	\N	0.00	2025-10-19 02:29:42.367707	2025-10-19 02:29:42.367707
d0ae998b-2c92-44e5-a90a-afced9bcdd45	BOMBILLO SILVANIA STAR 12W	7702048231769	t	2800.00	2600.00	\N	\N	19.00	2025-10-19 02:29:42.368092	2025-10-19 02:29:42.368092
935bf9ff-9a80-49f5-9779-bb7a34274769	VENENO MOSCA GENERAL BLANCO 1L	VENENO M	t	5800.00	5600.00	\N	\N	0.00	2025-10-19 02:29:42.368455	2025-10-19 02:29:42.368455
ba19cb7d-1b52-4e4d-bb25-a54ddb58cf1f	KOTEX NOCTURNA X16UNID	7702425805323	t	11600.00	11200.00	\N	\N	0.00	2025-10-19 02:29:42.368834	2025-10-19 02:29:42.368834
88ce50d4-0777-411d-b37b-a599a0fde6f2	TIKYS OJOS DE ZOMBIE X8UNID	7702007082814	t	7400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.369116	2025-10-19 02:29:42.369116
8dfdbc50-5cb1-461c-9898-71f29396cbd3	EASYCAT ARENA PARA GATOS 4.5	7707025802703	t	18600.00	18200.00	\N	\N	5.00	2025-10-19 02:29:42.369407	2025-10-19 02:29:42.369407
3e826fcc-9082-4f47-8061-72c879ffc3cc	KOTEX NOCTURNA X24	7702425524705	t	15500.00	15000.00	\N	\N	0.00	2025-10-19 02:29:42.369652	2025-10-19 02:29:42.369652
4e115b7d-a70a-475f-a1f9-53303a974ea1	TARRITO ROJO 135GR MAS CREMA	7702560049873	t	11000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.369943	2025-10-19 02:29:42.369943
d0c3f713-6709-410b-a3af-71e467c0abc8	GALLETA DRACULA X6UNID	7702025150656	t	10700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.370339	2025-10-19 02:29:42.370339
5660730e-e064-4ec7-88d1-b81db67dd16e	GALLETA DRACULA 27GR	7702025150663	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.370671	2025-10-19 02:29:42.370671
1c1f8829-a22f-4c63-a8c2-77d939f39c84	BOMBILLO SYVANIA 9W	7702048293620	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:42.37096	2025-10-19 02:29:42.37096
a8d68de9-7197-4725-83a3-1216386081eb	AROMATEL MANZANA VERDE 180ML	7702191164020	t	1600.00	1450.00	\N	\N	19.00	2025-10-19 02:29:42.371212	2025-10-19 02:29:42.371212
2aec61ac-7928-4d11-938e-47b7a227ea26	AVENA MOLIDA IDEAL 200GR	7709157335722	t	1000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.37147	2025-10-19 02:29:42.37147
820b00de-5f44-4af7-8cf7-a0fa7f018814	TIKYS GOLOCHIPS 20GR	7702007082029	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.371683	2025-10-19 02:29:42.371683
9c7cfc32-1ce9-48ed-a035-ce744196b74a	SALSA SABOR A QUESO RIK 200GR	75971939	t	12600.00	12200.00	\N	\N	0.00	2025-10-19 02:29:42.371962	2025-10-19 02:29:42.371962
fb4c19b2-754b-491f-ab76-3c5068e2b087	PANCAKES CORONA 320GR	7702007056754	t	9300.00	8950.00	\N	\N	19.00	2025-10-19 02:29:42.372214	2025-10-19 02:29:42.372214
d4ff652f-9cbc-4f30-a55e-60a794596db1	SUNTEA MACARACUYA 12GR	7702354955380	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:42.372473	2025-10-19 02:29:42.372473
17315996-60b8-497f-a2f3-5d6529e551bb	TRISASON SASONES 20GR	7702354955045	t	1000.00	892.00	\N	\N	19.00	2025-10-19 02:29:42.372732	2025-10-19 02:29:42.372732
5a45484d-8259-4b28-8cbc-0d79eae0bbd9	SARDINA LA SOBERANA EN TOMATE 320GR	7702910964184	t	6200.00	6000.00	\N	\N	19.00	2025-10-19 02:29:42.37299	2025-10-19 02:29:42.37299
d6567f81-6a96-4905-855d-2d653401d94c	ELLAS NOCTURNA X40UNID	7702108201770	t	8600.00	8300.00	\N	\N	0.00	2025-10-19 02:29:42.373264	2025-10-19 02:29:42.373264
f6fb431f-a3bc-40b2-a663-d368b8409b4c	TRIDENT TUTTI FRUTTI X70UNID	7622202022715	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.373576	2025-10-19 02:29:42.373576
e37fb392-cc00-4991-8b26-78062ec3e1cb	DOG CHOW MINIS Y PEQUEÑOS MORADA 350GR	7702521656799	t	4000.00	3850.00	\N	\N	5.00	2025-10-19 02:29:42.373826	2025-10-19 02:29:42.373826
60208f9d-114f-445d-b9a7-4bdf8a012793	DOG CHOW CACHORROS MEDIANOS 350GR	7702521495046	t	4000.00	3850.00	\N	\N	5.00	2025-10-19 02:29:42.374131	2025-10-19 02:29:42.374131
407e4cca-0fa1-4df8-a9cb-7e0b9a88e996	SOPA DE GALLINA CON FIDEOS MAGGI 52GR	7702024567738	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:42.374365	2025-10-19 02:29:42.374365
59bc3bed-048d-4151-a978-a6d1ab842ecf	SOPA AJIACO MAGGI 60GR	7702024085348	t	2700.00	2580.00	\N	\N	19.00	2025-10-19 02:29:42.374634	2025-10-19 02:29:42.374634
592dbcc6-e555-47ef-9617-f33a10becae5	SOPA DE SANCOCHO 60GR	7702024212904	t	2700.00	2580.00	\N	\N	19.00	2025-10-19 02:29:42.374877	2025-10-19 02:29:42.374877
8b69a37c-e7cf-43a4-a54d-3ada29b6a0d7	JUGO NUTICA ZUMO SURTIDO X24UNID	JUGO	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.37515	2025-10-19 02:29:42.37515
e1463635-7b00-438a-84ad-5b3755ebf276	JUGO NUTICA DE LULO 200ML	7708661161155	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.375364	2025-10-19 02:29:42.375364
5044b19c-4902-4ea5-b096-02802445b9f2	JUGO NUTIVA MANGO 200ML	7708661161469	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.375644	2025-10-19 02:29:42.375644
31757139-22c2-46dc-abe7-73b93798a501	JUGO NUTIVA MORA 200ML	7708661161711	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.375943	2025-10-19 02:29:42.375943
dc08cdfb-f86b-469e-870a-a8662b6c6f2b	JUGO PIÑA NARANJA 200ML	7708661161391	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.376196	2025-10-19 02:29:42.376196
371136ab-8693-4243-ae5b-e6393af4cb4c	NESCAFE FRASCO DOLCA 170GR MAS MUSS	7702024244455	t	19000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.376435	2025-10-19 02:29:42.376435
b3a381a7-50a2-4b4a-af72-5e22f2b88635	CHOCOLATINA DRACULA 42GR	7702007085112	t	2500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.376678	2025-10-19 02:29:42.376678
076a4539-03c7-4b74-9925-b1c77a16826e	FAB BARRA LIMON 300GR	7702191164594	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:42.376945	2025-10-19 02:29:42.376945
daab3eac-d945-4ac3-b454-4fc62d5bdd32	NESCAFE 144UNID	7702024070917	t	31500.00	\N	\N	\N	5.00	2025-10-19 02:29:42.377325	2025-10-19 02:29:42.377325
93cb2731-200b-4e23-aab3-b5db2f395e85	ACEITE DE ROMAERO SPRAY QUINA 50ML	ACEITE ROM	t	3500.00	3200.00	\N	\N	0.00	2025-10-19 02:29:42.377654	2025-10-19 02:29:42.377654
afa699ad-812e-4409-ae72-864bb877f97e	EXTERNIM INSECTISIDA MATA RASTREROS RED 400ML	7702158850355	t	11600.00	11200.00	\N	\N	0.00	2025-10-19 02:29:42.377994	2025-10-19 02:29:42.377994
d69c3296-f38a-4831-b6aa-726c5ff459cb	PROTECTOR SOLA SUNDAY 10GR	7707355051369	t	2500.00	2350.00	\N	\N	0.00	2025-10-19 02:29:42.378383	2025-10-19 02:29:42.378383
305bc850-94fb-49e8-8b99-759795b0d564	SUAVIZANTE FLORAL PINTO ECO 1L	7702856952399	t	4700.00	4550.00	\N	\N	19.00	2025-10-19 02:29:42.378619	2025-10-19 02:29:42.378619
db4f717a-83d3-490a-bfae-2e5525905909	SUPREMO MULTIUSOS FRESCURA AZUL 240GR	7708669890118	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:42.378894	2025-10-19 02:29:42.378894
c38073cc-bdd2-4aa6-afea-31683db28156	PAN TAJADO MANTEQUILA EL MEJOR	PAN ,AMTEQUILLA EL MEJOR	t	5200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.379123	2025-10-19 02:29:42.379123
bb7d9115-e2c8-4bb7-8ef6-e953925170e8	DETODITO FLAMIN HOT 50GR	7702189059000	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.3794	2025-10-19 02:29:42.3794
2cc28736-8f77-412b-851b-0d4715f4ffa8	ARROZ BACANISIMO	7708937039225	t	3000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.379684	2025-10-19 02:29:42.379684
6f4d3881-d2a2-4191-a45f-21a9dad507dd	MANI MOTO X12UNID 80GR CD	7702189055910	t	27000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.379985	2025-10-19 02:29:42.379985
7ef7ae9f-028d-4e6f-bd3e-02477f63d7dd	MANI MOTO FLAMIN HOT 35GR	7702189059055	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.380279	2025-10-19 02:29:42.380279
5db6e87b-4772-4d49-8567-076e3ef70813	MANI MOTO FLAMIN HOT X12UNID 35GR	7702189059062	t	23000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.380579	2025-10-19 02:29:42.380579
ead4ed07-1282-43f3-8890-748df5762195	DETERGENTE 3D EUCALIPTO LIMON 500GR	7702191163542	t	4300.00	4100.00	\N	\N	19.00	2025-10-19 02:29:42.380922	2025-10-19 02:29:42.380922
a8db427e-d79a-4510-a1d5-95f89f4a8870	COLCAFE GRANUADOR INTENSO X48UNID	7702032113095	t	11300.00	\N	\N	\N	5.00	2025-10-19 02:29:42.381231	2025-10-19 02:29:42.381231
fc84804c-b8b2-4aed-9f6c-bcfc18d57468	COLGATE DOBLE FRESCURA 100ML	7509546696768	t	6200.00	5900.00	\N	\N	19.00	2025-10-19 02:29:42.381708	2025-10-19 02:29:42.381708
f68a1325-2592-458e-b990-bfd5f6a9c4c5	TAKIS FUEGO 185GR	7500810029701	t	9000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.381981	2025-10-19 02:29:42.381981
720dfa1d-5284-4c09-bcd4-ca2669d4526f	BIMBOLETE X10UNID	7705326018397	t	9500.00	9400.00	\N	\N	19.00	2025-10-19 02:29:42.382303	2025-10-19 02:29:42.382303
804d1e61-e08d-4816-9f45-2abaf4fb0f0e	SUBMARINO MORA 35GR	7705326073778	t	1300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.382593	2025-10-19 02:29:42.382593
ed0273cc-8766-4341-bf59-9bebcd4ac38e	ACONDICIONADOR ANYELUZ GINSENG 500ML	7707957514552	t	34400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.382885	2025-10-19 02:29:42.382885
4690a666-607c-482a-a075-f955d9dbd9dc	TRATAMIENTO CAPILAR SKALA MAIS CACHINHOS 1.000GR	7897042017812	t	34000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.383148	2025-10-19 02:29:42.383148
68d31e6b-a5b6-4c67-a2e2-6159004d4dde	MIEL DE ABEJA NORSAN 250ML	7707349859537	t	5900.00	5700.00	\N	\N	0.00	2025-10-19 02:29:42.383427	2025-10-19 02:29:42.383427
21655543-60f0-453c-8e39-8ef9ee2ad398	CHORIZO MIXTO CARNOSAN X21	VCHORIZOZZ	t	12600.00	11200.00	11000.00	\N	0.00	2025-10-19 02:29:42.383993	2025-10-19 02:29:42.383993
786b5f4c-a30e-44f2-ae45-cd803c181583	MATRIMONIO DON FIDEL EXPRES 250GR	7770000900213	t	4800.00	4700.00	4500.00	\N	0.00	2025-10-19 02:29:42.384336	2025-10-19 02:29:42.384336
1812da85-a981-4ded-a2c2-7f5e1140ba51	MATRIMONIO DON FIDEL EXPRESS 500GR	7770000900206	t	9000.00	8500.00	8500.00	\N	0.00	2025-10-19 02:29:42.384688	2025-10-19 02:29:42.384688
9ee5e138-875a-4f1c-8b0d-62b171d97595	SPAGHETTI DORIA 125GR	7702085011027	t	1000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.384986	2025-10-19 02:29:42.384986
2197835a-6965-4aaa-99c7-973d92298536	PRESTOBARBA SCHI STREME VERDE X12 MAS QUATRO	PRESTO	t	32800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.385316	2025-10-19 02:29:42.385316
51efbb87-de9c-47b3-b709-4e5cde6a64da	SUAVIZANTE LIMPIA YA FLORAL 1L	7702037912839	t	4900.00	4750.00	\N	\N	19.00	2025-10-19 02:29:42.385563	2025-10-19 02:29:42.385563
3b72d995-6103-4883-bde3-135122be680f	DUX RELLENAS QUESO BLANCO X6UNID	7702025134366	t	8600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.385808	2025-10-19 02:29:42.385808
f8a4ca73-e7d5-4297-be28-7c88b09975af	AROMATEL FLORAL 1.8K TARRO	7702191349687	t	16000.00	15600.00	\N	\N	19.00	2025-10-19 02:29:42.386075	2025-10-19 02:29:42.386075
e8e498f8-0962-4e34-bffb-c05d5d0b66af	BUBBALOO RETO ACIDO X47	7622202222092	t	10300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.386403	2025-10-19 02:29:42.386403
469cda42-6a9d-4f12-8667-98686cd4b66a	BUBBALOO FRESA X47	7622202222054	t	10300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.38664	2025-10-19 02:29:42.38664
c0a67a09-6191-4444-b8ed-cda4862deb80	CHORIZO COCTEL CARNOSAN 500GR	CHORIZO COC	t	10000.00	9100.00	9000.00	\N	0.00	2025-10-19 02:29:42.38684	2025-10-19 02:29:42.38684
d7560126-b6db-46ee-b087-ca7775c4e65f	SALSA INGLESA IDEAL 165ML	SALSA IN	t	2000.00	1850.00	\N	\N	0.00	2025-10-19 02:29:42.387084	2025-10-19 02:29:42.387084
ce6b49ce-c51c-4f33-b2fb-2709f2aee88c	SALSA BBQ DIFFER 200GR	7707385973815	t	2900.00	2750.00	\N	\N	19.00	2025-10-19 02:29:42.387326	2025-10-19 02:29:42.387326
38d2f4df-7f96-4abc-a607-38eb3431d656	MAYONESA DIFFER 500GR	7707385972597	t	4200.00	4080.00	\N	\N	19.00	2025-10-19 02:29:42.38756	2025-10-19 02:29:42.38756
3ff5cbbe-d6c2-481f-bc0b-f536930b7579	TOMATE DIFFER 500GR	7707385973006	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:42.387769	2025-10-19 02:29:42.387769
530c4315-c444-4be4-a365-6119079cf75f	COMPOTA HEINZ GUAYABA 113GR	608875003586	t	3500.00	3250.00	\N	\N	19.00	2025-10-19 02:29:42.38806	2025-10-19 02:29:42.38806
63994543-e774-4a87-bafe-0ffac98c6afb	PAPEL SKAAP DELUXES MEGA X4 ROLLOS XXXG	7707371218425	t	5900.00	5700.00	\N	\N	19.00	2025-10-19 02:29:42.388405	2025-10-19 02:29:42.388405
0b4a6a68-19fa-464f-8577-f1f7b6f25173	PRESTOBARBA SCHICK XTREME VERDE X12	PRESTOBARBA SCHI	t	29500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.3887	2025-10-19 02:29:42.3887
0a497bba-3f33-4405-a547-9210b7d08890	GALLETA NAVIDAD NOEL CARAVANA 200GR	7702025150182	t	8500.00	8300.00	\N	\N	19.00	2025-10-19 02:29:42.389044	2025-10-19 02:29:42.389044
b6404547-4b6d-478a-b836-53667b58f45e	COCOSETTE PROMOCION X21UNID	7702024263135	t	31500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.390246	2025-10-19 02:29:42.390246
5fc1359f-bcbc-467a-ae47-367691704713	GELATINA SUNTEA FRUTOS ROJOS 16GR	7702354952419	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:42.39279	2025-10-19 02:29:42.39279
d99b7d87-e045-4ae1-a60f-184abb06b724	GALLETA NOEL CARAVANA BOLSA 120GR	7702025150151	t	3600.00	3500.00	\N	\N	19.00	2025-10-19 02:29:42.394931	2025-10-19 02:29:42.394931
10cd14b8-7b14-4894-bfc9-12aa81e5ebf4	SUAVITEL CUIDADO COMPLETO TARRO 2.8L	7509546681962	t	20500.00	19800.00	\N	\N	19.00	2025-10-19 02:29:42.395289	2025-10-19 02:29:42.395289
d9c904a2-5ca8-4011-91a9-48c24f0bf230	FULL FRESH LIMPIADOR 1000CM,	7702856107706	t	4400.00	4200.00	\N	\N	19.00	2025-10-19 02:29:42.395572	2025-10-19 02:29:42.395572
c662aeea-1940-4446-bf24-92cf6aaf98a5	PRESTOBARBA GILLETTE 2 HOJAS X2UNID	7500435161251	t	2600.00	2450.00	\N	\N	19.00	2025-10-19 02:29:42.395873	2025-10-19 02:29:42.395873
aacea146-cd0e-403a-95d2-e7885109e04b	DOVE HIDRATACION SHAMPOO 18ML	7702006653077	t	1000.00	900.00	\N	\N	19.00	2025-10-19 02:29:42.397523	2025-10-19 02:29:42.397523
83edb8ce-f8af-4448-b92c-1585f5096153	MANTEQUILLA NE 500GR	7590006200540	t	8600.00	8300.00	\N	\N	0.00	2025-10-19 02:29:42.399096	2025-10-19 02:29:42.399096
1d9d3f8b-4965-4ffb-8613-071aec80eba2	BALDE ANDELCO 12L	7708304268128	t	6300.00	6200.00	\N	\N	19.00	2025-10-19 02:29:42.399474	2025-10-19 02:29:42.399474
215a4aa5-64eb-4dbe-ba5c-41dcc3e7aaf6	TOALLAS SUAVES 10 MAS 2	7702120013214	t	3100.00	2970.00	\N	\N	0.00	2025-10-19 02:29:42.399813	2025-10-19 02:29:42.399813
35a66a10-d2c5-4e1c-a3d6-b6ad199376ca	LAVALOZA AK MANZANA 220GR	7702310040310	t	2300.00	2180.00	\N	\N	19.00	2025-10-19 02:29:42.400224	2025-10-19 02:29:42.400224
653e0cda-1660-4bae-b314-cdb5a203a920	SUAVIZANTE FULLER PIÑA COLADA 2L	7702856929759	t	12000.00	11800.00	\N	\N	19.00	2025-10-19 02:29:42.400497	2025-10-19 02:29:42.400497
5adf130d-1a2a-4968-8b66-0094a7078786	SUAVIZANTE FULL FRESH FRUTOS ROJOS 2L	7702856109120	t	12000.00	11800.00	\N	\N	19.00	2025-10-19 02:29:42.400998	2025-10-19 02:29:42.400998
4bae8163-82bf-4624-8ef7-c9ba29632fa9	DETERGENTE LIQUIDO PINTO COLORES 1L	7702856953020	t	6300.00	6200.00	\N	\N	19.00	2025-10-19 02:29:42.401245	2025-10-19 02:29:42.401245
56517d4e-7a5c-47f2-8873-bf2ec99d7594	LIMPIA PISOS FULLER BRISAS DEL BOSQUE 2L	7702856207758	t	8000.00	7800.00	\N	\N	19.00	2025-10-19 02:29:42.401621	2025-10-19 02:29:42.401621
37192e35-0906-4668-af09-439009459e2e	LIMPIA PISOS FULLER FRESH JARDIN EN SUEÑOS 2L	7702856207789	t	8000.00	7800.00	\N	\N	19.00	2025-10-19 02:29:42.401983	2025-10-19 02:29:42.401983
a91eb563-5a29-414e-bde5-0332b0e72865	PASTILLA AZUL PARA EL TAMQUE	PASTILLA	t	2500.00	2400.00	\N	\N	0.00	2025-10-19 02:29:42.402427	2025-10-19 02:29:42.402427
d613c3a2-1d5a-4caf-ab32-6703c44f711d	VENDA ELASTICA GRANDE 4	7707228360741	t	2400.00	2300.00	\N	\N	0.00	2025-10-19 02:29:42.402724	2025-10-19 02:29:42.402724
a218bbe7-1453-4dcd-9034-796349bdb605	VENDA ELASTICA MEDIANA 3	7707228360734	t	2000.00	1900.00	\N	\N	0.00	2025-10-19 02:29:42.40298	2025-10-19 02:29:42.40298
21964c9b-23da-4aee-9019-c03bba8f51b1	VENDA PEQUEÑA 2	7707228360727	t	1500.00	1400.00	\N	\N	0.00	2025-10-19 02:29:42.40319	2025-10-19 02:29:42.40319
ddfe9f1e-336a-480e-804d-1c1188cd4878	PROTECTORES DIARIOS NOSOTRAS MULTIESTILO X150UNID	7702027444654	t	14500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.403476	2025-10-19 02:29:42.403476
512675cb-334e-468a-af60-34460f4378f8	TOALLAS SUAVE NOCTURNA X8	7702120013221	t	3500.00	3390.00	\N	\N	0.00	2025-10-19 02:29:42.403742	2025-10-19 02:29:42.403742
898df4ec-1df6-4b3e-bf83-e846127055e7	VINAGRE ROJO CORONA 500ML	7707265950172	t	1200.00	1100.00	\N	\N	19.00	2025-10-19 02:29:42.403959	2025-10-19 02:29:42.403959
30efe495-de77-457b-9c40-feeaa3e9cab3	QUATRO TORONJA 1.5	7702535011706	t	3800.00	3500.00	\N	\N	19.00	2025-10-19 02:29:42.404207	2025-10-19 02:29:42.404207
3570bf80-9eb1-48dc-b0f1-7f0fe5fca594	LA ESPECIAL MINICHIPS 100GR	7702007084511	t	3800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.404422	2025-10-19 02:29:42.404422
36f394d3-f570-4289-b768-786f7d7d7edc	SHAMPOO AUTOBRILLANTE ECOCLEANER 500ML	7709009892885	t	15300.00	\N	\N	\N	0.00	2025-10-19 02:29:42.404655	2025-10-19 02:29:42.404655
9b30d87c-e16f-41b0-9887-2d1e64df3001	GEL DE BAÑO Y DUCHA AMALFIL AVENA 750ML	8414227691880	t	10500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.404894	2025-10-19 02:29:42.404894
d34a29c7-4d3c-4b1b-aaa8-683e0e78a7f9	MIXTO NATURAL LA VICTORIA X7UNID	7706642200558	t	15000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.405123	2025-10-19 02:29:42.405123
800e18b8-fe55-47fc-8d4a-3127f3192887	MIXTO LA VICTORIA BBQ X7UNID	7706642051754	t	15000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.405343	2025-10-19 02:29:42.405343
f4189995-de1b-4300-8d2d-a18f7cdf094d	PAPAS OREADITAS LA VICTORIA X12UNID	7706642317430	t	14200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.405545	2025-10-19 02:29:42.405545
fe8334c8-b24f-458d-9e03-0408e7986ef5	PAPAS OREADAS LA VICTORIA POLLO X7UNID	7706642004415	t	15500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.40576	2025-10-19 02:29:42.40576
a8a94981-684e-4656-bf2a-5f72aa98ee36	PAPAS OREADAS LA VICTORIA TOMATE X7	7706642006419	t	15500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.405962	2025-10-19 02:29:42.405962
9c4db220-b604-4b1f-bc3f-207d39b24157	PAPALLO LA VICTORIA X10UNID	PAPAL	t	13000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.406193	2025-10-19 02:29:42.406193
fd933f37-a1ca-4157-b0e3-d4f6e0e99cb0	TOCINETA LA VICTORIA X12UNID	TOCINETALA	t	13000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.406419	2025-10-19 02:29:42.406419
0c7f2247-3920-4c1f-bd11-f07b898b1627	RICA PASTA SABOR A QUESO 9G	7702024032052	t	900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.40664	2025-10-19 02:29:42.40664
d645252f-9366-42b1-bc94-c9d82ec8baa6	MASCARILLA HALURONIC ACID 8D 25ML	6942349742316	t	1000.00	850.00	\N	\N	0.00	2025-10-19 02:29:42.406855	2025-10-19 02:29:42.406855
e6d12faa-fe5a-49c1-8b75-0187f9c1b927	MASCARILLA ALOE VERA 25ML	6976504680052	t	1000.00	850.00	\N	\N	0.00	2025-10-19 02:29:42.407116	2025-10-19 02:29:42.407116
fefc6fa0-9635-4111-9b28-b5eef6bd71bb	MASCARILLA CALENDULA HYDRATANTE	6942349712395	t	1000.00	850.00	\N	\N	0.00	2025-10-19 02:29:42.407337	2025-10-19 02:29:42.407337
fd7aad75-5fce-4c29-951e-e4da6fbef6bb	MASCARLLA ARROZ 25GR	6942017810835	t	1000.00	800.00	\N	\N	0.00	2025-10-19 02:29:42.407597	2025-10-19 02:29:42.407597
4eff4b7d-be86-40cf-8105-e551dd4fa1a1	MASCARILLA MOISTURIZING 25ML	6976068956211	t	1000.00	850.00	\N	\N	0.00	2025-10-19 02:29:42.407856	2025-10-19 02:29:42.407856
b8a6347d-bb45-4846-a002-55669b406a9c	MASCARILLA BLUEPERRIES 25ML	6942349715921	t	1000.00	850.00	\N	\N	0.00	2025-10-19 02:29:42.408095	2025-10-19 02:29:42.408095
66d15d93-5bb5-4295-9d01-0de4e928507c	MASCARILLA PARA LAS OJERAS 7GR	6975239996339	t	1000.00	700.00	\N	\N	0.00	2025-10-19 02:29:42.40832	2025-10-19 02:29:42.40832
1aca54dc-68db-4403-a6b2-520a0f7c8548	COMBO ALMA BOUTIQUE DE ARROZ	ARROZ	t	15600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.408557	2025-10-19 02:29:42.408557
501eaecb-dad2-4048-9531-978abb3e8e6e	MASCARILLA COLAGENO LABIOS	6975239993246	t	1000.00	850.00	\N	\N	0.00	2025-10-19 02:29:42.408787	2025-10-19 02:29:42.408787
054387cf-3e9c-4478-82f9-205446324a9f	GITTER SPRAY TONOS SURTIDOS ESCARCHAS	6974011830229	t	5000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.40918	2025-10-19 02:29:42.40918
cd2f58ba-8dc8-4e22-811d-afbc7ca5783e	TOALLAS ANGELAS NOCTURNA X24	7707324640174	t	9000.00	8600.00	\N	\N	0.00	2025-10-19 02:29:42.409465	2025-10-19 02:29:42.409465
72bcbc96-8c0e-4a5d-b81d-f18fcfa347d5	CHEETOS HORNEADOS NATURAL 40GR	7702189057877	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:42.409771	2025-10-19 02:29:42.409771
19da089a-791a-45fe-b6ef-9cbb07fc71cd	CHEETOS BOLIQUESO 34GR	7702189057860	t	1900.00	1800.00	\N	\N	19.00	2025-10-19 02:29:42.410095	2025-10-19 02:29:42.410095
0da90fcd-0c53-4103-ad59-798bc81fc6bb	TAKIS BLUE HEAT 185GR	7500810031032	t	9400.00	9300.00	\N	\N	19.00	2025-10-19 02:29:42.410363	2025-10-19 02:29:42.410363
f78321ec-e2c4-410d-ad88-59c4be29cf36	TAKIS BLUE HEAT 50GR	7500810028094	t	3400.00	3350.00	\N	\N	19.00	2025-10-19 02:29:42.410597	2025-10-19 02:29:42.410597
2c091599-162e-4c05-bbce-16e04c6089aa	CREMA DE PEINAR FOR MEN EGO 265ML	7702006653527	t	15300.00	14900.00	\N	\N	19.00	2025-10-19 02:29:42.410838	2025-10-19 02:29:42.410838
22ecea64-2c42-4ae8-8669-fa2abc9bf68a	CREMA DE PEINAR FOR MEN EGO 18ML	7702006653640	t	1200.00	1060.00	\N	\N	19.00	2025-10-19 02:29:42.411058	2025-10-19 02:29:42.411058
78d425b1-d608-4a1a-b96a-28835d46bbaf	VELAS DE COLORES SANTA MARIA X10	7707297960170	t	1400.00	1280.00	\N	\N	0.00	2025-10-19 02:29:42.411311	2025-10-19 02:29:42.411311
ae017961-358e-4041-837c-ae861b9adfd2	SALTIN NOEL INTEGRAL 9X3	7702025110681	t	5500.00	5300.00	\N	\N	19.00	2025-10-19 02:29:42.411537	2025-10-19 02:29:42.411537
08e2419a-7a37-40b0-85bb-acbf3b597fce	AREQUIPE EL ANDINO TETERO 400GR	7700211072232	t	7200.00	6950.00	\N	\N	0.00	2025-10-19 02:29:42.411771	2025-10-19 02:29:42.411771
2d934624-bb4c-4ada-8cf3-e18af67e1039	SALTIN NOEL SEMILLAS Y CEREAL 3 TACOS	7702025126316	t	9400.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.411992	2025-10-19 02:29:42.411992
e5fbfc26-1fcf-4de8-b585-ba3f13a71122	GALLETA FELIZ NAVIDAD BOLSA COLOMBINA 150GR	7702011202222	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:42.412235	2025-10-19 02:29:42.412235
875d12ba-03ab-47b3-8006-311ce85bc761	GALLETA FELIZ NAVIDAD CAJA 200GR COLOMBINA	7702011202246	t	6800.00	6650.00	\N	\N	19.00	2025-10-19 02:29:42.412471	2025-10-19 02:29:42.412471
d9fb7125-818b-4fd9-9ff1-be6cd103e472	SHAMPO0 RITUAL BOTANICO CEBOLLA ARGAN 400ML	770700724000	t	30500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.412705	2025-10-19 02:29:42.412705
f91badbb-b95e-4bcc-be54-27a242efdf3a	SHAMPOO RITUAL BOTANICO ARGAN  400ML	770170084000	t	31000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.413129	2025-10-19 02:29:42.413129
6c528e94-94c7-4838-a81b-c365986541d4	ACEITE OLEOCALI VEGETAL 900ML	7701018076492	t	9500.00	9167.00	\N	\N	19.00	2025-10-19 02:29:42.413359	2025-10-19 02:29:42.413359
1acb4962-df2a-4954-860d-5cfc61544e6d	VINAGRE SABOR A MANZANA 500ML	8709367792550	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:42.413587	2025-10-19 02:29:42.413587
d056f6f3-e704-4804-82b3-b3c97726db9b	SUAVE GOLD SUAVE X4UNID	7702120012736	t	11200.00	10800.00	\N	\N	19.00	2025-10-19 02:29:42.41383	2025-10-19 02:29:42.41383
bc14342a-1ebd-4b0b-94f3-874238458a5d	TENEDOR GRANDE X20UNBID	TENEDOR	t	1400.00	1300.00	\N	\N	0.00	2025-10-19 02:29:42.414082	2025-10-19 02:29:42.414082
06b7dbeb-f97a-43d6-8449-3d2f63714a7b	SERVILLETA SKAAP NATRAL ECOLOGICA X180UNID	7707371216674	t	1300.00	1200.00	\N	\N	19.00	2025-10-19 02:29:42.414389	2025-10-19 02:29:42.414389
c8aedd35-9bff-4bed-aab4-5f153b23066b	ARIEL TRIPLE PODER 2.5KG	7500435205160	t	25000.00	24600.00	\N	\N	19.00	2025-10-19 02:29:42.414651	2025-10-19 02:29:42.414651
9c368e1a-a0ba-4515-944d-2d5d4c545c7b	ARIEL TRIPLE PODER 1.5GR	7500435196093	t	16200.00	15600.00	\N	\N	19.00	2025-10-19 02:29:42.414942	2025-10-19 02:29:42.414942
813fa35b-bebf-482b-b955-577bcc16e1eb	SHAMPOO SEDAL MAS ACONDICIONADOR KERATINA  340ML	7702006400978	t	25600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.41522	2025-10-19 02:29:42.41522
a8fd4e93-42fb-47d8-ae09-6cada1379839	SHAMPOO SEDAL MAS ACONDICIONADOR CELULAS 340ML	7702006404686	t	25800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.415482	2025-10-19 02:29:42.415482
b3138336-5bbe-4cf5-b5e1-ab09c66f6d11	SHAMPOO SEDAL MAS ACONDICIONADOR CERAMIDAS 340ML	7702006400916	t	25800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.415755	2025-10-19 02:29:42.415755
6417857f-b312-4e88-a85d-2ce8c8f5a6e7	MECHERA SWISS TIPO PISTOLA	7707822754861	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:42.416009	2025-10-19 02:29:42.416009
436b531e-0605-4a9b-bd2a-a3447c138fac	DUX RELLENO QUESO BLANCO 36GR	7702025137619	t	1600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.416285	2025-10-19 02:29:42.416285
6aea0a5e-c03b-4dde-b31a-82becd6e6303	ALOKADOS COFFE X100	7707014923709	t	8100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.416569	2025-10-19 02:29:42.416569
3f662aa0-b8c3-46f2-80d0-106a1017cbf5	YOGOLIN MIX GRAGEAS X3UNID	7705241185693	t	6900.00	6100.00	6000.00	\N	19.00	2025-10-19 02:29:42.416836	2025-10-19 02:29:42.416836
7dbdce51-5f57-446a-bab5-e59e00592d28	TENEDOR PEQUEÑO X100UNID	TENDORRR	t	2400.00	2250.00	\N	\N	0.00	2025-10-19 02:29:42.417075	2025-10-19 02:29:42.417075
0059d5bd-652e-4796-a424-fe528f66560b	CAFE IDEAL 125GR	7709390143283	t	3600.00	3500.00	\N	\N	0.00	2025-10-19 02:29:42.417344	2025-10-19 02:29:42.417344
cc6ec90f-a844-48f3-a8c4-12295d1ab40d	CAFE IDEAL 250GR	7709390143269	t	6300.00	6100.00	\N	\N	0.00	2025-10-19 02:29:42.417607	2025-10-19 02:29:42.417607
deccf1f6-4e43-42c2-a64c-194e2f32f261	TOALLAS ELLAS NOCTURNAS DELGADAS X40UNID	7702108205945	t	10500.00	10200.00	\N	\N	0.00	2025-10-19 02:29:42.417897	2025-10-19 02:29:42.417897
6c9ac60c-1d21-4988-85d7-0c5ae10c1b86	LA LECHERA ORIGINAL 25GR	7702024472308	t	900.00	850.00	\N	\N	0.00	2025-10-19 02:29:42.418165	2025-10-19 02:29:42.418165
b31e4711-3347-470c-b49c-0ca761070565	DOG CHOW COMIDA HUMEDA CON CARNE 100GR	7501072210265	t	2600.00	2550.00	\N	\N	0.00	2025-10-19 02:29:42.41841	2025-10-19 02:29:42.41841
45272656-83d5-456f-ab4d-dee0bec91ad9	MANJAR AREQUIPE COCO X12UNID	7707283881915	t	9800.00	\N	\N	\N	0.00	2025-10-19 02:29:42.418637	2025-10-19 02:29:42.418637
6be3559f-077b-4db6-aa64-7da12ea95217	SUPER HIPER ACIDO SURTIDO X70UNID	7703888298486	t	8200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.418901	2025-10-19 02:29:42.418901
33e2d902-9d8e-4f5a-ab4e-218f07258c39	ATUN RIQUEZAS DEL MAR ACEITE VEGETAL 170GR	7862138980653	t	3500.00	3250.00	\N	\N	19.00	2025-10-19 02:29:42.419169	2025-10-19 02:29:42.419169
0113f4a6-c280-4609-bd1b-b7a3ee11cb32	MAYONESA MA 910GR	719503030185	t	21500.00	20700.00	\N	\N	0.00	2025-10-19 02:29:42.419414	2025-10-19 02:29:42.419414
f6a6aa2a-e0f6-4dca-88f5-dc6f33e2a4b8	CHOCOLATE AROMA TRADICIONAL 200GR	7702088214906	t	4100.00	4000.00	\N	\N	19.00	2025-10-19 02:29:42.419669	2025-10-19 02:29:42.419669
ed7ef843-d802-4058-b96c-6ce4a36830d1	LMPIA PISOS LA JOYA AROMA BEBE 200ML	7702088902544	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.419902	2025-10-19 02:29:42.419902
35fd8169-30fc-4887-9806-0b9018c07705	LIMPIAPISOS LA JOYA FLORAL 200ML	7702088902513	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.420139	2025-10-19 02:29:42.420139
caf0cd34-abbd-4ec4-b269-4ff2c68fadc9	CHOCOLATE QUESADA TRADICIONAL 200ML	7702088214760	t	7000.00	6850.00	\N	\N	5.00	2025-10-19 02:29:42.420403	2025-10-19 02:29:42.420403
f5607d06-3f6a-4c19-b0a0-78ed016e5921	FLUO CARDENT TRIPLE ACCION  50ML	7702560042010	t	2500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.420631	2025-10-19 02:29:42.420631
83c2b3b8-005f-42ef-bf6c-be8e38dd7cfe	MILLOWS SNACK 35GR	7702011048172	t	1500.00	1400.00	\N	\N	19.00	2025-10-19 02:29:42.42085	2025-10-19 02:29:42.42085
82b84bfb-e55d-424f-9b35-3e8305a00f0e	COLCAFE CLASICO SUAVE 170GR	7702032119370	t	23300.00	22850.00	\N	\N	5.00	2025-10-19 02:29:42.42108	2025-10-19 02:29:42.42108
c3e28b7d-b8f1-4a3d-8316-7e7ef382a6bf	CUCHARA DULCERA TAMI X100UNID	645667269546	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.421331	2025-10-19 02:29:42.421331
f7dd7295-2259-4522-a1d1-e441bb5d6962	CHOCOLATE CORONA 100GR	7702007084528	t	3800.00	3680.00	\N	\N	5.00	2025-10-19 02:29:42.421619	2025-10-19 02:29:42.421619
aed72726-3565-4d87-8bc5-8103bbb0f381	YOGURT GRIEGO NATURAL 120GR	7705241614193	t	3000.00	2700.00	2600.00	\N	19.00	2025-10-19 02:29:42.421827	2025-10-19 02:29:42.421827
bfd57564-c582-4e9b-b2fb-40f8c6923358	YOGURT GRIEGO NATURAL 330GR	7705241280275	t	7900.00	7000.00	6900.00	\N	19.00	2025-10-19 02:29:42.422047	2025-10-19 02:29:42.422047
5ec3eb74-6072-4e29-9571-9ecde9cfc0b7	YOGURT GRIEGO FRUTOS VERDES 120GR	7705241338099	t	3500.00	3100.00	3000.00	\N	19.00	2025-10-19 02:29:42.422316	2025-10-19 02:29:42.422316
bd0c5eb5-d54c-44b7-8478-2c286cb162c2	YOGUT GRIEGO FRUTOS ROJOS 120GR	7705241038678	t	3500.00	3100.00	3000.00	\N	19.00	2025-10-19 02:29:42.422589	2025-10-19 02:29:42.422589
2dd71344-afbc-4a17-80e1-2482a8475e1f	YOGURT GRIEGO FRUTOS ROJOS 120GR	7705241348968	t	3500.00	3100.00	3000.00	\N	19.00	2025-10-19 02:29:42.422884	2025-10-19 02:29:42.422884
83039eb1-3a28-4cf5-840e-4603f5745f28	MECHERA GLOBAL X25UNID	7709867188045	t	10000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.423162	2025-10-19 02:29:42.423162
2ab516bb-8f80-41fd-a9d6-1b93a12b7e0a	MECHERA BLOBAL CON LUZ X25UNID	7709219592216	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.42344	2025-10-19 02:29:42.42344
06c5f716-b312-4def-b475-52a710eaeee6	VELON SAN JORGE CITRONELA 65GR	7707159822110	t	6100.00	5900.00	\N	\N	19.00	2025-10-19 02:29:42.423778	2025-10-19 02:29:42.423778
512b89d2-4a2a-4fda-81b0-b00696bd7392	VASOS 10 VBC X50UNID	VASOS	t	2600.00	2500.00	\N	\N	0.00	2025-10-19 02:29:42.424	2025-10-19 02:29:42.424
9b6e3613-b7db-49a0-a986-3e6cf6cd43ae	LECHERITAS RAMO 152GR 8 PORCIONES	7702914601375	t	4700.00	4600.00	\N	\N	19.00	2025-10-19 02:29:42.424259	2025-10-19 02:29:42.424259
7b81c92c-2d0b-49b1-86ef-c28b1586e34e	LA ESPECIAL DE AVELLANAS CROCANTES 100GR	7702007050202	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.424513	2025-10-19 02:29:42.424513
a3e9798b-8023-47f5-a50a-7e1dc965a4f7	TIO NACHO SHAMPOO ANTI CANAS 1L	650240062087	t	41500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.424794	2025-10-19 02:29:42.424794
2b8283fa-a448-43c8-b5f4-6324c1effb09	FAB ULTRA LIMPIESA 300GR BARRA	7702191164600	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:42.425117	2025-10-19 02:29:42.425117
5d4058d4-90c6-4c87-8a4e-2230ee0871c0	TRATAMIENTO CAPILAR KANECHOM POWER CACHOS 1KG	7893694002305	t	24600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.425429	2025-10-19 02:29:42.425429
3180db89-d94c-4ac2-9ae9-3198da47e89c	MASCARILLA CAPILAR MULTIVITAMINAS MILAGROS 450GR	7708075180766	t	28000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.425931	2025-10-19 02:29:42.425931
7910eb64-e121-43a3-8ea8-22122f76055f	ROSAL ULTRA CONFORT X3UNID	7702120013863	t	3500.00	3300.00	\N	\N	19.00	2025-10-19 02:29:42.426295	2025-10-19 02:29:42.426295
21ad41cf-385f-4464-8195-19302aa1b4bc	FORTIDENT X3UNID 128GR	7702006404938	t	12600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.426603	2025-10-19 02:29:42.426603
ad2f78df-800a-4b5c-9dc7-5daee3a177cf	PAN TAJADO BIMBO MANTEQUILLA 460GR	7705326080585	t	6000.00	5830.00	\N	\N	0.00	2025-10-19 02:29:42.42692	2025-10-19 02:29:42.42692
9a42ad22-e997-41bd-a493-2d22b8d8194e	HAMBURGUESA MINI BIMBO X4UNID	7705326019295	t	4200.00	4050.00	\N	\N	0.00	2025-10-19 02:29:42.427319	2025-10-19 02:29:42.427319
1d05885a-941a-4af4-a28c-646d9bf72721	TORTILLAS TIA ROSA INTEGRAL X8UNID	7705326001993	t	4900.00	4750.00	\N	\N	0.00	2025-10-19 02:29:42.427637	2025-10-19 02:29:42.427637
2ee1e185-a0f1-4898-a172-04e5b68b1d84	BUENAZO BIMBO 60GR	7705326825971	t	2300.00	2250.00	\N	\N	0.00	2025-10-19 02:29:42.427957	2025-10-19 02:29:42.427957
5e371d57-22d3-4b6e-ad69-46cfde725d81	MIGA DE PAN GUADALUPE 250GR	7705326020215	t	4400.00	4250.00	\N	\N	0.00	2025-10-19 02:29:42.428282	2025-10-19 02:29:42.428282
e87f7159-07ba-4b8a-b1ba-64ff34fb4810	PONQUE VINO BIMBO 260GR	7705326077042	t	10900.00	10700.00	\N	\N	0.00	2025-10-19 02:29:42.428548	2025-10-19 02:29:42.428548
cb3eabcd-ddfc-4cc7-a9df-94754b063c3e	CUCHARA DULCERA X100UNID	6960708090298	t	2900.00	2750.00	\N	\N	19.00	2025-10-19 02:29:42.428823	2025-10-19 02:29:42.428823
af5f130d-994e-490d-bc03-097965bf8c92	YOGURT GRIEGO NATURAL 500GR	7705241521736	t	12600.00	11200.00	11000.00	\N	19.00	2025-10-19 02:29:42.429143	2025-10-19 02:29:42.429143
dbacb3c9-6d3e-490d-8976-d4c586ba1e7b	HUGGIES TRIPLE PROTECCION XG X25UNID	7702425325067	t	21000.00	20300.00	\N	\N	19.00	2025-10-19 02:29:42.429419	2025-10-19 02:29:42.429419
a9f9fa57-24c7-4c84-bef8-2a604ecab5ff	LIMPIDO FLORAL 460ML	7702137007541	t	1400.00	1313.00	\N	\N	19.00	2025-10-19 02:29:42.429676	2025-10-19 02:29:42.429676
565a756a-c76e-4dc8-b268-f0efe65709a9	SUAVITEL NATURAL ESSENTIALS 160ML	7509546676135	t	1500.00	1450.00	\N	\N	19.00	2025-10-19 02:29:42.429975	2025-10-19 02:29:42.429975
0fae8979-9544-4412-a61b-5a322bbe09cc	MUAU NUGGET CON SALMON 12GR	7702993052402	t	1000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.430224	2025-10-19 02:29:42.430224
780b3b60-66b7-48f1-8458-98262423e155	DERSA BICARBONATO MANZANA 500GR	7702166004030	t	4700.00	4580.00	\N	\N	19.00	2025-10-19 02:29:42.430492	2025-10-19 02:29:42.430492
bcae449c-d512-42ad-86a3-60162c96ed85	SHAMPOO SAVITAL ANTICASPA 385ML	7702006207805	t	11500.00	11000.00	\N	\N	19.00	2025-10-19 02:29:42.430726	2025-10-19 02:29:42.430726
be3b921b-4887-4198-bc1d-367a2bfac66f	SUAVIZANTE BIO FLORAL PINTO 2L	7702856952382	t	8200.00	8000.00	\N	\N	19.00	2025-10-19 02:29:42.43099	2025-10-19 02:29:42.43099
5772e275-1965-4343-bd33-51dff5fb3181	MERMELADA TROPICO MORA 200GR	7708919428498	t	1900.00	1780.00	\N	\N	0.00	2025-10-19 02:29:42.431293	2025-10-19 02:29:42.431293
ee028f26-7ce5-4569-8004-f8a899cf10a6	FINI ROLLER 20GR	8410525149801	t	1200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.431546	2025-10-19 02:29:42.431546
44d6b676-45be-42e3-9407-d27e0c239ba6	FINI ROLER 20GR	8410525127465	t	1200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.431762	2025-10-19 02:29:42.431762
27d17a3c-be4d-484f-987c-49a9759b051b	FINI ROLLER	8410525159039	t	1200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.432021	2025-10-19 02:29:42.432021
72e14656-f200-4dc9-87c3-472a012a5bad	FINI ROLLER	8410525200182	t	1200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.432262	2025-10-19 02:29:42.432262
0186f068-8a0c-457d-b268-407cd476ded5	FINI ROLLER RISTRA X18UNID	8410525735218	t	19900.00	\N	\N	\N	0.00	2025-10-19 02:29:42.432506	2025-10-19 02:29:42.432506
a877e3e9-7f4d-48a2-8438-afc99d7ea2d5	GELATINA FRUTIÑO PIÑA 14GR	7702354955267	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.432724	2025-10-19 02:29:42.432724
3a46490b-ec15-4f2f-bea9-aa1e253583c3	GELATINA FRUTIÑO LIMON 14GR	7702354955243	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.432966	2025-10-19 02:29:42.432966
f704da3b-78fe-4b2f-9426-c2a6bf9a6a38	GELATINA FRUTIÑO MANGO AZUCAR 14GR	7702354955212	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.4332	2025-10-19 02:29:42.4332
53368808-1c1e-4eb7-a9c6-e8cd4fbdfe79	GELATINA FRUTIÑO MANDARINA 14GR	7702354955250	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.433402	2025-10-19 02:29:42.433402
d4b4daba-28ae-4949-81a9-9ca4633bf884	SUNTEA LIMON 12GR	7702354955366	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:42.433624	2025-10-19 02:29:42.433624
0ee34eb8-6e04-4efb-b7ab-3bb5d8c8afe0	SUNTEA FRUTOS ROJOS 12GR	7702354955397	t	1500.00	1334.00	\N	\N	19.00	2025-10-19 02:29:42.433828	2025-10-19 02:29:42.433828
af3002a7-a94f-407e-8a3e-dfd47927b234	FRUTIÑO LIMONADA 10GR	7702354955908	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:42.434059	2025-10-19 02:29:42.434059
e4d2eb0c-44cd-4c7f-a700-46a992dc4d94	JUGO RELOJ MAS COLLAR NIÑA	JUEGO	t	7000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.43437	2025-10-19 02:29:42.43437
297d75cc-07b3-4542-8587-72424689195d	JUEGO LENTES MAS MOÑITAS	JUEGOO	t	6000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.434619	2025-10-19 02:29:42.434619
3496fff7-401e-4d83-89ec-9bdb67e375fd	CEPILLO COLGATE 360 MEDIANO X5UNID	7702010631795	t	27600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.434851	2025-10-19 02:29:42.434851
fe927496-8fc0-46b5-9858-adc23bfaa704	CEPILLO ORAL B 7 BENEFICIOS CRISSCROSS X5UNID	7506195178645	t	27000.00	26300.00	\N	\N	0.00	2025-10-19 02:29:42.435085	2025-10-19 02:29:42.435085
a781897b-6a38-4368-9279-27a75c445e55	SHAMPOO TIO NACHO ANTI CANAS 950ML	650240069949	t	38000.00	37000.00	\N	\N	19.00	2025-10-19 02:29:42.435323	2025-10-19 02:29:42.435323
b41f0285-6f46-4ab7-aed5-00242f570beb	SHAMPOO TIO NACHO HERBOLARIA MILENARIA 950ML	650240061172	t	38000.00	37000.00	\N	\N	19.00	2025-10-19 02:29:42.435762	2025-10-19 02:29:42.435762
b0fa0f8c-8cc6-4c55-a60e-7b5ee144b5a0	SHAMPOO TIO NACHO ACLARANTE 950ML	650240066443	t	38000.00	37000.00	\N	\N	19.00	2025-10-19 02:29:42.436007	2025-10-19 02:29:42.436007
0662fd04-592d-4720-9b6c-aa1f86503a96	OBLEAS GRUESAS LA PAILA X100	38025	t	11800.00	11400.00	\N	\N	19.00	2025-10-19 02:29:42.436253	2025-10-19 02:29:42.436253
6df95d66-4ab3-4940-ae0e-e0141afe1934	TIJERA BIGOTERA DOBLAR	TIJERA	t	1000.00	900.00	\N	\N	0.00	2025-10-19 02:29:42.4365	2025-10-19 02:29:42.4365
e3d239c3-b2fe-4b2d-9cec-28eb67468aff	CORTA CURTICULAS SOLIGEN	4002320452060	t	5500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.436728	2025-10-19 02:29:42.436728
23e3ec3b-1842-4197-825c-9a2c963501a7	TIJERAS GRANDES 21CM	1984020260240	t	5500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.436951	2025-10-19 02:29:42.436951
9d000139-9301-483a-907e-b761b7ffb19d	RECARGA DE GAS DURALIGTH	RECARGA	t	2000.00	1800.00	\N	\N	0.00	2025-10-19 02:29:42.437182	2025-10-19 02:29:42.437182
b187d696-1dc7-4499-9a51-4c49e91c3431	ROSY XXL X24UNID	8690562110426	t	27000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.437414	2025-10-19 02:29:42.437414
5e1e4a69-d514-48ed-b536-88a2a7504e6b	GELATINA MONKEY GELA PLAY YOLIS X90UNID	7708527098755	t	27500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.437634	2025-10-19 02:29:42.437634
7ee2619d-bc99-4602-bb7f-e00555bd2a51	CHOCO CARROS DE CHOCOLATE YOLIS X50UNID	7708527098090	t	12300.00	11800.00	\N	\N	19.00	2025-10-19 02:29:42.437864	2025-10-19 02:29:42.437864
ea2437d0-6831-49b5-b465-8597c6c624cc	PIRULITO NEON X12 UNID	7702011074386	t	7300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.438091	2025-10-19 02:29:42.438091
a913a2dc-0b77-4606-bdd9-8723ac786e99	LA BOTELLITA LECHE CONDENSADA X10UNID	7707928443577	t	7500.00	7300.00	\N	\N	19.00	2025-10-19 02:29:42.438317	2025-10-19 02:29:42.438317
05cff61f-49c7-4af8-bd29-d73dea6977e9	LA BOTELLITA CARAMELO LIQUIDO X10UNID	7707928443584	t	7200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.438568	2025-10-19 02:29:42.438568
84d7c089-f6ed-4916-8c0b-e7fb0fa258b8	LA BOTELLITA POLVO ACIDO X10UNID	7707298441296	t	8200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.438793	2025-10-19 02:29:42.438793
d1f3fa40-869a-4f5e-b2f6-ef2476005f3f	SPEED MAX BLUE 310ML	7702090001211	t	1700.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.439019	2025-10-19 02:29:42.439019
b46cf37a-252a-4ab6-8c9e-89c021e99f81	MONEDAS CHOCO COIN YOLIS X200UNID	7709082030518	t	30500.00	30000.00	\N	\N	19.00	2025-10-19 02:29:42.43926	2025-10-19 02:29:42.43926
c3fd0c4a-8969-4bc1-be76-51acbcb254bb	TOALLAS ELLAS NOCTURNAS DISPENSADOR X30UNID	7702108208618	t	9900.00	\N	\N	\N	0.00	2025-10-19 02:29:42.439501	2025-10-19 02:29:42.439501
ff16bc18-80a7-41cb-873f-5a1cae70c2b4	MILO ACTIVA GO 180ML	7702024059561	t	2700.00	2650.00	\N	\N	19.00	2025-10-19 02:29:42.439787	2025-10-19 02:29:42.439787
8068f584-29b9-44dc-9e86-73f1c1e1a8c6	CREMA MARINERA MAGGI 56GR	7702024191308	t	3500.00	3400.00	\N	\N	19.00	2025-10-19 02:29:42.440011	2025-10-19 02:29:42.440011
dbd5e7be-cb92-4f41-ab09-b5a3f3e08b52	CREMA DE CHAMPIÑONES MAGGI 58GR	7702024169291	t	3500.00	3400.00	\N	\N	19.00	2025-10-19 02:29:42.440252	2025-10-19 02:29:42.440252
80a20049-1d16-4823-8678-f36eaa1e0efc	CREMA DE POLLO CON CHAMPIÑONES MAGGI 60GR	7702024600848	t	3500.00	3400.00	\N	\N	19.00	2025-10-19 02:29:42.440488	2025-10-19 02:29:42.440488
e3bdfdb3-b29c-4a4b-bd0e-5d535e7448ae	BASE SALSA NAPOLITANA MAGGI 48GR	7702024821052	t	4400.00	4300.00	\N	\N	19.00	2025-10-19 02:29:42.440713	2025-10-19 02:29:42.440713
8070e453-9d7f-4fe8-b7e2-4c29d784e024	BASE DE SALSA POLLO CON CHAMPIÑONES 50GR	7702024015901	t	4400.00	4300.00	\N	\N	19.00	2025-10-19 02:29:42.440939	2025-10-19 02:29:42.440939
14b957a3-f9a5-4fd4-ac24-8b26350e15eb	PAPEL PARAFINADO CUADRO UNICOLOR EL REY 100MT	PAPEL PARA	t	16000.00	15500.00	\N	\N	19.00	2025-10-19 02:29:42.44117	2025-10-19 02:29:42.44117
33ea3d07-3e94-45db-9bf1-a1b615b5a1c7	BUÑUELOS 200GR	7707345596115	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:42.441484	2025-10-19 02:29:42.441484
7208bb75-c097-4a66-a841-d76e41785c70	NATILLA SABOR AREQUIPE 200GR	7707345596788	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:42.441818	2025-10-19 02:29:42.441818
b4e30c46-8126-41ba-9dfb-a12c78bdc627	NATILLA TRADICIONAL 200GR	7708773299111	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:42.442188	2025-10-19 02:29:42.442188
c6988f17-ba8d-4d29-b137-7192024080bd	BIG BOM XXL FSEH AIR X48	7707014905682	t	15700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.442481	2025-10-19 02:29:42.442481
7940dab9-1dec-481d-b68b-7f7598adc5de	DURAZNO EN ALMIBAR XOE 520GR	7709098879835	t	5100.00	4900.00	\N	\N	0.00	2025-10-19 02:29:42.442779	2025-10-19 02:29:42.442779
61e7a1b9-2716-4035-96cd-c5d0c246fcd9	GALLETA NAVIDEÑA MI DIA 200GR	7700149191586	t	3600.00	3500.00	\N	\N	19.00	2025-10-19 02:29:42.443022	2025-10-19 02:29:42.443022
8e6c4d9f-efa9-4d4c-b857-f3f57c65375f	CAFE GALAVIZ EXTRA X50GR	7702182000016	t	1000.00	900.00	\N	\N	5.00	2025-10-19 02:29:42.443307	2025-10-19 02:29:42.443307
dd6134a7-e862-4588-b29a-a2a54c307b8a	HEAD SHOULDER ANTI COMEZON 375ML	7500435231237	t	18000.00	17500.00	\N	\N	19.00	2025-10-19 02:29:42.443573	2025-10-19 02:29:42.443573
8372fa6a-a8d3-4e19-89e2-a0d312f81585	HEAD SHOULDER ANTI COMEZON 180ML	7500435231244	t	12000.00	11700.00	\N	\N	19.00	2025-10-19 02:29:42.443962	2025-10-19 02:29:42.443962
f91c00d5-b9e5-47ca-a36c-4f305c1203fa	PRESTOBARBA SCHICK HAWAIIAN X12UNID	7707254790031	t	29000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.444394	2025-10-19 02:29:42.444394
83705cb1-5793-496f-8e9b-daf281e18e1b	7	6	t	1000.00	\N	\N	\N	10.00	2025-10-19 02:29:42.444689	2025-10-19 02:29:42.444689
3be1314a-96a8-48cb-b8eb-da2979f01144	BUTIFARRA CARNOSAN 450GR	BUTIFA	t	8400.00	7500.00	7400.00	\N	0.00	2025-10-19 02:29:42.445172	2025-10-19 02:29:42.445172
69a183e2-dcc1-4939-a319-109fbf7ba6da	VELAS DE PESEBRE X9 UNID	7707297967124	t	14500.00	13900.00	\N	\N	0.00	2025-10-19 02:29:42.445481	2025-10-19 02:29:42.445481
56826eca-b19c-40a8-a46a-24c0d547e0b6	VELAS PERSONALIZADA X7UNID	7707297962365	t	9300.00	8900.00	\N	\N	0.00	2025-10-19 02:29:42.445773	2025-10-19 02:29:42.445773
99797e0d-cf42-401c-ac2b-575bfcd9b886	VELAS GRANDE FUERTE X7	7707297961443	t	11600.00	11100.00	\N	\N	0.00	2025-10-19 02:29:42.446063	2025-10-19 02:29:42.446063
8d43f300-695c-45f1-a201-eafee965a4ab	VELAS GRANDE PASTEL X7UNID	7707297969395	t	13300.00	12700.00	\N	\N	0.00	2025-10-19 02:29:42.446446	2025-10-19 02:29:42.446446
e0c76f20-c6fb-4ddf-b1cf-873bd5496b38	SQUASH TROPICAL 500ML	7702090029741	t	2300.00	2000.00	\N	\N	19.00	2025-10-19 02:29:42.446724	2025-10-19 02:29:42.446724
411a6bea-0968-4a41-a822-fbcf92d3f022	NUTELLA CREMA 15GR X12UNID	NUTELLA	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.446994	2025-10-19 02:29:42.446994
122c00b6-2767-4b55-a9a2-edf215bff8de	GUANTES NEGROS DOBEL PEPA	6956846325309	t	2000.00	1600.00	\N	\N	0.00	2025-10-19 02:29:42.447264	2025-10-19 02:29:42.447264
c0fa79fa-f343-4d4f-b12d-e2724935043a	ACEITE DE COCO EXTRA VIRGEN MONTICELLO 110GR	7702085005965	t	13200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.447525	2025-10-19 02:29:42.447525
43111846-dfa2-42db-9d6f-19c86be6fd86	ENCENDEDOR DE PISTOLA HAOXUAN	2321090582350	t	6000.00	5800.00	\N	\N	0.00	2025-10-19 02:29:42.447772	2025-10-19 02:29:42.447772
4143cc75-0aaf-4a75-9b1f-f96af50e77c0	SAL REFISAL HIMALAYA MIX PIMIENTA 110GR	7703812406017	t	11300.00	\N	\N	\N	0.00	2025-10-19 02:29:42.448033	2025-10-19 02:29:42.448033
73555a63-aa50-487d-b040-0240e44e03b6	LINTERNA TIPO MILITAR PEQUEÑA MINI	LINTER	t	9000.00	8300.00	\N	\N	0.00	2025-10-19 02:29:42.448329	2025-10-19 02:29:42.448329
21078c1f-614e-4f33-be99-618f69a3cdff	ATUN ZENU LOMOS AGUA 120GR	7701101361672	t	4600.00	4500.00	\N	\N	19.00	2025-10-19 02:29:42.448563	2025-10-19 02:29:42.448563
dc71a69b-bc40-491a-8e37-79acddaa398d	SALTIN NOEL GALLETAS NAVIDAD BOLSA  200GR	7702025149421	t	5400.00	5180.00	\N	\N	19.00	2025-10-19 02:29:42.448841	2025-10-19 02:29:42.448841
877cac99-92a5-4813-b76c-14190c802b8e	GALLETA NAVIDEÑA SALTIN NOEL OCTAGONAL 260GR	7702025150250	t	26600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.449092	2025-10-19 02:29:42.449092
b2b891b3-8903-4ba4-84d9-7583ce0b2a8e	MANI LA ESPECIAL MIX CON TAJIN 150GR	7702007084450	t	9100.00	8850.00	\N	\N	19.00	2025-10-19 02:29:42.449354	2025-10-19 02:29:42.449354
4d50fd99-06ff-4fce-afb8-8dba7ff0f668	RICOSTILLA DESMENUZADO X24UNID	7702354939205	t	12500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.449651	2025-10-19 02:29:42.449651
fe46975b-a3a3-4179-adf3-f4d292358b87	BIO REPOLARIZADOR CAPILAR MILAGROS 450ML	7708075180087	t	33500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.449899	2025-10-19 02:29:42.449899
f467b0b8-82f3-4441-ae2f-cad747e73b1d	JABON INTIMO VENUS 180ML	7702108201817	t	6700.00	6400.00	\N	\N	0.00	2025-10-19 02:29:42.450148	2025-10-19 02:29:42.450148
1a630975-2a17-473e-8bf1-91d537d9f6b0	ALUMINIO HOUSE X100M	7707320620064	t	27500.00	26500.00	\N	\N	19.00	2025-10-19 02:29:42.450497	2025-10-19 02:29:42.450497
349c82b2-3696-4462-85a6-e07f7d71bd17	COOL A PED ROLL ON GEL VERDE 80GR	7708851548698	t	2800.00	2500.00	\N	\N	0.00	2025-10-19 02:29:42.450743	2025-10-19 02:29:42.450743
0bb0542e-028c-4f88-8142-f9137809f1cd	CINTA SELLO MAS 100MT	CINTASSS	t	4400.00	4100.00	\N	\N	0.00	2025-10-19 02:29:42.451037	2025-10-19 02:29:42.451037
5da0df2e-289b-4209-8ec2-cecb5e3d8c08	SHAMPOO NUTRIBELAS PROHIALURONICO MAS TRATAMIENTO 400ML	7702354954314	t	33500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.451344	2025-10-19 02:29:42.451344
5a6080ea-1f22-4062-9017-93e62858bcca	COLCAFE 3EN1 AREQUIPE 230GR	7702032118984	t	11500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.451629	2025-10-19 02:29:42.451629
d16b4187-12d4-4e86-b696-3cf3253c79e9	PAPEL ALUMINIO EL SOL 16MT CAJA	7707015511325	t	5000.00	4850.00	\N	\N	19.00	2025-10-19 02:29:42.451872	2025-10-19 02:29:42.451872
45d092d2-3ce5-4399-981d-d73604967fb3	BRILLO GRUESO X36UNID	BRILLOO	t	9200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.452155	2025-10-19 02:29:42.452155
8e3deed5-cb4e-4fe1-b564-0ffb6a3862b6	CHOCOLATE QUESADA 400GR VAINILLA	7702088214494	t	12700.00	12400.00	\N	\N	5.00	2025-10-19 02:29:42.45241	2025-10-19 02:29:42.45241
459e97e9-5340-427e-bb2c-844edf8dbc21	CHOCOLATE QUESDA TRADICIONAL 400GR	7702088214487	t	12700.00	12400.00	\N	\N	5.00	2025-10-19 02:29:42.452618	2025-10-19 02:29:42.452618
d1cd60ee-7a58-40eb-9b8a-33a20654047a	CHOCOLATE QUESADA CLAVOS Y CANELA 400GR	7702088214500	t	12700.00	12400.00	\N	\N	5.00	2025-10-19 02:29:42.452887	2025-10-19 02:29:42.452887
f22757f2-b5bd-48b0-8e0c-eef8fb30882d	PAPEL FAMILIA ACOLCHAMAX EXTRA GRANDE X9UNID	7702026153397	t	9000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.453134	2025-10-19 02:29:42.453134
01553f95-ccca-40ae-86ce-315869512894	MANI ESPECIAL CHOCO ARANDANOS X9UNID	7702007057676	t	13000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.453383	2025-10-19 02:29:42.453383
566a55cc-799f-43aa-a2f6-f4b78d3ac01c	AVENA EXTRA SEÑORA 1100GR	7709220129357	t	5800.00	5600.00	\N	\N	5.00	2025-10-19 02:29:42.453628	2025-10-19 02:29:42.453628
ecf0225d-cc4f-4423-96d6-cb5b3c2be4a9	CAREY HUMECTACION NATURAL 110GR	7702310022378	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:42.453889	2025-10-19 02:29:42.453889
c240d8a5-cd99-4631-9042-fe6e1c99b5f3	PROTEX HERBAL 110GR	7509546693545	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:42.454146	2025-10-19 02:29:42.454146
92a698aa-4e26-4cd0-83ba-2e4320368fc2	PROTEX NUTRI PROTEC 110GR	7509546693521	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:42.454416	2025-10-19 02:29:42.454416
c005a091-f484-42ac-85d0-08f2e52261d6	HIT FRUTAS TROPICALES 500ML	7707133052670	t	2400.00	2150.00	\N	\N	19.00	2025-10-19 02:29:42.454732	2025-10-19 02:29:42.454732
9d77ccda-071f-4817-9e0c-e714b8cf7a4b	ARIEL DOWNY 4KG	7500435111416	t	41000.00	40000.00	\N	\N	19.00	2025-10-19 02:29:42.454951	2025-10-19 02:29:42.454951
d69f45e0-a2bd-4bf6-8812-f9fb9f5e03af	GALLETA NAVIDEÑA SALTIN NOEL CAJA ROJA 200GR	7702025143566	t	8800.00	8600.00	\N	\N	19.00	2025-10-19 02:29:42.45521	2025-10-19 02:29:42.45521
103c8874-0f0f-4246-ab8f-25a0e85d7154	PAPELERA PLASTICA CON TAPA	PAPELERA	t	12500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.455429	2025-10-19 02:29:42.455429
273995f0-a05f-4006-8c25-b31a807db216	BOLSA ASEO 65 110CM X10UNID	BOSA ASEO	t	6400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.455747	2025-10-19 02:29:42.455747
b9605704-e502-46f1-a230-c454410e64d7	CONTENEDOR RECICLAJE 55LITROS X3UNID	CONTENEDOR RE	t	160500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.456001	2025-10-19 02:29:42.456001
f0430f66-4fd9-49c8-a525-775368616ae8	VASIJA CON TAPA 120 LITROS	VASIJA	t	39000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.456251	2025-10-19 02:29:42.456251
7148af0a-e91b-4cb4-93d1-df13b685d34c	TRAPERO 500 MAS PALO DE MADERA	TRAPEROCOMPLET	t	6500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.456534	2025-10-19 02:29:42.456534
6a97600b-c9c7-423d-9f84-54b746cd505b	BUÑUELO ANTIOQUEÑO 200GR	7708970947075	t	2700.00	2550.00	\N	\N	19.00	2025-10-19 02:29:42.456784	2025-10-19 02:29:42.456784
bbdf8840-6159-42a9-a86b-0997387772c5	TRIDENT X60 TUTTI FRUTTI 90GR	7622202015175	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.457032	2025-10-19 02:29:42.457032
05bc659c-756e-44d2-aaaa-5057413d1a15	TRIDENT SANDIA X24 X3CHICLES 122G	7702133452192	t	20700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.457309	2025-10-19 02:29:42.457309
14dced40-1c2e-4404-a3cb-85c1bbe114da	TRIDENT SANDIA PG 18 LLE 21 178G	7622201815103	t	23500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.457575	2025-10-19 02:29:42.457575
52705928-b407-4268-9291-0f9cb644d836	AVENA INSTANTANEA VAINILLA EXTRA S 180G	7709761545883	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.457857	2025-10-19 02:29:42.457857
4497a1f3-ba56-458e-bdef-8ba62b61179b	SUPER HIPER ACIDO X15	7703888295478	t	11600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.458337	2025-10-19 02:29:42.458337
9502f223-634f-4334-a7f4-6930ddfdfa18	VITAMINA C DISAAR TRAVELTIME	6932511226300	t	15000.00	14200.00	\N	\N	19.00	2025-10-19 02:29:42.458594	2025-10-19 02:29:42.458594
0769b2f6-e178-4def-afff-72df6fe26a0b	KIT SKIN CARE ALOE VERA 4EN1	6937914940020	t	12500.00	11800.00	\N	\N	19.00	2025-10-19 02:29:42.458911	2025-10-19 02:29:42.458911
7411b056-6393-442e-8717-3b747e370650	COMBO ALMA BEAUTY VITAMINA C X4	6942017810743	t	16000.00	15200.00	\N	\N	19.00	2025-10-19 02:29:42.459155	2025-10-19 02:29:42.459155
d0f57678-4871-4985-9809-8d3880a64afd	KIT 2EN1 PROTECTOR SUNCREEN ALOE VERA	6973931640444	t	8500.00	7900.00	\N	\N	19.00	2025-10-19 02:29:42.459419	2025-10-19 02:29:42.459419
7d2b3a2d-ad73-487a-a6c5-d282ea4b4551	SADOER RETINOL X5 PIEZAS	6976504687037	t	35000.00	33000.00	\N	\N	19.00	2025-10-19 02:29:42.459677	2025-10-19 02:29:42.459677
19c48c98-d7f6-4a43-b094-73f6064d2557	PROTECTOR SOLAR BARRA SUN CREEN  90	6903072437894	t	10500.00	9900.00	\N	\N	19.00	2025-10-19 02:29:42.459938	2025-10-19 02:29:42.459938
fc080e75-ab1a-40d3-bc2a-6766938c61ad	ALMA BEAUTY ACIDO HIALURONICO X5 PIEZAS	6942017810842	t	36500.00	34800.00	\N	\N	19.00	2025-10-19 02:29:42.46021	2025-10-19 02:29:42.46021
787454c4-21b8-405c-bcea-69d7f1ff41d0	EXFOLIADOR PARA LABIOS DE SILICONA	6973578912188	t	1500.00	1250.00	\N	\N	19.00	2025-10-19 02:29:42.46048	2025-10-19 02:29:42.46048
21d4df46-96f4-4b55-b906-976f990ae4a2	CHOKIS BLACKX6 222G	7702189056894	t	9800.00	9700.00	\N	\N	19.00	2025-10-19 02:29:42.460775	2025-10-19 02:29:42.460775
c68d343d-5be9-4795-a3cb-ff58cd792f11	LIMPIADOR FULL FRESH JARDIN DE SUEÑOS 3785	7702856007792	t	17200.00	16600.00	\N	\N	19.00	2025-10-19 02:29:42.461306	2025-10-19 02:29:42.461306
3e91652c-48ba-47f0-82bf-7dfc46784e40	LIMPIADOR FULL FRESH BICARBONATO LIMON 3785L	7702856991329	t	17200.00	16600.00	\N	\N	19.00	2025-10-19 02:29:42.461699	2025-10-19 02:29:42.461699
e52eca68-db9f-40be-a332-ef04b6d8c3b5	LIMPIADOR FULL FRESH FRESCURA NATURAL 3785L	7707112350742	t	17200.00	16600.00	\N	\N	19.00	2025-10-19 02:29:42.462009	2025-10-19 02:29:42.462009
86193f3d-56bd-432a-97fe-7034af41978c	LIMPIADOR FULL FRESH FRESCURA MANZANA  3785L	7702856926116	t	17200.00	16600.00	\N	\N	19.00	2025-10-19 02:29:42.462335	2025-10-19 02:29:42.462335
aad03ae9-5af0-492b-a8bd-b0f74ba2daa9	LIMPIADOR FULL FRESH CRISAS DEL BOSQUE 3785L	7702856007761	t	16600.00	16200.00	\N	\N	19.00	2025-10-19 02:29:42.462643	2025-10-19 02:29:42.462643
2736c277-7dcc-4ae9-838d-ee743ce55a73	ELIMINA OLORES PINTO ECO 500ML	7702856952436	t	8600.00	8400.00	\N	\N	19.00	2025-10-19 02:29:42.462972	2025-10-19 02:29:42.462972
d017d21b-4dbb-4038-9c5e-31879146c471	VARSOL FULL FRESH 500ML	7702856004210	t	6300.00	6200.00	\N	\N	19.00	2025-10-19 02:29:42.463597	2025-10-19 02:29:42.463597
91465a49-a88e-47fe-8bfd-df2720ba3d3d	LAVALOZA LIQUIDO PINTO ECO 500ML	7702856952405	t	3200.00	3050.00	\N	\N	19.00	2025-10-19 02:29:42.46385	2025-10-19 02:29:42.46385
551e63f8-c8f3-4e5c-a873-73db0838eb3a	TALCO TEXANA 240GR	7709990381047	t	5100.00	4900.00	\N	\N	0.00	2025-10-19 02:29:42.464151	2025-10-19 02:29:42.464151
6c296699-b784-4f2f-b51e-d3dc336bfdf8	AROMATICA MI DIA FRUTOS ROJOS X20UNID 20GR	7700149010795	t	2700.00	2600.00	\N	\N	0.00	2025-10-19 02:29:42.464472	2025-10-19 02:29:42.464472
d747d2e3-e3bb-41b2-b0aa-30b8ef19f7e0	CREMA DE WHISKY ORO 750ML	7709881439376	t	15500.00	14700.00	\N	\N	0.00	2025-10-19 02:29:42.46474	2025-10-19 02:29:42.46474
ab944aed-8118-41be-b34f-3285a1754509	HARINA DE MAIZ DON BENITO 1000GR	7708913820168	t	2600.00	2525.00	\N	\N	5.00	2025-10-19 02:29:42.464995	2025-10-19 02:29:42.464995
f8c6990a-a646-492e-8218-4e3702262a27	GALLETA NAVIDEÑA CAMPANITA BOLSA 180GR	7709674476502	t	3800.00	3600.00	\N	\N	19.00	2025-10-19 02:29:42.465219	2025-10-19 02:29:42.465219
efabcc63-5c50-48f7-9045-8783ce3e4c35	NATILLA IDEAL TRADICIONAL 200GR	7709474899327	t	3100.00	2950.00	\N	\N	0.00	2025-10-19 02:29:42.465439	2025-10-19 02:29:42.465439
6012dca4-7fc5-4997-ad46-0f27b5daaf6b	DURAZNOS EN ALMIBAR IDEAL 260GR	7709511768173	t	4100.00	3900.00	\N	\N	0.00	2025-10-19 02:29:42.465689	2025-10-19 02:29:42.465689
c8728f9b-fe9d-4030-8c59-b272f165bc78	VASOS CARTON 4ONZ IDEALTEX X50UNID	7702023110317	t	3000.00	2900.00	\N	\N	0.00	2025-10-19 02:29:42.465936	2025-10-19 02:29:42.465936
2bde1362-adf3-4394-a1c3-dd2d5d93583f	PAPAS CABELLO DE ANGEL PREMIUM DELY  1000GR	7709379602411	t	12400.00	12000.00	\N	\N	0.00	2025-10-19 02:29:42.466165	2025-10-19 02:29:42.466165
2c11eaef-5b4d-4a82-aed7-d48ae2d8e7a9	ARENA APRA GATOS SILVESTER 4KG	659525150624	t	14200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.466438	2025-10-19 02:29:42.466438
b4e35ed1-ac81-44fb-b833-c0593651a493	CUCHARA ECON PEQUEÑA X20UNID	CUCHARA	t	1400.00	1300.00	\N	\N	0.00	2025-10-19 02:29:42.466659	2025-10-19 02:29:42.466659
0c08fdf0-7d31-44bb-8629-a5ae6db43d50	PRESTOBARBA BIC AMARILLA 2 HOJAS	7702436482056	t	1200.00	1000.00	\N	\N	19.00	2025-10-19 02:29:42.466884	2025-10-19 02:29:42.466884
e305f986-6eae-4191-9c5f-e8222c459bfd	DESMANCHADIR ROPA COLOR LIMPIA YA 1L	7702037913447	t	4700.00	4550.00	\N	\N	19.00	2025-10-19 02:29:42.467146	2025-10-19 02:29:42.467146
1a326108-edfa-4d15-a986-32d7d310b3f5	FLAN VAINILLA YAKOMO 250GR	9780201379624	t	3200.00	4000.00	\N	\N	0.00	2025-10-19 02:29:42.4677	2025-10-19 02:29:42.4677
48c7e2eb-560d-4404-8eda-d32b8425bf04	PAPEL SUAVE GOLD X12UNID	7702120012743	t	27900.00	26800.00	\N	\N	19.00	2025-10-19 02:29:42.467932	2025-10-19 02:29:42.467932
0c230e17-3e18-4621-8c15-3fac836888a8	BOLSA PAPELERA BLANCA X30	7700304840212	t	2700.00	2600.00	\N	\N	0.00	2025-10-19 02:29:42.468199	2025-10-19 02:29:42.468199
41354317-34c0-4339-8df5-31c0747253d9	CAFE AROMA SOLUBLE TARRO 45GR	7702088212933	t	6900.00	6680.00	\N	\N	19.00	2025-10-19 02:29:42.468431	2025-10-19 02:29:42.468431
21b00f3a-751c-4100-947d-cd792c3c4d9b	OLSA VIKINGO X2UNID	BOLSSA VIK	t	1800.00	1700.00	\N	\N	0.00	2025-10-19 02:29:42.468676	2025-10-19 02:29:42.468676
873105c8-a1de-4349-84c7-e7b2e2773ead	LECHE CONDENSADA PARMALAT 400GR	7700604006356	t	9900.00	9700.00	\N	\N	0.00	2025-10-19 02:29:42.468975	2025-10-19 02:29:42.468975
53812108-f161-4366-a790-08596482db78	GALLETAS NAVIDEÑAS TRADICIONAL BOLSA ROJA 150GR	7709309429989	t	3500.00	3380.00	\N	\N	19.00	2025-10-19 02:29:42.469269	2025-10-19 02:29:42.469269
4499076d-89bb-4039-b3d6-86994257a495	DUX INTEGRAL 27.8GR	7702025185375	t	800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.469512	2025-10-19 02:29:42.469512
c0b577e2-ec5f-4c10-9eba-ec0b15ca6f6e	TOSH FUSION CEREALES 25.5GR	7702025148561	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.469761	2025-10-19 02:29:42.469761
66efdf54-86ec-4e21-a2d7-adddcabb0280	CREMA DE LECHE ALQUERIA 125GR	7702177007884	t	3300.00	3200.00	\N	\N	0.00	2025-10-19 02:29:42.470022	2025-10-19 02:29:42.470022
00eebbad-e340-45fb-93ef-dfe80cd8b122	JUMBO ALMENDRA 170GR	7702007085655	t	12800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.47032	2025-10-19 02:29:42.47032
115295e6-9ab0-4eac-8d1e-0e22e34cd88d	SACAR AMARILLAS	SACAS	t	2700.00	2500.00	\N	\N	0.00	2025-10-19 02:29:42.470592	2025-10-19 02:29:42.470592
31f74f18-6190-427d-b581-9cafce4388ed	JOHNSONS FUERZA Y VITAMINAS 750ML	7702031293637	t	32500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.47087	2025-10-19 02:29:42.47087
25e23f81-6663-46f3-b61c-51fca98f3ffa	DUCALES X5UNID 500GR	7702025149520	t	10200.00	10050.00	\N	\N	19.00	2025-10-19 02:29:42.471156	2025-10-19 02:29:42.471156
a8ce6c47-976e-4ead-be1d-1665916ab29f	ACONDICIONADOR MILAGROS HERBAL 450ML	7708075180612	t	31000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.471412	2025-10-19 02:29:42.471412
abbeacc5-aca0-4ccf-b5ab-66045c2191dd	COMPOTA BUBU VIDRIO 113GR	7704269108899	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:42.471761	2025-10-19 02:29:42.471761
664d726d-495a-4c8b-98f6-05788dce91e2	COMPOTA BUBU MANZANA VIDRIO 113GR	7704269108882	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:42.472029	2025-10-19 02:29:42.472029
7bb1d183-c112-406e-b83f-5d80580cd427	COMPOTA BUBU PERA VIDRIO 113GR	7704269108905	t	1800.00	1690.00	\N	\N	19.00	2025-10-19 02:29:42.472376	2025-10-19 02:29:42.472376
68a26ea0-8b21-4cd3-9c5b-4c23e8dc9943	VINO LA GRAN SAMBA 750ML	7709752263307	t	4500.00	4000.00	\N	\N	0.00	2025-10-19 02:29:42.472635	2025-10-19 02:29:42.472635
4eae3b67-f566-4a7c-90f1-6738575cec29	CREMA DE LECHE PROLECHE 170ML	7702130615491	t	4100.00	3950.00	\N	\N	0.00	2025-10-19 02:29:42.473723	2025-10-19 02:29:42.473723
4045794b-04ee-4867-94cb-28c530cb79c1	GLASE AUTOMATIO 175GR FRUTOS ROJOS	7591005996434	t	40000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.474188	2025-10-19 02:29:42.474188
785b9112-c94e-4b6d-a01a-293ea9dac1ce	GLASES AUTOMATICO PARAIZO AZUL 175GR	7501032909406	t	40000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.474521	2025-10-19 02:29:42.474521
65dfd100-e242-474e-8583-22da1c91b08f	AZUCAR PALACIO 5.000GR	7709241447768	t	19800.00	\N	\N	\N	5.00	2025-10-19 02:29:42.474991	2025-10-19 02:29:42.474991
e402d66d-cf7e-482e-9833-46c9a1ad2b05	INSECTICIDA RAYOL POTE BLANCO MOSCA CUCARACHA	INSEC	t	5800.00	5500.00	\N	\N	0.00	2025-10-19 02:29:42.475445	2025-10-19 02:29:42.475445
9c87bcbb-2ca2-45c9-b26a-678999a776e8	PONQUESITO MIX NAVIDEÑO X12UNID 228GR	7705326725141	t	13000.00	12800.00	\N	\N	19.00	2025-10-19 02:29:42.475935	2025-10-19 02:29:42.475935
8d584c03-8d3e-435b-abc9-4957c3287a6e	SCOTT 2 EN 1 X4UNID	7702425995734	t	5400.00	5200.00	\N	\N	19.00	2025-10-19 02:29:42.476299	2025-10-19 02:29:42.476299
7c580e8c-1e1f-434a-9105-4ed9382bf9e6	SPAGHETTI DORIA 1.000GR CON SAZONADOR	7702085006054	t	6600.00	6500.00	\N	\N	5.00	2025-10-19 02:29:42.476583	2025-10-19 02:29:42.476583
e8ad0bfc-04ea-4b6a-aa91-8e5036d4dbbe	AZUCAR SAMARA 2.500GR	7709531779586	t	9400.00	\N	\N	\N	5.00	2025-10-19 02:29:42.476855	2025-10-19 02:29:42.476855
b911afa4-e06e-49a5-bb66-f9d3deecd90c	ARROZ PROVICIA 1.000GR	614143317750	t	3700.00	3600.00	\N	\N	0.00	2025-10-19 02:29:42.477263	2025-10-19 02:29:42.477263
e85fcb3d-cf8b-46ac-8882-f0b75bf1c570	ACEITE  SOYA ISA 430ML	764451916685	t	3400.00	3209.00	\N	\N	0.00	2025-10-19 02:29:42.477521	2025-10-19 02:29:42.477521
c4cbad5c-bfd1-451a-953d-e0b9ba017997	ACEITE SOYA ISA 3.000ML	764451916777	t	21800.00	21000.00	\N	\N	0.00	2025-10-19 02:29:42.477787	2025-10-19 02:29:42.477787
ea79a76f-50a3-4843-989e-ddd12e2d41da	CHOCOLATE CORONA TRADICIONAL 450GR	7702007084535	t	15400.00	\N	\N	\N	5.00	2025-10-19 02:29:42.47803	2025-10-19 02:29:42.47803
49327ab1-4281-4e73-a108-1cc666505f0c	SPEED MAX 310ML	7702090071849	t	1800.00	1604.00	\N	\N	19.00	2025-10-19 02:29:42.478285	2025-10-19 02:29:42.478285
516d6dea-76d3-4d7d-9cce-14e03418fc9f	BOMBILLO MERCURY 9W	7707692866008	t	2800.00	2600.00	\N	\N	0.00	2025-10-19 02:29:42.478531	2025-10-19 02:29:42.478531
b20ea353-1a39-4fd6-b79b-4afa57eb76b4	BOMBILLO MERCURY 12W	7707692862161	t	4000.00	3900.00	\N	\N	0.00	2025-10-19 02:29:42.478814	2025-10-19 02:29:42.478814
6219f5be-e681-4051-9374-f6e5dbdbf077	BOMBILLO MERCURY 15W	7707692861553	t	5200.00	5100.00	\N	\N	0.00	2025-10-19 02:29:42.47915	2025-10-19 02:29:42.47915
e5754cf8-3028-455f-97db-04fa9f59b2d8	ESPUMA DE AFEITAR FULL X 200ML	7702856979235	t	9800.00	9600.00	\N	\N	0.00	2025-10-19 02:29:42.479559	2025-10-19 02:29:42.479559
5067974c-2ff8-4cd2-94e8-c266e6fda70b	COCO VARELA 180GR	7702191163726	t	2800.00	2650.00	\N	\N	19.00	2025-10-19 02:29:42.479807	2025-10-19 02:29:42.479807
d750e473-78de-4633-9dcf-972cff6cfed0	VASOS VBC 1Z X50UNID	7708932029863	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:42.480043	2025-10-19 02:29:42.480043
62cd434d-5d79-4404-8ee6-78bb666dc8c9	DESENGRASANTE IDEAL 500ML	7709997736109	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:42.480289	2025-10-19 02:29:42.480289
ef159d59-bf66-4bf5-92e1-5a5784333142	LAVALOZA LIQUIDO IDEAL 500ML	7709997101709	t	2600.00	2500.00	\N	\N	19.00	2025-10-19 02:29:42.480534	2025-10-19 02:29:42.480534
a8a250c3-6546-4052-bad9-43a38abc244b	CUCHARA SURAPLAS X100UNID	7709693020915	t	4600.00	4400.00	\N	\N	0.00	2025-10-19 02:29:42.480741	2025-10-19 02:29:42.480741
7afa458e-4dde-43de-b251-19d0556a27f2	TENEDOR SURAPLAS X100UNID	7709693020991	t	4600.00	4400.00	\N	\N	0.00	2025-10-19 02:29:42.481	2025-10-19 02:29:42.481
25b297c6-e486-438e-88c9-878ee8e16f9b	CREMA DENTAL COLGATE BATMAN 75ML	7705790022906	t	8800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.481266	2025-10-19 02:29:42.481266
b312a0ba-ca2c-4004-ab15-c20c69e8cacd	CHOCOLATE CORONA INSTANTANEO CLAVOS Y CANELA 950GR	7702007083118	t	33500.00	32700.00	\N	\N	0.00	2025-10-19 02:29:42.481516	2025-10-19 02:29:42.481516
fc8d4dc0-a2b6-4650-8c3e-c13f1cb763db	BIO MASCARILLA CAPILAR KABA 500ML	7708382645972	t	39500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.48178	2025-10-19 02:29:42.48178
d89d1a37-284c-403f-bc33-290226f817f7	MISTOLIN 500ML	MISTOLSS	t	1800.00	1700.00	\N	\N	0.00	2025-10-19 02:29:42.482013	2025-10-19 02:29:42.482013
9c671b85-f645-4fe7-9cfd-335f9a7609c6	MISTOLIN IN 500ML	7701019910092	t	1800.00	1700.00	\N	\N	0.00	2025-10-19 02:29:42.482433	2025-10-19 02:29:42.482433
4af0d5cf-2d35-4d8e-ae45-e928461e336c	DESINFECTANTE DE INODOROS FULL FRESH 500ML	7702856974308	t	8600.00	8400.00	\N	\N	0.00	2025-10-19 02:29:42.482786	2025-10-19 02:29:42.482786
3d6d9ccf-3a84-4f3d-bb7b-19af0ad04dab	MASA PASABOCAS EL REY X15UNID 210GR	MASA	t	2100.00	2000.00	\N	\N	0.00	2025-10-19 02:29:42.483208	2025-10-19 02:29:42.483208
177c5f6f-c071-40d3-a48f-19e0ff842d63	CHOCOLISTO BOLSA 1.500GR	7702007216226	t	40500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.483669	2025-10-19 02:29:42.483669
6b2885e6-c7d5-4025-b576-06e763916371	CEPILLO COLGATE ENCIAS X3UNID	7509546669472	t	23800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.484089	2025-10-19 02:29:42.484089
e860c353-8355-4613-9671-6207169e1d78	EMBOPLAS TRANSPARENTE 200M	EMBOPLA	t	5800.00	5600.00	\N	\N	0.00	2025-10-19 02:29:42.484392	2025-10-19 02:29:42.484392
94c50307-d18c-4061-9354-2724a241197c	CHOCOLATE CORONA TRADICIONAL 200GR	7702007085471	t	8700.00	8550.00	\N	\N	5.00	2025-10-19 02:29:42.484709	2025-10-19 02:29:42.484709
0af26512-e1c2-4a19-b163-b2885c19f447	AROMATEL FLORAL 4LITROS	7702191164129	t	30000.00	29400.00	\N	\N	19.00	2025-10-19 02:29:42.485095	2025-10-19 02:29:42.485095
15d5a8a4-5bb8-4c1e-83ff-81e5d39a119d	PAPEL EXPERT X4UNID	7702026154967	t	11200.00	10800.00	\N	\N	19.00	2025-10-19 02:29:42.48543	2025-10-19 02:29:42.48543
392b2a43-43c3-4f60-9e49-c5608066b222	CHOCOLATE QUESADA CLAVOS Y CANELA 200GR	7702088214784	t	7000.00	6850.00	\N	\N	5.00	2025-10-19 02:29:42.485861	2025-10-19 02:29:42.485861
b8683871-1c28-4d51-a918-6c23695e1842	CHOCOLATE QUESADA VAINILLA 200GR	7702088214777	t	7000.00	6850.00	\N	\N	5.00	2025-10-19 02:29:42.486264	2025-10-19 02:29:42.486264
8109f171-75f2-4a42-b5ab-fb78e1378afe	CREMA DE ARROZ POLLY 900GR	7591112004039	t	9400.00	9100.00	\N	\N	0.00	2025-10-19 02:29:42.486731	2025-10-19 02:29:42.486731
e8897a72-a6b4-420b-abaf-f7bc3b15fe72	PAN PERRO BIMBO SUPER X10UNID	7705326072511	t	11000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.487321	2025-10-19 02:29:42.487321
607a6c70-56c7-4c3e-8f49-a760f13edce5	ACEITE LA PERLA NORTE 1 LITRO	7708141784713	t	6600.00	6250.00	\N	\N	0.00	2025-10-19 02:29:42.487748	2025-10-19 02:29:42.487748
58db0099-cd2f-4561-bfb2-796cc10b1bd3	ALUMINIO GOLDENWARP 40M	7707339930833	t	10200.00	9850.00	\N	\N	19.00	2025-10-19 02:29:42.488116	2025-10-19 02:29:42.488116
eab59dc1-3925-4ff7-a6db-da441d0593d8	DE TODITO NATURAL BOLSAZA 80GR	7702189058065	t	4200.00	4000.00	3900.00	\N	19.00	2025-10-19 02:29:42.488467	2025-10-19 02:29:42.488467
5a2c15fe-9a4b-4eeb-8f7e-5b768d188c9a	PAPAS MARGARITA ONDULADAS TOMATE 105GR	7702189053848	t	6600.00	6500.00	6400.00	\N	19.00	2025-10-19 02:29:42.488796	2025-10-19 02:29:42.488796
e488b023-2f21-480a-847f-481bd2b00623	DORITOS PIZZA 41GR	7702189059796	t	2600.00	2500.00	2390.00	\N	19.00	2025-10-19 02:29:42.489129	2025-10-19 02:29:42.489129
9e567301-f6c5-4e84-a48b-48b17b8849e6	CEPILLO DORCO MAS PROTECTOR	6928158586310	t	3000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.489493	2025-10-19 02:29:42.489493
f5a9a31f-7896-4ab5-b24c-03d592bb07cb	WAFER XL 77 100GR	8681863042141	t	1200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.489821	2025-10-19 02:29:42.489821
91546a16-f002-46a3-8881-9377b0be727a	DERSA MANZANA VERDE 125GR	7702166002463	t	1400.00	1350.00	\N	\N	19.00	2025-10-19 02:29:42.490174	2025-10-19 02:29:42.490174
cd061c98-625f-4d03-a2f4-0abbc4e8d75f	DERSA MANZANA VERDE 250GR	7702166002456	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:42.490514	2025-10-19 02:29:42.490514
c618fcdb-76c4-4c5a-ae33-7c0b33efab23	VELON SANTA MARIA 5	7707297960019	t	3400.00	3250.00	\N	\N	0.00	2025-10-19 02:29:42.490953	2025-10-19 02:29:42.490953
741a9f4e-4521-4197-994b-a8e1f6dda048	DONKAN CACHORRO 800GR	7702084000145	t	6000.00	5800.00	\N	\N	5.00	2025-10-19 02:29:42.491331	2025-10-19 02:29:42.491331
c7a146a2-8b32-48e6-ba2e-cb3bf9dd7f6f	DONKAN ADULTOS 800GR	7702084000138	t	5600.00	5400.00	\N	\N	5.00	2025-10-19 02:29:42.4919	2025-10-19 02:29:42.4919
da898391-af45-4057-ae7b-51c9518097f2	AZUL KLEAN VAINILLA BAMBU 980ML	7702310042666	t	5200.00	5000.00	\N	\N	19.00	2025-10-19 02:29:42.492399	2025-10-19 02:29:42.492399
75afb5ff-c383-4f3c-bf30-3d59b658c39e	AZUL KLEAN ORQUIDEAS EXOTICAS 980ML	7702310042673	t	5200.00	5000.00	\N	\N	19.00	2025-10-19 02:29:42.492982	2025-10-19 02:29:42.492982
bd687d29-b3be-48a1-a22b-064aa5182f32	COPITOS CORONA 300UNID	7453010007751	t	5800.00	5650.00	\N	\N	0.00	2025-10-19 02:29:42.493514	2025-10-19 02:29:42.493514
e05ccf67-6737-4df1-b72e-0a026adc4367	SHAMPOO SAVITAL ANTICASPA 510ML MAS 350ML	7702006653244	t	20000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.493891	2025-10-19 02:29:42.493891
185852cd-61e6-490a-9d11-d81376195436	ALUMINIO TU GO IDEALTEX 100MT	ALUMIN	t	18000.00	17000.00	\N	\N	19.00	2025-10-19 02:29:42.494269	2025-10-19 02:29:42.494269
4dbb259a-c63b-4e0d-acb9-f7df97bc609c	PALILLOS EL SOL POTE 250UNID	7707015506451	t	2200.00	2040.00	\N	\N	19.00	2025-10-19 02:29:42.494562	2025-10-19 02:29:42.494562
74450946-85de-4532-9d24-909d07afe1fd	VASOS CARTON 6ONZ IDEALTEX X50UNID	7702023110324	t	4100.00	3950.00	\N	\N	19.00	2025-10-19 02:29:42.49496	2025-10-19 02:29:42.49496
622b8946-1767-47b3-9f79-9a21a9a8fec0	BOCADILLO LONJA AGUILA 250GR	7706606000545	t	1800.00	1700.00	\N	\N	0.00	2025-10-19 02:29:42.495308	2025-10-19 02:29:42.495308
311d5cc7-f961-4f9d-8ac3-a4881ef9b8ee	JUGO NECTAR CALIFORNIA PERA 300ML	7702617487382	t	2700.00	2460.00	\N	\N	19.00	2025-10-19 02:29:42.495649	2025-10-19 02:29:42.495649
85009731-7f78-45e6-bdce-21b9b0f4798f	JUGO NECTAR MANZANA 30ML	7702617487368	t	2700.00	2460.00	\N	\N	19.00	2025-10-19 02:29:42.495939	2025-10-19 02:29:42.495939
f3cd96dd-614f-4881-af44-c81469ce1b70	COLCAFE GRANIZADO 320GR	7702032119608	t	14800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.49628	2025-10-19 02:29:42.49628
d63e8445-80a4-4582-8643-1f3e10284083	TRATAMIENTO DOVE HIDRATACION 300GR	7702006653435	t	16500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.496566	2025-10-19 02:29:42.496566
089bd151-da9d-4b76-bd36-c3d7d9397092	CAFE SELLO ROJO 850 MAS 125GR MAS TAZA	7703036719108	t	36500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.496825	2025-10-19 02:29:42.496825
5c6d5784-283f-4779-b3f7-46f0fd6a0799	BALDE MODERNO 11LT	1	t	5500.00	5200.00	\N	\N	0.00	2025-10-19 02:29:42.497112	2025-10-19 02:29:42.497112
9a162e9c-de60-465d-ba8c-868fdba42689	RASTRILLO 16 DIENTES	RAST	t	4900.00	4750.00	\N	\N	0.00	2025-10-19 02:29:42.497386	2025-10-19 02:29:42.497386
b032a943-e0c4-41d2-a214-660613200fff	CEPILLO BAÑO OSBE CON COPA	CEPIL	t	4300.00	4100.00	\N	\N	19.00	2025-10-19 02:29:42.497656	2025-10-19 02:29:42.497656
6edb89de-2dbb-4480-940d-da1ec2e04428	NESTUM 5 CEREALES 350GR	7613033972720	t	22000.00	21500.00	\N	\N	19.00	2025-10-19 02:29:42.4979	2025-10-19 02:29:42.4979
0674131f-93c7-4cf2-9c03-aaa9a9201146	COLONIA MENNEN 50ML	COLONI	t	2500.00	2200.00	\N	\N	0.00	2025-10-19 02:29:42.498122	2025-10-19 02:29:42.498122
61c2c75c-626d-4eef-8d28-688e21cfe473	PRESTOBARBA SCHICK XTREME AZUL X12UNID	PRES	t	33500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.498409	2025-10-19 02:29:42.498409
49493358-2077-4122-b7bf-18e22f15464e	PAÑITOS HUGGIES PROTECCION X80UNID	7702425805187	t	4500.00	4300.00	\N	\N	0.00	2025-10-19 02:29:42.498649	2025-10-19 02:29:42.498649
f01f286f-97f2-4055-bace-800ebc0587d4	SALTIN NOEL 2 TACOS MENOS SODIO	7702025150946	t	4000.00	3850.00	\N	\N	19.00	2025-10-19 02:29:42.498869	2025-10-19 02:29:42.498869
c312c637-9ddb-4e15-ab94-66adb21c3608	KOTEX DISCRETA X10UNID	7702425801288	t	3600.00	3400.00	\N	\N	0.00	2025-10-19 02:29:42.499077	2025-10-19 02:29:42.499077
823c3072-1dcf-4b00-adef-c02268af3800	BANIRE AUTOMATICO SPRAY VAINILLA	7702532911672	t	34000.00	33000.00	\N	\N	19.00	2025-10-19 02:29:42.499291	2025-10-19 02:29:42.499291
c03ee7c4-a1f6-4722-a427-2f46f875b0ba	DESODORANTE DOVE ORIGINAL 150ML	7506306220089	t	15000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.499523	2025-10-19 02:29:42.499523
92d7ea28-6c72-4726-a19e-1bd4e12b74c1	MOPA TRAPERO MANA REF 1000	7707925742819	t	6800.00	6500.00	\N	\N	0.00	2025-10-19 02:29:42.499728	2025-10-19 02:29:42.499728
80a6e640-0ef0-4b89-b626-bafa6930d31d	MOPA TRAPERO MANA LIBRA LIBRA	7707925752795	t	5500.00	5350.00	\N	\N	0.00	2025-10-19 02:29:42.499943	2025-10-19 02:29:42.499943
9b4abaee-c53a-4848-8600-41b743c734e7	MOPA TRAPERO MANA MEGA ESPECIAL	7707925782792	t	4800.00	4600.00	\N	\N	0.00	2025-10-19 02:29:42.500333	2025-10-19 02:29:42.500333
dbb97219-3429-48f1-a2d2-2bca0c142e9a	MOPA TRAPERO MANA MEGA 500	MOPA TRAPEO	t	4000.00	3800.00	\N	\N	0.00	2025-10-19 02:29:42.500672	2025-10-19 02:29:42.500672
d05ec07e-932d-48db-ac42-cea5312d0562	MOPA TRAPERO MANA NEGRO ROJO MEGA 500	MOPAS	t	4200.00	4080.00	\N	\N	0.00	2025-10-19 02:29:42.500989	2025-10-19 02:29:42.500989
49ea51d5-177b-4d62-a38d-ac747c0478dc	CHOCOLISTO CHOCOLATE 1.000GR	7702007085914	t	32500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.501217	2025-10-19 02:29:42.501217
e1cd81f5-2b3d-444e-88a8-d606801f0f3a	FLUO CARDENT 36GR	7702560042416	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.501435	2025-10-19 02:29:42.501435
fb75c443-e604-48f4-a96a-05528b42435b	ARROZ PALACIO 5.000GR	7709241447720	t	17000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.501691	2025-10-19 02:29:42.501691
f26ec4b1-e1e0-4e82-9697-b0cbf4fe7f90	ARROZ PALACIO 2.500GR	7709241447737	t	8500.00	8300.00	\N	\N	0.00	2025-10-19 02:29:42.501921	2025-10-19 02:29:42.501921
5f40afd6-5fcd-4470-b63d-f63d00124e22	CHORIZO PAISA	CHORIZOZZ	t	6300.00	6200.00	\N	\N	0.00	2025-10-19 02:29:42.502152	2025-10-19 02:29:42.502152
fec0f249-39b6-4e86-b1de-18672b15acb9	CHORIZO AVICAMPO POLLO X10UNID	CHORIZOZ	t	19800.00	\N	\N	\N	0.00	2025-10-19 02:29:42.502374	2025-10-19 02:29:42.502374
d94c16bf-0dae-4279-a16e-e5b74939ed4b	CAFE INTENSO TROPICO 400GR	7707172846759	t	16200.00	15600.00	\N	\N	0.00	2025-10-19 02:29:42.502595	2025-10-19 02:29:42.502595
28c3bf14-ff2c-451c-89cd-0d880457f9ff	GELATINA SIN SABOR FRUTY FRESH 250GR	7709989481420	t	12500.00	12000.00	\N	\N	0.00	2025-10-19 02:29:42.502797	2025-10-19 02:29:42.502797
b3c7fd51-8868-48e7-bf4e-8a5c1c24512b	JARABE ACETAMINOFEN AG 90ML	7706569001436	t	3200.00	3000.00	\N	\N	0.00	2025-10-19 02:29:42.503022	2025-10-19 02:29:42.503022
32acc741-9970-4fc3-8b9c-4803262a419d	BRILLO FRELOZA X12UNID	7709324088925	t	2100.00	2000.00	\N	\N	0.00	2025-10-19 02:29:42.503285	2025-10-19 02:29:42.503285
5ec4d3af-2e77-4e27-8605-ddea992a3b55	LAVA PLATOS LA JOYA LIMON 990GR	7702088210823	t	5900.00	5750.00	\N	\N	19.00	2025-10-19 02:29:42.503539	2025-10-19 02:29:42.503539
2376eadf-8222-478e-8c11-29e32f9c8fec	TALCO YODORA 300GR MAS 90GR	7702057082178	t	27500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.503835	2025-10-19 02:29:42.503835
5f99ca76-5e54-4ae2-987f-a38cdacc1012	GALLETA DUX SALADITAS 8GR	7702025150854	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.504087	2025-10-19 02:29:42.504087
49e8abbf-280e-4f78-b136-7a862e3e56d8	SALTIN NOEL WAFER VAINILLA 18X4	7702025186440	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.504317	2025-10-19 02:29:42.504317
26e50626-50f7-4ff2-ba79-e556950fcbe5	SHAMPOO SOVE LAGO FORTALECIDO 400ML	7891150064881	t	20000.00	19500.00	\N	\N	19.00	2025-10-19 02:29:42.504557	2025-10-19 02:29:42.504557
36dd8055-7b27-4f76-83df-512ea4e93310	TRULULU SABORES CRUNCHY X12 UNID	7702993055922	t	10200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.504801	2025-10-19 02:29:42.504801
ce443e42-9aa8-482c-827c-f08bfcf24a14	LOKIÑO MINI FRUTAL X12UNID	7702993045855	t	10300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.505043	2025-10-19 02:29:42.505043
4c6985d1-dce9-4e50-9194-12bf1503a1ab	TRULULU CHOCOLORES X12UNID 360GR	7702993044094	t	19000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.50526	2025-10-19 02:29:42.50526
fee57946-3733-48a3-8976-974883f80d67	QUITA MANCHAS LIMPIA YA 1L	7702037913454	t	4700.00	4550.00	\N	\N	19.00	2025-10-19 02:29:42.505505	2025-10-19 02:29:42.505505
8b4b4827-67eb-4e61-bca7-64c671d6eea1	CANELA ESTILLA EL REY 11GR	7702175111170	t	2400.00	2250.00	\N	\N	19.00	2025-10-19 02:29:42.50572	2025-10-19 02:29:42.50572
2525003c-dfd3-4756-8e04-55f0e2719db9	RECOJEDO CON BANDA	RECOJEOR	t	3900.00	3650.00	\N	\N	0.00	2025-10-19 02:29:42.506038	2025-10-19 02:29:42.506038
a64daf8a-32a8-48a2-879a-1745f8c4661a	SUEROX 5 IONES  FRUTOS ROJOS 630ML	650240070938	t	7300.00	7000.00	\N	\N	0.00	2025-10-19 02:29:42.50644	2025-10-19 02:29:42.50644
4d86dfd0-c1da-469d-bbec-947f0bd35afd	SUEROX 5 IONES MORA AZUL HIERBABUENA 630ML	650240070914	t	7300.00	7000.00	\N	\N	0.00	2025-10-19 02:29:42.506675	2025-10-19 02:29:42.506675
c9af2071-ceef-4c73-810a-37253807c557	SUEROX 5 IONES FRESA KIWI 630ML	650240070891	t	7300.00	7000.00	\N	\N	0.00	2025-10-19 02:29:42.506926	2025-10-19 02:29:42.506926
b684b696-0b7a-4db9-b57e-f70fbf332bc5	PAÑITOS PINTO MICROFIBRA X6UNID	PAÑITO	t	19500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.507211	2025-10-19 02:29:42.507211
84318eab-ae8b-4493-b01e-fe2f53ab491a	JABON LIQUIDO FULL FRESH BARRA AZUL 2L	7702856925829	t	15000.00	14800.00	\N	\N	19.00	2025-10-19 02:29:42.507417	2025-10-19 02:29:42.507417
24ffcf89-d769-469b-90a2-f12a09603d8c	JUGO NUTIVA UFRES X6UNID	0117708661161039	t	4500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.507673	2025-10-19 02:29:42.507673
8bba5da6-546d-4d9d-8e22-20feabf6be30	TOMATE IDEAL 90GR	7708276981414	t	1100.00	1025.00	\N	\N	0.00	2025-10-19 02:29:42.507905	2025-10-19 02:29:42.507905
9ec25da7-fe72-4d7d-a41b-46be0b8b650b	SALSA ROSADA IDEAL 90GR	7709640614259	t	1500.00	1417.00	\N	\N	0.00	2025-10-19 02:29:42.508151	2025-10-19 02:29:42.508151
d8956259-248b-4ef2-a11c-55be88272af2	COMINO EL CHINO 25GR	7707057300710	t	2000.00	1850.00	\N	\N	0.00	2025-10-19 02:29:42.508379	2025-10-19 02:29:42.508379
293eeb4c-15f1-4ca1-a037-96b3ff402f07	FRIJOL BODEGA BOGOTA 460GR	7707193910293	t	5200.00	5000.00	\N	\N	0.00	2025-10-19 02:29:42.508638	2025-10-19 02:29:42.508638
4a223000-955d-4938-a118-efb8cd07e5ba	SHAMPOO HEAD SHOULDERS ANTICOMESON 375M 180M	7500435247771	t	28800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.508955	2025-10-19 02:29:42.508955
e2d443c8-f496-4a97-8d77-bb98bcd25cb7	FLUO CARDENT 50 ML MAS 22ML	7702560050008	t	3400.00	\N	\N	\N	0.00	2025-10-19 02:29:42.509263	2025-10-19 02:29:42.509263
b640cf3c-c38d-4f28-ae60-0049b8aac76e	ENCENDEDOR SWISS LITE JETT SOPLETE	7707822755370	t	8300.00	8200.00	\N	\N	0.00	2025-10-19 02:29:42.509497	2025-10-19 02:29:42.509497
3a907bc4-f0d2-4682-a0b6-6e0c68ef8733	SUNTEA FUSION DE FRUTAS 12GR	7702354955441	t	1500.00	1325.00	\N	\N	19.00	2025-10-19 02:29:42.509825	2025-10-19 02:29:42.509825
e0d09c49-cae3-42b1-bdb9-9bdcf2535884	PALMOLIVE NUTRICION RENOVADORA 110GR	7509546683652	t	2800.00	2700.00	\N	\N	19.00	2025-10-19 02:29:42.510104	2025-10-19 02:29:42.510104
e948f548-505c-4c3c-b930-8311a569e830	TOALLA COSINA FAMILIA GREEN DIA DIA 70 HOJA	7702026155179	t	2100.00	1950.00	\N	\N	19.00	2025-10-19 02:29:42.510422	2025-10-19 02:29:42.510422
913205ce-710e-4e81-bfd9-672f89c7fdf4	MAYONESA NATUCAMPO CLASICA 200GR	7709197690034	t	4500.00	4370.00	\N	\N	19.00	2025-10-19 02:29:42.510714	2025-10-19 02:29:42.510714
4c7ac610-8e38-4356-8a0f-f778bb846cc2	AGOGO ATOMO SURTIDO 60UNID	7703888601811	t	7200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.511033	2025-10-19 02:29:42.511033
35c63afa-0e77-4083-bbf6-d75494b9c0f2	PIAZZA NUCITA BARQUILLO X12UNID	7702011071910	t	7900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.511314	2025-10-19 02:29:42.511314
d0b044d5-0001-4b31-bf3c-001944b9f809	CAFE AROMA 1.000GR	7702088216214	t	35900.00	35100.00	\N	\N	5.00	2025-10-19 02:29:42.511597	2025-10-19 02:29:42.511597
448e4077-5f31-42a5-8006-f640fd5d6b7d	MOSTANEZA DEL RANCHO LA CONSTANCIA 190GR	7702097137784	t	7200.00	6950.00	\N	\N	19.00	2025-10-19 02:29:42.511866	2025-10-19 02:29:42.511866
d02cbf2c-6f7c-4338-92a8-f22f999ad002	CHOCOLATE 3 ESTRELLAS TRADICIONAL 500GR	7704781102252	t	6200.00	6000.00	\N	\N	5.00	2025-10-19 02:29:42.512133	2025-10-19 02:29:42.512133
b58c20a2-651d-4b33-87b6-eee47b3f0ec4	DETERGENTE 3D 5K BICARBONATO	7702191452073	t	37500.00	37000.00	\N	\N	19.00	2025-10-19 02:29:42.512644	2025-10-19 02:29:42.512644
917cc668-7885-4e8a-9d8f-2f1458c83583	AZUCARADITA HOLA DIA 250GR	7709990071283	t	3500.00	3350.00	\N	\N	0.00	2025-10-19 02:29:42.51314	2025-10-19 02:29:42.51314
e78a3956-8bbe-4be8-b3fd-c1edcdf53523	FRUTY AROS HOLA DIA 250GR	7709990548228	t	4200.00	4060.00	\N	\N	0.00	2025-10-19 02:29:42.513599	2025-10-19 02:29:42.513599
53f29899-2164-4cd9-ab04-ac7adb792da8	BOCADILLO LONJA TRICOLOR 350GR	7707320550545	t	3800.00	3680.00	\N	\N	0.00	2025-10-19 02:29:42.513979	2025-10-19 02:29:42.513979
0c1aacef-8e0e-4728-9584-234df99549a4	CEPILLO COLGATE DURO CLEAN EXTRA  X2	7509546031828	t	9500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.514548	2025-10-19 02:29:42.514548
4ed45bbe-7fb3-4ef8-a49e-d4e1bc055b4b	CEPILLO COLGATE PROCUIDADO SUAVE X4UNID	7509546074313	t	23200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.514865	2025-10-19 02:29:42.514865
bd77a65f-cf39-4f1c-913f-57015f76f19a	JABON BABY DOVE HUMECTACION ENSIBLE 75GR	7891150025998	t	4800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.515308	2025-10-19 02:29:42.515308
44835c37-1ca4-42b5-ba15-38cab6b86f9b	CEPILLO COLGATE NIÑOS MAS 2	7793100151224	t	2600.00	2450.00	\N	\N	19.00	2025-10-19 02:29:42.515603	2025-10-19 02:29:42.515603
07f5dddc-a211-4994-b0a0-e823a0be296d	COLCAFE AMARETTO 50GR	7702032119042	t	8600.00	8330.00	\N	\N	5.00	2025-10-19 02:29:42.515941	2025-10-19 02:29:42.515941
eef06a8c-078d-4885-a1ba-85b43101e28a	CEPILLO ORAL PLUS 400 MEDIA X3	7708682913375	t	10700.00	10300.00	\N	\N	19.00	2025-10-19 02:29:42.516253	2025-10-19 02:29:42.516253
e705e74e-b3cc-44b4-9107-4f94e7bc99cd	CEPILLO ORAL PLUS 400 MEDIA X5UNID	7708682913412	t	16800.00	16100.00	\N	\N	19.00	2025-10-19 02:29:42.516574	2025-10-19 02:29:42.516574
a0214d44-a005-4375-912f-49fd7a04e28d	SHAMPOO SEDAL KERATINA ANTIOXIDANT 650ML	7506306233164	t	25700.00	25000.00	\N	\N	19.00	2025-10-19 02:29:42.516925	2025-10-19 02:29:42.516925
ddc5dbd0-dbf2-477f-9ec5-1d11149cfdd6	SHAMPOO SEDAL CERAMIDAS 650ML	7702006910576	t	26400.00	25800.00	\N	\N	19.00	2025-10-19 02:29:42.517234	2025-10-19 02:29:42.517234
5c25ac3b-4384-4364-a87f-2651a68af336	SHAMPOO SEDAL CERAMIDAS 340ML	7506306237315	t	16000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.51755	2025-10-19 02:29:42.51755
d1770331-caec-488c-b52d-f13f3621655e	CREMA DE PEINA SEDAL KERATINA ANTIOXIDANTE 300ML	7506306233249	t	16000.00	15500.00	\N	\N	19.00	2025-10-19 02:29:42.51812	2025-10-19 02:29:42.51812
3044bab6-353d-4b67-9c30-725ed4618bb1	CREMA DE PEINAR SEDAL CELULAS MADRES 300ML	7702006301565	t	16000.00	15500.00	\N	\N	19.00	2025-10-19 02:29:42.518589	2025-10-19 02:29:42.518589
5d3fbf19-8317-41ed-b8b6-61c15942f401	KIT DE ORTODONCIA CIAJERON COMPLETO ORAL PLUS	7708682913290	t	24000.00	23100.00	\N	\N	19.00	2025-10-19 02:29:42.51898	2025-10-19 02:29:42.51898
5aa93012-2e24-4237-be11-98fff70ee30e	TRATAMIENTO SAVITAL NUTRICION AVANZADA 33ML	7702006406659	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.519345	2025-10-19 02:29:42.519345
981ed0f2-bddf-48b9-b027-202ac061c75e	CLORO HIPERCLORO 1 LITRO	CLOR	t	2700.00	2570.00	\N	\N	19.00	2025-10-19 02:29:42.519839	2025-10-19 02:29:42.519839
cf956225-620a-4570-ac20-db750ff36dc8	LAVALOZA MI DIA LIMON 3K	7700149152969	t	20000.00	19600.00	\N	\N	19.00	2025-10-19 02:29:42.520258	2025-10-19 02:29:42.520258
e429d540-903c-4557-b4a2-6ca0579df194	ENJUAGUE BUCAL ORAL B 500ML LIMPIEZA PROFUNDA 4 EN 1	7501086453016	t	15000.00	14400.00	\N	\N	0.00	2025-10-19 02:29:42.520609	2025-10-19 02:29:42.520609
a1c2b636-d847-4985-a944-ad7047b5ef3a	ESPONJA LUBA X2UNID	7460000080106	t	1100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.520962	2025-10-19 02:29:42.520962
519c41f7-be74-41fd-b53b-61f43d6d41c7	LOKIÑO MINIS FRUTOS ROJOS X12UNID	7702993046425	t	10300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.521383	2025-10-19 02:29:42.521383
da824114-f448-46be-8393-20b97556fe37	DORITOS FLAMIN HOT 175GR	7702189055842	t	7600.00	7400.00	\N	\N	19.00	2025-10-19 02:29:42.521652	2025-10-19 02:29:42.521652
3b2d2c8c-cc24-482b-8bea-e1ac83dd5267	SALMON NAGUARA SALSA ITALIANA	SLAMON	t	2200.00	2100.00	\N	\N	0.00	2025-10-19 02:29:42.521949	2025-10-19 02:29:42.521949
46cafe37-93d2-4d7c-8afc-7ed15bd9a1a2	OREO GALLETA X10	OREO	t	9400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.522305	2025-10-19 02:29:42.522305
4e8d41ae-8201-4d76-b385-2812e585e4a9	AREQUIPE CELEMA 250GR	7705436043166	t	5400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.522642	2025-10-19 02:29:42.522642
f29f546c-54c0-44ba-9d41-02825eefb568	CREMA DE LECHE CELEMA 200ML	7705436030265	t	2700.00	2600.00	\N	\N	0.00	2025-10-19 02:29:42.522995	2025-10-19 02:29:42.522995
62e7290b-f576-40fc-8270-381ab7939dca	LECHE CELEMA CAJA 900ML	7705436011974	t	4500.00	4300.00	\N	\N	0.00	2025-10-19 02:29:42.523323	2025-10-19 02:29:42.523323
8421905d-75c1-4fe6-a241-6af0bcd70189	LECHE SABORIZADA CELEMA 200ML FRESA	7705436062488	t	1600.00	1470.00	\N	\N	19.00	2025-10-19 02:29:42.523642	2025-10-19 02:29:42.523642
a0e18cd7-d952-4ff9-b0af-befa4c3376ca	NECTAR CELEMA DE PERA 200ML	7705436061351	t	1100.00	1000.00	\N	\N	19.00	2025-10-19 02:29:42.523985	2025-10-19 02:29:42.523985
aa62106b-8eea-44c4-8ccb-f20e2507b4cd	NECTAR CELEMA DE MANZANA 200ML	7705436061344	t	1100.00	1000.00	\N	\N	19.00	2025-10-19 02:29:42.524709	2025-10-19 02:29:42.524709
4bc56e16-d810-488e-9cd4-6a074969b9f2	LECHE SABORIZADA CELEMA AREQUIPE 200ML	7705436092379	t	1600.00	1470.00	\N	\N	19.00	2025-10-19 02:29:42.525136	2025-10-19 02:29:42.525136
d46bb7ce-b5cd-4910-9c61-0143624218df	SPEED STICK XTREME NIGHT GEL 70GR	7509546693149	t	11000.00	10600.00	\N	\N	19.00	2025-10-19 02:29:42.525444	2025-10-19 02:29:42.525444
7ed1c23e-c9e7-4411-8151-51d5c0478812	JUGO HIT MANGO 300ML	7707133074405	t	2000.00	1750.00	\N	\N	19.00	2025-10-19 02:29:42.525809	2025-10-19 02:29:42.525809
ddc539c8-6d37-4ed7-842e-c761882190ad	LINTERNA MINI VARTA RECARGABLE	7702094000180	t	16500.00	15600.00	\N	\N	19.00	2025-10-19 02:29:42.526185	2025-10-19 02:29:42.526185
551d1ba1-1844-4fca-99f0-81854e61a934	LINTERNA MINI VARTA RECARGABLE 7LED	7702094000036	t	22000.00	21400.00	\N	\N	19.00	2025-10-19 02:29:42.526484	2025-10-19 02:29:42.526484
8d6c47ba-3c31-4acb-a7f8-75b5f2264e00	DIOXOGEN JGB 120ML	7702560000027	t	5500.00	5200.00	\N	\N	0.00	2025-10-19 02:29:42.526782	2025-10-19 02:29:42.526782
ef69f0b5-5cd1-45c1-92a6-a34305f59016	FLIPS CHOCOLATE 400GR MAS 120GR	7702807705371	t	15600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.527169	2025-10-19 02:29:42.527169
d01e65bd-9bb1-4492-85a5-350f03616b8f	SPAGHETTI PAN 250GR	7702084900087	t	1800.00	1700.00	\N	\N	5.00	2025-10-19 02:29:42.52748	2025-10-19 02:29:42.52748
e6b61b46-dffc-4cf3-8d40-68662fe43921	PAÑITOS PEQUEÑIN ALOE 70UNI	7702026314415	t	10500.00	10200.00	\N	\N	19.00	2025-10-19 02:29:42.527784	2025-10-19 02:29:42.527784
4129eec6-739f-4aec-ac38-a1a344343ec0	MECHERA MGNIFICO CON LUZ X25 UNID	MECHE	t	13200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.528016	2025-10-19 02:29:42.528016
9c3213cb-a953-464d-a944-1c6f6f98911f	CREMA DE PEINAR SAVITAL COLAGENO 275ML	7702006299381	t	13000.00	12700.00	\N	\N	19.00	2025-10-19 02:29:42.528388	2025-10-19 02:29:42.528388
b8db2a6d-9f9f-4128-be15-229ac09cbe44	CREMA DE PEINAR SAVITAL SERUM DE AMINOACIDOS 275ML	7702006406468	t	13000.00	12700.00	\N	\N	19.00	2025-10-19 02:29:42.528701	2025-10-19 02:29:42.528701
f2f8d92d-9da3-4fa8-b8e2-a88e0e206c8b	LADY SPEED STICK CARBON ACTIVO 150ML	7509546688220	t	15500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.529355	2025-10-19 02:29:42.529355
e16d1b95-c80f-4bf8-afd6-5205ed9c8819	FRIJOL JR 460GR	7707171310350	t	4800.00	4700.00	\N	\N	0.00	2025-10-19 02:29:42.529805	2025-10-19 02:29:42.529805
1ffbf25f-1478-41af-9e4f-6ccc67e5355b	ACEITE ISA 1LITRO	764451916807	t	6100.00	5750.00	\N	\N	19.00	2025-10-19 02:29:42.530492	2025-10-19 02:29:42.530492
4ebe7a2b-a614-4c7d-b889-f7299320a1d8	COLCAFE SUAVE CLASICO X40UNID	7702032113088	t	11300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.531007	2025-10-19 02:29:42.531007
ad68f0fd-d868-468c-b6f6-1e57b49c6c67	MASMELO CRISMELO 75GR	760203006598	t	2900.00	2800.00	\N	\N	0.00	2025-10-19 02:29:42.531385	2025-10-19 02:29:42.531385
8a816ceb-865b-4100-9f9f-dc7cd07a54ca	TINTE LISSIA 6.45	7703819304941	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:42.531692	2025-10-19 02:29:42.531692
693fa30a-90e2-4d70-99cc-8cd25bf01fce	TINTE LISSIA 6.1	7703819301889	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:42.532047	2025-10-19 02:29:42.532047
86164ce4-a7b0-4ce1-badc-8575d117d9d0	TINTE LISSIA 8.0	7703819301872	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:42.532369	2025-10-19 02:29:42.532369
56c73f36-d6b8-4277-9ef8-f579e67484bf	TINTE LISSIA 7.1	7703819301896	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:42.532696	2025-10-19 02:29:42.532696
b4d704c3-bc74-46d2-b02b-6c3ceb3a1c70	TINTE LISSIA 7.0	7703819301865	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:42.533434	2025-10-19 02:29:42.533434
2f367cc0-65b5-4617-945b-cce98952b336	TINTE KERATON 9.0	7707230996204	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.533716	2025-10-19 02:29:42.533716
43508f24-325c-412f-bba0-5a346fd39a47	TINTE KERATON METALICO CENIZA	7707585182307	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.534042	2025-10-19 02:29:42.534042
22c83cb8-08aa-4c49-9e46-bbb822286473	TINTE KERATON METALICO VIOLETA	7707585180945	t	9500.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.534406	2025-10-19 02:29:42.534406
375a7edf-b2f6-4fa3-9ce1-fe9336edff57	COLGATE TOTAL 12 ANTI SARRO 75ML X3UNID	7509546691527	t	25300.00	\N	\N	\N	0.00	2025-10-19 02:29:42.534743	2025-10-19 02:29:42.534743
e459d2cb-3040-4800-9cc2-c13f7709bc5d	COLGATE TOTAL 12 CARBON ACTIVADO 75ML 3UNID	7509546683782	t	25300.00	\N	\N	\N	0.00	2025-10-19 02:29:42.535132	2025-10-19 02:29:42.535132
7f6ee1f2-f7b5-484f-a1a8-ef1620054e88	COLGATE TOTAL 12 PREVENCION ACTIVA 75ML X3UNID	7509546696287	t	25300.00	\N	\N	\N	0.00	2025-10-19 02:29:42.535569	2025-10-19 02:29:42.535569
690e894d-9484-40fa-9855-5e60eb1bb436	CHEESE TRIS BOLSAZA 120GR	7702189059864	t	4200.00	4000.00	3900.00	\N	19.00	2025-10-19 02:29:42.535935	2025-10-19 02:29:42.535935
0d805634-700b-4981-bcca-2a18aa995242	LECHE CONDENSADA TETERO LA SABANA 1.000GR	7707336380167	t	14700.00	14200.00	\N	\N	0.00	2025-10-19 02:29:42.536295	2025-10-19 02:29:42.536295
03569f27-bc57-4ccd-b306-8bfaef82ec1b	BIANCHI EN LINEA MANI X24UNID	7702993055588	t	9200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.536608	2025-10-19 02:29:42.536608
a61a7a29-90f5-4245-bc6c-144de79dd591	YODORA CREMA 32GR MAS 32GR	7702057082130	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.536971	2025-10-19 02:29:42.536971
e632869e-70b7-434e-827b-f5f30da3664f	DULCE DE TRACTOR JUGUETE	6914204014197	t	10000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.53737	2025-10-19 02:29:42.53737
86c829ed-8457-480f-930a-8535625863df	DINOSAURIO ALITAS JUGUETE	6914204014173	t	9400.00	\N	\N	\N	0.00	2025-10-19 02:29:42.537697	2025-10-19 02:29:42.537697
92a58d1a-ace8-4491-bb3d-20672921f25e	CEPILLO ORAL B AVANCE X5 PACK FAMILIAR	7506195178669	t	28000.00	27000.00	\N	\N	0.00	2025-10-19 02:29:42.538032	2025-10-19 02:29:42.538032
90af37af-9e5e-40b5-85a8-f95ab048fba1	PULPO REDONDO COLORES	PULPO	t	3000.00	2600.00	\N	\N	0.00	2025-10-19 02:29:42.538356	2025-10-19 02:29:42.538356
97cf8b7a-b635-4bda-8aca-a697544ee4fc	REPUESTO GLADE MANZANA CANELA 270ML	7501032904982	t	20700.00	20100.00	\N	\N	0.00	2025-10-19 02:29:42.538634	2025-10-19 02:29:42.538634
d2202620-a912-461b-9b59-4609a84fcd44	REPUESTO GLADE PARAISO AZUL 270ML	7501032906337	t	20700.00	20100.00	\N	\N	0.00	2025-10-19 02:29:42.538932	2025-10-19 02:29:42.538932
a32b63e4-66db-4f90-a338-917108576e26	REPUESTO GLADE HAWAIAN BREZE 270ML	7501032905002	t	20700.00	20100.00	\N	\N	0.00	2025-10-19 02:29:42.539248	2025-10-19 02:29:42.539248
5660ef89-72ef-4588-8915-5fd6c902b8c0	JABON JOHNSONS BABY CREMOSO 110GR	7702031401049	t	4900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.539527	2025-10-19 02:29:42.539527
71edfd7e-eaca-4829-8301-540ebb3df449	JABON JOHNSONS BABY CREMOSOS ORIGINAL 110GR	7702031401032	t	4900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.539844	2025-10-19 02:29:42.539844
b04267ac-18dc-4c67-9cf6-f1893368efb4	SHAMPOO ELVIVE LOREAL HIDRA HIALURONICO 680ML	7509552845891	t	29000.00	28000.00	\N	\N	19.00	2025-10-19 02:29:42.540189	2025-10-19 02:29:42.540189
a19a8890-fdf9-4870-8b46-a28dfdbd88b9	SHAMPOO ELVIVE LOREAL FREAM LONG 680ML	7509552836615	t	29000.00	28000.00	\N	\N	19.00	2025-10-19 02:29:42.540603	2025-10-19 02:29:42.540603
b47c2bba-13a6-4fa3-99e1-0ce7c8c36e42	SHAMPOO ELVIVE LOREAL GLYCOLIC 680ML	7509552928594	t	29000.00	28000.00	\N	\N	19.00	2025-10-19 02:29:42.540995	2025-10-19 02:29:42.540995
3033195c-24cc-410a-beec-3f847760a0d8	SHAMPOO PANTENE RESTAURACION 700ML	7500435114912	t	28000.00	27000.00	\N	\N	0.00	2025-10-19 02:29:42.541526	2025-10-19 02:29:42.541526
9dc85ffe-0a8e-4694-8d8e-86360c3b05de	SHAMPOO PANTENE BAMBU 750ML	7500435155854	t	28000.00	27000.00	\N	\N	0.00	2025-10-19 02:29:42.542008	2025-10-19 02:29:42.542008
63972123-3509-4bcc-8492-248dff3f45a6	SHAMPOO PANTENE RIZOS DEFINIDOS 200ML	7501001169091	t	12200.00	11800.00	\N	\N	19.00	2025-10-19 02:29:42.542563	2025-10-19 02:29:42.542563
82709df6-5f1a-4531-9e0f-6cb3cae4722f	CREMA DE PEINAR ROLDA ACIETE DE RICINO 300ML	7592871003332	t	14700.00	14200.00	\N	\N	0.00	2025-10-19 02:29:42.54287	2025-10-19 02:29:42.54287
d70c67c9-dbde-4c5c-827e-4a5788db4f06	CREMA DE PEINAR ROLDA COLAGENO 300ML	7592871004902	t	14700.00	14200.00	\N	\N	0.00	2025-10-19 02:29:42.543178	2025-10-19 02:29:42.543178
df47f0d7-3eba-4586-a7b1-8321d10dac54	CREMA PARA PEINAR ELVIVE LOREAL OLEO 300ML	7509552816334	t	12800.00	12300.00	\N	\N	0.00	2025-10-19 02:29:42.543812	2025-10-19 02:29:42.543812
f4027d03-8009-4522-9e7b-279c7c6ef612	CREMA PARA PEINAR ELVIVE DREAM LONG 300ML	7509552836677	t	12800.00	12300.00	\N	\N	0.00	2025-10-19 02:29:42.544222	2025-10-19 02:29:42.544222
9662713f-8020-400d-89e1-13a7e6acfcda	CREMA PARA PEINAR ROLDA CERA DE ABEJA 300ML	7592871004896	t	14700.00	14200.00	\N	\N	0.00	2025-10-19 02:29:42.544569	2025-10-19 02:29:42.544569
6fc66278-69ba-4ad0-bd4a-a308cd0677ff	PINZA ROPA ITECA X12UNID	7592302009308	t	4200.00	3950.00	\N	\N	0.00	2025-10-19 02:29:42.54494	2025-10-19 02:29:42.54494
6bda3946-cdda-4dd2-8cb8-3682b3c34e63	PELOTA ANTI ESTRES	PELOTA	t	1700.00	1500.00	\N	\N	0.00	2025-10-19 02:29:42.545244	2025-10-19 02:29:42.545244
c0701755-c615-4ea9-a35a-d3d4321f5fa2	COOL A PED CON CALNDULA 250ML	7708851548438	t	6800.00	6500.00	\N	\N	0.00	2025-10-19 02:29:42.545524	2025-10-19 02:29:42.545524
5a9ae00c-e8b2-4cdf-8723-b9e63d08878c	KID ROCIO DE ORO 150ML MAS 60ML	7709947068601	t	22500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.545902	2025-10-19 02:29:42.545902
2ef277c5-e630-4fdf-bedc-923d8b067a0e	CEPILLO WTAAWT X3UNID	6976635040206	t	3500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.546712	2025-10-19 02:29:42.546712
ec45b2b1-e2a2-4a67-b3ad-8abd67f81eb7	ESPONJA MALLA DE COLORES TIRA X24UNID	ESPONJA	t	7800.00	7200.00	\N	\N	0.00	2025-10-19 02:29:42.547097	2025-10-19 02:29:42.547097
fc9113d6-219e-4ef9-8e97-d81477902d69	REFISAL PARRILERA 454GR	7703812013697	t	9200.00	8700.00	\N	\N	0.00	2025-10-19 02:29:42.547456	2025-10-19 02:29:42.547456
6f4e8880-dbfc-4ff9-a570-46707d5737ff	ESPONJA MANA  X12UNID	ESPONJA MAN	t	5100.00	\N	\N	\N	0.00	2025-10-19 02:29:42.547872	2025-10-19 02:29:42.547872
e273fb87-b4d2-4ac4-9b83-7c3ddbe54221	GLADE AUTOMATICO ABRAZO DE VAINILLA 270ML	7501032913595	t	40000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.54825	2025-10-19 02:29:42.54825
b1e3c194-9fd2-4ccb-8bd5-a6476cb25567	CAFE SELLO ROJO 850GR MAS TAZA	7702032119950	t	31000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.548774	2025-10-19 02:29:42.548774
50f54fb1-a394-4e0e-ae68-93a32a58206f	ESPONJA TASK PG 2 LLV 3	7703147073342	t	9200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.549308	2025-10-19 02:29:42.549308
6886b967-ee46-4786-b485-70d8b3e358a0	MOSTAZA COLMANS 200GR	7708001730430	t	8500.00	8200.00	\N	\N	0.00	2025-10-19 02:29:42.549774	2025-10-19 02:29:42.549774
ddee0501-09fe-4605-aa7f-594df3f35dc3	fruit taste gelatina binkingo	6920484018343	t	1000.00	800.00	\N	\N	0.00	2025-10-19 02:29:42.550109	2025-10-19 02:29:42.550109
742c1549-d086-41dd-a9c3-7af05bd27a99	JABON EDEN 300GR	7704269815810	t	2400.00	2320.00	\N	\N	0.00	2025-10-19 02:29:42.550563	2025-10-19 02:29:42.550563
60596ac9-39d3-46b5-a933-c3773e2a6b59	SHAMPOO SEDALRIZOS DEFINIDOS 340ML	7506306237421	t	15000.00	14000.00	\N	\N	19.00	2025-10-19 02:29:42.550819	2025-10-19 02:29:42.550819
86cdbc03-2736-41dd-95aa-ef776db8d84e	RAVIOLI DE CARNE DORIA 250GR	7702085002094	t	10800.00	10400.00	\N	\N	19.00	2025-10-19 02:29:42.551076	2025-10-19 02:29:42.551076
bf153307-be4d-4597-a493-ee3bb1bb1ddc	RAVIOLI DE POLLO DORIA 250GR	7702085002346	t	10800.00	10400.00	\N	\N	19.00	2025-10-19 02:29:42.551328	2025-10-19 02:29:42.551328
175f2fff-1ff0-4260-aa59-2bfd65df17f2	LAVALOZA ANGEL CLEAN LIMON 3K	614143204364	t	19000.00	18500.00	\N	\N	19.00	2025-10-19 02:29:42.551559	2025-10-19 02:29:42.551559
8579a71e-5769-4b0c-b662-d43aae9ec08a	MOSQUITO COIL X10	6953937167848	t	5400.00	\N	\N	\N	0.00	2025-10-19 02:29:42.551882	2025-10-19 02:29:42.551882
f91cfc9a-292e-4815-9ab4-3acae629b254	NOSOTRAS INVISIBLE CLASICAS MULTIESTILO X10 MAS 5 PROTECTORES	7702026148447	t	5000.00	4850.00	\N	\N	0.00	2025-10-19 02:29:42.552133	2025-10-19 02:29:42.552133
3fb364d9-49ec-411a-a557-3b0aca8c1f05	SALSA PARA CARNES LAS CONSTANCIA BOLSA 110GR	7702097069412	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:42.552371	2025-10-19 02:29:42.552371
f79115ce-a960-4929-b77c-e49b1a224730	PEPSI ZERO 250ML	7702192053347	t	1000.00	917.00	\N	\N	19.00	2025-10-19 02:29:42.552607	2025-10-19 02:29:42.552607
efa3592e-f4d9-4e66-a8f9-2f0bd7d798d1	MANZANA POSTOBON 250ML	7702090072846	t	1000.00	917.00	\N	\N	19.00	2025-10-19 02:29:42.552851	2025-10-19 02:29:42.552851
77553442-f292-41f1-899a-0fcbe1d54f29	BROWNIE CHOCOLATE GUADALUPE 50GR	7705326096197	t	2000.00	1950.00	\N	\N	19.00	2025-10-19 02:29:42.553129	2025-10-19 02:29:42.553129
ca31ab6d-2424-44d9-9367-6cc9f1b24d18	PALO PINCHO GRUESO HOUSE 3CM X100UNI	7707320620156	t	2900.00	2750.00	\N	\N	19.00	2025-10-19 02:29:42.553364	2025-10-19 02:29:42.553364
43d8558a-61d7-45e7-98f8-8139d3a246ca	LECHE COSMOLAC 380GR	7708991514218	t	9000.00	8700.00	\N	\N	0.00	2025-10-19 02:29:42.553656	2025-10-19 02:29:42.553656
7d05fbd7-952a-4f85-a24f-b3e13a145e08	DETERGENTE 3D 500GR ALOE BICARBONATO	7702191452059	t	4300.00	4100.00	\N	\N	19.00	2025-10-19 02:29:42.553843	2025-10-19 02:29:42.553843
385b33ed-03db-49c4-bba7-e8353175248c	QCITOS FAMILIAR LA VICTORIA 180GR	7706642110444	t	5800.00	5600.00	\N	\N	0.00	2025-10-19 02:29:42.554029	2025-10-19 02:29:42.554029
013d5ab1-1679-4524-92af-2f908996bbc8	CONITOS TRI LIMON LA VICTORIA X8UNID DE 30GR	7706642010843	t	9800.00	9600.00	\N	\N	0.00	2025-10-19 02:29:42.554308	2025-10-19 02:29:42.554308
6f02571c-ccc2-43e9-bdb9-84d379ff1fff	QCITO LA VCTORIA X12UNID 22GR	7706642603939	t	10000.00	9800.00	\N	\N	0.00	2025-10-19 02:29:42.554556	2025-10-19 02:29:42.554556
413ea51c-e279-46a9-9760-c508eca22ecb	QCITO LA VICTORIA X8UNID 36GR	7706642311049	t	10500.00	10300.00	\N	\N	0.00	2025-10-19 02:29:42.554774	2025-10-19 02:29:42.554774
3bc49c30-fe83-4464-84ca-c0232855eff9	VINAGRE ROJO IDEAL 1  L	7709747919042	t	2000.00	1900.00	\N	\N	0.00	2025-10-19 02:29:42.555004	2025-10-19 02:29:42.555004
d474473c-e00f-47df-94c2-960863c8e32d	BIANCHI BARRA GRANDE X18UNID	7702993054888	t	22600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.555237	2025-10-19 02:29:42.555237
779bf37d-3f77-4b5e-a656-a9c960238777	SALMON COSTA RICA TOMATE 155GR	7862129151321	t	2500.00	2400.00	\N	\N	0.00	2025-10-19 02:29:42.555492	2025-10-19 02:29:42.555492
37fdcfff-382f-4b32-8c8c-3192de745c11	VINAGRE IDEAL ROJO 3L	7709844868656	t	3800.00	3600.00	\N	\N	0.00	2025-10-19 02:29:42.555745	2025-10-19 02:29:42.555745
b513ed7c-ad6c-4a26-8eda-da973b5a0b1c	SALCHICHA DELICHICKS X20UNID	7700506693258	t	20500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.556019	2025-10-19 02:29:42.556019
99c600a8-ea86-4516-b89c-4f50d757d254	TOALLAS PAPEL ACOLCHAMAX 80 HOJAS FAMILIA VERDE	7702026060619	t	8700.00	8400.00	\N	\N	19.00	2025-10-19 02:29:42.556316	2025-10-19 02:29:42.556316
5bff742d-e171-4dca-b7b8-e8a3ed38e94b	TOALLA COSINA MEGARROLLO 120 HOJAS FAMILIA VERDE	7702026062163	t	11000.00	10700.00	\N	\N	19.00	2025-10-19 02:29:42.556589	2025-10-19 02:29:42.556589
b4eb3a46-edfb-477f-a820-e03217cdbe5a	ACEITE OLIVETTO EXTRA VIRGEN 500ML	7702109014447	t	40000.00	39000.00	\N	\N	19.00	2025-10-19 02:29:42.556838	2025-10-19 02:29:42.556838
eca990d9-1323-4b2a-82f6-46af6b2d9cd0	AZUCAR PALACIO MORENA 2.5KG	7709241447782	t	10600.00	\N	\N	\N	5.00	2025-10-19 02:29:42.55718	2025-10-19 02:29:42.55718
4e2a3bda-1263-4ad7-8a80-f3e9a2194356	SONETTO EXPLOSION DE CHOCOLATE X50UNI	7702174087728	t	6600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.557536	2025-10-19 02:29:42.557536
52842376-baaa-47e9-bd6e-3aaf1e4bbdfa	SONETTO MOUSSE CHOCOLATE BLANCO X50UNID	7702174086745	t	6600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.557924	2025-10-19 02:29:42.557924
e24addf0-c03d-4b0b-b8a0-4b145e8721ff	MILO WAFER X18UNID	7702024734031	t	33000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.55829	2025-10-19 02:29:42.55829
6746350c-c482-4a7e-8753-3593551a4da0	LECHE COSMOLAC 200GR	7709227714815	t	5300.00	5000.00	\N	\N	0.00	2025-10-19 02:29:42.558619	2025-10-19 02:29:42.558619
6f761fa0-95f7-47b9-a41f-9731116293df	DESENREDANTE BUBU 190ML	7704269790858	t	8000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.558955	2025-10-19 02:29:42.558955
dc01e6b8-39aa-45d0-a913-cd16449b76a0	PONQUE TRADICIONAL GUADALUPE 180GR	7705326559333	t	5000.00	4900.00	\N	\N	0.00	2025-10-19 02:29:42.559237	2025-10-19 02:29:42.559237
e39743d3-ecfc-4ef0-b997-5b63a9ee7e4c	JOHNSONS BABY ANTES DE DORMIR 110GR	7702031900870	t	4700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.559505	2025-10-19 02:29:42.559505
753bd0c0-3ef8-4740-99b1-11e6ec944e39	SARDINA BOCADO DEL MAR 400GR	7702910042141	t	4800.00	4550.00	\N	\N	19.00	2025-10-19 02:29:42.559808	2025-10-19 02:29:42.559808
98a8bc62-e56e-49d1-a57e-b4e8bd9ba6c5	VINAGRE DELSAZON BLANCO 1 LITRO	7709956177868	t	2100.00	1950.00	\N	\N	0.00	2025-10-19 02:29:42.560137	2025-10-19 02:29:42.560137
6bcfa953-c095-465c-825b-44ddee123e6d	VINAGRE IDEAL ROJO 500ML	VIN12	t	1100.00	950.00	\N	\N	0.00	2025-10-19 02:29:42.560601	2025-10-19 02:29:42.560601
896883dd-421f-4483-900b-eab6ad406867	FRUTIÑO MARACU MANGO 10GR	7702354958404	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:42.560948	2025-10-19 02:29:42.560948
ea611726-eeb0-4e80-9f98-c2289bc342e6	FRUTIÑO DURAZNO 10GR	7702354957995	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:42.561324	2025-10-19 02:29:42.561324
0178bbe1-24f1-4a1d-af9f-872e1f2fd7f9	FRUTIÑO GUANABANA 10GR	7702354957988	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:42.5616	2025-10-19 02:29:42.5616
b789032c-4874-4100-b0ed-a3fed9665671	GELATINA SUNTEA FRESA 16GR	7702354952389	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:42.561867	2025-10-19 02:29:42.561867
a3961450-b0f8-4389-96b9-aa64ed002837	PEPSI 2.5L	7702192107675	t	4800.00	4438.00	\N	\N	19.00	2025-10-19 02:29:42.562175	2025-10-19 02:29:42.562175
a6fa5ef6-1ef7-4cea-af99-f53010349020	AZUCAR SEDESPENSA 500GR	7707309251432	t	2000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.562496	2025-10-19 02:29:42.562496
0a9ddfe7-03a1-4876-bd34-e4d9215ebce5	CHOCLITO PICANTE 45GR	7702189058553	t	2200.00	2100.00	2000.00	\N	19.00	2025-10-19 02:29:42.562743	2025-10-19 02:29:42.562743
69a7d536-2964-4331-be57-153f2e1d78de	AROMATEL MANDAEINA FLOR LOTO 180ML	7702191164013	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.563074	2025-10-19 02:29:42.563074
ef96e730-dd35-4f79-95af-57fd7c8f8635	TENEDOR TAMI X100UNID	645667269553	t	2700.00	2600.00	\N	\N	0.00	2025-10-19 02:29:42.563317	2025-10-19 02:29:42.563317
8b955c45-10dd-4353-97ec-2df830aa65f0	ARROZ PALACIO 500GR	7709990134100	t	1900.00	1800.00	\N	\N	0.00	2025-10-19 02:29:42.563618	2025-10-19 02:29:42.563618
6658bd0e-5b4a-4ca6-bee6-d3e45aca1a89	MANTEQUILLA MA	7590006200144	t	16000.00	15500.00	\N	\N	0.00	2025-10-19 02:29:42.563913	2025-10-19 02:29:42.563913
e8ec006b-fa79-4288-b53a-28783026bed2	CONITOS TRI LIMON VOCKY30GR	7706642224318	t	1400.00	1300.00	\N	\N	19.00	2025-10-19 02:29:42.564182	2025-10-19 02:29:42.564182
889be0c2-6e31-443e-a23f-08392f1ac994	SALMON INCOSA SALSA DE TOMATE 170GR	7592225000253	t	2400.00	2250.00	\N	\N	0.00	2025-10-19 02:29:42.564416	2025-10-19 02:29:42.564416
50bb0207-0946-4427-aa59-6c512f045e50	ARROZ PRIMOR PREMIUM 1.000GR	7709348768896	t	3300.00	3200.00	\N	\N	0.00	2025-10-19 02:29:42.564717	2025-10-19 02:29:42.564717
fa77acea-2a29-4e24-bda1-5c924dfb0572	CHOCODISK TIRA X6	7702011052520	t	5300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.564964	2025-10-19 02:29:42.564964
a398e5e4-d228-4b85-aeab-b0b24ff36cae	OBLEAS GRANDES X50UNID	7707899456200	t	6400.00	6200.00	\N	\N	0.00	2025-10-19 02:29:42.565226	2025-10-19 02:29:42.565226
e268883d-446e-434f-871d-7d22c13c2f85	AREQUIPE EL ANDINO 250GR	7709068596649	t	4900.00	4700.00	\N	\N	0.00	2025-10-19 02:29:42.56546	2025-10-19 02:29:42.56546
9f04a430-0aca-4d97-840d-0f99a0bfaeea	OBLEAS MAS AREQUIPE 240GR	13029	t	7800.00	7500.00	\N	\N	0.00	2025-10-19 02:29:42.56571	2025-10-19 02:29:42.56571
9987f2b9-805e-475e-ab11-be667a4f6b09	TOALLA ACOLCHAMAX VERDE 44HJ	7702026154264	t	4700.00	4550.00	\N	\N	19.00	2025-10-19 02:29:42.566108	2025-10-19 02:29:42.566108
daf1fd66-98cb-43bd-8132-e118084e8c02	GUANTES TASK TALLA M 8	7703147300691	t	4200.00	3960.00	\N	\N	0.00	2025-10-19 02:29:42.566396	2025-10-19 02:29:42.566396
d51b1ff5-a706-4918-9af8-b283d83ca490	GUANTES TASK L TALLA 9	7703147300707	t	4200.00	3960.00	\N	\N	0.00	2025-10-19 02:29:42.566723	2025-10-19 02:29:42.566723
f7e9200d-617c-49af-bcb8-cc1df88b7332	CAFE GURME X100UNID	7702993055595	t	7700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.567024	2025-10-19 02:29:42.567024
b1758845-d9c9-49de-b39c-ca210c8562a3	COLCAFE BALANCEADO LIOFILIZADO 85GR	7702032119646	t	14800.00	14200.00	\N	\N	5.00	2025-10-19 02:29:42.567348	2025-10-19 02:29:42.567348
b177c0b7-9e2f-4745-85cb-1d6c0190e34c	CHOCOLATE LA ESPECIAL COCOA TRADICIONAL 400GR	7702007086607	t	8500.00	8280.00	\N	\N	5.00	2025-10-19 02:29:42.567795	2025-10-19 02:29:42.567795
8b968b2b-cc14-4737-81e8-112ef7b2e08f	CHOCOLATE LA ESPECIAL COCOA TRADICIONAL 200GR	7702007086591	t	4500.00	4380.00	\N	\N	5.00	2025-10-19 02:29:42.568144	2025-10-19 02:29:42.568144
f8918394-df30-4366-9dfe-010a69f9c1db	CHOCOLATE LA ESPECIAL COCOA TRADICIONAL 25GR	7702007086621	t	600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.568382	2025-10-19 02:29:42.568382
58bd1fce-193a-42bd-8762-c17d0af332f4	AVENA ALPINA DESLACTOSADA 250GR	7702001044726	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.568636	2025-10-19 02:29:42.568636
99464882-e173-4c1f-bb1a-36f4f3a874e4	PENNE RIGATE 1KG MAS PESTO ROSSO MONTICELLO	7702085006245	t	14200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.568861	2025-10-19 02:29:42.568861
d60a646b-cecd-4742-979c-23772b1fc32d	SELLO ROJO GO VAINILLA 190ML	7702032119110	t	2700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.569116	2025-10-19 02:29:42.569116
f910b8ff-9bf2-494b-b5f0-659a5cf29269	LECHE COSMOLAC 900GR	7709990000375	t	20800.00	20100.00	\N	\N	19.00	2025-10-19 02:29:42.569337	2025-10-19 02:29:42.569337
18fa267e-6928-4e9b-b125-96dd475728d0	FABULOSO LAVANDA 2LITROS	7702010225109	t	18000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.569563	2025-10-19 02:29:42.569563
0662365b-d8ec-4e7f-82d9-881be63923a1	COLGATE PLAX ODOR CONTROL 500ML	7509546679532	t	17800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.569763	2025-10-19 02:29:42.569763
3767435b-7721-4fc9-8740-6b905c2a6b44	TROLLI MANGO BICHE 65GR	7702174085823	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.570009	2025-10-19 02:29:42.570009
95b3e5ae-5818-43d8-8e4f-a7964281d5ba	ACETAMINOFEN LAPROFF CEREZA 60ML	7703038060987	t	2500.00	2200.00	\N	\N	0.00	2025-10-19 02:29:42.570231	2025-10-19 02:29:42.570231
3404dda8-80be-4ae9-bc73-42bfec241d3c	BONAROPA XTRA PERLAS DE FRAGANCIA JARDIN SILVESTRE 285GR	7700304251087	t	11600.00	11200.00	\N	\N	0.00	2025-10-19 02:29:42.570468	2025-10-19 02:29:42.570468
54ac035c-4ccf-45bd-bc7d-5e9947fb4207	BONAROPA XTRA PERLAS DE FRAGANCIA PARAISO TROPICAL 285GR	7700304383559	t	11600.00	11200.00	\N	\N	0.00	2025-10-19 02:29:42.570687	2025-10-19 02:29:42.570687
b4c16639-231a-4ff9-adcd-2574469df74b	PEDIGREE SABOR A CARNE 100GR	7896029015001	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:42.570914	2025-10-19 02:29:42.570914
c2d8c8a9-a08d-4504-a837-77389757c6fc	PEDIGREE RAZAS PEQUEÑAS 100GR	706460249316	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:42.571152	2025-10-19 02:29:42.571152
43a0fb60-aad9-41fa-b573-bfd6e168c7df	WHISKAS CARNE 85GR	7896029046609	t	3300.00	3200.00	\N	\N	19.00	2025-10-19 02:29:42.571377	2025-10-19 02:29:42.571377
6d67f8d4-ffca-494f-9612-5a81aa2d6ba2	ACEITE DON OLIO VEGETAL DE CANOLA EN SPRAY 180ML	7700304151387	t	13800.00	13300.00	\N	\N	0.00	2025-10-19 02:29:42.571589	2025-10-19 02:29:42.571589
09fc4a00-24bc-486b-a0fa-760c5179a1c2	BISCOLATA STIX PALITOS 40GR	8691707140049	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:42.571849	2025-10-19 02:29:42.571849
d6fc4098-5bd8-40e0-abdf-d02134a989cc	BISCOLATA MOOD MILK CHOCOLATE 40GR	8699141157005	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:42.572084	2025-10-19 02:29:42.572084
54e88165-7000-4367-9966-39f48018975b	COLONIA BEBE LITLE ANGELS 200ML	7700304785490	t	9500.00	9000.00	\N	\N	19.00	2025-10-19 02:29:42.572323	2025-10-19 02:29:42.572323
5550c923-9b35-4695-a472-10cfea2dbb04	ESPONJA DE ACERO BRILLO X6 IDY HOUSE	7700304223220	t	1300.00	1200.00	\N	\N	0.00	2025-10-19 02:29:42.572551	2025-10-19 02:29:42.572551
5b4861e0-cfb6-4485-84be-aa357870f048	ESENCIA SABOR A VAINILLA BLANCA 155MLSPECIARIA	7700304312627	t	3800.00	3700.00	\N	\N	19.00	2025-10-19 02:29:42.572777	2025-10-19 02:29:42.572777
b52cdb47-c4dc-4b2d-91e2-aac92cca3c02	ACEITE OLIVA EXTRA VIRGEN CASTELL DE FERRO 250ML	7700304182084	t	14900.00	14400.00	\N	\N	19.00	2025-10-19 02:29:42.573035	2025-10-19 02:29:42.573035
b4fbfff8-b244-4f58-8acc-ae9ac2d4e78e	ACEITE DE OLIVA EXTRA VIRGEN CASTELL DE FERRO 500ML	7700304004645	t	24000.00	23500.00	\N	\N	19.00	2025-10-19 02:29:42.573291	2025-10-19 02:29:42.573291
fe3cf9f4-2e0a-4aca-9aad-34d426d9dafa	JABON LIQUIDO ANTIBACTERIAL NATURAL FEELING 500ML COCO	7700304793709	t	4200.00	4000.00	\N	\N	19.00	2025-10-19 02:29:42.573507	2025-10-19 02:29:42.573507
fd4e0f94-89d4-46f6-9a3e-75e6fd9c9b9e	JABON LIQUIDO ANTIBACTERIAL NATURAL HIERBAS 500ML	7700304523887	t	4200.00	4000.00	\N	\N	19.00	2025-10-19 02:29:42.573729	2025-10-19 02:29:42.573729
7f22dd9d-5ba9-4039-b238-4f5051f7c291	JABON ANTIBACTERIAL FEELING VAINILLA  500ML	7700304700271	t	4100.00	3900.00	\N	\N	19.00	2025-10-19 02:29:42.573944	2025-10-19 02:29:42.573944
d2216eb9-c8b3-47f8-9df1-191a5fac6e77	TROLLI MORDISCOS 70GR	7702174087766	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.574189	2025-10-19 02:29:42.574189
26bcf1fd-9389-4a8d-9be3-94d5637f53f1	TROLLI RANASAPOS 65GR	7702174085663	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.574462	2025-10-19 02:29:42.574462
40fab61a-d025-4f1a-879f-dfd24a0097d5	TROLLI BANANAS 70GR	7702174087759	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.574749	2025-10-19 02:29:42.574749
2a34e281-4801-4b3a-942f-3ae42fb72e6c	TROLLI FANTASIA MIX	7702174088039	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.575096	2025-10-19 02:29:42.575096
ada1ff1c-e1ab-46dd-b7e1-0c0381af3ec3	TROLLI USAROS 70G	7702174088015	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.575437	2025-10-19 02:29:42.575437
8b8b1988-34b6-43d1-8515-76ea9dcec99d	TROLLI ANACONDA 70GR	7702174087773	t	1600.00	1500.00	\N	\N	19.00	2025-10-19 02:29:42.575826	2025-10-19 02:29:42.575826
b0676045-c52e-46c9-bc4f-72c4ce6a6e40	BUCARINE MENTA FRESCA ENJUAGUE BUCAL 500ML	7700304141791	t	7700.00	7400.00	\N	\N	19.00	2025-10-19 02:29:42.576164	2025-10-19 02:29:42.576164
5fc2d705-1b2c-4651-8b07-9e5671838f6f	CREMA LAVALOZA BRILLA KING 500GR	7700304553167	t	3000.00	2850.00	\N	\N	19.00	2025-10-19 02:29:42.576459	2025-10-19 02:29:42.576459
0b484ca6-4739-4849-9d4f-737e201e3f11	SAL MARINA REFISAL 800GR	7703812007559	t	5100.00	4900.00	\N	\N	0.00	2025-10-19 02:29:42.576757	2025-10-19 02:29:42.576757
dfc6bd5b-6d4b-43a9-8b4d-5510e973e6c5	ALGODON LITTLE ANGELS 50GR	7700304880300	t	2100.00	1980.00	\N	\N	0.00	2025-10-19 02:29:42.577017	2025-10-19 02:29:42.577017
bc8d8a56-2895-481b-9de7-23dc977dc76c	LECHE ENTERA LATTI 900ML	7700304904211	t	3300.00	3150.00	\N	\N	0.00	2025-10-19 02:29:42.57724	2025-10-19 02:29:42.57724
357844ef-a624-4ac0-8e78-2d1bfc7142b8	GALLETAS PARA GATOS MAGIS FRIENDS 75 GR	7700304783489	t	2600.00	2470.00	\N	\N	0.00	2025-10-19 02:29:42.577487	2025-10-19 02:29:42.577487
3ae0a3a0-f1d0-45d9-a91b-45d3e5f25bf9	TARRITO ROJO JGB TRADICIONAL 200GR	7702560048876	t	14700.00	14200.00	\N	\N	19.00	2025-10-19 02:29:42.577737	2025-10-19 02:29:42.577737
5dc6d36d-d2bf-4534-92d1-f8d76a6bd695	ROPA COLOR BONAROPA 1L	7700304998562	t	3300.00	3150.00	\N	\N	19.00	2025-10-19 02:29:42.578021	2025-10-19 02:29:42.578021
1d6ac693-65d0-4056-9387-d543e82ca566	TOLLAS HUMEDAS LITTLE ANGELS X72UNID	7700304893386	t	4700.00	4500.00	\N	\N	0.00	2025-10-19 02:29:42.578338	2025-10-19 02:29:42.578338
d73c42ab-108d-4530-9c4e-bb80e215840e	CABANOS CAMAZA MAGIC FIRENDS 100GR	7700304712328	t	2400.00	2250.00	\N	\N	19.00	2025-10-19 02:29:42.578645	2025-10-19 02:29:42.578645
2d48ccdc-5598-457f-9fb2-ce199c9a21ff	TOALLA COSINA RENDY DOBLE X50UNID	7700304604401	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:42.578902	2025-10-19 02:29:42.578902
d1e08f68-f25e-46ec-b5dc-0d6175be97c3	BLANQUEADOR CLORO BRILLA KING 2L	7700304530939	t	3500.00	3400.00	\N	\N	19.00	2025-10-19 02:29:42.579128	2025-10-19 02:29:42.579128
58cf2fbb-61d1-4bbd-8f0b-4a36a4c38b8d	SEDA DENTAL MENTA FRESCA BUCARINE 50	7700304371877	t	3000.00	2850.00	\N	\N	0.00	2025-10-19 02:29:42.579395	2025-10-19 02:29:42.579395
2c952d60-8967-4a35-81f7-96b398c8b038	PEINA FACIL LITTLE ANGELS KIDS 250ML	7700304360741	t	9900.00	9500.00	\N	\N	19.00	2025-10-19 02:29:42.579641	2025-10-19 02:29:42.579641
addfd251-2fa3-4db5-a0ec-b5b93be179af	JABON INTIMO FRESH Y FREE DE ALGODOL 300ML	7700304918485	t	4600.00	4400.00	\N	\N	19.00	2025-10-19 02:29:42.579862	2025-10-19 02:29:42.579862
744b8a3a-8fe9-4be1-9882-5fc8b0fb0696	DESINFECTANTE ELIMINA OLORES HOSH 360ML	7700304446414	t	7000.00	6700.00	\N	\N	19.00	2025-10-19 02:29:42.580136	2025-10-19 02:29:42.580136
accf707c-8e88-433b-874f-5c8873fb569f	SHAMPOO GEL DE BAÑO 2 EN 1 400ML	7700304608348	t	8400.00	8000.00	\N	\N	19.00	2025-10-19 02:29:42.580408	2025-10-19 02:29:42.580408
c65f4c7f-5abe-478c-b5fc-d90efd76fb9c	BOMBILLO ZAFIRO 9W	7707489450746	t	2200.00	2100.00	\N	\N	19.00	2025-10-19 02:29:42.580672	2025-10-19 02:29:42.580672
180f8ee8-cf32-4fbf-aaf0-3e4cf26a08d3	PAÑITOS HUMEDOS INFINITA X100	7708416000180	t	5100.00	4850.00	\N	\N	19.00	2025-10-19 02:29:42.580959	2025-10-19 02:29:42.580959
29acffaf-3f94-44fe-8609-64841f25ea0b	TOALLA COSINA NOVA X3UNIDADES X50HJ	7707199344856	t	6300.00	6050.00	\N	\N	19.00	2025-10-19 02:29:42.581253	2025-10-19 02:29:42.581253
ac62305d-edfe-437f-a598-45746426f113	FULMINANTE DIANA 250GR	7707166100935	t	1900.00	1800.00	\N	\N	5.00	2025-10-19 02:29:42.581534	2025-10-19 02:29:42.581534
433feeb3-c9e3-4014-9ab8-70b1f5b34c8f	CODO DIANA 250GR	7707166100836	t	1900.00	1800.00	\N	\N	5.00	2025-10-19 02:29:42.581827	2025-10-19 02:29:42.581827
40549d58-1888-477f-94d3-a738882826b2	FIDEO COMARRICO 125GR	7707307962842	t	900.00	850.00	\N	\N	0.00	2025-10-19 02:29:42.582096	2025-10-19 02:29:42.582096
fb1b5b76-613e-4a62-bf70-3b0135b3030f	LECHE CONDENSADA LA LECHERA NESTLE 395GR	7702024053224	t	11000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.582335	2025-10-19 02:29:42.582335
645edee5-d72b-4100-8d83-f6f84df8cdb2	COPITOS LITTLE ANGELS X10	7700304407453	t	3000.00	2800.00	\N	\N	0.00	2025-10-19 02:29:42.582529	2025-10-19 02:29:42.582529
77d08ad5-9cd1-4e25-86d3-ead009932e37	FRAGANCIA DE AMBIENTE DESINFECTANTE AGUA DE JAZMIN 150ML	7700304171293	t	5200.00	4850.00	\N	\N	0.00	2025-10-19 02:29:42.582726	2025-10-19 02:29:42.582726
6da002c8-9b41-455c-b4f0-5790e62b91be	FRAGANCIA DE AMBIENTE DESINFECTANTE NECTAR FLORAR 150ML	7700304143160	t	5200.00	4850.00	\N	\N	0.00	2025-10-19 02:29:42.582946	2025-10-19 02:29:42.582946
4d8ad09f-e59a-427b-9358-218d81cc4a35	FRAGANCIA DE AMBIENTE DESINFECTANTE HOJAS DE LIMA 150ML	7700304359288	t	5200.00	4850.00	\N	\N	0.00	2025-10-19 02:29:42.583172	2025-10-19 02:29:42.583172
b335e337-1928-477f-a0c5-fd4683df12b3	LOCION GIDRATANTE CORPORAL NATURAL 1L	7700304027668	t	12000.00	11400.00	\N	\N	0.00	2025-10-19 02:29:42.583367	2025-10-19 02:29:42.583367
f33fc95b-ec53-4dbc-8f5b-2d8c22b9568d	LIMPIADOR DE JUNTAS BILLA KING 500ML	7700304132744	t	3600.00	3400.00	\N	\N	0.00	2025-10-19 02:29:42.583596	2025-10-19 02:29:42.583596
9dcba631-e75b-4d77-9f55-e1cab4b82751	DETODITO POLLO PARRILLERO 50GR	7702189059963	t	3000.00	2900.00	\N	\N	0.00	2025-10-19 02:29:42.583827	2025-10-19 02:29:42.583827
64fd3b2c-795e-4267-b301-b8cff229191b	SHAMPOO PANTENE COLAGENO 300ML MAS ACONDICIONADOR 250ML	7500435208994	t	33500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.584022	2025-10-19 02:29:42.584022
43d78ffd-cede-48db-8691-238df0fb9807	SALSA DE PIÑA IDEAL TERRO 460GR	7709483153526	t	5600.00	5400.00	\N	\N	0.00	2025-10-19 02:29:42.584251	2025-10-19 02:29:42.584251
a276a2df-9961-4748-9607-88b3150da74f	ARVEJA AMARILLA LA SOBERANA 500GR	7702910344290	t	2000.00	1900.00	\N	\N	0.00	2025-10-19 02:29:42.584461	2025-10-19 02:29:42.584461
a0ed3ccf-e5e1-4993-beff-1a219f052000	SALSA DE PIÑA IDEAL 200GR DOY PACK	7709640614280	t	2600.00	2450.00	\N	\N	0.00	2025-10-19 02:29:42.584657	2025-10-19 02:29:42.584657
892dac8b-9de6-4d99-a541-3116cd6cfec5	OBLAS MINI MAS AREQUIPE 180GR	OBLAS	t	6600.00	6380.00	\N	\N	0.00	2025-10-19 02:29:42.584859	2025-10-19 02:29:42.584859
06bedb20-4418-432c-9afb-4dc24ccb5e92	COCOSETTE X18UNID	7702024172833	t	30000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.585093	2025-10-19 02:29:42.585093
06bebe1b-2054-49df-885a-f4b489e5857b	CEBOLLA MOLIDA LA SAZON DE LA VILLA 50GR	7707767147926	t	1600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.585315	2025-10-19 02:29:42.585315
d4b3c525-62e4-4201-8ce4-79078b96d987	AZUCAR LEO 1K	7709657755631	t	3900.00	3800.00	\N	\N	0.00	2025-10-19 02:29:42.585539	2025-10-19 02:29:42.585539
b5e8ae40-e7ef-450a-81fa-c85bff5968ed	SILICONA CAPILAR JHUNIOS ROLD VERDE	SILICO	t	1800.00	1650.00	\N	\N	0.00	2025-10-19 02:29:42.586025	2025-10-19 02:29:42.586025
6d5f5d4f-9f90-4df9-830c-169a1ceca4d8	LOKIÑO MINIS FRUTO ROJOS 30G	7702993046418	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.586304	2025-10-19 02:29:42.586304
baff2923-8416-4d24-900b-f67ec40affbe	BOCADILLO COMBINA DE LONJA 300GR	7707337090317	t	2600.00	2500.00	\N	\N	0.00	2025-10-19 02:29:42.586573	2025-10-19 02:29:42.586573
b77bc6ee-9da7-4e33-8a73-e3ee401a6ca8	SPARTA LATA AZUL 310ML	7702354958848	t	2000.00	1771.00	\N	\N	19.00	2025-10-19 02:29:42.586865	2025-10-19 02:29:42.586865
1c3b4e8a-253b-49c4-a12d-afd7710934b6	SPARTA AMARILLO 310ML	7702354958831	t	2000.00	1771.00	\N	\N	19.00	2025-10-19 02:29:42.587103	2025-10-19 02:29:42.587103
36b75390-1435-4316-a82e-cb4b494bece4	VIVE 100 LATA 310ML	7702354958817	t	2000.00	1771.00	\N	\N	19.00	2025-10-19 02:29:42.58738	2025-10-19 02:29:42.58738
3b19fbf1-597c-49ef-a75b-fe6f467da33c	CEPILLO CON PROTECTOR REF 2440	6976635041401	t	1500.00	1200.00	\N	\N	0.00	2025-10-19 02:29:42.58759	2025-10-19 02:29:42.58759
eeefc0a5-f4fa-4f61-bf61-a17d509a1b52	CEPILLO WTAAWT	6975290470212	t	1200.00	750.00	\N	\N	0.00	2025-10-19 02:29:42.58784	2025-10-19 02:29:42.58784
a7795b0d-c0c9-4db8-a4a1-f86f34c424c4	CEPILLO X2 ADULTOS	6972919085093	t	3000.00	2700.00	\N	\N	0.00	2025-10-19 02:29:42.588071	2025-10-19 02:29:42.588071
34833c0f-58a3-41ec-aeeb-2da0f636419b	CEPILLO DORCO 003	6928158580035	t	2200.00	1950.00	\N	\N	0.00	2025-10-19 02:29:42.588331	2025-10-19 02:29:42.588331
959b5390-05d3-4b24-84bf-165787af8310	BALSAMO PARA PIES Y PIERNAS CANSADOS 250ML	5901350433171	t	13200.00	12600.00	\N	\N	0.00	2025-10-19 02:29:42.588554	2025-10-19 02:29:42.588554
5ea13c4c-a274-43ff-89b2-acaf039a241f	BETUM LIQUIDO PROTEKTOR NEGRO 60ML	7702377486038	t	4800.00	4500.00	\N	\N	0.00	2025-10-19 02:29:42.588776	2025-10-19 02:29:42.588776
af82febe-1416-40b7-9219-d9af70af7a32	BETUM LIQUIDO PROTEKTOR BLANCO 60ML	7702377036660	t	4800.00	4500.00	\N	\N	0.00	2025-10-19 02:29:42.589167	2025-10-19 02:29:42.589167
5f7aa9a2-62ee-4723-a52f-7676e009abea	BETUM LIQUIDP PROTEKTO 60ML	7702377706518	t	4800.00	4500.00	\N	\N	0.00	2025-10-19 02:29:42.589394	2025-10-19 02:29:42.589394
edd2f9d0-c938-436d-a82b-2b498db68fd1	CREMA PARA PEINAR KOLORS PRO 250ML	7700304276219	t	8000.00	7600.00	\N	\N	0.00	2025-10-19 02:29:42.589735	2025-10-19 02:29:42.589735
1eef0cb9-de18-4f92-ab15-1ccc395d8694	DESODORANTE AEROSOL NATURAL FEELING 150ML	7700304021567	t	8400.00	8000.00	\N	\N	0.00	2025-10-19 02:29:42.590025	2025-10-19 02:29:42.590025
475b1f98-ff7e-429b-a42e-4d4a2ec841dd	GUANTES  DOMESTICOS TIDY HOUSE TALLA AMARILLO M	7700304321025	t	3200.00	3100.00	\N	\N	0.00	2025-10-19 02:29:42.590386	2025-10-19 02:29:42.590386
6fe4715c-4278-4e3b-bf76-c72e9c4a9960	GUANTES INDUSTRIAL TIDY HOUSE TALLA MNEGRO	7700304236886	t	3800.00	3620.00	\N	\N	0.00	2025-10-19 02:29:42.590641	2025-10-19 02:29:42.590641
e3ad5c0f-828a-42be-a5b0-cbd9d162b1e3	LIMPIA VIDRIOS BRILLA KING 500ML	7700304233397	t	2700.00	2680.00	\N	\N	0.00	2025-10-19 02:29:42.591234	2025-10-19 02:29:42.591234
dd57c73d-aec4-4cf6-9f9f-7bd7afc37100	DETERGENTE LIQUIDO BONAROPA XTRA 1LITRO	7700304130429	t	6000.00	5700.00	\N	\N	0.00	2025-10-19 02:29:42.591747	2025-10-19 02:29:42.591747
ab74d4ae-c737-4898-b093-fa5bd4fd7cfc	CUCHARA CRISTAL DARNEL X20UNIDADES	7702458015782	t	1300.00	1200.00	\N	\N	0.00	2025-10-19 02:29:42.592106	2025-10-19 02:29:42.592106
2975d305-3c33-40ec-8a7c-e48ac61d8503	BOMBILLO NALPILUX LED 9W	7703255300262	t	2400.00	2250.00	\N	\N	0.00	2025-10-19 02:29:42.592447	2025-10-19 02:29:42.592447
bf00c496-4b9b-470d-ad16-b618dd81b75f	BOMBILLO NALPILUX LED 20W	7703255300309	t	9800.00	9500.00	\N	\N	0.00	2025-10-19 02:29:42.592816	2025-10-19 02:29:42.592816
bb4e9da2-dd58-430e-84cd-330514d62b18	JABON LIQUIDO SUITE ANTIBACTERIAL AVENA 1LITRO	7702538251925	t	8200.00	7950.00	\N	\N	19.00	2025-10-19 02:29:42.593088	2025-10-19 02:29:42.593088
171fb896-366b-4900-af35-ce04c81d67f5	AREQUIPE DEL BOSQUE TETERO 390GR	7708360516379	t	6700.00	6500.00	\N	\N	0.00	2025-10-19 02:29:42.593381	2025-10-19 02:29:42.593381
a65c8386-50e2-45fa-b102-fd6f565f1f57	MIELDATOS PASTILLA X4	7707232095752	t	2000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.593629	2025-10-19 02:29:42.593629
508eba44-1d95-41e7-b292-f14fdd06bf2c	MOSTAZA IDEAL 400GR	7709483153588	t	3800.00	3700.00	\N	\N	0.00	2025-10-19 02:29:42.593874	2025-10-19 02:29:42.593874
9fea9c4e-ca81-4a9a-a66f-433572241389	DICLOFENACO 50MG GENFAR	7702605100866	t	4800.00	\N	\N	\N	0.00	2025-10-19 02:29:42.5941	2025-10-19 02:29:42.5941
042fe735-d89b-4563-96eb-f8645b757e8d	LIMPIADOR CITRONELA BRILLA KING 1L	7700304675548	t	3200.00	3000.00	\N	\N	0.00	2025-10-19 02:29:42.594461	2025-10-19 02:29:42.594461
f1a03731-e21c-478a-aee1-85df49f4a5a3	BIOAQUA LIMPIADOR FACIAL CON CEPILLO	6976068951803	t	9000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.594755	2025-10-19 02:29:42.594755
c57ddbcb-8ec6-4038-98a1-e21073cbf4e7	ESPUMA LIMPIADORA ALOE VERA	7708080149581	t	12500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.595037	2025-10-19 02:29:42.595037
58bab962-eec3-4651-aa54-1ac8baae8855	TUBOS DE ENCRESPAR	2017042133984	t	2500.00	2300.00	\N	\N	19.00	2025-10-19 02:29:42.595313	2025-10-19 02:29:42.595313
fef164f9-3a85-4c34-87c6-1fb07ba5269e	TOALLA SECADORA CABELLO MICROFIBRA	6932077435765	t	5500.00	5300.00	\N	\N	19.00	2025-10-19 02:29:42.595535	2025-10-19 02:29:42.595535
4f38d134-35de-4c44-8536-2ad8bade9c29	BALSAMO LABIAL BIOAQUA	6976623800232	t	2500.00	2200.00	\N	\N	19.00	2025-10-19 02:29:42.595762	2025-10-19 02:29:42.595762
4257f979-8ba5-495d-839e-30cb601af914	BALSAMO LABIAL BIAQUA HOMBRE	6976623805442	t	2500.00	2300.00	\N	\N	19.00	2025-10-19 02:29:42.596119	2025-10-19 02:29:42.596119
ffa49f96-e621-4292-9af2-033d1e536c52	TRATAMIENTO CAOILAR DE ARROZ BIOAQUA	6976068951810	t	8500.00	8300.00	\N	\N	19.00	2025-10-19 02:29:42.596423	2025-10-19 02:29:42.596423
286bff01-717f-4cb4-be19-96ebd0fa12a6	COMPACTO FITBB	6903072416486	t	4800.00	4600.00	\N	\N	19.00	2025-10-19 02:29:42.596677	2025-10-19 02:29:42.596677
72879132-9d03-4d3b-9f21-707860eb4633	WAFER JET MINI X30UNID	7702007086102	t	12400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.596971	2025-10-19 02:29:42.596971
bfe04a5a-c969-4aa1-9e1d-0e04241c8b4b	WAFER JET MINI 6GR	7702007086096	t	500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.597238	2025-10-19 02:29:42.597238
aa177fea-f6ea-49ba-948a-ec12d0d3281c	TUTTI FRUTTI NARANJA 1.5	7702509116130	t	3500.00	3167.00	\N	\N	19.00	2025-10-19 02:29:42.597569	2025-10-19 02:29:42.597569
a92fab0a-0964-43c3-b7aa-f4f246a432c1	BOMBILLO EVEREADY 10W	8888021306880	t	3400.00	3300.00	\N	\N	19.00	2025-10-19 02:29:42.597803	2025-10-19 02:29:42.597803
154ad068-e9d0-4150-9043-22cc9facb687	PURINA SMART EXT 500GR GATO	7702712000608	t	5000.00	4850.00	\N	\N	5.00	2025-10-19 02:29:42.598018	2025-10-19 02:29:42.598018
7b706140-5e87-47e0-a8d4-6d437d89f6f8	ACEITE ISA 2700ML	764451916760	t	21000.00	20500.00	\N	\N	19.00	2025-10-19 02:29:42.598247	2025-10-19 02:29:42.598247
a391f15d-cb30-41c5-abbd-9cae6a12ec4b	PAÑAL WINNY 5X30	7701021116666	t	43000.00	42500.00	\N	\N	19.00	2025-10-19 02:29:42.598529	2025-10-19 02:29:42.598529
36bb4108-2d7e-4798-9455-6258103531dd	INSECTICIDA AEROSOL BLACK FLAG 280ML	891549112053	t	7500.00	7250.00	\N	\N	0.00	2025-10-19 02:29:42.598741	2025-10-19 02:29:42.598741
6a5d1bdd-9bba-446b-b9a5-1c294e3930ca	INSECTICIDA AEROSOL BLACK FLAG 400ML	891549112046	t	12300.00	11900.00	\N	\N	0.00	2025-10-19 02:29:42.598975	2025-10-19 02:29:42.598975
e06b8957-e977-45d6-a0bb-5b75f62fee18	CERA EXPRESS JG ESCARLATA ROJA 400	7713042115917	t	2200.00	2000.00	\N	\N	19.00	2025-10-19 02:29:42.599231	2025-10-19 02:29:42.599231
c577c448-a799-4242-86fd-d4285190b0a1	CERA EXPRESS JG ESCARLATA NEUTRA 400	7713042115894	t	2200.00	2000.00	\N	\N	19.00	2025-10-19 02:29:42.599495	2025-10-19 02:29:42.599495
46954ec0-c9ea-4d09-90da-546abb978342	ROPA COLOR SAN LIMPIDO 1 L	7702140233005	t	3600.00	3500.00	\N	\N	19.00	2025-10-19 02:29:42.599838	2025-10-19 02:29:42.599838
870bd6b7-358c-4fda-bee8-2c83503d9a3f	CEPILLO ROPA TIPO PLANCA PINTO	7702856951934	t	3600.00	3450.00	\N	\N	19.00	2025-10-19 02:29:42.600135	2025-10-19 02:29:42.600135
41f2594e-85a7-43b9-b1cc-5f4d34fcb612	PROTECTORES NOSOTRAS LARGOS X50 UNID	7702027440946	t	9500.00	9000.00	\N	\N	0.00	2025-10-19 02:29:42.60034	2025-10-19 02:29:42.60034
31ee7450-0ac1-4fe3-a1a2-c9838320bee0	MAYOBURGER LA CONSTANCIA 80GR	7702097162243	t	2000.00	1900.00	\N	\N	19.00	2025-10-19 02:29:42.600564	2025-10-19 02:29:42.600564
15fedf41-7402-4e3c-80b8-e0861a330354	NECTAR CALIFORNIA MANZANA 900ML	7702617021425	t	6200.00	5800.00	\N	\N	19.00	2025-10-19 02:29:42.600767	2025-10-19 02:29:42.600767
1155d3e5-412c-4c40-add2-c102f63e99a1	VINAGRE ROJO DELSAZON 500ML	7708162674451	t	1200.00	1100.00	\N	\N	19.00	2025-10-19 02:29:42.601267	2025-10-19 02:29:42.601267
c31b69de-85b9-461d-8b07-5ed4c136c5bc	SHAMPOO NUTRIBELA BIOKERATINA 400ML MAS TRATAMIENTO 300ML	7702354958251	t	31500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.601566	2025-10-19 02:29:42.601566
54400071-c640-483e-821f-b54336243fa8	YUPIS HORNEADOS PICANTIKOS 39GR	7703133014014	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:42.602009	2025-10-19 02:29:42.602009
770b69c0-2583-4542-94c1-1fc0c6d0801a	YUPIS HORNEADOS NATURAL 39GR	7703133014328	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:42.602302	2025-10-19 02:29:42.602302
81e0fb26-bd65-412d-97f0-ca2e368efd88	YUPIS HORNEADOS QUESO 39GR	7703133011525	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:42.60255	2025-10-19 02:29:42.60255
11eb1ace-2a07-40ab-bf64-fec4927633cd	MR BROWN MILO 50GR	7705326839176	t	3100.00	3000.00	\N	\N	19.00	2025-10-19 02:29:42.60278	2025-10-19 02:29:42.60278
45ce3ac1-f649-4010-8e09-2fa3a7e949fe	PAN PERRO BIMBO DORADO X6 UNID	7705326629166	t	7500.00	7400.00	\N	\N	0.00	2025-10-19 02:29:42.603036	2025-10-19 02:29:42.603036
51e49d48-7cfc-46e9-857c-7a100a2d2056	AVENA FINESE ALPINA 250GR	7702001084999	t	3500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.603421	2025-10-19 02:29:42.603421
ec5ff88f-5415-4306-8be8-ae16c9d06cee	SALSA DE TOMATE BARY 150GR	7702439281830	t	2600.00	2450.00	\N	\N	19.00	2025-10-19 02:29:42.603692	2025-10-19 02:29:42.603692
127d135d-0c4a-459e-b84b-f0b49af6ccde	COLCAFE BALANCEADO LIOFILIZADO 47GR	7702032119653	t	9100.00	8800.00	\N	\N	5.00	2025-10-19 02:29:42.603965	2025-10-19 02:29:42.603965
94ad66eb-52b9-4feb-af09-b30cc183f697	CHOCOLISTO CHOCOLATE TARRO 900GR MAS 90GR	7702007085938	t	34500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.604283	2025-10-19 02:29:42.604283
622b0d2b-580d-4ffd-87fd-5c815c0622ea	LECHE CONDENSADA BOSQUE TETERO 390GR	7709990434385	t	6700.00	6500.00	\N	\N	0.00	2025-10-19 02:29:42.604579	2025-10-19 02:29:42.604579
05dd5587-e94c-4e07-98f1-ae0e9beb27e7	CABELLO DE ANGEL CAPRISIMA 250GR	7700304131709	t	1500.00	1400.00	\N	\N	0.00	2025-10-19 02:29:42.604841	2025-10-19 02:29:42.604841
33c0e08f-11a3-4695-872e-20b7852b8ebf	CUBITO GALLINA SPECIARIA X8UNID	7700304660841	t	2300.00	2200.00	\N	\N	0.00	2025-10-19 02:29:42.60519	2025-10-19 02:29:42.60519
d74816eb-0edc-43e2-ac6f-7c5bcee7014d	DELIKA PASTA DE PIMENTON 110GR	7709990012026	t	3200.00	3050.00	\N	\N	0.00	2025-10-19 02:29:42.605465	2025-10-19 02:29:42.605465
4ddfb948-be64-4952-a72e-8c5a398c2981	DELIKA PASTA DE AJO 110GR	7709990927412	t	3200.00	3050.00	\N	\N	0.00	2025-10-19 02:29:42.605703	2025-10-19 02:29:42.605703
c51fa96a-ff50-4954-b378-81aa52823136	MAGIC FRIENDS CACHORRO 1KG	7700304555628	t	6600.00	6400.00	\N	\N	0.00	2025-10-19 02:29:42.605953	2025-10-19 02:29:42.605953
8316a046-a870-42fc-8ca8-33ec2c288c97	WHISKAS POLLO 85GR	7896029046173	t	3300.00	3200.00	\N	\N	0.00	2025-10-19 02:29:42.606183	2025-10-19 02:29:42.606183
8579ff8c-1933-4f49-ab39-4642ba66ee4e	ARENA PARA GATOS MAGIC FRIDENDS 4KG	7700304079568	t	17800.00	17200.00	\N	\N	0.00	2025-10-19 02:29:42.606406	2025-10-19 02:29:42.606406
cc5ed460-d61f-4229-90bf-ee7049794e98	BOLSA BASURA RESISTENTE NEGRA X10	7700304151462	t	2300.00	2200.00	\N	\N	0.00	2025-10-19 02:29:42.606636	2025-10-19 02:29:42.606636
41c01315-187b-451d-9469-adc84d44e0d9	PAÑO ADSORBENTE TIDY HOUSE	7700304493647	t	1400.00	1300.00	\N	\N	0.00	2025-10-19 02:29:42.606868	2025-10-19 02:29:42.606868
d48e0b20-4f02-4f22-8546-bec8e0a02192	SHAMPOO NATURAL FEELING BOTANICALS 600ML	7700304194315	t	10500.00	10000.00	\N	\N	0.00	2025-10-19 02:29:42.607093	2025-10-19 02:29:42.607093
e5696c5d-84a7-4f39-8016-d48f2ba643e7	SHAMPOO NATURAL FEELING BOTANICALS COCO 600ML	7700304667147	t	10500.00	10000.00	\N	\N	0.00	2025-10-19 02:29:42.607321	2025-10-19 02:29:42.607321
2b3d01b1-c4a0-4b51-a4e9-943d48adfdb5	AGUA MICELAR DELIA 200ML	5906750847306	t	5400.00	5200.00	\N	\N	0.00	2025-10-19 02:29:42.607509	2025-10-19 02:29:42.607509
34fce31e-a1f2-418e-a5db-3e4909c771e1	DETERGENTE BONAROPA XTRA PODER 3 LITROS	7700304587636	t	15000.00	14600.00	\N	\N	0.00	2025-10-19 02:29:42.607722	2025-10-19 02:29:42.607722
571949bb-575f-4552-8bf6-c7ca3cd4fc80	DETERGENTE BONAROPA BABY 1LITRO	7700304534746	t	9500.00	9150.00	\N	\N	0.00	2025-10-19 02:29:42.607938	2025-10-19 02:29:42.607938
d12490d0-2d86-4cb6-9b46-5df165e09aba	SUAVIZANTE BONA ROPA FLORAL 1 LITRO	7700304924462	t	4200.00	4000.00	\N	\N	0.00	2025-10-19 02:29:42.608174	2025-10-19 02:29:42.608174
d8f87d08-fac6-4f1b-b764-9c81c0b9bf2a	SUAVIZANTE BONAROPA MANZANA 1LITRO	7700304507962	t	4200.00	4000.00	\N	\N	0.00	2025-10-19 02:29:42.608406	2025-10-19 02:29:42.608406
004126c1-8aa5-4cee-99e9-008ea598bbae	TOALLITAS LITLE ANGELS X10	7700304673650	t	1300.00	1250.00	\N	\N	0.00	2025-10-19 02:29:42.609012	2025-10-19 02:29:42.609012
17d4a7fa-0e4e-4092-afd8-182d671d75d0	LECHE ALGARRA 1 LITRO	7702477417017	t	3000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.609242	2025-10-19 02:29:42.609242
64f9ae3a-7aa3-49d8-aced-4dc0b25dceac	PAPEL RENDY X12 UNID	7700304309122	t	16500.00	16000.00	\N	\N	0.00	2025-10-19 02:29:42.609461	2025-10-19 02:29:42.609461
af5b7850-e038-4fd0-b695-58af2cb0f197	DETERGENTE BARRA LIQUIDO BRILLA KING 1 LITRO	7708276719185	t	5400.00	5200.00	\N	\N	0.00	2025-10-19 02:29:42.609667	2025-10-19 02:29:42.609667
97f4d889-5689-48a3-8f82-2972a1c4578c	DETERGENTE BONAROPA 900GR	7700304211180	t	4200.00	4000.00	\N	\N	0.00	2025-10-19 02:29:42.609865	2025-10-19 02:29:42.609865
619392ad-c96a-4e3a-a93b-6ccf307da4bc	SHAMPOO PARA BEBE LITLE ANGELS 360ML	7700304273140	t	6000.00	5800.00	\N	\N	0.00	2025-10-19 02:29:42.610092	2025-10-19 02:29:42.610092
cc38a328-9e25-4270-b0c4-d244d9851509	YOGUR ALQUERIA MIX170G	7707331407791	t	4000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.610469	2025-10-19 02:29:42.610469
5e374c89-53c8-42a3-802d-0147ab12231c	SCOTT RINDEMAX	7702425093416	t	1100.00	984.00	\N	\N	0.00	2025-10-19 02:29:42.610752	2025-10-19 02:29:42.610752
abb6b82d-b38f-4a47-b97e-638948e8cb52	QUITA MANCHAS LIQUIDO AZULK EXTRA 500ML	7702310043151	t	3600.00	3500.00	\N	\N	19.00	2025-10-19 02:29:42.610968	2025-10-19 02:29:42.610968
f898d1bc-1d12-44a3-8f34-679fd49f0242	TRAS LAVALOZA LIMON BARRA 300GR	7708669890521	t	2100.00	1950.00	\N	\N	19.00	2025-10-19 02:29:42.611229	2025-10-19 02:29:42.611229
43751dbc-dee1-4fee-bc2c-6ab1940caa8c	MOPA TRAPERO BLANCO N500	MOPAA	t	4000.00	3700.00	\N	\N	19.00	2025-10-19 02:29:42.611461	2025-10-19 02:29:42.611461
0cd2c4ed-aba6-4bfc-89f5-dfdd93983f84	ROPA COLOR FULL FRESH 1 LITRO	7702856009918	t	8000.00	7800.00	\N	\N	0.00	2025-10-19 02:29:42.611755	2025-10-19 02:29:42.611755
efa76d52-2c5e-414e-8670-886d31f9aaba	PILAS ENERGIZER AAA	039800014009	t	4400.00	4250.00	\N	\N	19.00	2025-10-19 02:29:42.612106	2025-10-19 02:29:42.612106
ef9b0b5f-9e43-492f-ad79-07a1822faba8	PILAS ENERGIZER AA	039800015464	t	4400.00	4250.00	\N	\N	19.00	2025-10-19 02:29:42.612381	2025-10-19 02:29:42.612381
b1b90d2e-22ed-477d-afd0-c61b475cdd45	GELATINA FRUTIÑO FRESA LINE 11GR	7702354956929	t	2200.00	2070.00	\N	\N	19.00	2025-10-19 02:29:42.612616	2025-10-19 02:29:42.612616
8d990522-366d-4a22-839e-bb346942c240	GELATINA FRUTIÑO CEREZA LINE 11GR	7702354956936	t	2200.00	2070.00	\N	\N	19.00	2025-10-19 02:29:42.612828	2025-10-19 02:29:42.612828
7dfd19ba-00ac-45fb-9950-5e9a8f0d7c74	GELATINA FRUTIÑO FRUTOS ROJOS LINE 11GR	7702354956905	t	2200.00	2070.00	\N	\N	19.00	2025-10-19 02:29:42.613068	2025-10-19 02:29:42.613068
ff39ed6b-f88b-422a-b9f3-d412241df814	GELATINA FRUTIÑO NARANJA LINE 11GR	7702354956912	t	2200.00	2070.00	\N	\N	19.00	2025-10-19 02:29:42.613292	2025-10-19 02:29:42.613292
f4a5792e-ff86-43af-aa24-f30b6d6d6806	GELATINA FRUTIÑO PIÑA LINE 11GR	7702354956875	t	2200.00	2070.00	\N	\N	19.00	2025-10-19 02:29:42.613517	2025-10-19 02:29:42.613517
4bf816b5-c95e-42e2-89c9-30a003122db5	SALCHICHON GALVICARNES AHUMADO	77095307743	t	7300.00	7100.00	\N	\N	19.00	2025-10-19 02:29:42.613748	2025-10-19 02:29:42.613748
b9be66c9-83da-4df3-b80e-5d046c6166bd	YOGUETA MIXCHOCOLATE  X24 UNID	7702174084024	t	7600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.613947	2025-10-19 02:29:42.613947
4b6d886c-8ea6-4cfd-9251-d443b1e57c1f	SALCHICHA DELICHICKS X6	7700506019737	t	12600.00	12300.00	\N	\N	0.00	2025-10-19 02:29:42.614173	2025-10-19 02:29:42.614173
ece17a72-2a61-4b0c-b2e6-3e60df1f1a78	PAÑITOS NATURAL WIPES X40UNID	6944970601352	t	3300.00	3100.00	\N	\N	0.00	2025-10-19 02:29:42.614411	2025-10-19 02:29:42.614411
76bb3dd1-85eb-452c-9a03-97c90113e007	PAÑOTOS HUMEDOS DAULYN X80	7709990618235	t	4200.00	4000.00	\N	\N	0.00	2025-10-19 02:29:42.614627	2025-10-19 02:29:42.614627
ed2667c4-3bf5-4196-a56f-4eec4ac3585a	LISTERINE ORIGINAL 500ML	7702035431110	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:42.614834	2025-10-19 02:29:42.614834
b7ff2924-857a-4935-8d27-47d56fca0abb	PAN TAJADO ARTESANAL BIMBO SABOR A MANTEQUILLA 500GR	7705326079442	t	7900.00	7750.00	\N	\N	0.00	2025-10-19 02:29:42.615055	2025-10-19 02:29:42.615055
3acd85fb-f6c2-4add-b7c3-db68c157a301	SHAMPOO NUTRIBELA 400ML MAS NUTRIBELA 300ML	7702354956387	t	31500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.615274	2025-10-19 02:29:42.615274
bed36921-7443-4c8d-9dfa-2e22838689ec	AMPOLLA ELIXIR REVITALIZANTE MILAGROS 30ML	7708075180940	t	10000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.615456	2025-10-19 02:29:42.615456
0e0481d5-bc25-46d0-a367-4f3cee4195bc	CHOCOLATINA JET LECHE X24UNID MAS BALONES X18	7702007080506	t	27000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.615775	2025-10-19 02:29:42.615775
07d54647-e351-4a30-ad92-7dab3956aa82	LECHE EN POLVO MILK 360	7708486368364	t	8800.00	8500.00	\N	\N	0.00	2025-10-19 02:29:42.616006	2025-10-19 02:29:42.616006
7ad8896a-219d-40ab-9804-7bc9c174d22d	FORTIDENT CUATRIACCION TOTAL 76GR	7891150083899	t	2700.00	2584.00	\N	\N	19.00	2025-10-19 02:29:42.616206	2025-10-19 02:29:42.616206
20d33cb9-7065-4b08-9ddc-5f9fa26b4c07	VARSOL ECOLOGICO PINTO 500ML	7702856952450	t	6000.00	5830.00	\N	\N	0.00	2025-10-19 02:29:42.616421	2025-10-19 02:29:42.616421
efe09784-67d6-4efa-adbc-1893309d4291	SILICONA LIQUIDA 100ML OFFI ESCO	7709023412045	t	4400.00	4100.00	\N	\N	0.00	2025-10-19 02:29:42.616644	2025-10-19 02:29:42.616644
41c96788-b735-44db-9062-30467e559fa3	SILICONA LIQUIDA 60ML OFFI ESCO	7709023412090	t	3000.00	2850.00	\N	\N	0.00	2025-10-19 02:29:42.616846	2025-10-19 02:29:42.616846
f10a5979-7788-4dab-92e1-89f1131d7f22	WAFER ITALO MI DIA X18UNID	7700149375030	t	5600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.617044	2025-10-19 02:29:42.617044
727a43bc-f2a3-4055-bcb9-db5e69c849e9	DETERGENTE LIQUIDO BONAROPA PRENDAS OSCURAS 1L	7700304345373	t	7600.00	7250.00	\N	\N	0.00	2025-10-19 02:29:42.617265	2025-10-19 02:29:42.617265
be433744-226b-418b-99ad-ff340453fc58	DETERGENTE LIQUIDO BONAROPA 1L	7700304551019	t	4800.00	4600.00	\N	\N	19.00	2025-10-19 02:29:42.617517	2025-10-19 02:29:42.617517
5f0a2854-4909-43af-a148-0f1d85b967b0	QUITAMANCHAS BONAROPA ROPA BLANCA 1L	7700304484546	t	4700.00	4500.00	\N	\N	19.00	2025-10-19 02:29:42.617753	2025-10-19 02:29:42.617753
7230bbee-5c6b-450f-8451-cecae6ff718c	BLANQUEADOR GEL BRILLA KING 1L	7700304572687	t	6600.00	6300.00	\N	\N	19.00	2025-10-19 02:29:42.617988	2025-10-19 02:29:42.617988
073d2190-2d11-4b86-9cec-e7f7d3e75705	TOALLAS COCINA RENDY PREMIUM TRIPLE	7700304210534	t	2400.00	2300.00	\N	\N	0.00	2025-10-19 02:29:42.618216	2025-10-19 02:29:42.618216
021f80e3-d437-4fea-9f15-77133e886560	PROTECTORES FRESH Y FEE X15 UNID	7700304839766	t	1500.00	1380.00	\N	\N	19.00	2025-10-19 02:29:42.618467	2025-10-19 02:29:42.618467
fe92b7f9-64cb-42bc-957f-ae07c3690b13	LIMPIADOR TODO EN 1 BRILLA KING 500ML	7700304699490	t	5000.00	4800.00	\N	\N	0.00	2025-10-19 02:29:42.618697	2025-10-19 02:29:42.618697
8673da3c-381d-4f50-a79b-1535a2886784	ACONDICIONADOR KOLORS PRO 400ML	7700304028733	t	9400.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.618893	2025-10-19 02:29:42.618893
9d4eeae1-7229-4f8b-b7cb-a5da127017ec	ANTIBACTERIAL Y HUMECTANTE NATURAL NATURAL FREELING 135ML	7700304199570	t	3700.00	3600.00	\N	\N	19.00	2025-10-19 02:29:42.619793	2025-10-19 02:29:42.619793
22b16c17-11f1-44ca-aa75-54b61c6a3bb3	ANTIBACTERIAL Y HUMECTANTE NATURAL FEELING 135ML	7700304164233	t	3700.00	3600.00	\N	\N	19.00	2025-10-19 02:29:42.620088	2025-10-19 02:29:42.620088
07449599-6cbc-4eec-8b47-c0312867eb72	ANTIBACTERIAL Y HUMECTANTE NATURAL FEELING 135ML	7700304895540	t	3700.00	3600.00	\N	\N	19.00	2025-10-19 02:29:42.620352	2025-10-19 02:29:42.620352
4177afee-fd71-4f75-aacc-622006123615	ACONDICIONADOR KOLORS BRILLO Y SUAVIDAD 400ML	7700304773596	t	9400.00	9200.00	\N	\N	19.00	2025-10-19 02:29:42.620563	2025-10-19 02:29:42.620563
338eac65-7491-46c9-bffb-3c65c2ea4344	JABON BARRA COCO 200GR	7708276719413	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:42.620796	2025-10-19 02:29:42.620796
0f0977ea-7a12-4ef6-867a-082fb72208fe	AROMATICAS TOSH X20 24G FRUTOS ROJOS	7702032113132	t	8000.00	7800.00	\N	\N	19.00	2025-10-19 02:29:42.62108	2025-10-19 02:29:42.62108
1c95f170-3dc9-4045-90a1-3611cb319138	AROMATICAS TOSH X20 19G MANZANILLA Y LIMONCILLO	7702032119417	t	5500.00	5300.00	\N	\N	19.00	2025-10-19 02:29:42.621297	2025-10-19 02:29:42.621297
5581f5f8-a6d1-46d7-87b3-dba40c4a3e1b	FESTIVAL MUNDO SECRETO 10X4 METEORITO ACIDO	7702025151547	t	10800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.621516	2025-10-19 02:29:42.621516
a6c5e894-0981-4b5b-b4a7-607f05d7fc41	SALSA CHINA REYES 175ML	7708162674413	t	2100.00	1950.00	\N	\N	19.00	2025-10-19 02:29:42.621734	2025-10-19 02:29:42.621734
37ba7d52-17e9-4875-a8bc-9aa6d3525888	2500	JABON BONAROPA BARRA VETEADO 250G	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.621948	2025-10-19 02:29:42.621948
ac9f3b8a-2a31-4557-a5a4-ede185a41221	JABON VETEADO BONAROPA 250G	7700304725779	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:42.622194	2025-10-19 02:29:42.622194
1e763b69-f225-482a-99ee-8e24b6d85dbc	SHAMPOO KERATINA 18G	7500435241038	t	1000.00	767.00	\N	\N	19.00	2025-10-19 02:29:42.622426	2025-10-19 02:29:42.622426
f55c4d93-b7af-4f0d-8dc1-b10214fe091c	BOCADILLO HOJA PRINCIPE X18	7709584249869	t	6300.00	\N	\N	\N	0.00	2025-10-19 02:29:42.622659	2025-10-19 02:29:42.622659
c607dff4-c56d-4ac1-ae10-956161e526d1	TINTE LISSIA 7.3	7703819301964	t	8900.00	8500.00	\N	\N	19.00	2025-10-19 02:29:42.622879	2025-10-19 02:29:42.622879
e7f7c1a7-2025-4c56-af05-1fa6e705026e	HUGOHIT 1 LITRO CAJA	7707133055053	t	4200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.623085	2025-10-19 02:29:42.623085
ff512397-4097-4194-969b-6ea4024bbc83	HIT NARANJA PIÑA 500ML	7707133044033	t	2500.00	2292.00	\N	\N	19.00	2025-10-19 02:29:42.623317	2025-10-19 02:29:42.623317
7efc0f4a-32b5-43ee-b291-4f3c2fb4e952	KOLA FULL MK 25G	7702057737146	t	1700.00	1550.00	\N	\N	0.00	2025-10-19 02:29:42.62351	2025-10-19 02:29:42.62351
6bd6a82c-cf76-45c9-a84b-40fc328abca5	TORNILLO PUGLIESE 1000G	7702020061537	t	3500.00	3334.00	\N	\N	5.00	2025-10-19 02:29:42.623727	2025-10-19 02:29:42.623727
bcd6dd88-494a-497f-9d03-83537b5f9b0e	MISTOLIN IN PLUS 1L	7701019910399	t	2400.00	2300.00	\N	\N	19.00	2025-10-19 02:29:42.623934	2025-10-19 02:29:42.623934
09867eb3-bf09-4e72-ab3c-537924512869	SHAMPOO HEAD SHOULDERS COCO 180ML	7500435142564	t	12000.00	11500.00	\N	\N	19.00	2025-10-19 02:29:42.624154	2025-10-19 02:29:42.624154
3d055d47-06a9-4869-9898-a163046e905d	COBERTURA SEMIAMARGA DLUCHY 500GR	7707165872482	t	11000.00	10600.00	\N	\N	19.00	2025-10-19 02:29:42.624344	2025-10-19 02:29:42.624344
996a5a20-f9ff-4e63-9bd1-29c7963fc702	GUANTES TIDY HOUSE NEGRO M INDUSTRIAL	7700304373123	t	3800.00	3650.00	\N	\N	19.00	2025-10-19 02:29:42.624542	2025-10-19 02:29:42.624542
f7ebbcc7-7f87-42ae-a043-ac3e498500a3	CHOCOLATE CORONA CLAVO CANELA 200G	7702007085488	t	7000.00	6800.00	\N	\N	19.00	2025-10-19 02:29:42.624747	2025-10-19 02:29:42.624747
aadf976c-0890-4279-90d2-e8fcf3b1a9da	JABON CREMOSO LITTLE ANGELS X3	7700304002115	t	6000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.624963	2025-10-19 02:29:42.624963
9adaedd6-2d28-4932-8dd0-bebee28e6493	AROMATEL FRAMBUESA 180G	7702191164853	t	1600.00	1450.00	\N	\N	19.00	2025-10-19 02:29:42.625182	2025-10-19 02:29:42.625182
d409e040-470e-4471-8db7-1e21c55205f0	DETODITO NATURAL 80GR	7702189059277	t	4200.00	4000.00	3900.00	\N	19.00	2025-10-19 02:29:42.625379	2025-10-19 02:29:42.625379
c6df1a84-5a21-498b-b094-1719813452ef	AROMATEL FRAMBUESA 400ML	7702191164846	t	2700.00	2600.00	\N	\N	19.00	2025-10-19 02:29:42.625615	2025-10-19 02:29:42.625615
c598047b-3e93-4743-8590-8da18726b0da	GUANTES HOUSE DOMESTICO AMARILLO M	7700304684823	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:42.625838	2025-10-19 02:29:42.625838
862c70eb-ba0e-41f7-ba24-5dac73489607	DURAZNOS ALMIBAR 1000G CARVAJAL MALDONADO	658325393576	t	9100.00	8800.00	\N	\N	19.00	2025-10-19 02:29:42.626087	2025-10-19 02:29:42.626087
ec235afb-6267-4afa-9f0a-790ffb370003	DURAZNOS ALMIBAR 500G CARVAJAL MALDONADO	658325393583	t	4900.00	4730.00	\N	\N	19.00	2025-10-19 02:29:42.626454	2025-10-19 02:29:42.626454
3a600af2-7d93-42e0-904b-411ad65a9467	JUGO CALIFORNIA 215	7702617021135	t	2400.00	2200.00	\N	\N	0.00	2025-10-19 02:29:42.626725	2025-10-19 02:29:42.626725
ea400140-9e3a-45f0-95e9-9fafeedde98a	CLORO YES 1800ML	7702560045110	t	7200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.626966	2025-10-19 02:29:42.626966
26654a94-15cb-49ed-bb16-d60ceb8552a0	PÁPA MARGARITA ONDULADAS CHPROZP L 36G	7702189059918	t	2400.00	2250.00	\N	\N	0.00	2025-10-19 02:29:42.627304	2025-10-19 02:29:42.627304
02729717-92c6-463a-8033-5ca5cb5f8a79	SHAMPOO NUTRIBELA BIOKERATINA  18ML	7702354958138	t	1000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.627561	2025-10-19 02:29:42.627561
92a06fe6-1808-4b2b-85be-3e1c08f1e17c	ACONDICONADOR SAVITAL 100ML	7702006406499	t	3200.00	3100.00	\N	\N	19.00	2025-10-19 02:29:42.627806	2025-10-19 02:29:42.627806
2e3a30f3-3d09-491f-b3b0-c4ba1bc52b7e	ACONDICIONADOR NUTRIBELA BIOKERATINA 370ML	7702354958121	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:42.628039	2025-10-19 02:29:42.628039
ce8b88de-d6a9-419c-8215-c97ff6768c7e	SHAMPOO NUTRIBELA BIOKERATINA 400ML	7702354958114	t	19500.00	19000.00	\N	\N	19.00	2025-10-19 02:29:42.628298	2025-10-19 02:29:42.628298
914119e0-63b2-4980-9414-c07dd304675d	YOGOLIN MIX GRAGEAS	7705241826206	t	2600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.628552	2025-10-19 02:29:42.628552
7a252b13-fa03-4da5-9073-ebdce17e21d9	HEAD SHOULDER DERMA SENSITIVE 375ML	7500435148061	t	18000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.628778	2025-10-19 02:29:42.628778
d4cbe5e5-3925-4780-a55b-5ddca75ec4a2	AGUA BRISA 1 L	7702535013830	t	2200.00	1900.00	\N	\N	0.00	2025-10-19 02:29:42.628981	2025-10-19 02:29:42.628981
d30b750f-81ed-43b4-8f24-288f12969bba	DETERGENTE 3D BICARBONATO 1KG	7702191452066	t	9100.00	\N	\N	\N	19.00	2025-10-19 02:29:42.629284	2025-10-19 02:29:42.629284
274e5ee5-cc22-44fc-8c7a-22a4864c2c9a	SHAMPOO SAVITAL ACEITE DE ARGAN 510ML	7702006208581	t	14500.00	14000.00	\N	\N	19.00	2025-10-19 02:29:42.629923	2025-10-19 02:29:42.629923
c10df7f3-6928-4585-b7ef-58b793175e65	JUMBO FLOW MINI 18GR	7702007040241	t	1400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.630193	2025-10-19 02:29:42.630193
22d5531e-a33c-44ad-9649-16acbf122607	PAPAS MARGARITA	7702189056023	t	2400.00	\N	\N	\N	0.00	2025-10-19 02:29:42.630494	2025-10-19 02:29:42.630494
8ff0bf6d-5c7f-4529-904f-b35fee83f13e	GUANTES GLOVAL TALLA 8	7707177700230	t	5700.00	\N	\N	\N	0.00	2025-10-19 02:29:42.63081	2025-10-19 02:29:42.63081
98e5dc8a-dbff-4b94-8e8b-1d253a15ce4d	AMBIENTADOR BON AIR X3	7702532312295	t	25000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.631101	2025-10-19 02:29:42.631101
1396ccd1-b378-438b-9e51-3dff455387dc	GEL ROLDA 1.000GR	7707342220617	t	22000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.63142	2025-10-19 02:29:42.63142
672c745c-da84-4c1e-b7bb-341606ed62f7	DORITOS SABOR BBQ DULCE 41GR	7702189060006	t	2600.00	2500.00	2390.00	\N	0.00	2025-10-19 02:29:42.6318	2025-10-19 02:29:42.6318
3bea021a-b175-4a39-83ee-d577c5e27f5c	MANI MOTO SALADO 36GR	7702189056382	t	2000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.632096	2025-10-19 02:29:42.632096
6d317b8f-93d3-4dff-9162-8711b9e58c14	LONCHERA FRITO LAY X12	7702189226877	t	13600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.63235	2025-10-19 02:29:42.63235
fb7b1b71-96c5-48f6-bb2d-63432470f96e	CHOKIS CHOCOLATOSO 19GR	7702189011251	t	1700.00	\N	\N	\N	19.00	2025-10-19 02:29:42.632614	2025-10-19 02:29:42.632614
ff179a45-58e0-4c5d-b5f0-990899a346b9	NUTRIBELA NUTRIVION 27ML	7702354942212	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.632864	2025-10-19 02:29:42.632864
8217c42d-abec-435d-8e5c-0b7bb93c10f7	LIMPIAPISOS FULLER FRESH LAVANDA 3785ML	7702856007730	t	17200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.63313	2025-10-19 02:29:42.63313
19b125e8-f916-4c9c-a439-57a815b4895f	PAPAS MARGARITA MAYONESA	7702189057815	t	2400.00	\N	\N	\N	19.00	2025-10-19 02:29:42.633409	2025-10-19 02:29:42.633409
16db1ec6-f3df-4669-ab2d-6045ab5de6f0	SALMON MAR 170GR	7591002700201	t	4900.00	4750.00	\N	\N	0.00	2025-10-19 02:29:42.633655	2025-10-19 02:29:42.633655
52e5ed4c-2be7-4bf0-83af-89b80723d267	ELECTROLIC DE MARACUYA 625ML	7501125184864	t	7400.00	7180.00	\N	\N	19.00	2025-10-19 02:29:42.633895	2025-10-19 02:29:42.633895
8da0270c-d68e-4d5b-bd78-703202de660a	NUTRIBELA PRO HIALURONICO 27ML	7702354957254	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.634139	2025-10-19 02:29:42.634139
724ee42a-4eb0-4725-be91-e87ea2bf25fe	PAPAS MARGARITA POLLO BOLSAZA 75GR	7702189059666	t	4200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.63436	2025-10-19 02:29:42.63436
5201abeb-0776-4478-80af-a9f205d04d1a	FLUOCARDENT 75ML	7702560049996	t	3300.00	3150.00	\N	\N	0.00	2025-10-19 02:29:42.6346	2025-10-19 02:29:42.6346
de2cd31f-408c-42b2-b2bc-a58f447dfcba	GOL MINI	7702007080568	t	800.00	\N	\N	\N	0.00	2025-10-19 02:29:42.634827	2025-10-19 02:29:42.634827
1c2a48dd-e65d-447d-b155-5f4ff0809e16	DETODITO LIMON  FAMILIAR 165GR	7702189057648	t	7600.00	\N	\N	\N	0.00	2025-10-19 02:29:42.635091	2025-10-19 02:29:42.635091
847404a6-bbd5-446f-ae9f-ab1afc050a72	TRIDENRTE X60	7622201765118	t	12600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.635322	2025-10-19 02:29:42.635322
c340211f-a141-46fe-8b82-d9cb175dfdd0	AROMATICAS MI DIA BUENAS NOCHES 20GR X20 SOBRES	7700149385572	t	3100.00	3000.00	\N	\N	0.00	2025-10-19 02:29:42.635598	2025-10-19 02:29:42.635598
91c95552-8508-42a7-99c0-339d85966e27	AROMATICAS MI DIA DESPUES DE COMIDA 20GR X20UNID	7700149385589	t	3100.00	3000.00	\N	\N	0.00	2025-10-19 02:29:42.63585	2025-10-19 02:29:42.63585
e8c32275-deaa-40b5-86f0-51af96c4fdd5	SHAMPOO Y ACONDICIONADOR NUTRIBELLA MAS TRATAMIENTO	7702354957315	t	47500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.636086	2025-10-19 02:29:42.636086
58f0637a-b591-4ead-a801-9821d598aaf3	YOGURT GRIEGO LA MEJOR 1KILO	7705241923899	t	23000.00	20500.00	20000.00	\N	0.00	2025-10-19 02:29:42.636385	2025-10-19 02:29:42.636385
d9fcb3c2-ebf1-49fa-89ea-d7ca2ed6db25	PAPAS MARGARITA FLAMIN	7702189058614	t	2400.00	\N	\N	\N	0.00	2025-10-19 02:29:42.636653	2025-10-19 02:29:42.636653
53448927-eb69-4e49-97f8-c645cbc7c9ee	COPITOS ECOLOGICOS X50UNI	7702208146100	t	2600.00	2450.00	\N	\N	0.00	2025-10-19 02:29:42.636948	2025-10-19 02:29:42.636948
5b83897f-a8f6-4645-b9ce-25f8a3af181e	JABON LAK SENSACION	7702310020862	t	1900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.63723	2025-10-19 02:29:42.63723
c6bb5448-cb2a-4614-91e8-fe0d0ed6911b	TOALLA COSINA NUBE 120HJ	7707151602208	t	8200.00	7900.00	\N	\N	19.00	2025-10-19 02:29:42.63748	2025-10-19 02:29:42.63748
610409cb-44c3-41d6-87b0-f39ae07149c9	JUGO HIT LULO 300ML	7707133074429	t	2000.00	1750.00	\N	\N	19.00	2025-10-19 02:29:42.637737	2025-10-19 02:29:42.637737
8af9e336-99e8-4153-88a2-21dd47c7fce7	JUGO HIT FRUTAS TROPICALES 300ML	7707133074412	t	2000.00	1750.00	\N	\N	19.00	2025-10-19 02:29:42.638013	2025-10-19 02:29:42.638013
8025b8e2-2fab-4ccb-bad9-88bac4a8676d	SUAVITEL VERDE	7509546689050	t	1500.00	1450.00	\N	\N	19.00	2025-10-19 02:29:42.638252	2025-10-19 02:29:42.638252
e1ec0fd3-ce02-422a-a35e-e8616abd6493	TRIDENT X60	7622201764999	t	14000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.638504	2025-10-19 02:29:42.638504
e7607090-4c87-4562-90d1-1109b0da3b9b	SHAMPOO ACONDICIONADOR Y TRATAMIENTO NUTRIBELLA	7702354957308	t	47500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.638777	2025-10-19 02:29:42.638777
c0f742ed-648d-44af-b6c4-0ef4f20697ed	JUGO HIT 1.5 NARANJA PIÑA	7707133022710	t	4500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.63903	2025-10-19 02:29:42.63903
97cf59c5-7c72-4047-b608-37c500e37ab5	PALILLOS CHEVERE X180UNI	7707339930673	t	700.00	600.00	\N	\N	0.00	2025-10-19 02:29:42.639309	2025-10-19 02:29:42.639309
184e28f4-b4c3-42bc-83b8-94df2870954d	AZUCAR VALERY 1K	7708977697966	t	4000.00	3880.00	\N	\N	0.00	2025-10-19 02:29:42.639598	2025-10-19 02:29:42.639598
8aeb1005-74f2-4aab-b233-37eceec8f248	JABON LIQUIDO DOVE BABY 200ML	7891150025981	t	15800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.639862	2025-10-19 02:29:42.639862
91bdd3fc-8e15-4364-ab10-9b012ade5caa	TRIDENT MENTA MAS FUERTE X60UNID	7622202244032	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.640135	2025-10-19 02:29:42.640135
d52a3c3b-addb-47da-9164-653654a4ac16	LIMPIADOR FULL FRESH CANELA 3785ML	7702856007600	t	16600.00	16200.00	\N	\N	19.00	2025-10-19 02:29:42.640401	2025-10-19 02:29:42.640401
bd31c825-663d-4467-82eb-68afd32d7544	TRIDENT MENTA X60UNID	7622201765088	t	14000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.640648	2025-10-19 02:29:42.640648
59566733-6f47-41d3-a082-b6a19de0b363	TRIDENT X18UNID MORA AZUL	7622201776688	t	23500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.641392	2025-10-19 02:29:42.641392
ff7ed537-43f7-4686-938c-312ff2c5d3d3	FRUTIÑO MANGO DULCE 10GR	7702354955915	t	1000.00	890.00	\N	\N	19.00	2025-10-19 02:29:42.641704	2025-10-19 02:29:42.641704
187098e9-769c-46c6-ab43-8048f397c449	WAFER MILO	7702024181729	t	2000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.64196	2025-10-19 02:29:42.64196
f0598302-c4e7-42ae-a2cc-96aab9efd244	BUBBALOO FRUTAS X47UNID	7622202222023	t	10300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.642248	2025-10-19 02:29:42.642248
abf744cf-bf6c-4743-b536-91fe8aa837ab	PAPAS CHILOE 500GR	7709733550631	t	5100.00	4950.00	\N	\N	0.00	2025-10-19 02:29:42.6425	2025-10-19 02:29:42.6425
3f5794ee-c87a-4d98-8397-613155c58b48	JUGO CELEMA MANGO 200ML	7705436094830	t	1100.00	1000.00	\N	\N	19.00	2025-10-19 02:29:42.642727	2025-10-19 02:29:42.642727
1f0770e0-1c21-4fec-95d2-81bd998de82c	LECHE ENTERA COLANTA 900ML	7702129003674	t	3300.00	3150.00	\N	\N	0.00	2025-10-19 02:29:42.642933	2025-10-19 02:29:42.642933
6e01188c-70fd-4acc-ab9f-e7aaa5ba2f21	SALCHICHA WEST RANCHERA COLANTA DUO	7702129073356	t	3000.00	2900.00	\N	\N	19.00	2025-10-19 02:29:42.6432	2025-10-19 02:29:42.6432
4512b5d6-6ff2-4992-b026-37747bedbfa4	SALCHICHA WEST RANCHERA COLANTA X12UNID	7702129073370	t	16400.00	16200.00	\N	\N	19.00	2025-10-19 02:29:42.643685	2025-10-19 02:29:42.643685
db0abe0a-8dc1-40f3-8b5e-1b3e30e2380e	LECHE DESLACTOSADA COLANTA 900ML	7702129003704	t	4200.00	4100.00	4000.00	\N	0.00	2025-10-19 02:29:42.643958	2025-10-19 02:29:42.643958
f25c3c02-d181-4e54-b67b-423c5cc659de	LECHE DESLACTOSADA COLANTA 400ML	7702129004510	t	2200.00	2100.00	2000.00	\N	0.00	2025-10-19 02:29:42.644223	2025-10-19 02:29:42.644223
dc913191-0fc9-4e38-bd13-7e7a7b518a3e	QUESO PARMESANO RALLADO 40GR	7702129019316	t	4800.00	4700.00	\N	\N	0.00	2025-10-19 02:29:42.644466	2025-10-19 02:29:42.644466
0bc40239-7910-4562-9bca-4bb4314d87ee	QUESO CREMA COLANTA 150GR	7702129025034	t	3600.00	3500.00	\N	\N	0.00	2025-10-19 02:29:42.644721	2025-10-19 02:29:42.644721
d3977452-e13d-48d4-9878-080a212b922f	QUESO CREMA COLANTA 400GR	7702129025157	t	8800.00	8600.00	\N	\N	0.00	2025-10-19 02:29:42.645216	2025-10-19 02:29:42.645216
e41c17c5-55f6-41dd-9310-d3ffea02ea63	CREMA DE LECHE COLANTA 870GR	7702129035514	t	18600.00	18300.00	\N	\N	0.00	2025-10-19 02:29:42.645699	2025-10-19 02:29:42.645699
66752cdb-f1fc-46bf-b28e-91b0cf299bbc	SUPER COOM AZUCARADAS COLANTA 170GR	7702129047326	t	2700.00	\N	\N	\N	0.00	2025-10-19 02:29:42.646017	2025-10-19 02:29:42.646017
2a96bcfb-6cc3-407a-8341-f7aff0ab737d	SALCHICHON CERVECERO COLANTA 500GR	7702129074100	t	12500.00	12300.00	\N	\N	5.00	2025-10-19 02:29:42.646341	2025-10-19 02:29:42.646341
588182b1-a468-4bd2-9ddd-8533543879da	PROTECTORES ELLAS X60UNID	7702108205457	t	7500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.646593	2025-10-19 02:29:42.646593
99749991-a876-4bc0-aece-26b9521893f3	HEAD SHOULDER 375 MAS 375	7500435142526	t	34600.00	\N	\N	\N	19.00	2025-10-19 02:29:42.646904	2025-10-19 02:29:42.646904
43eb9b38-2bc2-4b83-b5c1-ae1b2879bd8f	SARDINA ROBIN HOOD TOMATE 425GR	7862119507374	t	5300.00	5060.00	\N	\N	19.00	2025-10-19 02:29:42.647153	2025-10-19 02:29:42.647153
7a403340-14b5-4d62-b4e2-2bbbf4a18c09	SARDINA LUHOMAR TOMATE	7709747005950	t	4700.00	4550.00	\N	\N	0.00	2025-10-19 02:29:42.647451	2025-10-19 02:29:42.647451
b0d023f9-7538-4ff8-bcde-ebc5e7489bf0	COLCAFE INTENSO GRANULADO 170GR	7702032104383	t	28000.00	27400.00	\N	\N	5.00	2025-10-19 02:29:42.647886	2025-10-19 02:29:42.647886
02bdd1a2-23a8-4f3b-b211-80419e848910	PAÑITOS HUMEDOS NATURAL WIPES X100	6944970601062	t	5800.00	5600.00	\N	\N	0.00	2025-10-19 02:29:42.648164	2025-10-19 02:29:42.648164
1acd691c-0a6c-48de-8730-a42e3c7edb92	LIMPIA PISOS BICARBONATO LIMPIA YA 960ML	7702037915137	t	2500.00	2400.00	\N	\N	19.00	2025-10-19 02:29:42.648435	2025-10-19 02:29:42.648435
41805e9b-9bb2-4d2c-813e-dd852d4322d2	MOPA TRAPERO LEOMAR ROJO	7709561548992	t	4600.00	4400.00	\N	\N	0.00	2025-10-19 02:29:42.648775	2025-10-19 02:29:42.648775
cf4a4361-82d9-42ac-9d45-75bc5ed3c259	MOPA TRAPERO LEOMAR BLANCO ROJO	7709561548916	t	6600.00	6350.00	\N	\N	0.00	2025-10-19 02:29:42.649006	2025-10-19 02:29:42.649006
033cae26-9442-4ed3-954e-0cec2cbcc9d3	VASOS CARTON 7ONZ CAFETEROS DE CARTON	7702023110331	t	4700.00	4550.00	\N	\N	0.00	2025-10-19 02:29:42.649293	2025-10-19 02:29:42.649293
18b7f5e6-4d36-4bef-a664-afb947eb29eb	MECHAS LOKA	7702174079839	t	3200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.649509	2025-10-19 02:29:42.649509
45a50a07-b4e1-4cd1-967b-9277374bfe5e	GEL ROLDA BLACK 250GR	7707342220662	t	7300.00	7050.00	\N	\N	19.00	2025-10-19 02:29:42.649744	2025-10-19 02:29:42.649744
eb163d73-0c77-48c7-b680-4da9d8814f99	GEL ROLDA ROJA 125GR	7707342220594	t	4300.00	4200.00	\N	\N	16.00	2025-10-19 02:29:42.65006	2025-10-19 02:29:42.65006
08c64c90-acc5-4341-86e5-cf5f8541c70a	WUAU GALLETAS 20GR	7702993053027	t	1000.00	\N	\N	\N	16.00	2025-10-19 02:29:42.650442	2025-10-19 02:29:42.650442
444b98f1-be29-4fff-bdf5-5ac38bc48548	MOSNTER	070847034322	t	8500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.65077	2025-10-19 02:29:42.65077
e638c369-751a-44a4-812d-34e3219bdf12	DESODORANTE DOVE ORIGINAL 150ML	7506306241183	t	14500.00	14000.00	\N	\N	19.00	2025-10-19 02:29:42.651098	2025-10-19 02:29:42.651098
f7f0477f-ca45-4402-b1aa-bf6ee6526a12	KOTEX NORMAL CORIS X10UNI	7702425800779	t	4000.00	3850.00	\N	\N	19.00	2025-10-19 02:29:42.65139	2025-10-19 02:29:42.65139
519772d9-ba4f-43c6-9bdc-0ea18e762714	LECHE CONDENSADA TETERO  DEL BOSQUE 1.000	7009990434386	t	11600.00	11100.00	\N	\N	19.00	2025-10-19 02:29:42.651653	2025-10-19 02:29:42.651653
88cf3cf4-98f4-4795-91cb-8eed64c64dce	CHOCOLATE AROMA CANELA Y CLAVO 500GR	7702088205485	t	8400.00	8100.00	\N	\N	5.00	2025-10-19 02:29:42.651954	2025-10-19 02:29:42.651954
6e572fa1-cb0a-49f0-9f41-065655e5715c	AZUCAR INCAUCA 500GR	7702059401021	t	2000.00	\N	\N	\N	5.00	2025-10-19 02:29:42.65237	2025-10-19 02:29:42.65237
569b262f-8dd7-4244-a1fa-bb3bb31fd283	AZUCAR LEO 1.000GR	7702948125366	t	3900.00	3800.00	\N	\N	5.00	2025-10-19 02:29:42.652644	2025-10-19 02:29:42.652644
19cbcab2-0416-4304-abda-cbfe2415c22e	FABULOSO NARANJA 180ML	7509546688756	t	1700.00	1600.00	\N	\N	19.00	2025-10-19 02:29:42.652986	2025-10-19 02:29:42.652986
c13d5105-146b-4ff5-9eb8-0083a42466e8	CUCHARA MARPLAST X100	7709460192104	t	4100.00	\N	\N	\N	0.00	2025-10-19 02:29:42.65329	2025-10-19 02:29:42.65329
8c68a816-115c-4702-8f06-db5fb8346c65	FLOR DE JAMAICA 10GR LA SAZON DE VILLA	7707767146349	t	1500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.653522	2025-10-19 02:29:42.653522
2ffb7ee7-e065-4b19-a8c1-c14ff0a592af	COLGATE TRIPLE ACCION 75ML	7509546699998	t	3700.00	3542.00	\N	\N	19.00	2025-10-19 02:29:42.653855	2025-10-19 02:29:42.653855
26b34025-2c3f-4884-86ac-ec3bac68bf47	KOLA HIPINTO 2.5 LITROS	7702090064223	t	4800.00	4313.00	\N	\N	19.00	2025-10-19 02:29:42.654124	2025-10-19 02:29:42.654124
6bee8dd0-bf7a-44c3-9320-8ce9ce8b2ab5	BIANCHI BARRITA FRESA Y CAFE X24	7702993054390	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.654421	2025-10-19 02:29:42.654421
f61201f3-de94-4b04-b8de-7a5df4d4fef3	CHOCOBARRILETE X24UNID	7702993052785	t	9900.00	\N	\N	\N	19.00	2025-10-19 02:29:42.654681	2025-10-19 02:29:42.654681
53d4a6ee-3913-4c7e-a26d-f8f7206cdc82	ADOBO COMPLETO LA SAZON DE LA VILLA 50GR	7707767149197	t	1500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.655185	2025-10-19 02:29:42.655185
d83fb9b6-790f-442b-bb78-b7dae198fdf3	SADO BRETAÑA 10OZ	7702090020847	t	2600.00	2380.00	\N	\N	0.00	2025-10-19 02:29:42.655487	2025-10-19 02:29:42.655487
5df0fe93-e7b8-424a-a87a-d528636ea14e	YOGO YOGO MELOCOTON ALPINA 185GR	7702001117444	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.65573	2025-10-19 02:29:42.65573
b930fc57-19d0-4e59-9625-4c68a4bb126c	YOGO YOGO FRES ALPINA 185GR	7702001117437	t	2200.00	\N	\N	\N	19.00	2025-10-19 02:29:42.656013	2025-10-19 02:29:42.656013
2b70a10f-813e-47dd-9323-d842ef2708c2	ALPIN FRESA ALPINA 200ML	7702001044450	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.656305	2025-10-19 02:29:42.656305
11cc9afd-29f0-4388-8d0a-fa985edda065	ALPIN VAINILLA ALPINA 200ML	7702001044467	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.656637	2025-10-19 02:29:42.656637
2ef5f505-8716-4f3b-aa4f-c114213f4ff1	ALPIN CHOCOLATE ALPINA 200ML	7702001044306	t	3300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.656943	2025-10-19 02:29:42.656943
3cc98fac-97ec-4023-85ad-f36ae7691357	SALCHICHON CIFUENTES DE POLLO PREMIUM	SALCHINOCN	t	8100.00	7900.00	7750.00	\N	19.00	2025-10-19 02:29:42.657286	2025-10-19 02:29:42.657286
423c0ec6-0e20-48de-a140-e29fa9b723cf	TIO NACHO PROPOLEO CONTROL 415ML	650240069352	t	28000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.657552	2025-10-19 02:29:42.657552
aed0dfc9-45b5-4f4f-8887-dcabeeb342e6	NUTRIBELA BIOKERATINA 450ML	7702354957186	t	21000.00	20200.00	\N	\N	19.00	2025-10-19 02:29:42.657864	2025-10-19 02:29:42.657864
1e2e1498-d7e4-4dd2-b45e-00786f5494e1	DISCO TOTAL CORTE	6925582150308	t	2500.00	2200.00	\N	\N	0.00	2025-10-19 02:29:42.658294	2025-10-19 02:29:42.658294
8e6a9912-bc44-4ae3-9af3-cb000fa4978c	KIT DE UÑAS VERDE TORENIX	6941418762262	t	8500.00	\N	\N	\N	16.00	2025-10-19 02:29:42.658676	2025-10-19 02:29:42.658676
564b38bf-c0ce-4b1c-9c17-5008fde92aa2	PEGA AMARILLO SUPER MAS	PEGA AMARILLO	t	3000.00	2600.00	\N	\N	0.00	2025-10-19 02:29:42.659024	2025-10-19 02:29:42.659024
09a08a67-1c70-40b1-8621-d904ad00298f	PEGANTE AMARILLO SUPER MAS PEQUEÑO	PAGANTES AMARILLO	t	1500.00	1300.00	\N	\N	0.00	2025-10-19 02:29:42.65935	2025-10-19 02:29:42.65935
5d8ecfa4-c5ef-4606-8838-242d9209ccdf	DESTORNILLADOR PEQUEÑO	DESTORNILLADOR PEQUEÑO	t	2800.00	2500.00	\N	\N	0.00	2025-10-19 02:29:42.659631	2025-10-19 02:29:42.659631
8b3a7c2b-e87c-426a-bf14-411c86db191c	FABULOSOS 5L LAVANDA	7702010310096	t	35000.00	\N	\N	\N	19.00	2025-10-19 02:29:42.659947	2025-10-19 02:29:42.659947
3d0e911a-02b6-4cb8-93bd-6f98fc5441c2	DULCE CONEJO VILVATO X20UNID	6920484018510	t	22000.00	21000.00	\N	\N	19.00	2025-10-19 02:29:42.660328	2025-10-19 02:29:42.660328
4cf4f82a-b2bf-413a-b87e-51b33d292a1e	GELATINA DIPLOKO DINO X30UNID	7705733742939	t	17000.00	16500.00	\N	\N	19.00	2025-10-19 02:29:42.660722	2025-10-19 02:29:42.660722
42ff3727-cc04-4a1e-af30-bb9b0f1e1453	VICK VAPORUB LATA ECONOMICO	VISCK	t	2500.00	2200.00	\N	\N	0.00	2025-10-19 02:29:42.660977	2025-10-19 02:29:42.660977
e1991e6e-69ea-4ff7-8803-9b22a1557529	REMOVEDOR DE ESMALTE SUPER MAS 60ML	REMONVE	t	1500.00	1300.00	\N	\N	16.00	2025-10-19 02:29:42.661325	2025-10-19 02:29:42.661325
9eadef0a-b929-4816-a531-07bfd6a3c288	SOLDADURA PVC LIQUIDA	SOLDA	t	2800.00	2500.00	\N	\N	0.00	2025-10-19 02:29:42.661637	2025-10-19 02:29:42.661637
df204d17-a082-433b-93ec-e5e9dccbca35	GATORLIT MORAS 620ML	7702192902263	t	3800.00	3500.00	\N	\N	19.00	2025-10-19 02:29:42.661959	2025-10-19 02:29:42.661959
577b84fb-9261-4ad4-b922-8eed1dc30a90	GATORLIT FRESA KIWI 620ML	7702192046561	t	3800.00	3500.00	\N	\N	19.00	2025-10-19 02:29:42.662292	2025-10-19 02:29:42.662292
64133fc9-a669-451f-a0f2-0eee3da1798c	GATORLIT MORA 620ML	7702192308256	t	3800.00	3500.00	\N	\N	19.00	2025-10-19 02:29:42.662656	2025-10-19 02:29:42.662656
7d892f60-2920-4d02-b51b-10abe76defe2	BALSAMO BIOQUA NARANJA	6976623804414	t	2500.00	2200.00	\N	\N	16.00	2025-10-19 02:29:42.662923	2025-10-19 02:29:42.662923
5d34bd8d-cdee-4312-a29b-9ab6385a3a55	BALSAMO ALOE VERA	6976623804421	t	2500.00	2200.00	\N	\N	16.00	2025-10-19 02:29:42.663274	2025-10-19 02:29:42.663274
ccc0e455-e07c-427a-a769-2c4fcb8c51e4	SUGAR BLUH 3 EN 1	6937118816381	t	2500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.663647	2025-10-19 02:29:42.663647
8353a7a6-d25a-4ea7-806e-723f6035160e	COLAGENO LABIOS  Y OJERAS	6926923600797	t	1500.00	1300.00	\N	\N	0.00	2025-10-19 02:29:42.663967	2025-10-19 02:29:42.663967
8152c225-11fa-48a2-a7cb-ca223ef5df46	MASCARILLA HYALURONIC ACID VITAMINA C	6942349742323	t	1000.00	850.00	\N	\N	0.00	2025-10-19 02:29:42.664288	2025-10-19 02:29:42.664288
74abe687-41ae-460f-a1ce-92c888d4b412	MASCARILLA BAD GIRL MAKEUP DAY	6947790531878	t	1000.00	850.00	\N	\N	0.00	2025-10-19 02:29:42.664671	2025-10-19 02:29:42.664671
e75a3fc5-3266-4299-b733-644fb3ba0fb7	MASCARILLA PANDA	6947790543369	t	1000.00	850.00	\N	\N	0.00	2025-10-19 02:29:42.66496	2025-10-19 02:29:42.66496
6ea38de8-dc5d-48f4-8f31-dc4a8bb64609	MASCARILLA 3 PASAOS CHOVEMOAR	6974470910111	t	1800.00	\N	\N	\N	0.00	2025-10-19 02:29:42.66531	2025-10-19 02:29:42.66531
abc076de-bb58-4bdc-9e26-8a3ca67bf084	MASCARILLA 3 PASOS BIOAQUA	6942017806708	t	2500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.665563	2025-10-19 02:29:42.665563
6572f1f8-5142-4662-a3d0-a161c168e274	SALMON DE TOMATE CAYUCO	7599787000028	t	2500.00	2400.00	\N	\N	0.00	2025-10-19 02:29:42.665821	2025-10-19 02:29:42.665821
b5b50b24-ab90-450e-baca-35c248f0e9e6	CREMA DE ARROZ EXTRA SEÑORA 450GR	7708624784650	t	5700.00	5500.00	\N	\N	19.00	2025-10-19 02:29:42.666109	2025-10-19 02:29:42.666109
e3074281-c07e-4610-b3cf-9539fafea64d	COLAGENO DE LABIO BIOAQUA X20UNID	6973098890676	t	8000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.666359	2025-10-19 02:29:42.666359
86d512fb-840b-4664-a95d-f18cf20d2a37	PAPEL ALUMINIO HOUSE EVER 7 METROS	7707897179996	t	2700.00	2680.00	\N	\N	19.00	2025-10-19 02:29:42.66665	2025-10-19 02:29:42.66665
4bf63bc2-5343-4200-8b8c-45a2a6109e01	MASCARILLA REMOVEDORA DE ACNE	6942349702846	t	1500.00	1300.00	\N	\N	0.00	2025-10-19 02:29:42.66698	2025-10-19 02:29:42.66698
aabcff5d-8a5c-4832-8986-50d72301205a	PROTECTOR SOLAR DE COALGENO	6942349738180	t	4200.00	\N	\N	\N	0.00	2025-10-19 02:29:42.667312	2025-10-19 02:29:42.667312
216cb62a-56d4-4f2d-a69e-d8faa0ab9bd6	COLAGENO DE OJERAS KISS BEAUTY 30UNID	6903072391929	t	6500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.667695	2025-10-19 02:29:42.667695
be0cbb8d-4bbe-4afe-a00c-91d1507fdb21	SHAMPOO ALOE VERA	6942349735684	t	500.00	\N	\N	\N	0.00	2025-10-19 02:29:42.668028	2025-10-19 02:29:42.668028
9601c767-8274-46d2-835d-e96da854f062	GALLETA ITALIANNA	8681863046002	t	1500.00	\N	\N	\N	16.00	2025-10-19 02:29:42.668313	2025-10-19 02:29:42.668313
ab4ebbd4-b2e1-45e6-a65d-ee822316b191	JUGO HIT LILO 500ML	7707133085456	t	2500.00	\N	\N	\N	19.00	2025-10-19 02:29:42.66885	2025-10-19 02:29:42.66885
fe5a0d60-1aaa-4bb3-90cd-4a2378725b01	JUMBO RYANCASRO X3 170GR	7702007088335	t	39300.00	\N	\N	\N	19.00	2025-10-19 02:29:42.669318	2025-10-19 02:29:42.669318
53d038ec-6d44-40d5-8edd-b0e561c91ed9	JUMBO RYAN CASTRO 170 EDICION LIMITADA	7702007088328	t	13800.00	\N	\N	\N	19.00	2025-10-19 02:29:42.669584	2025-10-19 02:29:42.669584
e1b2010e-3af8-4d2f-a354-9395eec184a3	OREGANO MOLIDO LA SAZON DE LA VILLA 25GR	7707767141351	t	1500.00	\N	\N	\N	16.00	2025-10-19 02:29:42.669812	2025-10-19 02:29:42.669812
1ee132da-ba36-4540-870d-b0dd132283e8	AVENA TONING 1100GR	7702622131577	t	8700.00	8300.00	\N	\N	0.00	2025-10-19 02:29:42.670103	2025-10-19 02:29:42.670103
c68f9e45-1954-48cd-ab66-9f23facf521e	PAPAS KRUMER CHIPS 350GR	7709990115482	t	3700.00	3500.00	\N	\N	0.00	2025-10-19 02:29:42.670356	2025-10-19 02:29:42.670356
2d028831-7caa-4f19-bbaa-69515e2b4743	INDULECHE 25GR	7709590459788	t	1000.00	930.00	\N	\N	0.00	2025-10-19 02:29:42.670615	2025-10-19 02:29:42.670615
4f89884c-c072-491f-a15a-76d4570536a1	AZUCARITAS HOLA DIA 500GR	7709990071245	t	6900.00	6700.00	\N	\N	0.00	2025-10-19 02:29:42.670859	2025-10-19 02:29:42.670859
bc020cc6-a863-4fa4-8e3e-581e2014d0c5	DURAZNO ALMIBAR CARVAJAL 250GR	658325393590	t	3400.00	3200.00	\N	\N	0.00	2025-10-19 02:29:42.671123	2025-10-19 02:29:42.671123
6a1b87f6-8d5c-4e1a-adce-de1a8007c60b	ARROZ 500GR	7700798036849	t	2000.00	\N	\N	\N	0.00	2025-10-19 02:29:42.671324	2025-10-19 02:29:42.671324
56179ab0-8fc5-4dba-8350-3b5c1962e31f	CEPILLO	6976635041135	t	1500.00	\N	\N	\N	16.00	2025-10-19 02:29:42.671588	2025-10-19 02:29:42.671588
9b7b2bb3-8068-40c8-8e2a-5c7a309100a0	SALSA INGLESA IDEAL 165ML	7708969766069	t	1900.00	1750.00	\N	\N	19.00	2025-10-19 02:29:42.671813	2025-10-19 04:32:20.183328
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, description, "isCompleted", todo_id, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: todos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.todos (id, description, "isCompleted", created_by, assigned_to, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, password, role, "isActive", "createdAt", "updatedAt") FROM stdin;
731fd637-243a-443f-ad6f-c42646a40de1	supervisor	supervisor@ejemplo.com	$2b$10$oyyR3Oa5SBW/ds5yOEsjP.sVZDInSZMKfT3X5TmhM14Kx9vKtqBUq	supervisor	t	2025-10-18 01:56:56.314705	2025-10-18 01:56:56.314705
ca1a7383-bd88-4dbd-af05-0d06ce7474d0	empleado	empleado@ejemplo.com	$2b$10$Dr/cQdy1y1naq.cLHDzfQuTIsg.T0r7n6bprOgKEpFmwZN4lb2OCi	employee	t	2025-10-18 01:57:00.185872	2025-10-18 01:57:00.185872
e0eb17cf-1e0a-4d42-a465-2b3d0ec62545	adalberto	admin@ejemplo.com	$2b$10$vSPEOStn8h/qbsLJ4hhpzepWgSEzyMBVmJTG//MNmyrXmRKIe0Kaa	admin	t	2025-10-18 01:56:29.049223	2025-10-18 01:56:29.049223
\.


--
-- Name: order_items PK_005269d8574e6fac0493715c308; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT "PK_005269d8574e6fac0493715c308" PRIMARY KEY (id);


--
-- Name: products PK_0806c755e0aca124e67c0cf6d7d; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT "PK_0806c755e0aca124e67c0cf6d7d" PRIMARY KEY (id);


--
-- Name: payments PK_197ab7af18c93fbb0c9b28b4a59; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT "PK_197ab7af18c93fbb0c9b28b4a59" PRIMARY KEY (id);


--
-- Name: credits PK_45cea097fd0ee625d2e840ed99c; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credits
    ADD CONSTRAINT "PK_45cea097fd0ee625d2e840ed99c" PRIMARY KEY (id);


--
-- Name: product_update_tasks PK_669499e267cba746edf9347c094; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_update_tasks
    ADD CONSTRAINT "PK_669499e267cba746edf9347c094" PRIMARY KEY (id);


--
-- Name: orders PK_710e2d4957aa5878dfe94e4ac2f; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "PK_710e2d4957aa5878dfe94e4ac2f" PRIMARY KEY (id);


--
-- Name: tasks PK_8d12ff38fcc62aaba2cab748772; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "PK_8d12ff38fcc62aaba2cab748772" PRIMARY KEY (id);


--
-- Name: expenses PK_94c3ceb17e3140abc9282c20610; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT "PK_94c3ceb17e3140abc9282c20610" PRIMARY KEY (id);


--
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- Name: credit_transactions PK_a408319811d1ab32832ec86fc2c; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_transactions
    ADD CONSTRAINT "PK_a408319811d1ab32832ec86fc2c" PRIMARY KEY (id);


--
-- Name: todos PK_ca8cafd59ca6faaf67995344225; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.todos
    ADD CONSTRAINT "PK_ca8cafd59ca6faaf67995344225" PRIMARY KEY (id);


--
-- Name: clients PK_f1ab7cf3a5714dbc6bb4e1c28a4; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "PK_f1ab7cf3a5714dbc6bb4e1c28a4" PRIMARY KEY (id);


--
-- Name: clients UQ_513896bbf9d55cf1381b35df942; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "UQ_513896bbf9d55cf1381b35df942" UNIQUE (celular);


--
-- Name: users UQ_97672ac88f789774dd47f7c8be3; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE (email);


--
-- Name: clients UQ_a590ac15c1e78a178a7fee4b136; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT "UQ_a590ac15c1e78a178a7fee4b136" UNIQUE (nombre);


--
-- Name: products UQ_adfc522baf9d9b19cd7d9461b7e; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT "UQ_adfc522baf9d9b19cd7d9461b7e" UNIQUE (barcode);


--
-- Name: users UQ_fe0bb3f6520ee0469504521e710; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_fe0bb3f6520ee0469504521e710" UNIQUE (username);


--
-- Name: order_items FK_145532db85752b29c57d2b7b1f1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT "FK_145532db85752b29c57d2b7b1f1" FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: product_update_tasks FK_162076d17c9741928050a84feb9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_update_tasks
    ADD CONSTRAINT "FK_162076d17c9741928050a84feb9" FOREIGN KEY ("productId") REFERENCES public.products(id);


--
-- Name: orders FK_574a2f0932043d4e4baf188ee05; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "FK_574a2f0932043d4e4baf188ee05" FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: credits FK_7252924d0939c77f906021929fa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credits
    ADD CONSTRAINT "FK_7252924d0939c77f906021929fa" FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: expenses FK_7c0c012c2f8e6578277c239ee61; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT "FK_7c0c012c2f8e6578277c239ee61" FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: payments FK_7fa006fa7e232b86631cad02ed4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT "FK_7fa006fa7e232b86631cad02ed4" FOREIGN KEY (credit_id) REFERENCES public.credits(id) ON DELETE CASCADE;


--
-- Name: todos FK_8ba0d6c1b7454fd07c2f4171076; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.todos
    ADD CONSTRAINT "FK_8ba0d6c1b7454fd07c2f4171076" FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: order_items FK_9263386c35b6b242540f9493b00; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT "FK_9263386c35b6b242540f9493b00" FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: product_update_tasks FK_cfc6894a5df3dfe363fda0fad3e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_update_tasks
    ADD CONSTRAINT "FK_cfc6894a5df3dfe363fda0fad3e" FOREIGN KEY ("completedById") REFERENCES public.users(id);


--
-- Name: tasks FK_dc071472d0cd0f12477393cead5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "FK_dc071472d0cd0f12477393cead5" FOREIGN KEY (todo_id) REFERENCES public.todos(id) ON DELETE CASCADE;


--
-- Name: todos FK_dca43172d9b4b43e2cc86643b49; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.todos
    ADD CONSTRAINT "FK_dca43172d9b4b43e2cc86643b49" FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: credit_transactions FK_e5ee2f50aa9c457c17b795d9217; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_transactions
    ADD CONSTRAINT "FK_e5ee2f50aa9c457c17b795d9217" FOREIGN KEY (credit_id) REFERENCES public.credits(id) ON DELETE CASCADE;


--
-- Name: product_update_tasks FK_e8776e960367faa55f53adf4225; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_update_tasks
    ADD CONSTRAINT "FK_e8776e960367faa55f53adf4225" FOREIGN KEY ("createdById") REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

