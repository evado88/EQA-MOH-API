--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: applications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.applications (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    lab_id integer NOT NULL,
    scheme_id integer NOT NULL,
    service_id integer NOT NULL,
    method_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.applications OWNER TO postgres;

--
-- Name: applications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.applications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.applications_id_seq OWNER TO postgres;

--
-- Name: applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.applications_id_seq OWNED BY public.applications.id;


--
-- Name: audits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audits (
    id integer NOT NULL,
    user_id integer NOT NULL,
    user_email character varying NOT NULL,
    token character varying NOT NULL,
    date timestamp with time zone NOT NULL,
    feature character varying NOT NULL,
    model character varying,
    object_id integer,
    action character varying NOT NULL,
    before jsonb,
    after jsonb,
    created_at timestamp with time zone,
    created_by character varying
);


ALTER TABLE public.audits OWNER TO postgres;

--
-- Name: audits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audits_id_seq OWNER TO postgres;

--
-- Name: audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audits_id_seq OWNED BY public.audits.id;


--
-- Name: districts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.districts (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    province_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.districts OWNER TO postgres;

--
-- Name: districts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.districts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.districts_id_seq OWNER TO postgres;

--
-- Name: districts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.districts_id_seq OWNED BY public.districts.id;


--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enrollments (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    scheme_id integer NOT NULL,
    lab_id integer NOT NULL,
    service_id integer NOT NULL,
    method_id integer NOT NULL,
    pt_cycle_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.enrollments OWNER TO postgres;

--
-- Name: enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.enrollments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.enrollments_id_seq OWNER TO postgres;

--
-- Name: enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.enrollments_id_seq OWNED BY public.enrollments.id;


--
-- Name: lab_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lab_types (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.lab_types OWNER TO postgres;

--
-- Name: lab_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lab_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lab_types_id_seq OWNER TO postgres;

--
-- Name: lab_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lab_types_id_seq OWNED BY public.lab_types.id;


--
-- Name: laboratorys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.laboratorys (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    contact_person_name character varying NOT NULL,
    code character varying NOT NULL,
    lab_type_id integer NOT NULL,
    "position" character varying NOT NULL,
    district_id integer NOT NULL,
    province_id integer NOT NULL,
    phone_number character varying NOT NULL,
    physical_address character varying NOT NULL,
    email_address character varying NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying,
    method_list jsonb
);


ALTER TABLE public.laboratorys OWNER TO postgres;

--
-- Name: laboratorys_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.laboratorys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.laboratorys_id_seq OWNER TO postgres;

--
-- Name: laboratorys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.laboratorys_id_seq OWNED BY public.laboratorys.id;


--
-- Name: list_stages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.list_stages (
    id integer NOT NULL,
    stage_name character varying NOT NULL,
    description character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.list_stages OWNER TO postgres;

--
-- Name: list_stages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.list_stages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.list_stages_id_seq OWNER TO postgres;

--
-- Name: list_stages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.list_stages_id_seq OWNED BY public.list_stages.id;


--
-- Name: list_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.list_statuses (
    id integer NOT NULL,
    status_name character varying NOT NULL,
    description character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.list_statuses OWNER TO postgres;

--
-- Name: list_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.list_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.list_statuses_id_seq OWNER TO postgres;

--
-- Name: list_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.list_statuses_id_seq OWNED BY public.list_statuses.id;


--
-- Name: meters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meters (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    customer_number character varying NOT NULL,
    customer_name character varying NOT NULL,
    identity_number character varying NOT NULL,
    address character varying NOT NULL,
    communicate_address character varying NOT NULL,
    invoice_number character varying NOT NULL,
    open_account_date date NOT NULL,
    station_name character varying NOT NULL,
    operator_uid character varying NOT NULL,
    province_name character varying NOT NULL,
    city_name character varying NOT NULL,
    town_name character varying NOT NULL,
    village_name character varying NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.meters OWNER TO postgres;

--
-- Name: meters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.meters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.meters_id_seq OWNER TO postgres;

--
-- Name: meters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.meters_id_seq OWNED BY public.meters.id;


--
-- Name: method_samples; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.method_samples (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    method_id integer NOT NULL,
    service_id integer NOT NULL,
    scheme_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.method_samples OWNER TO postgres;

--
-- Name: method_samples_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.method_samples_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.method_samples_id_seq OWNER TO postgres;

--
-- Name: method_samples_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.method_samples_id_seq OWNED BY public.method_samples.id;


--
-- Name: methods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.methods (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    service_id integer NOT NULL,
    scheme_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.methods OWNER TO postgres;

--
-- Name: methods_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.methods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.methods_id_seq OWNER TO postgres;

--
-- Name: methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.methods_id_seq OWNED BY public.methods.id;


--
-- Name: providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.providers (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.providers OWNER TO postgres;

--
-- Name: providers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.providers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.providers_id_seq OWNER TO postgres;

--
-- Name: providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.providers_id_seq OWNED BY public.providers.id;


--
-- Name: provinces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provinces (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    code character varying NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.provinces OWNER TO postgres;

--
-- Name: provinces_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.provinces_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.provinces_id_seq OWNER TO postgres;

--
-- Name: provinces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.provinces_id_seq OWNED BY public.provinces.id;


--
-- Name: pt_cycle_samples; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pt_cycle_samples (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.pt_cycle_samples OWNER TO postgres;

--
-- Name: pt_cycle_samples_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pt_cycle_samples_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pt_cycle_samples_id_seq OWNER TO postgres;

--
-- Name: pt_cycle_samples_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pt_cycle_samples_id_seq OWNED BY public.pt_cycle_samples.id;


--
-- Name: pt_cycle_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pt_cycle_statuses (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.pt_cycle_statuses OWNER TO postgres;

--
-- Name: pt_cycle_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pt_cycle_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pt_cycle_statuses_id_seq OWNER TO postgres;

--
-- Name: pt_cycle_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pt_cycle_statuses_id_seq OWNED BY public.pt_cycle_statuses.id;


--
-- Name: pt_cycles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pt_cycles (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    code character varying NOT NULL,
    effective_date date NOT NULL,
    scheme_id integer NOT NULL,
    pt_cyle_status_id integer NOT NULL,
    closing_date date NOT NULL,
    shipping_date date NOT NULL,
    reports_availability_date date NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.pt_cycles OWNER TO postgres;

--
-- Name: pt_cycles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pt_cycles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pt_cycles_id_seq OWNER TO postgres;

--
-- Name: pt_cycles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pt_cycles_id_seq OWNED BY public.pt_cycles.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: schemes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schemes (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    provider_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.schemes OWNER TO postgres;

--
-- Name: schemes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schemes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.schemes_id_seq OWNER TO postgres;

--
-- Name: schemes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schemes_id_seq OWNED BY public.schemes.id;


--
-- Name: services; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.services (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    scheme_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.services OWNER TO postgres;

--
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.services_id_seq OWNER TO postgres;

--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.services_id_seq OWNED BY public.services.id;


--
-- Name: tb_xpert_ultra_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_xpert_ultra_results (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    scheme_id integer NOT NULL,
    lab_id integer NOT NULL,
    service_id integer NOT NULL,
    pt_cycle_id integer NOT NULL,
    method_id integer NOT NULL,
    enrollment_id integer NOT NULL,
    method_sample_id integer NOT NULL,
    result_nterpretable character varying,
    tb_detection_result character varying,
    rif_result character varying,
    uninterpretable_result character varying,
    ultra_spc double precision,
    "is1081_IS6110" double precision,
    "rpoB1" double precision,
    "rpoB2" double precision,
    "rpoB3" double precision,
    "rpoB4" double precision,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying,
    xpert_module_number character varying
);


ALTER TABLE public.tb_xpert_ultra_results OWNER TO postgres;

--
-- Name: tb_xpert_ultra_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_xpert_ultra_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_xpert_ultra_results_id_seq OWNER TO postgres;

--
-- Name: tb_xpert_ultra_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_xpert_ultra_results_id_seq OWNED BY public.tb_xpert_ultra_results.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    code character varying,
    type integer,
    fname character varying NOT NULL,
    lname character varying NOT NULL,
    "position" character varying,
    email character varying NOT NULL,
    mobile_code character varying NOT NULL,
    mobile character varying NOT NULL,
    address_physical character varying,
    address_postal character varying,
    role_id integer NOT NULL,
    password character varying NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying,
    laboratory_id integer,
    province_id integer,
    district_id integer
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: applications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications ALTER COLUMN id SET DEFAULT nextval('public.applications_id_seq'::regclass);


--
-- Name: audits id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audits ALTER COLUMN id SET DEFAULT nextval('public.audits_id_seq'::regclass);


--
-- Name: districts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts ALTER COLUMN id SET DEFAULT nextval('public.districts_id_seq'::regclass);


--
-- Name: enrollments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments ALTER COLUMN id SET DEFAULT nextval('public.enrollments_id_seq'::regclass);


--
-- Name: lab_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_types ALTER COLUMN id SET DEFAULT nextval('public.lab_types_id_seq'::regclass);


--
-- Name: laboratorys id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys ALTER COLUMN id SET DEFAULT nextval('public.laboratorys_id_seq'::regclass);


--
-- Name: list_stages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_stages ALTER COLUMN id SET DEFAULT nextval('public.list_stages_id_seq'::regclass);


--
-- Name: list_statuses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_statuses ALTER COLUMN id SET DEFAULT nextval('public.list_statuses_id_seq'::regclass);


--
-- Name: meters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meters ALTER COLUMN id SET DEFAULT nextval('public.meters_id_seq'::regclass);


--
-- Name: method_samples id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples ALTER COLUMN id SET DEFAULT nextval('public.method_samples_id_seq'::regclass);


--
-- Name: methods id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods ALTER COLUMN id SET DEFAULT nextval('public.methods_id_seq'::regclass);


--
-- Name: providers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers ALTER COLUMN id SET DEFAULT nextval('public.providers_id_seq'::regclass);


--
-- Name: provinces id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces ALTER COLUMN id SET DEFAULT nextval('public.provinces_id_seq'::regclass);


--
-- Name: pt_cycle_samples id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_samples ALTER COLUMN id SET DEFAULT nextval('public.pt_cycle_samples_id_seq'::regclass);


--
-- Name: pt_cycle_statuses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_statuses ALTER COLUMN id SET DEFAULT nextval('public.pt_cycle_statuses_id_seq'::regclass);


--
-- Name: pt_cycles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles ALTER COLUMN id SET DEFAULT nextval('public.pt_cycles_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: schemes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes ALTER COLUMN id SET DEFAULT nextval('public.schemes_id_seq'::regclass);


--
-- Name: services id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services ALTER COLUMN id SET DEFAULT nextval('public.services_id_seq'::regclass);


--
-- Name: tb_xpert_ultra_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results ALTER COLUMN id SET DEFAULT nextval('public.tb_xpert_ultra_results_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: applications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.applications (id, name, description, lab_id, scheme_id, service_id, method_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Levy Ultra Application	\N	1	1	2	1	1	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-24 01:11:14.384673+02	\N	\N	\N
\.


--
-- Data for Name: audits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audits (id, user_id, user_email, token, date, feature, model, object_id, action, before, after, created_at, created_by) FROM stdin;
1	0	nkoleevans@hotmail.com	public	2026-07-22 05:35:19+02	Authentication	\N	\N	Unauthorised	null	null	2026-07-22 05:35:20.207287+02	nkoleevans@hotmail.com
2	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:35:31+02	Session	\N	\N	Start	null	{"exp": 1784693131, "jti": "4d7e1cabd583411b82057e8f959d513f", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 05:35:31.574841+02	nkoleevans@gmail.com
3	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:35:40+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 05:35:41.431763+02	nkoleevans@gmail.com
4	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:35:42+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 05:35:43.342368+02	nkoleevans@gmail.com
5	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:35:45+02	Users	\N	\N	View - Allowed	null	null	2026-07-22 05:35:45.943794+02	nkoleevans@gmail.com
6	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:35:47+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 05:35:47.988106+02	nkoleevans@gmail.com
7	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:36:07+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 05:36:07.918857+02	nkoleevans@gmail.com
8	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:37:22+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 05:37:22.555371+02	nkoleevans@gmail.com
9	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:37:28+02	Users	\N	\N	View - Allowed	null	null	2026-07-22 05:37:29.424247+02	nkoleevans@gmail.com
10	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:37:30+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 05:37:30.925525+02	nkoleevans@gmail.com
11	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:39:54+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 05:39:54.782528+02	nkoleevans@gmail.com
12	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:41+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:43.29577+02	nkoleevans@gmail.com
13	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:46+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:46.733093+02	nkoleevans@gmail.com
14	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:51+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:52.326936+02	nkoleevans@gmail.com
15	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:52+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:53.458609+02	nkoleevans@gmail.com
16	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:53+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:54.395348+02	nkoleevans@gmail.com
17	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:55+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:56.010372+02	nkoleevans@gmail.com
18	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:57+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:57.846121+02	nkoleevans@gmail.com
19	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:59+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:46:00.477595+02	nkoleevans@gmail.com
20	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:46:02+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 05:46:04.049806+02	nkoleevans@gmail.com
21	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:46:14+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:46:14.787203+02	nkoleevans@gmail.com
22	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:46:16+02	District List	\N	\N	View - Allowed	null	null	2026-07-22 05:46:17.505026+02	nkoleevans@gmail.com
23	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:46:17+02	Province List	\N	\N	View - Allowed	null	null	2026-07-22 05:46:17.98723+02	nkoleevans@gmail.com
24	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:46:18+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 05:46:19.236912+02	nkoleevans@gmail.com
25	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:46:19+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 05:46:20.138862+02	nkoleevans@gmail.com
26	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:48:34+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 05:48:36.678629+02	nkoleevans@gmail.com
27	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:49:18+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 05:49:19.509363+02	nkoleevans@gmail.com
28	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:49:32+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 05:49:35.078891+02	nkoleevans@gmail.com
29	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:50:00+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 05:50:00.959272+02	nkoleevans@gmail.com
30	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:50:01+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 05:50:02.067161+02	nkoleevans@gmail.com
31	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:50:01+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 05:50:02.56924+02	nkoleevans@gmail.com
32	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:50:02+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 05:50:02.939891+02	nkoleevans@gmail.com
33	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:50:02+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-22 05:50:03.352519+02	nkoleevans@gmail.com
34	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:50:03+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:50:03.872692+02	nkoleevans@gmail.com
35	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:52:42+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:52:45.502563+02	nkoleevans@gmail.com
36	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:52:53+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 05:52:54.113877+02	nkoleevans@gmail.com
37	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:52:54+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:52:56.893925+02	nkoleevans@gmail.com
38	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:52:56+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 05:52:57.38431+02	nkoleevans@gmail.com
39	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:52:58+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:52:59.402343+02	nkoleevans@gmail.com
40	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:28+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:30.922883+02	nkoleevans@gmail.com
41	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:32.421078+02	nkoleevans@gmail.com
42	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:35+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:37.902971+02	nkoleevans@gmail.com
43	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:39+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:40.307832+02	nkoleevans@gmail.com
45	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:41+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:42.491305+02	nkoleevans@gmail.com
46	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:42+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:42.961879+02	nkoleevans@gmail.com
48	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:44+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:46.681992+02	nkoleevans@gmail.com
49	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:46+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:47.122891+02	nkoleevans@gmail.com
44	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:41+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:41.929211+02	nkoleevans@gmail.com
47	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:43+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:44.827386+02	nkoleevans@gmail.com
50	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:28+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:31.057901+02	nkoleevans@gmail.com
51	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:32+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:32.871597+02	nkoleevans@gmail.com
52	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:33+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:34.335424+02	nkoleevans@gmail.com
53	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:37+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:38.254482+02	nkoleevans@gmail.com
54	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:38+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:39.26101+02	nkoleevans@gmail.com
55	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:40+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:40.563763+02	nkoleevans@gmail.com
56	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:56+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:59.28403+02	nkoleevans@gmail.com
57	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:55:29+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 05:55:29.564669+02	nkoleevans@gmail.com
58	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:55:29+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 05:55:30.364984+02	nkoleevans@gmail.com
59	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:55:30+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 05:55:31.365755+02	nkoleevans@gmail.com
60	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:55:33+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 05:55:35.380859+02	nkoleevans@gmail.com
61	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:55:37+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 05:55:37.977433+02	nkoleevans@gmail.com
62	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:55:38+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:55:38.945842+02	nkoleevans@gmail.com
63	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:57:07+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:57:10.999385+02	nkoleevans@gmail.com
64	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:59:10+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:59:10.670507+02	nkoleevans@gmail.com
65	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 06:02:21+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:02:22.22293+02	nkoleevans@gmail.com
66	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 06:03:41+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:03:41.711982+02	nkoleevans@gmail.com
67	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:05:35+02	Session	\N	\N	Start	null	{"exp": 1784694935, "jti": "5afc934a75ce42c1a0b94b870c414725", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 06:05:35.651638+02	nkoleevans@gmail.com
68	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:07:34+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:07:34.733452+02	nkoleevans@gmail.com
69	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:07:35+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:07:36.100408+02	nkoleevans@gmail.com
70	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:07:40+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:07:41.391913+02	nkoleevans@gmail.com
71	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:08:01+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:08:01.902479+02	nkoleevans@gmail.com
72	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:09:45+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:09:47.878893+02	nkoleevans@gmail.com
73	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:09:56+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:09:56.691331+02	nkoleevans@gmail.com
74	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:10:02+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:10:03.416069+02	nkoleevans@gmail.com
75	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:10:04+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:10:05.002825+02	nkoleevans@gmail.com
76	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:10:17+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:10:17.907225+02	nkoleevans@gmail.com
77	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:10:27+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:10:27.81358+02	nkoleevans@gmail.com
78	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:10:30+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:10:31.193482+02	nkoleevans@gmail.com
79	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:10:36+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:10:36.826353+02	nkoleevans@gmail.com
80	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:33.853217+02	nkoleevans@gmail.com
81	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:35+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:36.029836+02	nkoleevans@gmail.com
82	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:36+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:37.132904+02	nkoleevans@gmail.com
83	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:38+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:38.594985+02	nkoleevans@gmail.com
84	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:40+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:40.955738+02	nkoleevans@gmail.com
85	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:41+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:43.147611+02	nkoleevans@gmail.com
86	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:45+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:46.647973+02	nkoleevans@gmail.com
87	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:46+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:48.123458+02	nkoleevans@gmail.com
88	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:14:54+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:14:54.641691+02	nkoleevans@gmail.com
89	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:14:57+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:14:57.905984+02	nkoleevans@gmail.com
90	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:14:58+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:14:59.337841+02	nkoleevans@gmail.com
91	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:14:59+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:14:59.904658+02	nkoleevans@gmail.com
92	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:15:00+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:15:00.705473+02	nkoleevans@gmail.com
93	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:15:01+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:15:02.496687+02	nkoleevans@gmail.com
94	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:15:02+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:15:03.057095+02	nkoleevans@gmail.com
95	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:15+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:15.932236+02	nkoleevans@gmail.com
96	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:16+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:17.272399+02	nkoleevans@gmail.com
97	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:18+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:18.717737+02	nkoleevans@gmail.com
98	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:19+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:19.649481+02	nkoleevans@gmail.com
99	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:19+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:20.430336+02	nkoleevans@gmail.com
100	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:23+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:23.916596+02	nkoleevans@gmail.com
101	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:24+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:24.951161+02	nkoleevans@gmail.com
102	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:24+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:25.475492+02	nkoleevans@gmail.com
103	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:25+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:26.354966+02	nkoleevans@gmail.com
104	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:26+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:26.93155+02	nkoleevans@gmail.com
105	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:26+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:27.482629+02	nkoleevans@gmail.com
106	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:29+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:29.92587+02	nkoleevans@gmail.com
107	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:32+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:32.95779+02	nkoleevans@gmail.com
108	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:19:07+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:19:07.843182+02	nkoleevans@gmail.com
109	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:19:08+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:19:08.996481+02	nkoleevans@gmail.com
110	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:19:09+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:19:11.071344+02	nkoleevans@gmail.com
111	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:19:11+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 06:19:12.190885+02	nkoleevans@gmail.com
112	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:19:12+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:19:13.329256+02	nkoleevans@gmail.com
113	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:19:14+02	PT Cycle Samples List	\N	\N	View - Allowed	null	null	2026-07-22 06:19:14.990684+02	nkoleevans@gmail.com
114	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:13+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:14.82198+02	nkoleevans@gmail.com
115	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:14+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:14.971342+02	nkoleevans@gmail.com
116	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:16+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:16.648089+02	nkoleevans@gmail.com
117	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:16+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:17.251806+02	nkoleevans@gmail.com
118	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:17+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:17.692035+02	nkoleevans@gmail.com
119	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:17+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:18.201017+02	nkoleevans@gmail.com
120	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:19+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:19.654953+02	nkoleevans@gmail.com
121	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:19+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:20.134427+02	nkoleevans@gmail.com
122	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:20+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:21.3856+02	nkoleevans@gmail.com
123	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:21+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:22.264122+02	nkoleevans@gmail.com
124	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:22+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:22.801435+02	nkoleevans@gmail.com
125	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:22+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:23.441762+02	nkoleevans@gmail.com
126	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:47+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:48.074182+02	nkoleevans@gmail.com
127	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:51+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:51.71363+02	nkoleevans@gmail.com
128	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:53+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:54.214301+02	nkoleevans@gmail.com
129	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:54+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:59.391196+02	nkoleevans@gmail.com
130	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:23:09+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:23:12.417885+02	nkoleevans@gmail.com
131	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:23:13+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:23:14.195589+02	nkoleevans@gmail.com
132	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:23:14+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:23:14.942534+02	nkoleevans@gmail.com
133	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:01+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:04.020237+02	nkoleevans@gmail.com
134	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:03+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:04.31496+02	nkoleevans@gmail.com
135	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:05+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:05.754088+02	nkoleevans@gmail.com
136	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:06+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:07.40278+02	nkoleevans@gmail.com
137	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:45+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:46.136727+02	nkoleevans@gmail.com
138	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:46+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:47.30531+02	nkoleevans@gmail.com
139	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:48+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:49.227522+02	nkoleevans@gmail.com
140	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:25:46+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:25:46.541141+02	nkoleevans@gmail.com
141	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:25:48+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:25:48.57849+02	nkoleevans@gmail.com
142	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:26:40+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:26:43.366007+02	nkoleevans@gmail.com
143	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:30:50+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:30:52.043239+02	nkoleevans@gmail.com
144	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:39:36+02	Session	\N	\N	Start	null	{"exp": 1784696976, "jti": "cef71fe6140c479ab739632c5be32fad", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 06:39:37.588474+02	nkoleevans@gmail.com
145	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:39:43+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:39:43.613898+02	nkoleevans@gmail.com
146	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:39:45+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:39:45.654958+02	nkoleevans@gmail.com
147	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:04+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:04.961103+02	nkoleevans@gmail.com
148	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:06+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-22 06:40:06.893884+02	nkoleevans@gmail.com
149	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:08+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:08.581123+02	nkoleevans@gmail.com
150	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:08+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:10.408715+02	nkoleevans@gmail.com
151	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:10+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:10.899555+02	nkoleevans@gmail.com
152	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:21+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:22.405278+02	nkoleevans@gmail.com
153	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:24+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:24.669911+02	nkoleevans@gmail.com
154	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:25+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:28.879724+02	nkoleevans@gmail.com
155	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:43+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:43.752872+02	nkoleevans@gmail.com
156	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:46+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:47.884506+02	nkoleevans@gmail.com
157	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:48+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:49.288677+02	nkoleevans@gmail.com
158	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:49+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:40:50.196898+02	nkoleevans@gmail.com
159	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:56+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:41:00.01118+02	nkoleevans@gmail.com
160	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:42:50+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:42:53.018954+02	nkoleevans@gmail.com
161	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:00+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:00.734886+02	nkoleevans@gmail.com
162	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:01+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:02.43168+02	nkoleevans@gmail.com
163	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:03+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:03.897287+02	nkoleevans@gmail.com
164	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:03+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:04.279293+02	nkoleevans@gmail.com
165	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:06+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:06.674185+02	nkoleevans@gmail.com
166	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:07+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:08.101652+02	nkoleevans@gmail.com
167	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:08+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:08.645198+02	nkoleevans@gmail.com
168	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:11+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:11.544893+02	nkoleevans@gmail.com
169	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:24+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:25.332311+02	nkoleevans@gmail.com
170	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:25+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:26.345269+02	nkoleevans@gmail.com
171	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:44:11+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:44:11.601114+02	nkoleevans@gmail.com
172	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:44:53+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:44:53.613197+02	nkoleevans@gmail.com
173	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:53:24+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:53:24.731679+02	nkoleevans@gmail.com
174	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:53:25+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:53:25.961685+02	nkoleevans@gmail.com
175	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:53:26+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:53:26.69854+02	nkoleevans@gmail.com
176	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:53:54+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 06:53:55.76551+02	nkoleevans@gmail.com
177	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:54:00+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 06:54:01.098392+02	nkoleevans@gmail.com
178	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 07:07:12+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:07:15.459201+02	nkoleevans@gmail.com
179	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:12:51+02	Session	\N	\N	Start	null	{"exp": 1784698971, "jti": "fcd5bf456fec4d3b8f37668e59a49f82", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 07:12:53.339178+02	nkoleevans@gmail.com
180	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:12:53+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 07:12:54.321503+02	nkoleevans@gmail.com
181	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:12:54+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:12:55.137872+02	nkoleevans@gmail.com
182	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:13:21+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:13:24.623066+02	nkoleevans@gmail.com
183	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:14:39+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:14:42.124051+02	nkoleevans@gmail.com
184	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:16:22+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:16:23.384998+02	nkoleevans@gmail.com
185	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:16:23+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:16:23.970733+02	nkoleevans@gmail.com
186	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:16:24+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:16:25.215808+02	nkoleevans@gmail.com
187	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:16:27+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:16:27.583831+02	nkoleevans@gmail.com
188	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:39+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:19:40.248053+02	nkoleevans@gmail.com
189	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:41+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-22 07:19:41.873334+02	nkoleevans@gmail.com
190	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:44+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 07:19:45.011624+02	nkoleevans@gmail.com
191	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:45+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 07:19:45.691914+02	nkoleevans@gmail.com
192	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:45+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-22 07:19:46.524291+02	nkoleevans@gmail.com
193	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:48+02	Province List	\N	\N	View - Allowed	null	null	2026-07-22 07:19:48.867679+02	nkoleevans@gmail.com
194	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:49+02	District List	\N	\N	View - Allowed	null	null	2026-07-22 07:19:50.457352+02	nkoleevans@gmail.com
195	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:12+02	Province List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:13.419006+02	nkoleevans@gmail.com
196	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:14+02	District List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:15.387433+02	nkoleevans@gmail.com
197	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:20+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:20.928169+02	nkoleevans@gmail.com
198	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:22+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:23.160578+02	nkoleevans@gmail.com
199	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:23+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:24.714867+02	nkoleevans@gmail.com
200	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:24+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:25.263875+02	nkoleevans@gmail.com
201	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:25+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:26.955221+02	nkoleevans@gmail.com
202	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:26+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:27.501906+02	nkoleevans@gmail.com
203	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:27+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:27.95186+02	nkoleevans@gmail.com
204	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:29+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:30.063839+02	nkoleevans@gmail.com
205	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:33+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:20:34.077562+02	nkoleevans@gmail.com
206	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:33:31+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:33:32.329323+02	nkoleevans@gmail.com
207	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:33:40+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:33:43.173327+02	nkoleevans@gmail.com
208	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:33:57+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:33:58.659073+02	nkoleevans@gmail.com
209	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:34:01+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-22 07:34:02.311656+02	nkoleevans@gmail.com
210	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:34:21+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:34:22.600521+02	nkoleevans@gmail.com
211	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:34:42+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:34:42.717401+02	nkoleevans@gmail.com
212	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:34:45+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:34:45.571856+02	nkoleevans@gmail.com
213	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:34:47+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:34:47.76451+02	nkoleevans@gmail.com
214	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:37:16+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:37:18.815424+02	nkoleevans@gmail.com
215	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:38:21+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:38:23.868133+02	nkoleevans@gmail.com
216	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:38:45+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:38:46.480324+02	nkoleevans@gmail.com
217	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:40:12+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:40:13.309466+02	nkoleevans@gmail.com
218	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:40:18+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:40:21.15946+02	nkoleevans@gmail.com
219	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:42:54+02	Session	\N	\N	Start	null	{"exp": 1784700774, "jti": "413cb336b95b4e328f8484e240341660", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 07:42:55.045923+02	nkoleevans@gmail.com
220	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:42:56+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:42:56.964805+02	nkoleevans@gmail.com
221	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:42:57+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:42:57.947764+02	nkoleevans@gmail.com
222	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:43:05+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:43:08.227749+02	nkoleevans@gmail.com
223	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:44:25+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:44:27.514874+02	nkoleevans@gmail.com
224	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:44:43+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:44:43.622833+02	nkoleevans@gmail.com
225	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:44:53+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:44:54.29115+02	nkoleevans@gmail.com
226	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:44:58+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:44:58.73446+02	nkoleevans@gmail.com
227	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:45:55+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:45:58.400781+02	nkoleevans@gmail.com
228	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:46:01+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:46:01.735051+02	nkoleevans@gmail.com
229	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:52:38+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:52:40.448188+02	nkoleevans@gmail.com
230	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:52:44+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:52:44.863246+02	nkoleevans@gmail.com
231	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:52:55+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:52:56.060981+02	nkoleevans@gmail.com
232	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:52:56+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:52:57.364147+02	nkoleevans@gmail.com
233	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:04+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:05.325217+02	nkoleevans@gmail.com
234	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:15+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:15.666248+02	nkoleevans@gmail.com
235	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:16+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:17.000937+02	nkoleevans@gmail.com
236	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:17+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:17.917107+02	nkoleevans@gmail.com
237	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:17+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:18.478241+02	nkoleevans@gmail.com
238	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:28+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:29.302309+02	nkoleevans@gmail.com
239	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:29+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:29.884584+02	nkoleevans@gmail.com
240	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:29+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:31.289946+02	nkoleevans@gmail.com
241	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:34+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:35.14677+02	nkoleevans@gmail.com
242	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:35+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:35.679679+02	nkoleevans@gmail.com
243	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:35+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:36.54391+02	nkoleevans@gmail.com
244	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:36+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:37.089433+02	nkoleevans@gmail.com
245	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:37+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:39.151583+02	nkoleevans@gmail.com
246	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:43+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 07:53:44.286667+02	nkoleevans@gmail.com
247	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:44+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 07:53:44.811564+02	nkoleevans@gmail.com
248	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:45+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:46.114849+02	nkoleevans@gmail.com
249	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:48+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:49.856533+02	nkoleevans@gmail.com
250	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:50+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:50.829308+02	nkoleevans@gmail.com
251	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:51+02	Review Service	\N	\N	View - Allowed	null	null	2026-07-22 07:53:52.276581+02	nkoleevans@gmail.com
252	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:55+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:55.611939+02	nkoleevans@gmail.com
253	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:56+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:53:56.98208+02	nkoleevans@gmail.com
254	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:59+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:59.650326+02	nkoleevans@gmail.com
255	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:54:01+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:54:02.204475+02	nkoleevans@gmail.com
256	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:54:02+02	Review Method	\N	\N	View - Allowed	null	null	2026-07-22 07:54:03.25173+02	nkoleevans@gmail.com
257	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:54:09+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:54:09.678457+02	nkoleevans@gmail.com
258	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:50:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 12:50:32.41947+02	admin@gmail.com
259	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:50:37+02	Users	\N	\N	View - Allowed	null	null	2026-07-22 12:50:44.529004+02	admin@gmail.com
260	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:51:49+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 12:51:52.470094+02	admin@gmail.com
261	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:51:52+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 12:51:52.975943+02	admin@gmail.com
262	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:51:54+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 12:51:55.075323+02	admin@gmail.com
263	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:51:56+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 12:51:57.100769+02	admin@gmail.com
264	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:52:44+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 12:52:45.406232+02	admin@gmail.com
265	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:52:46+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 12:52:46.765929+02	admin@gmail.com
266	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:52:48+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 12:52:53.191128+02	admin@gmail.com
267	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:53:20+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 12:53:22.425721+02	admin@gmail.com
268	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:53:22+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 12:53:22.949564+02	admin@gmail.com
269	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:53:25+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 12:53:25.977504+02	admin@gmail.com
270	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:57:54+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 12:57:55.451676+02	admin@gmail.com
271	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:58:02+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 12:58:02.619612+02	admin@gmail.com
272	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:58:03+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 12:58:04.70007+02	admin@gmail.com
273	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:58:14+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 12:58:15.008991+02	admin@gmail.com
274	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:58:20+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 12:58:22.34875+02	admin@gmail.com
275	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:58:21+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 12:58:22.462457+02	admin@gmail.com
276	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 13:00:38+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 13:00:40.299787+02	admin@gmail.com
277	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 13:00:40+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 13:00:41.101066+02	admin@gmail.com
278	0	admin@gmail.com	public	2026-07-22 15:31:33+02	Authentication	\N	\N	Unauthorised	null	null	2026-07-22 15:31:33.77183+02	admin@gmail.com
279	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:07+02	Session	\N	\N	Start	null	{"exp": 1784728927, "jti": "783431e259534bce83df240cb5ed1752", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 15:32:08.431534+02	nkoleevans@gmail.com
280	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:16+02	Users	\N	\N	View - Allowed	null	null	2026-07-22 15:32:17.48437+02	nkoleevans@gmail.com
281	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:18+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:19.10875+02	nkoleevans@gmail.com
282	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:20+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 15:32:20.637664+02	nkoleevans@gmail.com
283	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:20+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 15:32:21.020913+02	nkoleevans@gmail.com
284	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:21+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:21.825736+02	nkoleevans@gmail.com
285	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:23+02	Province List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:24.032655+02	nkoleevans@gmail.com
286	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:24+02	District List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:24.826051+02	nkoleevans@gmail.com
287	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:25+02	Province List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:25.882949+02	nkoleevans@gmail.com
288	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:26+02	District List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:26.741726+02	nkoleevans@gmail.com
289	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:27+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:27.727502+02	nkoleevans@gmail.com
290	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:28+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:29.01185+02	nkoleevans@gmail.com
291	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:30+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:30.755807+02	nkoleevans@gmail.com
292	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:33+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:33.832187+02	nkoleevans@gmail.com
293	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:35+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 15:32:35.935421+02	nkoleevans@gmail.com
294	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:01+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:02.375216+02	nkoleevans@gmail.com
295	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:06+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:06.776659+02	nkoleevans@gmail.com
296	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:07+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 15:33:08.233157+02	nkoleevans@gmail.com
297	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:22+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:23.350584+02	nkoleevans@gmail.com
298	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:36+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:37.146968+02	nkoleevans@gmail.com
299	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:37+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:38.309477+02	nkoleevans@gmail.com
300	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:38+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:39.248856+02	nkoleevans@gmail.com
301	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:39+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:40.313565+02	nkoleevans@gmail.com
303	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:43+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:44.261617+02	nkoleevans@gmail.com
304	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:44+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:45.310215+02	nkoleevans@gmail.com
305	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:45+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:45.902625+02	nkoleevans@gmail.com
307	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:47+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:47.671131+02	nkoleevans@gmail.com
308	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:48+02	Users	\N	\N	View - Allowed	null	null	2026-07-22 15:33:49.017953+02	nkoleevans@gmail.com
309	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:43:54+02	Session	\N	\N	Start	null	{"exp": 1784729634, "jti": "ff48cc35d4634599a4a5c6e0c799e947", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 15:43:55.368882+02	nkoleevans@gmail.com
310	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:08+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 15:44:08.539159+02	nkoleevans@gmail.com
311	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:08+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-22 15:44:09.516304+02	nkoleevans@gmail.com
312	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:28+02	Province List	\N	\N	View - Allowed	null	null	2026-07-22 15:44:29.405169+02	nkoleevans@gmail.com
313	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:38+02	District List	\N	\N	View - Allowed	null	null	2026-07-22 15:44:38.734294+02	nkoleevans@gmail.com
314	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:40+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 15:44:41.472928+02	nkoleevans@gmail.com
315	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:45+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:44:46.240099+02	nkoleevans@gmail.com
302	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:41+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 15:33:41.561717+02	nkoleevans@gmail.com
316	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:54+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-22 15:44:54.936094+02	nkoleevans@gmail.com
317	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:57+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:44:58.321595+02	nkoleevans@gmail.com
318	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:18+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:45:18.690418+02	nkoleevans@gmail.com
325	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:46:00+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 15:46:01.378649+02	nkoleevans@gmail.com
326	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:46:21+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 15:46:22.284915+02	nkoleevans@gmail.com
327	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:47:08+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:47:09.467888+02	nkoleevans@gmail.com
306	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:46+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:47.297433+02	nkoleevans@gmail.com
319	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:23+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 15:45:24.421867+02	nkoleevans@gmail.com
320	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:31+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:45:31.773891+02	nkoleevans@gmail.com
321	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:32+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 15:45:32.889238+02	nkoleevans@gmail.com
322	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:45+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:45:45.739968+02	nkoleevans@gmail.com
323	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:46+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 15:45:47.481624+02	nkoleevans@gmail.com
324	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:59+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 15:45:59.596857+02	nkoleevans@gmail.com
328	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:23+02	Session	\N	\N	Start	null	{"exp": 1784806103, "jti": "642463dd03654483a4c26f1f9611aed7", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-23 12:58:24.388392+02	nkoleevans@gmail.com
329	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:28+02	Users	\N	\N	View - Allowed	null	null	2026-07-23 12:58:29.677805+02	nkoleevans@gmail.com
330	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:29+02	Role List	\N	\N	View - Allowed	null	null	2026-07-23 12:58:30.423071+02	nkoleevans@gmail.com
331	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 12:58:31.581233+02	nkoleevans@gmail.com
332	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:31+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 12:58:32.354143+02	nkoleevans@gmail.com
333	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:32+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 12:58:33.166716+02	nkoleevans@gmail.com
334	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:33+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 12:58:34.182193+02	nkoleevans@gmail.com
335	0	nkoleevans@hotmail.com	public	2026-07-23 13:08:47+02	Authentication	\N	\N	Unauthorised	null	null	2026-07-23 13:08:48.146707+02	nkoleevans@hotmail.com
336	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:08:51+02	Session	\N	\N	Start	null	{"exp": 1784806731, "jti": "67e09fed1e1e47caaf76003f2c8236d3", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-23 13:08:52.070795+02	nkoleevans@gmail.com
337	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:08:53+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:08:54.5143+02	nkoleevans@gmail.com
338	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:08:54+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:08:55.424763+02	nkoleevans@gmail.com
339	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:08:55+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:08:56.428308+02	nkoleevans@gmail.com
340	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:08:58+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:08:58.652275+02	nkoleevans@gmail.com
341	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:08:58+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:08:59.251141+02	nkoleevans@gmail.com
342	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:10:43+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:10:45.499652+02	nkoleevans@gmail.com
343	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:10:41+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:10:45.736167+02	nkoleevans@gmail.com
344	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:11:51+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:11:54.919766+02	nkoleevans@gmail.com
345	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:17+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:23.491961+02	nkoleevans@gmail.com
346	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:17+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:23.817028+02	nkoleevans@gmail.com
347	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:18+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:23.828196+02	nkoleevans@gmail.com
348	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:29+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:29.739264+02	nkoleevans@gmail.com
349	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:29+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:30.985519+02	nkoleevans@gmail.com
350	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:32.456625+02	nkoleevans@gmail.com
351	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:34+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:35.300902+02	nkoleevans@gmail.com
352	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:35+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:36.047222+02	nkoleevans@gmail.com
353	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:36+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:36.738245+02	nkoleevans@gmail.com
354	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:36+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:37.169847+02	nkoleevans@gmail.com
355	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:37+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:37.583185+02	nkoleevans@gmail.com
356	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:38+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:38.984977+02	nkoleevans@gmail.com
357	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:43+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:48.877912+02	nkoleevans@gmail.com
358	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:04+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:04.8173+02	nkoleevans@gmail.com
359	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:05+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:05.972224+02	nkoleevans@gmail.com
360	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:07+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:07.910893+02	nkoleevans@gmail.com
361	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:11+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:12.530533+02	nkoleevans@gmail.com
362	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:12+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:12.927097+02	nkoleevans@gmail.com
364	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:14+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:15.220786+02	nkoleevans@gmail.com
367	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:20+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:21.008248+02	nkoleevans@gmail.com
369	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:23+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:23.836963+02	nkoleevans@gmail.com
372	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:25+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:25.698386+02	nkoleevans@gmail.com
374	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:26+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:26.83217+02	nkoleevans@gmail.com
363	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:12+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:13.325734+02	nkoleevans@gmail.com
366	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:20+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:20.616797+02	nkoleevans@gmail.com
368	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:20+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:21.38358+02	nkoleevans@gmail.com
371	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:24+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:25.288766+02	nkoleevans@gmail.com
373	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:25+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:26.00181+02	nkoleevans@gmail.com
378	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:41:28+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:41:29.721933+02	nkoleevans@gmail.com
365	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:19+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:20.003541+02	nkoleevans@gmail.com
370	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:24+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:24.726428+02	nkoleevans@gmail.com
375	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:40:35+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:40:36.454517+02	nkoleevans@gmail.com
376	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:40:37+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:40:37.707741+02	nkoleevans@gmail.com
377	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:41:27+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:41:28.504254+02	nkoleevans@gmail.com
379	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:43:49+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-23 13:43:50.494482+02	nkoleevans@gmail.com
380	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:43:58+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-23 13:44:02.280708+02	nkoleevans@gmail.com
381	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:44:05+02	Session	\N	\N	Start	null	{"exp": 1784808845, "jti": "fc18fe466a2443fcb7d61261ae2e75ef", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-23 13:44:05.7545+02	nkoleevans@gmail.com
382	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:44:07+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:44:08.11331+02	nkoleevans@gmail.com
383	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:44:08+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-23 13:44:09.141444+02	nkoleevans@gmail.com
384	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:45:46+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:45:47.2853+02	nkoleevans@gmail.com
385	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:45:50+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:45:50.615527+02	nkoleevans@gmail.com
386	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:45:52+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:45:53.454499+02	nkoleevans@gmail.com
387	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:45:54+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:45:54.719625+02	nkoleevans@gmail.com
388	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:46:17+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-23 13:46:17.700217+02	nkoleevans@gmail.com
389	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:46:25+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:46:26.458575+02	nkoleevans@gmail.com
390	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:46:30+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:46:30.922975+02	nkoleevans@gmail.com
391	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:46:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:46:31.877855+02	nkoleevans@gmail.com
392	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:46:35+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:46:35.666236+02	nkoleevans@gmail.com
393	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:02+02	Service	\N	\N	View - Allowed	null	null	2026-07-23 13:47:02.951733+02	nkoleevans@gmail.com
394	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:07+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:08.496548+02	nkoleevans@gmail.com
395	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:08+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:09.173827+02	nkoleevans@gmail.com
396	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:10+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:11.402721+02	nkoleevans@gmail.com
397	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:15+02	Review Service	\N	\N	View - Allowed	null	null	2026-07-23 13:47:16.614182+02	nkoleevans@gmail.com
398	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:19+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:19.820915+02	nkoleevans@gmail.com
399	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:21+02	Review Service	\N	\N	View - Allowed	null	null	2026-07-23 13:47:22.010263+02	nkoleevans@gmail.com
400	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:24+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:24.615987+02	nkoleevans@gmail.com
401	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:25+02	Service	\N	\N	View - Allowed	null	null	2026-07-23 13:47:25.912044+02	nkoleevans@gmail.com
402	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:35+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:35.800427+02	nkoleevans@gmail.com
403	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:36+02	Review Service	\N	\N	View - Allowed	null	null	2026-07-23 13:47:36.833167+02	nkoleevans@gmail.com
404	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:40+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:40.780431+02	nkoleevans@gmail.com
405	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:44+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:45.454645+02	nkoleevans@gmail.com
406	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:48:08+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:48:13.728205+02	nkoleevans@gmail.com
407	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:48:09+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:48:13.772795+02	nkoleevans@gmail.com
408	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:48:13+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:48:14.115572+02	nkoleevans@gmail.com
409	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:50:25+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:50:28.123366+02	nkoleevans@gmail.com
410	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:55:29+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:56:34.433031+02	nkoleevans@gmail.com
411	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:56:45+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:56:46.122294+02	nkoleevans@gmail.com
412	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:56:54+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:56:55.301618+02	nkoleevans@gmail.com
413	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:56:57+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:56:57.892995+02	nkoleevans@gmail.com
414	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:56:58+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:56:58.656762+02	nkoleevans@gmail.com
415	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:57:26+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:57:28.981428+02	nkoleevans@gmail.com
416	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:57:55+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:57:55.978559+02	nkoleevans@gmail.com
417	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:58:02+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:58:05.68111+02	nkoleevans@gmail.com
418	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:58:41+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:58:42.431638+02	nkoleevans@gmail.com
419	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:58:43+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:58:43.571737+02	nkoleevans@gmail.com
420	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:58:57+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:58:57.783317+02	nkoleevans@gmail.com
421	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:59:13+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 13:59:14.048668+02	nkoleevans@gmail.com
422	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:59:16+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 13:59:16.609008+02	nkoleevans@gmail.com
423	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:01:31+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 14:01:34.848037+02	nkoleevans@gmail.com
424	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:41+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:41.558319+02	nkoleevans@gmail.com
425	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:43+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 14:02:44.519794+02	nkoleevans@gmail.com
426	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:47+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:48.287984+02	nkoleevans@gmail.com
427	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:51+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:52.131583+02	nkoleevans@gmail.com
428	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:56+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:57.220526+02	nkoleevans@gmail.com
429	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:57+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:57.621476+02	nkoleevans@gmail.com
430	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:58+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:58.555889+02	nkoleevans@gmail.com
431	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:58+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:59.129058+02	nkoleevans@gmail.com
432	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:03:00+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:03:00.537476+02	nkoleevans@gmail.com
433	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:03:01+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:03:01.548725+02	nkoleevans@gmail.com
434	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:03:01+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:03:02.087781+02	nkoleevans@gmail.com
435	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:03:02+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:03:02.990558+02	nkoleevans@gmail.com
436	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:03:35+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-23 14:03:35.594033+02	nkoleevans@gmail.com
437	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:05:36+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:05:37.352595+02	nkoleevans@gmail.com
438	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:07:47+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:07:50.420825+02	nkoleevans@gmail.com
439	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:07:51+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-07-23 14:07:52.42974+02	nkoleevans@gmail.com
440	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:08:37+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-23 14:08:37.636086+02	nkoleevans@gmail.com
441	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:08:37+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-07-23 14:08:39.240569+02	nkoleevans@gmail.com
442	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:08:40+02	Province List	\N	\N	View - Allowed	null	null	2026-07-23 14:08:41.446212+02	nkoleevans@gmail.com
443	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:08:41+02	District List	\N	\N	View - Allowed	null	null	2026-07-23 14:08:42.013026+02	nkoleevans@gmail.com
444	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:08:46+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:08:47.808477+02	nkoleevans@gmail.com
445	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:10:55+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:10:55.802292+02	nkoleevans@gmail.com
446	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:11:07+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:11:13.186099+02	nkoleevans@gmail.com
447	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:11:11+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:11:13.19747+02	nkoleevans@gmail.com
448	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:11:29+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:11:31.630942+02	nkoleevans@gmail.com
449	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:12:30+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:12:33.677961+02	nkoleevans@gmail.com
450	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:13:45+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:13:51.123887+02	nkoleevans@gmail.com
451	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:14:23+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:14:23.883221+02	nkoleevans@gmail.com
452	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:16:35+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-23 14:16:37.357051+02	nkoleevans@gmail.com
453	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:17:04+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-23 14:17:04.850343+02	nkoleevans@gmail.com
454	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:17:06+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-23 14:17:07.323561+02	nkoleevans@gmail.com
455	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:17:17+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-23 14:17:18.049118+02	nkoleevans@gmail.com
456	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:19:43+02	Session	\N	\N	Start	null	{"exp": 1784810983, "jti": "c49e6b4d50fe41359c63f6f6317459c6", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-23 14:19:44.538016+02	nkoleevans@gmail.com
457	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:19:45+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-23 14:19:46.183511+02	nkoleevans@gmail.com
458	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:20:42+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:20:42.990336+02	nkoleevans@gmail.com
459	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:20:42+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:20:43.232733+02	nkoleevans@gmail.com
460	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:20:49+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:20:49.920085+02	nkoleevans@gmail.com
461	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:20:56+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:20:56.665899+02	nkoleevans@gmail.com
462	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:20:59+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:21:00.001897+02	nkoleevans@gmail.com
463	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:21:02+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:21:02.917902+02	nkoleevans@gmail.com
464	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:21:44+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:21:45.298841+02	nkoleevans@gmail.com
465	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:21:45+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:21:45.97585+02	nkoleevans@gmail.com
466	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:22:08+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:22:09.085205+02	nkoleevans@gmail.com
467	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:22:09+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:22:09.7656+02	nkoleevans@gmail.com
468	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:22:15+02	PT Cycle Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:22:15.647342+02	nkoleevans@gmail.com
469	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:23:24+02	Role List	\N	\N	View - Allowed	null	null	2026-07-23 14:23:25.28979+02	nkoleevans@gmail.com
470	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:23:48+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:23:48.743312+02	nkoleevans@gmail.com
471	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:23:49+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:23:50.335549+02	nkoleevans@gmail.com
472	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:23:51+02	PT Cycle Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:23:52.286269+02	nkoleevans@gmail.com
473	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:23:55+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:23:56.190198+02	nkoleevans@gmail.com
474	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:24:01+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:24:01.828173+02	nkoleevans@gmail.com
475	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:24:06+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:24:06.740805+02	nkoleevans@gmail.com
476	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:24:08+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:24:08.724072+02	nkoleevans@gmail.com
477	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:26:03+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:26:03.698604+02	nkoleevans@gmail.com
478	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:26:04+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:26:04.967162+02	nkoleevans@gmail.com
479	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:26:05+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:26:05.652677+02	nkoleevans@gmail.com
480	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:26:28+02	PT Cycle Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:26:32.677965+02	nkoleevans@gmail.com
481	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:26:30+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:26:33.258289+02	nkoleevans@gmail.com
482	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:26:31+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:26:33.269835+02	nkoleevans@gmail.com
483	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:27:14+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:27:16.604143+02	nkoleevans@gmail.com
484	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:28:25+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:28:28.255099+02	nkoleevans@gmail.com
485	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:02+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:02.631927+02	nkoleevans@gmail.com
486	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:08+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:09.176099+02	nkoleevans@gmail.com
487	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:09+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:09.658836+02	nkoleevans@gmail.com
488	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:09+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:10.171713+02	nkoleevans@gmail.com
489	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:10+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:10.608273+02	nkoleevans@gmail.com
490	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:15+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:15.93871+02	nkoleevans@gmail.com
491	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:18+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:19.178983+02	nkoleevans@gmail.com
492	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:21+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:23.093005+02	nkoleevans@gmail.com
493	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:23+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:23.654939+02	nkoleevans@gmail.com
494	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:25+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:26.11712+02	nkoleevans@gmail.com
495	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:33+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:34.18632+02	nkoleevans@gmail.com
496	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:35+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:36.203235+02	nkoleevans@gmail.com
497	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:36+02	PT Cycle Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:29:37.103521+02	nkoleevans@gmail.com
498	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:46+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:46.620381+02	nkoleevans@gmail.com
499	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:46+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:47.227399+02	nkoleevans@gmail.com
500	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:30:50+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:30:51.021915+02	nkoleevans@gmail.com
501	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:30:51+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:30:51.646434+02	nkoleevans@gmail.com
502	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:30:52+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:30:52.558075+02	nkoleevans@gmail.com
503	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:30:55+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:30:56.343674+02	nkoleevans@gmail.com
504	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:30:59+02	PT Cycle Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:30:59.902047+02	nkoleevans@gmail.com
505	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:19+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:19.8014+02	nkoleevans@gmail.com
508	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:22+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:23.191197+02	nkoleevans@gmail.com
511	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:25+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:25.624989+02	nkoleevans@gmail.com
513	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:26+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:27.479747+02	nkoleevans@gmail.com
515	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:28+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:28.952027+02	nkoleevans@gmail.com
506	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:19+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:20.416663+02	nkoleevans@gmail.com
507	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:22+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:22.751513+02	nkoleevans@gmail.com
509	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:23+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:23.563311+02	nkoleevans@gmail.com
510	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:23+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:23.84959+02	nkoleevans@gmail.com
512	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:25+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:26.259909+02	nkoleevans@gmail.com
514	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:27+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:28.142768+02	nkoleevans@gmail.com
516	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:29+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:29.846506+02	nkoleevans@gmail.com
517	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:31+02	PT Cycle Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:31:32.467752+02	nkoleevans@gmail.com
518	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:28+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:29.352777+02	nkoleevans@gmail.com
519	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:39+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:40.029007+02	nkoleevans@gmail.com
520	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:42+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:42.612989+02	nkoleevans@gmail.com
521	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:43+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:43.861718+02	nkoleevans@gmail.com
522	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:44+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:44.820909+02	nkoleevans@gmail.com
523	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:44+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:45.493607+02	nkoleevans@gmail.com
524	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:45+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:45.95484+02	nkoleevans@gmail.com
525	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:46+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:46.758482+02	nkoleevans@gmail.com
526	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:46+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:47.559409+02	nkoleevans@gmail.com
527	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:47+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:48.401601+02	nkoleevans@gmail.com
528	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:48+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:49.012714+02	nkoleevans@gmail.com
529	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:36:10+02	Service	\N	\N	View - Allowed	null	null	2026-07-23 14:36:10.948989+02	nkoleevans@gmail.com
530	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:36:14+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:36:14.891547+02	nkoleevans@gmail.com
531	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:36:15+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 14:36:15.816513+02	nkoleevans@gmail.com
532	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:15+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 14:38:18.190389+02	nkoleevans@gmail.com
533	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:18+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:38:19.334346+02	nkoleevans@gmail.com
534	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:20+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:38:21.005521+02	nkoleevans@gmail.com
535	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:35+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:38:35.915653+02	nkoleevans@gmail.com
536	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:37+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:38:38.363121+02	nkoleevans@gmail.com
537	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:40+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:38:40.987744+02	nkoleevans@gmail.com
538	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:42+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:38:42.807466+02	nkoleevans@gmail.com
539	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:40:34+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:40:36.922016+02	nkoleevans@gmail.com
540	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:40:36+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:40:37.034467+02	nkoleevans@gmail.com
541	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:40:38+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:40:38.665057+02	nkoleevans@gmail.com
542	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:40:53+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:40:56.090627+02	nkoleevans@gmail.com
543	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:41:26+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:41:29.420743+02	nkoleevans@gmail.com
544	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:41:46+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:41:49.564983+02	nkoleevans@gmail.com
545	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:42:36+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:42:37.13291+02	nkoleevans@gmail.com
546	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:42:40+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:42:40.97945+02	nkoleevans@gmail.com
547	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:42:56+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:42:56.727364+02	nkoleevans@gmail.com
548	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:12+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:12.549537+02	nkoleevans@gmail.com
549	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:13+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:13.572706+02	nkoleevans@gmail.com
550	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:15+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:15.655479+02	nkoleevans@gmail.com
551	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:16+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:17.310802+02	nkoleevans@gmail.com
552	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:17+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:17.688202+02	nkoleevans@gmail.com
553	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:17+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:18.020123+02	nkoleevans@gmail.com
554	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:17+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:18.487804+02	nkoleevans@gmail.com
556	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:46:21+02	Role List	\N	\N	View - Allowed	null	null	2026-07-23 14:46:22.521116+02	nkoleevans@gmail.com
559	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:49:39+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-23 14:49:39.767173+02	nkoleevans@gmail.com
560	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:50:26+02	Lab Type	\N	\N	View - Allowed	null	null	2026-07-23 14:50:26.970633+02	nkoleevans@gmail.com
562	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:50:41+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-07-23 14:50:41.80763+02	nkoleevans@gmail.com
563	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:51:00+02	Review PT Cycle Status	\N	\N	View - Allowed	null	null	2026-07-23 14:51:01.024126+02	nkoleevans@gmail.com
565	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:51:30+02	Province List	\N	\N	View - Allowed	null	null	2026-07-23 14:51:31.500345+02	nkoleevans@gmail.com
567	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:51:50+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:51:51.520215+02	nkoleevans@gmail.com
569	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:52:04+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:52:05.470739+02	nkoleevans@gmail.com
570	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:52:12+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-23 14:52:13.351072+02	nkoleevans@gmail.com
571	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:52:20+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:52:20.755793+02	nkoleevans@gmail.com
574	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:53:01+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:53:01.925663+02	nkoleevans@gmail.com
578	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:54:58+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:54:58.562436+02	nkoleevans@gmail.com
579	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:55:02+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 14:55:03.198688+02	nkoleevans@gmail.com
581	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:55:21+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:55:22.034518+02	nkoleevans@gmail.com
582	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:55:26+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:55:26.783989+02	nkoleevans@gmail.com
583	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:55:54+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:55:55.480343+02	nkoleevans@gmail.com
585	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:58:29+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:58:29.765653+02	nkoleevans@gmail.com
586	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:58:30+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 14:58:31.395796+02	nkoleevans@gmail.com
589	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:09:18+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-23 15:09:18.806478+02	nkoleevans@gmail.com
591	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:14+02	Users	\N	\N	View - Allowed	null	null	2026-07-23 15:15:15.307939+02	nkoleevans@gmail.com
592	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:16+02	Role List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:18.05218+02	nkoleevans@gmail.com
594	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:20+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-23 15:15:20.571932+02	nkoleevans@gmail.com
596	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:21+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:21.97893+02	nkoleevans@gmail.com
597	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:24+02	Province List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:25.522653+02	nkoleevans@gmail.com
598	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:25+02	District List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:25.79136+02	nkoleevans@gmail.com
600	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:28+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:29.260436+02	nkoleevans@gmail.com
602	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:30+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:30.736355+02	nkoleevans@gmail.com
604	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:32+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:33.716152+02	nkoleevans@gmail.com
605	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:33+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:34.255675+02	nkoleevans@gmail.com
607	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:35+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:36.150317+02	nkoleevans@gmail.com
609	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:41+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:41.822542+02	nkoleevans@gmail.com
611	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:43+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:45.464645+02	nkoleevans@gmail.com
613	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:18+02	Session	\N	\N	Start	null	{"exp": 1784842158, "jti": "6ebf7e0cc13e4e96ad5b6d1e85804b96", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-23 22:59:19.186515+02	nkoleevans@gmail.com
615	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:23+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 22:59:27.652857+02	nkoleevans@gmail.com
616	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:34+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 22:59:35.194257+02	nkoleevans@gmail.com
618	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:41+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 22:59:42.548062+02	nkoleevans@gmail.com
620	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:44+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 22:59:45.49218+02	nkoleevans@gmail.com
621	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:57+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 22:59:57.658782+02	nkoleevans@gmail.com
555	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:19+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:20.47205+02	nkoleevans@gmail.com
557	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:48:59+02	Users	\N	\N	View - Allowed	null	null	2026-07-23 14:48:59.975741+02	nkoleevans@gmail.com
558	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:49:05+02	Role List	\N	\N	View - Allowed	null	null	2026-07-23 14:49:06.023837+02	nkoleevans@gmail.com
561	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:50:34+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-23 14:50:35.337097+02	nkoleevans@gmail.com
564	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:51:04+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-07-23 14:51:05.354273+02	nkoleevans@gmail.com
566	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:51:33+02	District List	\N	\N	View - Allowed	null	null	2026-07-23 14:51:34.238115+02	nkoleevans@gmail.com
568	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:51:56+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 14:51:57.272907+02	nkoleevans@gmail.com
572	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:52:44+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:52:45.48528+02	nkoleevans@gmail.com
573	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:52:54+02	Service	\N	\N	View - Allowed	null	null	2026-07-23 14:52:54.900814+02	nkoleevans@gmail.com
575	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:53:06+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:53:07.289938+02	nkoleevans@gmail.com
576	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:53:24+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:53:24.72862+02	nkoleevans@gmail.com
577	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:53:54+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:53:55.034867+02	nkoleevans@gmail.com
580	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:55:09+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:55:10.381572+02	nkoleevans@gmail.com
584	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:56:32+02	Province List	\N	\N	View - Allowed	null	null	2026-07-23 14:56:33.18335+02	nkoleevans@gmail.com
587	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:03:35+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 15:03:36.018967+02	nkoleevans@gmail.com
588	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:03:38+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 15:03:38.856009+02	nkoleevans@gmail.com
590	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:09:21+02	Role List	\N	\N	View - Allowed	null	null	2026-07-23 15:09:22.511164+02	nkoleevans@gmail.com
593	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:19+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-23 15:15:19.965665+02	nkoleevans@gmail.com
595	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:20+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:21.381854+02	nkoleevans@gmail.com
599	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:27+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:28.520712+02	nkoleevans@gmail.com
601	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:29+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:30.106715+02	nkoleevans@gmail.com
603	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:30+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:31.269114+02	nkoleevans@gmail.com
606	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:34+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:35.385581+02	nkoleevans@gmail.com
608	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:40+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:41.082265+02	nkoleevans@gmail.com
610	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:42+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:42.69919+02	nkoleevans@gmail.com
612	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:45+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:47.342716+02	nkoleevans@gmail.com
614	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:21+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 22:59:21.897107+02	nkoleevans@gmail.com
617	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:40+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 22:59:41.03574+02	nkoleevans@gmail.com
619	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:42+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 22:59:43.09537+02	nkoleevans@gmail.com
622	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:01+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:00:01.541349+02	nkoleevans@gmail.com
623	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:02+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 23:00:02.911176+02	nkoleevans@gmail.com
624	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:08+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 23:00:09.366398+02	nkoleevans@gmail.com
625	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:10+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 23:00:10.8263+02	nkoleevans@gmail.com
626	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:14+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 23:00:14.913223+02	nkoleevans@gmail.com
627	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:15+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 23:00:16.090295+02	nkoleevans@gmail.com
628	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:18+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:00:19.361368+02	nkoleevans@gmail.com
629	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:15+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:16.097143+02	nkoleevans@gmail.com
630	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:17+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:17.973281+02	nkoleevans@gmail.com
631	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:22+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:23.235757+02	nkoleevans@gmail.com
632	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:25+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:25.98835+02	nkoleevans@gmail.com
633	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:27+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:27.840475+02	nkoleevans@gmail.com
634	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:30+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:30.987322+02	nkoleevans@gmail.com
635	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:32+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:33.742686+02	nkoleevans@gmail.com
637	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:10:17+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 23:10:17.588604+02	nkoleevans@gmail.com
638	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:10:18+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 23:10:18.620759+02	nkoleevans@gmail.com
640	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:10:25+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:10:26.108673+02	nkoleevans@gmail.com
636	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:10:14+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 23:10:15.033515+02	nkoleevans@gmail.com
639	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:10:23+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 23:10:24.520066+02	nkoleevans@gmail.com
641	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:11:52+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:11:52.822521+02	nkoleevans@gmail.com
642	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:14:27+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:14:28.031627+02	nkoleevans@gmail.com
643	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:14:57+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:14:58.367618+02	nkoleevans@gmail.com
644	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:15:03+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:15:03.673483+02	nkoleevans@gmail.com
645	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:15:05+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:15:06.090851+02	nkoleevans@gmail.com
646	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:16:28+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:16:29.230741+02	nkoleevans@gmail.com
647	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:16:30+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:16:31.311284+02	nkoleevans@gmail.com
648	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:17:24+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:17:24.57776+02	nkoleevans@gmail.com
649	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:17:39+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:17:39.821353+02	nkoleevans@gmail.com
650	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:17:52+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:17:52.532732+02	nkoleevans@gmail.com
651	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:17:53+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:17:53.532814+02	nkoleevans@gmail.com
652	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:27+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:27.691755+02	nkoleevans@gmail.com
653	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:27+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:28.42925+02	nkoleevans@gmail.com
654	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:38+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:38.776526+02	nkoleevans@gmail.com
655	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:39+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:39.594637+02	nkoleevans@gmail.com
656	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:40+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:41.532499+02	nkoleevans@gmail.com
657	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:41+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:42.423066+02	nkoleevans@gmail.com
658	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:42+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:42.846121+02	nkoleevans@gmail.com
659	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:42+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:43.17659+02	nkoleevans@gmail.com
660	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:44+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:45.310345+02	nkoleevans@gmail.com
661	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:50+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:51.570425+02	nkoleevans@gmail.com
662	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:40:27+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 23:40:27.641812+02	nkoleevans@gmail.com
663	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:40:29+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:40:30.079932+02	nkoleevans@gmail.com
664	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:40:31+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 23:40:32.121855+02	nkoleevans@gmail.com
665	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:40:32+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:40:32.67387+02	nkoleevans@gmail.com
666	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:45:06+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:45:08.325204+02	nkoleevans@gmail.com
667	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:45:08+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:45:08.8789+02	nkoleevans@gmail.com
668	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:45:09+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:45:10.886642+02	nkoleevans@gmail.com
669	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:45:10+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:45:11.869536+02	nkoleevans@gmail.com
670	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:45:16+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:45:17.047287+02	nkoleevans@gmail.com
671	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:47:05+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:47:06.180669+02	nkoleevans@gmail.com
672	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:47:14+02	Session	\N	\N	Start	null	{"exp": 1784845034, "jti": "334a970bf1ae4b3a8a25870143064c4f", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-23 23:47:14.964078+02	nkoleevans@gmail.com
673	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:47:15+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:47:16.662003+02	nkoleevans@gmail.com
674	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:47:16+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:47:17.51685+02	nkoleevans@gmail.com
675	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:48:55+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:48:59.687259+02	nkoleevans@gmail.com
676	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:49:13+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:49:16.431094+02	nkoleevans@gmail.com
677	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:49:30+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:49:31.296131+02	nkoleevans@gmail.com
678	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:52:31+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:52:33.482829+02	nkoleevans@gmail.com
679	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:53:25+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:53:26.060326+02	nkoleevans@gmail.com
680	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:53:30+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:53:31.060101+02	nkoleevans@gmail.com
681	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:53:34+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:53:35.228822+02	nkoleevans@gmail.com
682	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:53:35+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:53:36.293308+02	nkoleevans@gmail.com
683	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:53:43+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:53:44.342381+02	nkoleevans@gmail.com
684	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:56:49+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-23 23:56:49.886179+02	nkoleevans@gmail.com
685	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 00:08:24+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:08:25.735303+02	nkoleevans@gmail.com
686	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 00:11:05+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:11:08.583347+02	nkoleevans@gmail.com
687	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 00:11:20+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:11:23.379743+02	nkoleevans@gmail.com
688	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 00:15:51+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:15:53.948025+02	nkoleevans@gmail.com
689	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:19:55+02	Session	\N	\N	Start	null	{"exp": 1784846995, "jti": "f8698ebe653a45e1810ab85a0713055d", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 00:19:55.972521+02	nkoleevans@gmail.com
690	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:19:57+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 00:19:58.192072+02	nkoleevans@gmail.com
691	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:20:00+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:20:00.665548+02	nkoleevans@gmail.com
692	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:20:31+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:20:34.17527+02	nkoleevans@gmail.com
693	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:23:18+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:23:18.811594+02	nkoleevans@gmail.com
694	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:23:25+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:23:26.107772+02	nkoleevans@gmail.com
695	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:26:14+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:26:14.898328+02	nkoleevans@gmail.com
696	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:26:39+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:26:39.602586+02	nkoleevans@gmail.com
697	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:29:49+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:29:51.204911+02	nkoleevans@gmail.com
698	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:29:52+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:29:53.032606+02	nkoleevans@gmail.com
699	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:29:53+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:29:53.986704+02	nkoleevans@gmail.com
700	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:29:54+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:29:55.446189+02	nkoleevans@gmail.com
701	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:30:41+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:30:41.817817+02	nkoleevans@gmail.com
702	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:31:21+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:31:25.34631+02	nkoleevans@gmail.com
703	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:32:20+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:32:26.064604+02	nkoleevans@gmail.com
704	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:32:22+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:32:28.01318+02	nkoleevans@gmail.com
705	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:32:28+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:32:30.463447+02	nkoleevans@gmail.com
706	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:32:33+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:32:34.0075+02	nkoleevans@gmail.com
707	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:32:47+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:32:49.013927+02	nkoleevans@gmail.com
708	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:33:02+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:33:03.110272+02	nkoleevans@gmail.com
709	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:34:39+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:34:41.100134+02	nkoleevans@gmail.com
710	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:35:02+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:35:04.821282+02	nkoleevans@gmail.com
711	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:35:08+02	Application	\N	\N	View - Allowed	null	null	2026-07-24 00:35:08.612488+02	nkoleevans@gmail.com
712	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:35:10+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:35:10.757591+02	nkoleevans@gmail.com
713	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:36:09+02	Application	\N	\N	View - Allowed	null	null	2026-07-24 00:36:11.458659+02	nkoleevans@gmail.com
714	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:36:30+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:36:30.926471+02	nkoleevans@gmail.com
715	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:36:41+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:36:41.577645+02	nkoleevans@gmail.com
716	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:36:44+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:36:45.057348+02	nkoleevans@gmail.com
717	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:36:55+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:36:55.565076+02	nkoleevans@gmail.com
718	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:38:46+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:38:48.125408+02	nkoleevans@gmail.com
719	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:38:57+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:38:57.761081+02	nkoleevans@gmail.com
720	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:39:59+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:39:59.722624+02	nkoleevans@gmail.com
721	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:40:05+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:40:07.822269+02	nkoleevans@gmail.com
722	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:40:23+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:40:23.859914+02	nkoleevans@gmail.com
723	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:41:11+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:41:12.506248+02	nkoleevans@gmail.com
724	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:41:12+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:41:13.268309+02	nkoleevans@gmail.com
725	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:41:50+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:41:53.29571+02	nkoleevans@gmail.com
726	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:45:22+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:45:24.709337+02	nkoleevans@gmail.com
727	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:48:58+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:49:01.314948+02	nkoleevans@gmail.com
728	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:49:01+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:49:01.759743+02	nkoleevans@gmail.com
729	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:49:34+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:49:35.072495+02	nkoleevans@gmail.com
730	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:49:49+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:49:50.055368+02	nkoleevans@gmail.com
731	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:49:52+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 00:49:52.688818+02	nkoleevans@gmail.com
732	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:49:56+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:49:57.29206+02	nkoleevans@gmail.com
733	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:50:09+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 00:50:13.752739+02	nkoleevans@gmail.com
734	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:50:18+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:50:19.024592+02	nkoleevans@gmail.com
735	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:50:22+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:50:22.607141+02	nkoleevans@gmail.com
736	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:50:23+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:50:24.509571+02	nkoleevans@gmail.com
737	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:50:26+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:50:27.214357+02	nkoleevans@gmail.com
738	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:50:46+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 00:50:46.80183+02	nkoleevans@gmail.com
739	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:51:05+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:51:05.848107+02	nkoleevans@gmail.com
740	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:53:29+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:53:29.663382+02	nkoleevans@gmail.com
741	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:53:43+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 00:53:44.141969+02	nkoleevans@gmail.com
742	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:53:44+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:53:45.21428+02	nkoleevans@gmail.com
743	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:56:42+02	Session	\N	\N	Start	null	{"exp": 1784849202, "jti": "974379f73e784c05a5cf8b1dccd5bd9a", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 00:56:43.009426+02	nkoleevans@gmail.com
744	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:56:45+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 00:56:46.018925+02	nkoleevans@gmail.com
745	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:56:46+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:56:47.438451+02	nkoleevans@gmail.com
746	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:57:02+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:57:05.506959+02	nkoleevans@gmail.com
747	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:58:20+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:58:22.951519+02	nkoleevans@gmail.com
748	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:58:49+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:58:52.070373+02	nkoleevans@gmail.com
749	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:59:13+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:59:16.229471+02	nkoleevans@gmail.com
750	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:59:35+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:59:35.86173+02	nkoleevans@gmail.com
751	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:59:36+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:59:37.30454+02	nkoleevans@gmail.com
752	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:00:07+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:00:08.249914+02	nkoleevans@gmail.com
753	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:00:10+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 01:00:10.614812+02	nkoleevans@gmail.com
754	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:00:58+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 01:00:58.609406+02	nkoleevans@gmail.com
755	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:00:59+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:00:59.827285+02	nkoleevans@gmail.com
756	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:00:59+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:00.365728+02	nkoleevans@gmail.com
757	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:00+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:01.85116+02	nkoleevans@gmail.com
758	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:02+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 01:01:02.802063+02	nkoleevans@gmail.com
759	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:06+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:07.352491+02	nkoleevans@gmail.com
760	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:07+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:07.946364+02	nkoleevans@gmail.com
761	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:08+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:09.136378+02	nkoleevans@gmail.com
762	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:09+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:11.854543+02	nkoleevans@gmail.com
764	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:34+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:34.884062+02	nkoleevans@gmail.com
765	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:36+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:01:37.371882+02	nkoleevans@gmail.com
763	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:13+02	Role List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:14.454759+02	nkoleevans@gmail.com
766	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:06:36+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:06:37.410273+02	nkoleevans@gmail.com
767	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:06:44+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:06:45.03256+02	nkoleevans@gmail.com
768	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:06:45+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:06:46.179852+02	nkoleevans@gmail.com
769	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:07:35+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:07:37.256329+02	nkoleevans@gmail.com
770	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:08:19+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 01:08:20.342131+02	nkoleevans@gmail.com
771	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:08:23+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:08:24.346216+02	nkoleevans@gmail.com
772	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:08:38+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 01:08:39.497718+02	nkoleevans@gmail.com
773	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:08:40+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:08:40.605576+02	nkoleevans@gmail.com
774	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:09:03+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 01:09:06.363439+02	nkoleevans@gmail.com
775	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:09:04+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:09:06.490282+02	nkoleevans@gmail.com
776	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:09:09+02	Application	\N	\N	View - Allowed	null	null	2026-07-24 01:09:09.748008+02	nkoleevans@gmail.com
777	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:09:16+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:09:16.81887+02	nkoleevans@gmail.com
778	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:09:18+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:09:18.642829+02	nkoleevans@gmail.com
779	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:10:41+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:10:41.63214+02	nkoleevans@gmail.com
780	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:10:45+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:10:45.915795+02	nkoleevans@gmail.com
781	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:10:51+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:10:51.533842+02	nkoleevans@gmail.com
782	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:10:51+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:10:52.319933+02	nkoleevans@gmail.com
783	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:10:52+02	Application	\N	\N	View - Allowed	null	null	2026-07-24 01:10:53.343139+02	nkoleevans@gmail.com
784	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:11:14+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:11:15.11956+02	nkoleevans@gmail.com
785	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:11:29+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:11:30.539182+02	nkoleevans@gmail.com
786	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:11:31+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:11:32.3098+02	nkoleevans@gmail.com
787	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:11:55+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:11:55.830608+02	nkoleevans@gmail.com
788	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:11:57+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:11:58.068387+02	nkoleevans@gmail.com
789	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:12:04+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:12:05.208254+02	nkoleevans@gmail.com
790	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:12:08+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 01:12:09.521107+02	nkoleevans@gmail.com
791	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:12:14+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:12:15.088484+02	nkoleevans@gmail.com
792	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:12:16+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 01:12:16.614308+02	nkoleevans@gmail.com
793	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:12:19+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 01:12:19.733218+02	nkoleevans@gmail.com
794	1	nkoleevans@gmail.com	12d5371a62d542b4a798af4648958694	2026-07-23 01:53:02+02	Session	\N	\N	Start	null	{"exp": 1784852582, "jti": "12d5371a62d542b4a798af4648958694", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 01:53:03.052619+02	nkoleevans@gmail.com
795	1	nkoleevans@gmail.com	12d5371a62d542b4a798af4648958694	2026-07-23 01:53:05+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:53:05.547596+02	nkoleevans@gmail.com
796	1	nkoleevans@gmail.com	12d5371a62d542b4a798af4648958694	2026-07-23 01:53:08+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:53:09.270624+02	nkoleevans@gmail.com
797	1	nkoleevans@gmail.com	7323260c182741948bebfbbd0f187e96	2026-07-23 01:53:38+02	Session	\N	\N	Start	null	{"exp": 1784852618, "jti": "7323260c182741948bebfbbd0f187e96", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 01:53:39.07226+02	nkoleevans@gmail.com
798	1	nkoleevans@gmail.com	7323260c182741948bebfbbd0f187e96	2026-07-23 01:53:42+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:53:43.506917+02	nkoleevans@gmail.com
799	1	nkoleevans@gmail.com	7323260c182741948bebfbbd0f187e96	2026-07-23 01:54:41+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:54:41.789197+02	nkoleevans@gmail.com
800	1	nkoleevans@gmail.com	7323260c182741948bebfbbd0f187e96	2026-07-23 01:58:11+02	Role List	\N	\N	View - Allowed	null	null	2026-07-24 01:58:11.77694+02	nkoleevans@gmail.com
801	1	nkoleevans@gmail.com	7323260c182741948bebfbbd0f187e96	2026-07-24 02:04:40+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 02:04:41.535223+02	nkoleevans@gmail.com
802	1	nkoleevans@gmail.com	7323260c182741948bebfbbd0f187e96	2026-07-24 02:04:44+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 02:04:45.186213+02	nkoleevans@gmail.com
803	0	nkoleevans@hotmail.com	public	2026-07-24 02:04:59+02	Authentication	\N	\N	Unauthorised	null	null	2026-07-24 02:05:00.399155+02	nkoleevans@hotmail.com
805	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:05:45+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 02:05:46.216808+02	nkoleevans@hotmail.com
804	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:05:43+02	Session	\N	\N	Start	null	{"exp": 1784853343, "jti": "f8a4355ac56b42af8950fd7d5b84165d", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 02:05:44.202375+02	nkoleevans@hotmail.com
807	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:05:51+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 02:05:51.775221+02	nkoleevans@hotmail.com
806	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:05:46+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 02:05:47.473978+02	nkoleevans@hotmail.com
808	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:06:00+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 02:06:01.071165+02	nkoleevans@hotmail.com
809	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:06:12+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 02:06:13.33196+02	nkoleevans@hotmail.com
810	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:06:45+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 02:06:45.603676+02	nkoleevans@hotmail.com
811	3	jane@gmail.com	38eb77c6f8b3429aa6a911d01b8376ac	2026-07-24 02:07:02+02	Session	\N	\N	Start	null	{"exp": 1784853422, "jti": "38eb77c6f8b3429aa6a911d01b8376ac", "sub": "jane@gmail.com", "name": "Jane Banda", "role": 9, "mobile": "0977123456", "userid": 3}	2026-07-24 02:07:03.227438+02	jane@gmail.com
812	2	nkoleevans@hotmail.com	c3bfea11f99f4a798a324ea1fd0ba02d	2026-07-24 02:07:50+02	Session	\N	\N	Start	null	{"exp": 1784853470, "jti": "c3bfea11f99f4a798a324ea1fd0ba02d", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 02:07:51.485761+02	nkoleevans@hotmail.com
813	2	nkoleevans@hotmail.com	c3bfea11f99f4a798a324ea1fd0ba02d	2026-07-24 02:07:53+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 02:07:54.409148+02	nkoleevans@hotmail.com
814	2	nkoleevans@hotmail.com	1853506344c744739a34067da13c8dd7	2026-07-24 02:48:00+02	Session	\N	\N	Start	null	{"exp": 1784855880, "jti": "1853506344c744739a34067da13c8dd7", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 02:48:01.011418+02	nkoleevans@hotmail.com
815	2	nkoleevans@hotmail.com	9413316212fd479eb1e6ab026780b660	2026-07-24 02:48:34+02	Session	\N	\N	Start	null	{"exp": 1784855914, "jti": "9413316212fd479eb1e6ab026780b660", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 02:48:35.416541+02	nkoleevans@hotmail.com
816	2	nkoleevans@hotmail.com	9413316212fd479eb1e6ab026780b660	2026-07-24 02:48:38+02	Method List	\N	\N	View - Allowed	null	null	2026-07-24 02:48:38.848633+02	nkoleevans@hotmail.com
817	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:15:46+02	Session	\N	\N	Start	null	{"exp": 1784857546, "jti": "f23646357e0f41b2b273709c4aaebc62", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 03:15:46.923132+02	nkoleevans@hotmail.com
818	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:15:51+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 03:15:51.60923+02	nkoleevans@hotmail.com
819	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:15:59+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 03:16:00.21306+02	nkoleevans@hotmail.com
820	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:16:01+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 03:16:02.514563+02	nkoleevans@hotmail.com
821	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:16:41+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 03:16:42.001245+02	nkoleevans@hotmail.com
822	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:16:46+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 03:16:46.933057+02	nkoleevans@hotmail.com
823	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:17:18+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 03:17:18.869596+02	nkoleevans@hotmail.com
824	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:17:27+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 03:17:27.656846+02	nkoleevans@hotmail.com
825	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:17:27+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 03:17:28.262472+02	nkoleevans@hotmail.com
826	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:17:28+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 03:17:29.315856+02	nkoleevans@hotmail.com
827	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:17:30+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 03:17:31.052572+02	nkoleevans@hotmail.com
828	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:29:13+02	Session	\N	\N	Start	null	{"exp": 1784876353, "jti": "5f9ad37cc8a54b7e8075de735a106b80", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 08:29:14.050256+02	nkoleevans@hotmail.com
829	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:29:16+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:29:16.807494+02	nkoleevans@hotmail.com
830	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:29:37+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:29:38.193249+02	nkoleevans@hotmail.com
831	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:30:42+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:30:43.497636+02	nkoleevans@hotmail.com
832	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:30:47+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 08:30:48.033146+02	nkoleevans@hotmail.com
833	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:32:50+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:32:51.451362+02	nkoleevans@hotmail.com
834	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:32:59+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-24 08:33:00.470672+02	nkoleevans@hotmail.com
835	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:33:01+02	Method List	\N	\N	View - Allowed	null	null	2026-07-24 08:33:01.766813+02	nkoleevans@hotmail.com
836	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:33:09+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 08:33:10.407003+02	nkoleevans@hotmail.com
837	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:33:11+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 08:33:12.223347+02	nkoleevans@hotmail.com
838	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:33:12+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 08:33:12.968817+02	nkoleevans@hotmail.com
839	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:33:16+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 08:33:17.182232+02	nkoleevans@hotmail.com
840	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:34:39+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:34:40.027901+02	nkoleevans@hotmail.com
841	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:34:41+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 08:34:41.664643+02	nkoleevans@hotmail.com
842	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:35:45+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 08:35:46.245464+02	nkoleevans@hotmail.com
843	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:36:58+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 08:36:58.876299+02	nkoleevans@hotmail.com
846	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:37:46+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 08:37:46.894921+02	nkoleevans@hotmail.com
847	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:38:16+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:38:17.222595+02	nkoleevans@hotmail.com
848	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:38:20+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 08:38:20.714874+02	nkoleevans@hotmail.com
849	4	markdoe@gmail.com	a155d0f74a364953b37c9e7b8a5b8c92	2026-07-24 08:38:30+02	Session	\N	\N	Start	null	{"exp": 1784876910, "jti": "a155d0f74a364953b37c9e7b8a5b8c92", "sub": "markdoe@gmail.com", "name": "Mark Doe", "role": 9, "mobile": "0977123457", "userid": 4}	2026-07-24 08:38:31.103196+02	markdoe@gmail.com
854	2	nkoleevans@hotmail.com	0f3432a94473449c80eb5b8ff84b46fb	2026-07-24 08:43:12+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 08:43:12.853404+02	nkoleevans@hotmail.com
855	2	nkoleevans@hotmail.com	0f3432a94473449c80eb5b8ff84b46fb	2026-07-24 08:43:38+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 08:43:39.151958+02	nkoleevans@hotmail.com
863	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:48:24+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 08:48:24.701489+02	nkoleevans@gmail.com
844	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:37:38+02	Method List	\N	\N	View - Allowed	null	null	2026-07-24 08:37:38.66714+02	nkoleevans@hotmail.com
845	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:37:42+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:37:42.914641+02	nkoleevans@hotmail.com
850	4	markdoe@gmail.com	a155d0f74a364953b37c9e7b8a5b8c92	2026-07-24 08:42:19+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 08:42:19.724098+02	markdoe@gmail.com
857	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:43:58+02	Session	\N	\N	Start	null	{"exp": 1784877238, "jti": "baeb6d66a21d44e39e7150019246ebe6", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 08:43:58.818799+02	nkoleevans@gmail.com
858	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:44:03+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 08:44:04.466842+02	nkoleevans@gmail.com
861	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:44:10+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 08:44:11.231488+02	nkoleevans@gmail.com
851	4	markdoe@gmail.com	a155d0f74a364953b37c9e7b8a5b8c92	2026-07-24 08:42:20+02	PT Cycle List	\N	\N	View - Permission Denied	null	null	2026-07-24 08:42:20.847079+02	markdoe@gmail.com
852	2	nkoleevans@hotmail.com	0f3432a94473449c80eb5b8ff84b46fb	2026-07-24 08:43:00+02	Session	\N	\N	Start	null	{"exp": 1784877180, "jti": "0f3432a94473449c80eb5b8ff84b46fb", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 08:43:01.165544+02	nkoleevans@hotmail.com
853	2	nkoleevans@hotmail.com	0f3432a94473449c80eb5b8ff84b46fb	2026-07-24 08:43:02+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 08:43:03.186872+02	nkoleevans@hotmail.com
856	2	nkoleevans@hotmail.com	0f3432a94473449c80eb5b8ff84b46fb	2026-07-24 08:43:42+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 08:43:43.326398+02	nkoleevans@hotmail.com
859	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:44:05+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 08:44:05.572296+02	nkoleevans@gmail.com
860	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:44:09+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 08:44:09.878378+02	nkoleevans@gmail.com
862	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:48:21+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:48:21.537613+02	nkoleevans@gmail.com
864	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:50:03+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 08:50:03.983707+02	nkoleevans@gmail.com
865	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:50:05+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 08:50:06.077477+02	nkoleevans@gmail.com
866	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:53:34+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 08:53:34.644978+02	nkoleevans@gmail.com
867	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:02:48+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 09:02:48.874517+02	nkoleevans@gmail.com
868	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:05:13+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-07-24 09:05:17.677622+02	nkoleevans@gmail.com
869	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:05:43+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 09:05:43.855397+02	nkoleevans@gmail.com
870	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:05:45+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 09:05:45.689436+02	nkoleevans@gmail.com
871	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:05:48+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 09:05:49.411888+02	nkoleevans@gmail.com
872	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:05:58+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 09:05:58.690838+02	nkoleevans@gmail.com
873	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:06:01+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 09:06:01.706945+02	nkoleevans@gmail.com
874	1	nkoleevans@gmail.com	7469a1cf7aed4611a3eb244ab58ef53f	2026-07-24 10:11:31+02	Session	\N	\N	Start	null	{"exp": 1784882491, "jti": "7469a1cf7aed4611a3eb244ab58ef53f", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 10:11:32.931221+02	nkoleevans@gmail.com
875	1	nkoleevans@gmail.com	7469a1cf7aed4611a3eb244ab58ef53f	2026-07-24 10:11:38+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 10:11:38.95129+02	nkoleevans@gmail.com
876	1	nkoleevans@gmail.com	7469a1cf7aed4611a3eb244ab58ef53f	2026-07-24 10:22:30+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 10:22:32.083761+02	nkoleevans@gmail.com
877	1	nkoleevans@gmail.com	7469a1cf7aed4611a3eb244ab58ef53f	2026-07-24 10:25:14+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 10:25:15.073018+02	nkoleevans@gmail.com
878	1	nkoleevans@gmail.com	7469a1cf7aed4611a3eb244ab58ef53f	2026-07-24 10:40:29+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 10:40:31.621797+02	nkoleevans@gmail.com
879	1	nkoleevans@gmail.com	9895670d9f604e3b95b11d8837392463	2026-07-24 10:43:15+02	Session	\N	\N	Start	null	{"exp": 1784884395, "jti": "9895670d9f604e3b95b11d8837392463", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 10:43:16.460453+02	nkoleevans@gmail.com
880	1	nkoleevans@gmail.com	9895670d9f604e3b95b11d8837392463	2026-07-24 10:43:22+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 10:43:22.727101+02	nkoleevans@gmail.com
881	1	nkoleevans@gmail.com	9895670d9f604e3b95b11d8837392463	2026-07-24 10:43:24+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 10:43:24.78025+02	nkoleevans@gmail.com
882	1	nkoleevans@gmail.com	9895670d9f604e3b95b11d8837392463	2026-07-24 10:43:34+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 10:43:36.150438+02	nkoleevans@gmail.com
883	1	nkoleevans@gmail.com	9ac6ed0d5f7a495c8d065b8074e3c146	2026-07-24 10:44:18+02	Session	\N	\N	Start	null	{"exp": 1784884458, "jti": "9ac6ed0d5f7a495c8d065b8074e3c146", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 10:44:18.744397+02	nkoleevans@gmail.com
884	1	nkoleevans@gmail.com	9ac6ed0d5f7a495c8d065b8074e3c146	2026-07-24 10:44:31+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 10:44:31.635593+02	nkoleevans@gmail.com
885	1	nkoleevans@gmail.com	1e3d2507aa934b1dbd6772219eff11ec	2026-07-24 10:47:20+02	Session	\N	\N	Start	null	{"exp": 1784884640, "jti": "1e3d2507aa934b1dbd6772219eff11ec", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 10:47:21.210721+02	nkoleevans@gmail.com
886	1	nkoleevans@gmail.com	1e3d2507aa934b1dbd6772219eff11ec	2026-07-24 10:47:26+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 10:47:27.193263+02	nkoleevans@gmail.com
887	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:47:37+02	Session	\N	\N	Start	null	{"exp": 1784884657, "jti": "4df8825633ab48a3aab7a156d8f2c6ca", "sub": "markdoe@gmail.com", "name": "Mark Doe", "role": 9, "mobile": "0977123457", "userid": 4}	2026-07-24 10:47:38.201445+02	markdoe@gmail.com
888	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:47:40+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 10:47:41.54302+02	markdoe@gmail.com
889	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:51:43+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 10:51:43.680018+02	markdoe@gmail.com
890	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:51:44+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 10:51:45.117093+02	markdoe@gmail.com
891	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:51:52+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 10:51:52.884104+02	markdoe@gmail.com
892	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:52:44+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 10:52:45.189059+02	markdoe@gmail.com
893	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:53:48+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 10:53:48.835469+02	markdoe@gmail.com
894	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:53:51+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 10:53:52.044032+02	markdoe@gmail.com
895	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:01:10+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:01:19.086232+02	markdoe@gmail.com
896	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:06:17+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 11:06:20.183927+02	markdoe@gmail.com
897	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:06:23+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:06:23.60222+02	markdoe@gmail.com
898	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:06:27+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:06:28.132466+02	markdoe@gmail.com
899	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:06:32+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:06:33.442539+02	markdoe@gmail.com
900	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:06:36+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:06:37.336977+02	markdoe@gmail.com
901	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:08:17+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:08:17.603534+02	markdoe@gmail.com
902	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:08:20+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:08:20.771474+02	markdoe@gmail.com
903	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:08:24+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:08:25.440711+02	markdoe@gmail.com
904	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:08:25+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:08:26.461971+02	markdoe@gmail.com
905	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:08:35+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 11:08:35.840432+02	markdoe@gmail.com
906	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:08:38+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:08:39.133242+02	markdoe@gmail.com
907	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:09:16+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:09:17.223234+02	markdoe@gmail.com
908	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:09:23+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:09:29.309489+02	markdoe@gmail.com
909	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:09:33+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:09:34.231246+02	markdoe@gmail.com
910	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:09:38+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:09:38.713915+02	markdoe@gmail.com
911	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:10:00+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:10:01.412108+02	markdoe@gmail.com
912	1	nkoleevans@gmail.com	7d41b2afeeab4772a6305123844c830f	2026-07-24 11:10:08+02	Session	\N	\N	Start	null	{"exp": 1784886008, "jti": "7d41b2afeeab4772a6305123844c830f", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 11:10:09.489333+02	nkoleevans@gmail.com
913	1	nkoleevans@gmail.com	7d41b2afeeab4772a6305123844c830f	2026-07-24 11:10:16+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 11:10:16.817942+02	nkoleevans@gmail.com
914	1	nkoleevans@gmail.com	7d41b2afeeab4772a6305123844c830f	2026-07-24 11:10:17+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 11:10:18.194979+02	nkoleevans@gmail.com
915	1	nkoleevans@gmail.com	7d41b2afeeab4772a6305123844c830f	2026-07-24 11:10:21+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 11:10:21.90826+02	nkoleevans@gmail.com
916	4	markdoe@gmail.com	095518c4379e44eca293f32879ee7b33	2026-07-24 11:10:28+02	Session	\N	\N	Start	null	{"exp": 1784886028, "jti": "095518c4379e44eca293f32879ee7b33", "sub": "markdoe@gmail.com", "name": "Mark Doe", "role": 9, "mobile": "0977123457", "userid": 4}	2026-07-24 11:10:29.231263+02	markdoe@gmail.com
917	4	markdoe@gmail.com	095518c4379e44eca293f32879ee7b33	2026-07-24 11:10:29+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:10:30.302812+02	markdoe@gmail.com
918	4	markdoe@gmail.com	095518c4379e44eca293f32879ee7b33	2026-07-24 11:10:31+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:10:32.377736+02	markdoe@gmail.com
919	1	nkoleevans@gmail.com	f25f6c37d2c8448a837921d0c2302d45	2026-07-24 11:17:44+02	Session	\N	\N	Start	null	{"exp": 1784886463, "jti": "f25f6c37d2c8448a837921d0c2302d45", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 11:17:44.57731+02	nkoleevans@gmail.com
920	1	nkoleevans@gmail.com	f25f6c37d2c8448a837921d0c2302d45	2026-07-24 11:17:46+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 11:17:47.437409+02	nkoleevans@gmail.com
921	1	nkoleevans@gmail.com	068033c84a64491797f8d6ce5dcac130	2026-07-24 11:20:47+02	Session	\N	\N	Start	null	{"exp": 1784886647, "jti": "068033c84a64491797f8d6ce5dcac130", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 11:20:47.853512+02	nkoleevans@gmail.com
922	1	nkoleevans@gmail.com	068033c84a64491797f8d6ce5dcac130	2026-07-24 11:20:50+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 11:20:50.65659+02	nkoleevans@gmail.com
923	0	alanphiri@gmail.com	public	2026-07-24 11:21:10+02	Authentication	\N	\N	Unauthorised	null	null	2026-07-24 11:21:10.518242+02	alanphiri@gmail.com
924	2	nkoleevans@hotmail.com	821da8e4eb64471c9dd605adf7c5ce8a	2026-07-24 11:21:18+02	Session	\N	\N	Start	null	{"exp": 1784886678, "jti": "821da8e4eb64471c9dd605adf7c5ce8a", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 11:21:19.166315+02	nkoleevans@hotmail.com
925	2	nkoleevans@hotmail.com	821da8e4eb64471c9dd605adf7c5ce8a	2026-07-24 11:21:20+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 11:21:21.30511+02	nkoleevans@hotmail.com
926	2	nkoleevans@hotmail.com	821da8e4eb64471c9dd605adf7c5ce8a	2026-07-24 11:21:22+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 11:21:22.6128+02	nkoleevans@hotmail.com
927	2	nkoleevans@hotmail.com	821da8e4eb64471c9dd605adf7c5ce8a	2026-07-24 11:21:33+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 11:21:34.465166+02	nkoleevans@hotmail.com
928	2	nkoleevans@hotmail.com	821da8e4eb64471c9dd605adf7c5ce8a	2026-07-24 11:21:37+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 11:21:37.671972+02	nkoleevans@hotmail.com
929	5	alanphiri@gmail.com	eec6218fda1549c4a3c21ab1e987a1bf	2026-07-24 11:21:58+02	Session	\N	\N	Start	null	{"exp": 1784886718, "jti": "eec6218fda1549c4a3c21ab1e987a1bf", "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "097765435363", "userid": 5}	2026-07-24 11:21:59.268031+02	alanphiri@gmail.com
931	2	nkoleevans@hotmail.com	c77f51f4fe404966a3676f3cbd0b3878	2026-07-24 11:22:28+02	Session	\N	\N	Start	null	{"exp": 1784886748, "jti": "c77f51f4fe404966a3676f3cbd0b3878", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 11:22:29.307636+02	nkoleevans@hotmail.com
933	2	nkoleevans@hotmail.com	c77f51f4fe404966a3676f3cbd0b3878	2026-07-24 11:22:33+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-24 11:22:34.526279+02	nkoleevans@hotmail.com
935	2	nkoleevans@hotmail.com	c77f51f4fe404966a3676f3cbd0b3878	2026-07-24 11:22:38+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 11:22:39.256308+02	nkoleevans@hotmail.com
936	2	nkoleevans@hotmail.com	c77f51f4fe404966a3676f3cbd0b3878	2026-07-24 11:22:44+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 11:22:45.088816+02	nkoleevans@hotmail.com
938	5	alanphiri@gmail.com	087f4c8ac11647a2a0141c839746e206	2026-07-24 11:23:14+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:23:14.834797+02	alanphiri@gmail.com
940	2	nkoleevans@hotmail.com	2a42b0ef76b74b1d95e0f6ec7680b679	2026-07-24 11:23:30+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 11:23:31.096397+02	nkoleevans@hotmail.com
941	2	nkoleevans@hotmail.com	2a42b0ef76b74b1d95e0f6ec7680b679	2026-07-24 11:23:31+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 11:23:32.12447+02	nkoleevans@hotmail.com
942	2	nkoleevans@hotmail.com	2a42b0ef76b74b1d95e0f6ec7680b679	2026-07-24 11:25:45+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 11:25:46.52729+02	nkoleevans@hotmail.com
944	5	alanphiri@gmail.com	1863d1440abc47799eff43d441a313e6	2026-07-24 11:26:07+02	Session	\N	\N	Start	null	{"exp": 1784886967, "jti": "1863d1440abc47799eff43d441a313e6", "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "097765435363", "userid": 5}	2026-07-24 11:26:08.016666+02	alanphiri@gmail.com
949	5	alanphiri@gmail.com	384766dd80fe41e38c0744ca50ae106f	2026-07-24 11:30:14+02	Session	\N	\N	Start	null	{"exp": 1784887214, "jti": "384766dd80fe41e38c0744ca50ae106f", "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "097765435363", "userid": 5}	2026-07-24 11:30:14.715939+02	alanphiri@gmail.com
951	2	nkoleevans@hotmail.com	d88893ca6faf4c33a1f8c0bd2e56dc45	2026-07-24 11:31:37+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-24 11:31:40.262938+02	nkoleevans@hotmail.com
952	2	nkoleevans@hotmail.com	46d8b8107fa2404eb0bd2e57ae93129f	2026-07-27 09:38:11+02	Session	\N	\N	Start	null	{"exp": 1785139691, "jti": "46d8b8107fa2404eb0bd2e57ae93129f", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-27 09:38:12.211839+02	nkoleevans@hotmail.com
930	5	alanphiri@gmail.com	eec6218fda1549c4a3c21ab1e987a1bf	2026-07-24 11:22:08+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:22:08.793502+02	alanphiri@gmail.com
932	2	nkoleevans@hotmail.com	c77f51f4fe404966a3676f3cbd0b3878	2026-07-24 11:22:32+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-24 11:22:33.310074+02	nkoleevans@hotmail.com
934	2	nkoleevans@hotmail.com	c77f51f4fe404966a3676f3cbd0b3878	2026-07-24 11:22:34+02	Service List	\N	\N	View - Allowed	null	null	2026-07-24 11:22:35.252739+02	nkoleevans@hotmail.com
937	5	alanphiri@gmail.com	087f4c8ac11647a2a0141c839746e206	2026-07-24 11:23:12+02	Session	\N	\N	Start	null	{"exp": 1784886792, "jti": "087f4c8ac11647a2a0141c839746e206", "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "097765435363", "userid": 5}	2026-07-24 11:23:13.295628+02	alanphiri@gmail.com
939	2	nkoleevans@hotmail.com	2a42b0ef76b74b1d95e0f6ec7680b679	2026-07-24 11:23:28+02	Session	\N	\N	Start	null	{"exp": 1784886808, "jti": "2a42b0ef76b74b1d95e0f6ec7680b679", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 11:23:28.867575+02	nkoleevans@hotmail.com
943	2	nkoleevans@hotmail.com	2a42b0ef76b74b1d95e0f6ec7680b679	2026-07-24 11:25:56+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 11:25:57.102295+02	nkoleevans@hotmail.com
945	5	alanphiri@gmail.com	1863d1440abc47799eff43d441a313e6	2026-07-24 11:26:11+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:26:11.690851+02	alanphiri@gmail.com
946	5	alanphiri@gmail.com	1863d1440abc47799eff43d441a313e6	2026-07-24 11:26:27+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:26:27.761745+02	alanphiri@gmail.com
947	5	alanphiri@gmail.com	1863d1440abc47799eff43d441a313e6	2026-07-24 11:29:40+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:29:40.530005+02	alanphiri@gmail.com
948	5	alanphiri@gmail.com	1863d1440abc47799eff43d441a313e6	2026-07-24 11:29:42+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:29:42.808564+02	alanphiri@gmail.com
950	2	nkoleevans@hotmail.com	d88893ca6faf4c33a1f8c0bd2e56dc45	2026-07-24 11:30:44+02	Session	\N	\N	Start	null	{"exp": 1784887244, "jti": "d88893ca6faf4c33a1f8c0bd2e56dc45", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 11:30:44.988528+02	nkoleevans@hotmail.com
953	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:24:52+02	Session	\N	\N	Start	null	{"exp": 1785153292, "jti": "4350696c25c44db986e17f6b76f65657", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-27 13:24:53.416071+02	nkoleevans@hotmail.com
954	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:24:57+02	Meter List	\N	\N	View - Allowed	null	null	2026-07-27 13:24:58.238543+02	nkoleevans@hotmail.com
955	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:25:36+02	Application List	\N	\N	View - Allowed	null	null	2026-07-27 13:25:36.756625+02	nkoleevans@hotmail.com
956	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:25:38+02	Meter List	\N	\N	View - Allowed	null	null	2026-07-27 13:25:38.799933+02	nkoleevans@hotmail.com
957	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:26:31+02	Application List	\N	\N	View - Allowed	null	null	2026-07-27 13:26:32.015665+02	nkoleevans@hotmail.com
958	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:26:32+02	Meter List	\N	\N	View - Allowed	null	null	2026-07-27 13:26:33.422082+02	nkoleevans@hotmail.com
959	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:28:31+02	Meter List	\N	\N	View - Allowed	null	null	2026-07-27 13:28:32.449057+02	nkoleevans@hotmail.com
960	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:28:39+02	Meter	\N	\N	View - Allowed	null	null	2026-07-27 13:28:39.653851+02	nkoleevans@hotmail.com
961	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:29:27+02	Meter List	\N	\N	View - Allowed	null	null	2026-07-27 13:29:28.007518+02	nkoleevans@hotmail.com
962	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:04+02	Session	\N	\N	Start	null	{"exp": 1789129984, "jti": "fa5f961adc1046aea5b5911620014dea", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-11 14:03:05.324578+02	nkoleevans@gmail.com
963	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:07+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:07.989442+02	nkoleevans@gmail.com
964	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:08+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:09.107564+02	nkoleevans@gmail.com
965	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:09+02	Method List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:10.573639+02	nkoleevans@gmail.com
966	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:10+02	Service List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:10.831163+02	nkoleevans@gmail.com
967	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:11+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:11.629338+02	nkoleevans@gmail.com
968	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:37+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:38.332224+02	nkoleevans@gmail.com
969	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:38+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:39.229755+02	nkoleevans@gmail.com
970	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:39+02	Service List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:39.902568+02	nkoleevans@gmail.com
971	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:39+02	Method List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:40.500278+02	nkoleevans@gmail.com
972	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:40+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:40.927427+02	nkoleevans@gmail.com
973	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:41+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:42.18566+02	nkoleevans@gmail.com
974	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:43+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:43.607123+02	nkoleevans@gmail.com
975	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:31:52+02	Session	\N	\N	Start	null	{"exp": 1789401712, "jti": "fb9991aecac44c62b349b97b2f81a4b5", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-14 17:31:53.73807+02	nkoleevans@gmail.com
976	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:31:56+02	Province List	\N	\N	View - Allowed	null	null	2026-09-14 17:31:57.398778+02	nkoleevans@gmail.com
977	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:31:57+02	District List	\N	\N	View - Allowed	null	null	2026-09-14 17:31:57.554556+02	nkoleevans@gmail.com
978	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:31:58+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-14 17:32:00.614857+02	nkoleevans@gmail.com
979	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:32:40+02	Province List	\N	\N	View - Allowed	null	null	2026-09-14 17:32:41.746106+02	nkoleevans@gmail.com
981	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:34:59+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 17:35:00.000358+02	nkoleevans@gmail.com
983	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:36:11+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 17:36:11.570256+02	nkoleevans@gmail.com
985	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:36:47+02	Method List	\N	\N	View - Allowed	null	null	2026-09-14 17:36:48.227925+02	nkoleevans@gmail.com
988	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:37:07+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-14 17:37:07.726388+02	nkoleevans@gmail.com
990	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:37:50+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-14 17:37:50.697932+02	nkoleevans@gmail.com
991	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:37:51+02	Review Method Sample	\N	\N	View - Allowed	null	null	2026-09-14 17:37:51.876884+02	nkoleevans@gmail.com
994	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:46:41+02	Session	\N	\N	Start	null	{"exp": 1789402601, "jti": "14e41380068344c6b4a3bc3b2f3f8b8c", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-14 17:46:43.268081+02	nkoleevans@gmail.com
996	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:46:49+02	Application List	\N	\N	View - Allowed	null	null	2026-09-14 17:46:50.410635+02	nkoleevans@gmail.com
997	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:48:31+02	Role List	\N	\N	View - Allowed	null	null	2026-09-14 17:48:32.084832+02	nkoleevans@gmail.com
999	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:49:43+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-14 17:49:44.447969+02	nkoleevans@gmail.com
980	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:32:45+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-14 17:32:46.371072+02	nkoleevans@gmail.com
982	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:35:38+02	Service List	\N	\N	View - Allowed	null	null	2026-09-14 17:35:38.560412+02	nkoleevans@gmail.com
984	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:36:21+02	Service List	\N	\N	View - Allowed	null	null	2026-09-14 17:36:21.936023+02	nkoleevans@gmail.com
986	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:36:56+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-14 17:36:56.942189+02	nkoleevans@gmail.com
987	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:36:58+02	Review Method Sample	\N	\N	View - Allowed	null	null	2026-09-14 17:36:59.430008+02	nkoleevans@gmail.com
989	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:37:11+02	Method List	\N	\N	View - Allowed	null	null	2026-09-14 17:37:11.698947+02	nkoleevans@gmail.com
992	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:38:20+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-14 17:38:21.244449+02	nkoleevans@gmail.com
993	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:38:22+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-14 17:38:23.477516+02	nkoleevans@gmail.com
995	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:46:45+02	Users	\N	\N	View - Allowed	null	null	2026-09-14 17:46:45.87943+02	nkoleevans@gmail.com
998	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:48:33+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-09-14 17:48:35.475494+02	nkoleevans@gmail.com
1000	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:50:15+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-14 17:50:15.679215+02	nkoleevans@gmail.com
1001	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:50:38+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-14 17:50:38.822302+02	nkoleevans@gmail.com
\.


--
-- Data for Name: districts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.districts (id, name, description, province_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Chililabombwe	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.648912+02	\N	\N	\N
2	Chingola	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.660966+02	\N	\N	\N
3	Kalulushi	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.674004+02	\N	\N	\N
4	Kitwe	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.678524+02	\N	\N	\N
5	Luanshya	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.681533+02	\N	\N	\N
6	Lufwanyama	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.685536+02	\N	\N	\N
7	Masaiti	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.689533+02	\N	\N	\N
8	Mpongwe	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.692532+02	\N	\N	\N
9	Mufulira	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.699055+02	\N	\N	\N
10	Ndola	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.701572+02	\N	\N	\N
11	Chadiza	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.707122+02	\N	\N	\N
12	Chama	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.709129+02	\N	\N	\N
13	Chasefu	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.712659+02	\N	\N	\N
14	Chipangali	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.715658+02	\N	\N	\N
15	Chipata	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.720659+02	\N	\N	\N
16	Kasenengwa	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.724663+02	\N	\N	\N
17	Katete	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.728176+02	\N	\N	\N
18	Lumezi	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.735212+02	\N	\N	\N
19	Lundazi	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.740261+02	\N	\N	\N
20	Mambwe	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.745263+02	\N	\N	\N
21	Nyimba	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.750265+02	\N	\N	\N
22	Petauke	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.753262+02	\N	\N	\N
23	Sinda	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.756785+02	\N	\N	\N
24	Vubwi	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.760823+02	\N	\N	\N
25	Itezhi-Tezhi	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.767353+02	\N	\N	\N
26	Kabwe	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.771858+02	\N	\N	\N
27	Kapiri Mposhi	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.774862+02	\N	\N	\N
28	Luano	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.779903+02	\N	\N	\N
29	Mkushi	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.781899+02	\N	\N	\N
30	Mumbwa	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.784902+02	\N	\N	\N
31	Ngabwe	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.788898+02	\N	\N	\N
32	Serenje	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.796921+02	\N	\N	\N
33	Shibuyunji	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.801921+02	\N	\N	\N
34	Chibombo	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.803427+02	\N	\N	\N
35	Chilanga	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.806439+02	\N	\N	\N
36	Chirundu	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.807435+02	\N	\N	\N
37	Kafue	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.80995+02	\N	\N	\N
38	Luangwa	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.812464+02	\N	\N	\N
39	Lusaka	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.815772+02	\N	\N	\N
40	Rufunsa	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.81777+02	\N	\N	\N
41	Choma	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.819773+02	\N	\N	\N
42	Gwembe	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.823278+02	\N	\N	\N
43	Kalomo	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.824284+02	\N	\N	\N
44	Kazungula	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.830315+02	\N	\N	\N
45	Livingstone	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.833828+02	\N	\N	\N
46	Mazabuka	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.840349+02	\N	\N	\N
47	Monze	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.847863+02	\N	\N	\N
48	Namwala	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.857386+02	\N	\N	\N
49	Pemba	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.859384+02	\N	\N	\N
50	Siavonga	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.862419+02	\N	\N	\N
51	Sinazongwe	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.865753+02	\N	\N	\N
52	Zimba	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.872278+02	\N	\N	\N
53	Isoka	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.881599+02	\N	\N	\N
54	Kanchibiya	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.885606+02	\N	\N	\N
55	Lavushimanda	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.890119+02	\N	\N	\N
56	Mafinga	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.893117+02	\N	\N	\N
57	Mpika	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.895115+02	\N	\N	\N
58	Nakonde	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.897631+02	\N	\N	\N
59	Shiwang'andu	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.900146+02	\N	\N	\N
60	Chinsali	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.904145+02	\N	\N	\N
61	Kasama	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.90866+02	\N	\N	\N
62	Chilubi	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.913171+02	\N	\N	\N
63	Kaputa	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.920725+02	\N	\N	\N
64	Luwingu	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.923734+02	\N	\N	\N
65	Mbala	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.927735+02	\N	\N	\N
66	Mporokoso	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.934768+02	\N	\N	\N
67	Mpulungu	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.938768+02	\N	\N	\N
68	Nsama	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.94128+02	\N	\N	\N
69	Senga Hill	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.944282+02	\N	\N	\N
70	Lunte	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.949799+02	\N	\N	\N
71	Mansa	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.956313+02	\N	\N	\N
72	Chembe	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.959313+02	\N	\N	\N
73	Chiengi	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.965831+02	\N	\N	\N
74	Chipili	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.968854+02	\N	\N	\N
75	Kawambwa	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.972365+02	\N	\N	\N
76	Lunga	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.974363+02	\N	\N	\N
77	Milenge	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.977876+02	\N	\N	\N
78	Mwansabombwe	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.979875+02	\N	\N	\N
79	Mwense	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.981876+02	\N	\N	\N
80	Nchelenge	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.982875+02	\N	\N	\N
81	Samfya	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.985876+02	\N	\N	\N
82	Mongu	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.988382+02	\N	\N	\N
83	Kalabo	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.991385+02	\N	\N	\N
84	Kaoma	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.994387+02	\N	\N	\N
85	Limulunga	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.997385+02	\N	\N	\N
86	Lukulu	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.999889+02	\N	\N	\N
87	Mitete	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.002899+02	\N	\N	\N
88	Nalolo	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.005407+02	\N	\N	\N
89	Nkeyema	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.00741+02	\N	\N	\N
90	Senanga	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.009408+02	\N	\N	\N
91	Sesheke	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.012407+02	\N	\N	\N
92	Shangombo	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.016913+02	\N	\N	\N
93	Sikongo	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.019921+02	\N	\N	\N
94	Sioma	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.02192+02	\N	\N	\N
95	Kabompo	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.023429+02	\N	\N	\N
96	Chavuma	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.027944+02	\N	\N	\N
97	Ikelenge	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.030455+02	\N	\N	\N
98	Kalumbila	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.032455+02	\N	\N	\N
99	Kasempa	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.036476+02	\N	\N	\N
100	Manyinga	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.040475+02	\N	\N	\N
101	Mufumbwe	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.042478+02	\N	\N	\N
102	Mwinilunga	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.045989+02	\N	\N	\N
103	Solwezi	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.048988+02	\N	\N	\N
104	Zambezi	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.050497+02	\N	\N	\N
\.


--
-- Data for Name: enrollments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.enrollments (id, name, description, scheme_id, lab_id, service_id, method_id, pt_cycle_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Enrollment Levy TB Cycle 1	\N	1	1	2	1	1	1	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-24 00:49:34.425012+02	\N	\N	\N
\.


--
-- Data for Name: lab_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lab_types (id, name, description, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Government	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:19:22.13977+02	\N	\N	\N
2	Private	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:19:22.15481+02	\N	\N	\N
3	Religious	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:19:22.159843+02	\N	\N	\N
4	Temp	\N	1	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:50:34.687177+02	\N	\N	\N
\.


--
-- Data for Name: laboratorys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.laboratorys (id, name, description, contact_person_name, code, lab_type_id, "position", district_id, province_id, phone_number, physical_address, email_address, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by, method_list) FROM stdin;
1	Levy Mwanawasa Kabwe	\N	Musa Choolwe	--	1	Senior Technician	26	1	260977123456	Plot 54003	musachoolwe@gmail.com	1	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-24 01:10:41.010605+02	\N	\N	\N	[]
2	Levy Lusaka	\N	Jane Banda	REG001	1	Supervisor	39	5	0977123456	Munali	jane@gmail.com	1	4	5	1	2026-07-24 02:05:50.897452+02	nkoleevans@hotmail.com		\N	\N	\N	\N	\N	\N	2026-07-24 01:52:57.485239+02	\N	2026-07-24 02:05:51.156644+02	nkoleevans@hotmail.com	[]
3	Private Lab 1	\N	Mark Doe	REG001	2	Supervisor	12	3	0977123457	Chama Plot A	markdoe@gmail.com	1	4	5	1	2026-07-24 08:38:16.478437+02	nkoleevans@hotmail.com		\N	\N	\N	\N	\N	\N	2026-07-24 08:29:04.853528+02	\N	2026-07-24 08:38:16.603786+02	nkoleevans@hotmail.com	[{"id": 1, "name": "Ultra", "user": {"id": 1, "code": null, "type": 1, "email": "nkoleevans@gmail.com", "fname": "John", "lname": "Doe", "mobile": "+260978989259", "role_id": 1, "user_id": null, "password": "$argon2id$v=19$m=65536,t=3,p=4$vleKcY7RGsOY03rPmVNK6Q$PAc0uocZOXQH1O5+flC3guorhWaHJzOm7SIJtMDIDPs", "position": "Clerk", "stage_id": 1, "status_id": 1, "created_at": "2026-07-22T03:34:55.377760+00:00", "created_by": "nkoleevans@gmail.com", "review1_at": null, "review1_by": null, "review2_at": null, "review2_by": null, "review3_at": null, "review3_by": null, "updated_at": null, "updated_by": null, "district_id": null, "mobile_code": "+260", "province_id": null, "laboratory_id": null, "address_postal": null, "approval_levels": 3, "address_physical": null, "review1_comments": null, "review2_comments": null, "review3_comments": null}, "stage": {"id": 2, "created_at": "2026-07-22T03:34:05.530670+00:00", "created_by": "System", "stage_name": "Submitted", "updated_at": null, "updated_by": null, "description": null}, "scheme": {"id": 1, "name": "Tuberculosis (TB)", "user_id": 1, "stage_id": 2, "status_id": 2, "created_at": "2026-07-23T11:46:25.836985+00:00", "created_by": null, "review1_at": null, "review1_by": null, "review2_at": null, "review2_by": null, "review3_at": null, "review3_by": null, "updated_at": null, "updated_by": null, "description": null, "provider_id": 1, "approval_levels": 1, "review1_comments": null, "review2_comments": null, "review3_comments": null}, "status": {"id": 2, "created_at": "2026-07-22T03:34:01.390120+00:00", "created_by": "System", "updated_at": null, "updated_by": null, "description": null, "status_name": "Submitted"}, "service": {"id": 1, "name": "TB Microscopy", "user_id": 1, "stage_id": 2, "scheme_id": 1, "status_id": 2, "created_at": "2026-07-22T05:52:44.223225+00:00", "created_by": null, "review1_at": null, "review1_by": null, "review2_at": null, "review2_by": null, "review3_at": null, "review3_by": null, "updated_at": "2026-07-22T13:33:01.711123+00:00", "updated_by": null, "description": null, "approval_levels": 1, "review1_comments": null, "review2_comments": null, "review3_comments": null}, "user_id": 1, "stage_id": 2, "scheme_id": 1, "status_id": 2, "created_at": "2026-07-23T11:58:41.742170+00:00", "created_by": null, "review1_at": null, "review1_by": null, "review2_at": null, "review2_by": null, "review3_at": null, "review3_by": null, "service_id": 1, "updated_at": null, "updated_by": null, "description": null, "approval_levels": 1, "review1_comments": null, "review2_comments": null, "review3_comments": null}]
4	UTH New Lab	\N	Alan Phiri	REG001	1	Supervisor	44	9	097765435363	Kazungula	alanphiri@gmail.com	1	4	5	1	2026-07-24 11:21:33.665422+02	nkoleevans@hotmail.com		\N	\N	\N	\N	\N	\N	2026-07-24 11:20:35.316509+02	\N	2026-07-24 11:21:33.814121+02	nkoleevans@hotmail.com	[{"id": 1, "name": "Ultra", "user": {"id": 1, "code": null, "type": 1, "email": "nkoleevans@gmail.com", "fname": "John", "lname": "Doe", "mobile": "+260978989259", "role_id": 1, "user_id": null, "password": "$argon2id$v=19$m=65536,t=3,p=4$vleKcY7RGsOY03rPmVNK6Q$PAc0uocZOXQH1O5+flC3guorhWaHJzOm7SIJtMDIDPs", "position": "Clerk", "stage_id": 1, "status_id": 1, "created_at": "2026-07-22T03:34:55.377760+00:00", "created_by": "nkoleevans@gmail.com", "review1_at": null, "review1_by": null, "review2_at": null, "review2_by": null, "review3_at": null, "review3_by": null, "updated_at": null, "updated_by": null, "district_id": null, "mobile_code": "+260", "province_id": null, "laboratory_id": null, "address_postal": null, "approval_levels": 3, "address_physical": null, "review1_comments": null, "review2_comments": null, "review3_comments": null}, "stage": {"id": 2, "created_at": "2026-07-22T03:34:05.530670+00:00", "created_by": "System", "stage_name": "Submitted", "updated_at": null, "updated_by": null, "description": null}, "scheme": {"id": 1, "name": "Tuberculosis (TB)", "user_id": 1, "stage_id": 2, "status_id": 2, "created_at": "2026-07-23T11:46:25.836985+00:00", "created_by": null, "review1_at": null, "review1_by": null, "review2_at": null, "review2_by": null, "review3_at": null, "review3_by": null, "updated_at": null, "updated_by": null, "description": null, "provider_id": 1, "approval_levels": 1, "review1_comments": null, "review2_comments": null, "review3_comments": null}, "status": {"id": 2, "created_at": "2026-07-22T03:34:01.390120+00:00", "created_by": "System", "updated_at": null, "updated_by": null, "description": null, "status_name": "Submitted"}, "service": {"id": 1, "name": "TB Microscopy", "user_id": 1, "stage_id": 2, "scheme_id": 1, "status_id": 2, "created_at": "2026-07-22T05:52:44.223225+00:00", "created_by": null, "review1_at": null, "review1_by": null, "review2_at": null, "review2_by": null, "review3_at": null, "review3_by": null, "updated_at": "2026-07-22T13:33:01.711123+00:00", "updated_by": null, "description": null, "approval_levels": 1, "review1_comments": null, "review2_comments": null, "review3_comments": null}, "user_id": 1, "stage_id": 2, "scheme_id": 1, "status_id": 2, "created_at": "2026-07-23T11:58:41.742170+00:00", "created_by": null, "review1_at": null, "review1_by": null, "review2_at": null, "review2_by": null, "review3_at": null, "review3_by": null, "service_id": 1, "updated_at": null, "updated_by": null, "description": null, "approval_levels": 1, "review1_comments": null, "review2_comments": null, "review3_comments": null}]
\.


--
-- Data for Name: list_stages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.list_stages (id, stage_name, description, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Awaiting Submission	\N	2026-07-22 05:34:05.53067+02	System	\N	\N
2	Submitted	\N	2026-07-22 05:34:05.53067+02	System	\N	\N
3	First Approval	\N	2026-07-22 05:34:05.53067+02	System	\N	\N
4	Second Approval	\N	2026-07-22 05:34:05.53067+02	System	\N	\N
5	Approved	\N	2026-07-22 05:34:05.53067+02	System	\N	\N
\.


--
-- Data for Name: list_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.list_statuses (id, status_name, description, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Draft	\N	2026-07-22 05:34:01.39012+02	System	\N	\N
2	Submitted	\N	2026-07-22 05:34:01.39012+02	System	\N	\N
3	Under Review	\N	2026-07-22 05:34:01.39012+02	System	\N	\N
4	Approved	\N	2026-07-22 05:34:01.39012+02	System	\N	\N
5	Rejected	\N	2026-07-22 05:34:01.39012+02	System	\N	\N
\.


--
-- Data for Name: meters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meters (id, name, description, customer_number, customer_name, identity_number, address, communicate_address, invoice_number, open_account_date, station_name, operator_uid, province_name, city_name, town_name, village_name, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
\.


--
-- Data for Name: method_samples; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.method_samples (id, name, description, method_id, service_id, scheme_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Ultra-CDL-2026-A-1	\N	1	1	1	1	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:42:36.463423+02	\N	\N	\N
2	Ultra-CDL-2026-A-2	\N	1	2	1	1	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:42:56.111238+02	\N	\N	\N
\.


--
-- Data for Name: methods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.methods (id, name, description, service_id, scheme_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Ultra	\N	1	1	1	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 13:58:41.74217+02	\N	\N	\N
2	XDR	\N	2	1	1	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 13:58:57.171916+02	\N	\N	\N
\.


--
-- Data for Name: providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.providers (id, name, description, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	CDL	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 13:12:24.605112+02	\N	\N	\N
\.


--
-- Data for Name: provinces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.provinces (id, name, description, code, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Central	\N	ZM-02	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.859852+02	\N	\N	\N
2	Copperbelt	\N	ZM-08	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.866367+02	\N	\N	\N
3	Eastern	\N	ZM-03	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.869879+02	\N	\N	\N
4	Luapula	\N	ZM-04	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.873909+02	\N	\N	\N
5	Lusaka	\N	ZM-09	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.87691+02	\N	\N	\N
6	Muchinga	\N	ZM-10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.879914+02	\N	\N	\N
7	Northern	\N	ZM-05	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.885427+02	\N	\N	\N
8	North-Western	\N	ZM-06	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.888609+02	\N	\N	\N
9	Southern	\N	ZM-07	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.891624+02	\N	\N	\N
10	Western	\N	ZM-01	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.89414+02	\N	\N	\N
\.


--
-- Data for Name: pt_cycle_samples; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pt_cycle_samples (id, name, description, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
\.


--
-- Data for Name: pt_cycle_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pt_cycle_statuses (id, name, description, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Upcoming	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:08:34.128485+02	\N	\N	\N
2	Started	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:08:34.138955+02	\N	\N	\N
3	Samples Shipped	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:08:34.141476+02	\N	\N	\N
4	Report Available	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:08:34.145994+02	\N	\N	\N
5	Closed	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:08:34.15096+02	\N	\N	\N
\.


--
-- Data for Name: pt_cycles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pt_cycles (id, name, description, code, effective_date, scheme_id, pt_cyle_status_id, closing_date, shipping_date, reports_availability_date, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	TB Cycle 1	\N	TB-001	2026-08-01	1	3	2026-08-31	2026-08-10	2026-08-25	2	4	5	1	2026-07-24 08:44:09.293111+02	nkoleevans@gmail.com		\N	\N	\N	\N	\N	\N	2026-07-23 14:29:01.866014+02	\N	2026-07-24 09:05:48.821623+02	nkoleevans@gmail.com
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, description, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Administrator	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.548572+02	\N	\N	\N
2	Scheme Head	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.554389+02	\N	\N	\N
3	Scheme Coordinator	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.558354+02	\N	\N	\N
4	Scheme Quality Officers	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.560383+02	\N	\N	\N
5	Finance Officers	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.563896+02	\N	\N	\N
6	Provincial Biomedical Scientists (PBs)	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.565803+02	\N	\N	\N
7	EQA/QMS Focal Point Persons (FPPs)	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.570203+02	\N	\N	\N
8	District Laboratory Coordinators 	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.572715+02	\N	\N	\N
9	Facility Super User	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.576227+02	\N	\N	\N
10	Facility Staff	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.578746+02	\N	\N	\N
\.


--
-- Data for Name: schemes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schemes (id, name, description, provider_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Tuberculosis (TB)	\N	1	1	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 13:46:25.836985+02	\N	\N	\N
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, name, description, scheme_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	TB Microscopy	\N	1	1	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:52:44.223225+02	\N	2026-07-22 15:33:01.711123+02	\N
2	TB Xpert 	\N	1	1	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 13:47:07.879945+02	\N	2026-07-23 13:47:40.205901+02	\N
\.


--
-- Data for Name: tb_xpert_ultra_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_xpert_ultra_results (id, name, description, scheme_id, lab_id, service_id, pt_cycle_id, method_id, enrollment_id, method_sample_id, result_nterpretable, tb_detection_result, rif_result, uninterpretable_result, ultra_spc, "is1081_IS6110", "rpoB1", "rpoB2", "rpoB3", "rpoB4", user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by, xpert_module_number) FROM stdin;
5	'Ultra-CDL-2026-A-1' for 'Private Lab 1'	\N	1	3	1	1	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-24 11:25:56.507496+02	\N	\N	\N	\N
6	'Ultra-CDL-2026-A-2' for 'Private Lab 1'	\N	1	3	2	1	1	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-24 11:25:56.520621+02	\N	\N	\N	\N
7	'Ultra-CDL-2026-A-1' for 'UTH New Lab'	\N	1	4	1	1	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-24 11:25:56.523704+02	\N	\N	\N	\N
8	'Ultra-CDL-2026-A-2' for 'UTH New Lab'	\N	1	4	2	1	1	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-24 11:25:56.525704+02	\N	\N	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, code, type, fname, lname, "position", email, mobile_code, mobile, address_physical, address_postal, role_id, password, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by, laboratory_id, province_id, district_id) FROM stdin;
1	\N	1	John	Doe	Clerk	nkoleevans@gmail.com	+260	+260978989259	\N	\N	1	$argon2id$v=19$m=65536,t=3,p=4$vleKcY7RGsOY03rPmVNK6Q$PAc0uocZOXQH1O5+flC3guorhWaHJzOm7SIJtMDIDPs	1	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:34:55.37776+02	nkoleevans@gmail.com	\N	\N	\N	\N	\N
2	\N	1	Jane	Doe	Clerk	nkoleevans@hotmail.com	+260	+260978989259	\N	\N	1	$argon2id$v=19$m=65536,t=3,p=4$vleKcY7RGsOY03rPmVNK6Q$PAc0uocZOXQH1O5+flC3guorhWaHJzOm7SIJtMDIDPs	1	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:34:55.37776+02	nkoleevans@gmail.com	\N	\N	\N	\N	\N
3	\N	1	Jane	Banda	Supervisor	jane@gmail.com	+260	0977123456	jane@gmail.com	jane@gmail.com	9	$argon2id$v=19$m=65536,t=3,p=4$1Zqzdo5xTgmBsBZC6L1XSg$TbrcXF42EmIoGfN/YzKLvGjlGIfNdp+rgyPDNXQVpoc	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-24 02:05:51.150351+02	nkoleevans@gmail.com	\N	\N	\N	\N	\N
4	\N	1	Mark	Doe	Supervisor	markdoe@gmail.com	+260	0977123457	markdoe@gmail.com	markdoe@gmail.com	9	$argon2id$v=19$m=65536,t=3,p=4$ek/pPefcGyPEmHNube29Nw$7QKMT4Ehm9KTgQf75+kaxzjW3cQomQAiq7BgxXk0gUs	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-24 08:38:16.617107+02	nkoleevans@gmail.com	\N	\N	\N	\N	\N
5	\N	1	Alan	Phiri	Supervisor	alanphiri@gmail.com	+260	097765435363	alanphiri@gmail.com	alanphiri@gmail.com	9	$argon2id$v=19$m=65536,t=3,p=4$wNgbQwjh/L+X8n7vPYdQqg$GMTgx7U5rqw6YeI72zdeU5uygxCtkyt26kTGi/KYqgc	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-24 11:21:33.830525+02	nkoleevans@gmail.com	\N	\N	\N	\N	\N
\.


--
-- Name: applications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.applications_id_seq', 1, true);


--
-- Name: audits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audits_id_seq', 1001, true);


--
-- Name: districts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.districts_id_seq', 104, true);


--
-- Name: enrollments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.enrollments_id_seq', 1, true);


--
-- Name: lab_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lab_types_id_seq', 4, true);


--
-- Name: laboratorys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.laboratorys_id_seq', 4, true);


--
-- Name: list_stages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.list_stages_id_seq', 1, false);


--
-- Name: list_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.list_statuses_id_seq', 1, false);


--
-- Name: meters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meters_id_seq', 1, false);


--
-- Name: method_samples_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.method_samples_id_seq', 2, true);


--
-- Name: methods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.methods_id_seq', 2, true);


--
-- Name: providers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.providers_id_seq', 1, true);


--
-- Name: provinces_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.provinces_id_seq', 10, true);


--
-- Name: pt_cycle_samples_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pt_cycle_samples_id_seq', 1, false);


--
-- Name: pt_cycle_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pt_cycle_statuses_id_seq', 5, true);


--
-- Name: pt_cycles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pt_cycles_id_seq', 1, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 10, true);


--
-- Name: schemes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schemes_id_seq', 1, true);


--
-- Name: services_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.services_id_seq', 2, true);


--
-- Name: tb_xpert_ultra_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_xpert_ultra_results_id_seq', 8, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 5, true);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: audits audits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (id);


--
-- Name: lab_types lab_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_types
    ADD CONSTRAINT lab_types_pkey PRIMARY KEY (id);


--
-- Name: laboratorys laboratorys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_pkey PRIMARY KEY (id);


--
-- Name: list_stages list_stages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_stages
    ADD CONSTRAINT list_stages_pkey PRIMARY KEY (id);


--
-- Name: list_statuses list_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_statuses
    ADD CONSTRAINT list_statuses_pkey PRIMARY KEY (id);


--
-- Name: meters meters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT meters_pkey PRIMARY KEY (id);


--
-- Name: method_samples method_samples_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_pkey PRIMARY KEY (id);


--
-- Name: methods methods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT methods_pkey PRIMARY KEY (id);


--
-- Name: providers providers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: provinces provinces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT provinces_pkey PRIMARY KEY (id);


--
-- Name: pt_cycle_samples pt_cycle_samples_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_samples
    ADD CONSTRAINT pt_cycle_samples_pkey PRIMARY KEY (id);


--
-- Name: pt_cycle_statuses pt_cycle_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_statuses
    ADD CONSTRAINT pt_cycle_statuses_pkey PRIMARY KEY (id);


--
-- Name: pt_cycles pt_cycles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT pt_cycles_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schemes schemes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_applications_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_applications_id ON public.applications USING btree (id);


--
-- Name: ix_audits_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_audits_id ON public.audits USING btree (id);


--
-- Name: ix_districts_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_districts_id ON public.districts USING btree (id);


--
-- Name: ix_enrollments_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_enrollments_id ON public.enrollments USING btree (id);


--
-- Name: ix_lab_types_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_lab_types_id ON public.lab_types USING btree (id);


--
-- Name: ix_laboratorys_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_laboratorys_id ON public.laboratorys USING btree (id);


--
-- Name: ix_list_stages_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_list_stages_id ON public.list_stages USING btree (id);


--
-- Name: ix_list_statuses_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_list_statuses_id ON public.list_statuses USING btree (id);


--
-- Name: ix_meters_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_meters_id ON public.meters USING btree (id);


--
-- Name: ix_method_samples_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_method_samples_id ON public.method_samples USING btree (id);


--
-- Name: ix_methods_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_methods_id ON public.methods USING btree (id);


--
-- Name: ix_providers_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_providers_id ON public.providers USING btree (id);


--
-- Name: ix_provinces_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_provinces_id ON public.provinces USING btree (id);


--
-- Name: ix_pt_cycle_samples_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pt_cycle_samples_id ON public.pt_cycle_samples USING btree (id);


--
-- Name: ix_pt_cycle_statuses_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pt_cycle_statuses_id ON public.pt_cycle_statuses USING btree (id);


--
-- Name: ix_pt_cycles_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pt_cycles_id ON public.pt_cycles USING btree (id);


--
-- Name: ix_roles_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_roles_id ON public.roles USING btree (id);


--
-- Name: ix_schemes_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_schemes_id ON public.schemes USING btree (id);


--
-- Name: ix_services_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_services_id ON public.services USING btree (id);


--
-- Name: ix_tb_xpert_ultra_results_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tb_xpert_ultra_results_id ON public.tb_xpert_ultra_results USING btree (id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: applications applications_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_lab_id_fkey FOREIGN KEY (lab_id) REFERENCES public.laboratorys(id);


--
-- Name: applications applications_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: applications applications_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: applications applications_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: applications applications_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: applications applications_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: applications applications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: districts districts_province_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_province_id_fkey FOREIGN KEY (province_id) REFERENCES public.provinces(id);


--
-- Name: districts districts_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: districts districts_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: districts districts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: enrollments enrollments_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: enrollments enrollments_pt_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pt_cycle_id_fkey FOREIGN KEY (pt_cycle_id) REFERENCES public.pt_cycles(id);


--
-- Name: enrollments enrollments_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: enrollments enrollments_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: enrollments enrollments_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: enrollments enrollments_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: enrollments enrollments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: lab_types lab_types_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_types
    ADD CONSTRAINT lab_types_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: lab_types lab_types_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_types
    ADD CONSTRAINT lab_types_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: lab_types lab_types_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_types
    ADD CONSTRAINT lab_types_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: laboratorys laboratorys_district_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_district_id_fkey FOREIGN KEY (district_id) REFERENCES public.districts(id);


--
-- Name: laboratorys laboratorys_lab_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_lab_type_id_fkey FOREIGN KEY (lab_type_id) REFERENCES public.lab_types(id);


--
-- Name: laboratorys laboratorys_province_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_province_id_fkey FOREIGN KEY (province_id) REFERENCES public.provinces(id);


--
-- Name: laboratorys laboratorys_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: laboratorys laboratorys_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: laboratorys laboratorys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: meters meters_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT meters_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: meters meters_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT meters_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: meters meters_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT meters_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: method_samples method_samples_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: method_samples method_samples_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: method_samples method_samples_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: method_samples method_samples_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: method_samples method_samples_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: method_samples method_samples_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: methods methods_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT methods_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: methods methods_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT methods_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: methods methods_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT methods_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: methods methods_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT methods_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: methods methods_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT methods_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: providers providers_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: providers providers_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: providers providers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: provinces provinces_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT provinces_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: provinces provinces_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT provinces_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: provinces provinces_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT provinces_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: pt_cycle_samples pt_cycle_samples_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_samples
    ADD CONSTRAINT pt_cycle_samples_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: pt_cycle_samples pt_cycle_samples_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_samples
    ADD CONSTRAINT pt_cycle_samples_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: pt_cycle_samples pt_cycle_samples_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_samples
    ADD CONSTRAINT pt_cycle_samples_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: pt_cycle_statuses pt_cycle_statuses_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_statuses
    ADD CONSTRAINT pt_cycle_statuses_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: pt_cycle_statuses pt_cycle_statuses_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_statuses
    ADD CONSTRAINT pt_cycle_statuses_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: pt_cycle_statuses pt_cycle_statuses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_statuses
    ADD CONSTRAINT pt_cycle_statuses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: pt_cycles pt_cycles_pt_cyle_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT pt_cycles_pt_cyle_status_id_fkey FOREIGN KEY (pt_cyle_status_id) REFERENCES public.pt_cycle_statuses(id);


--
-- Name: pt_cycles pt_cycles_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT pt_cycles_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: pt_cycles pt_cycles_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT pt_cycles_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: pt_cycles pt_cycles_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT pt_cycles_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: pt_cycles pt_cycles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT pt_cycles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: roles roles_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: roles roles_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: roles roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: schemes schemes_provider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES public.providers(id);


--
-- Name: schemes schemes_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: schemes schemes_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: schemes schemes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: services services_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: services services_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: services services_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_method_sample_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_method_sample_id_fkey FOREIGN KEY (method_sample_id) REFERENCES public.method_samples(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_pt_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_pt_cycle_id_fkey FOREIGN KEY (pt_cycle_id) REFERENCES public.pt_cycles(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: users users_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- PostgreSQL database dump complete
--

