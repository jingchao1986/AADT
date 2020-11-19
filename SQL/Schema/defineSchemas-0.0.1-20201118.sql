--liquibase formatted sql

--changeset Zhoujc:20201118-1
--preconditions onFail:CONTINUE onError:HALT
--Create schemas.
CREATE SCHEMA IF NOT EXISTS aadt;