package com.example.myfortune.model

import java.util.Date
import java.util.UUID

/** Mirrors myfortune/Models/Fortune.swift. */
data class Fortune(
    val id: String = UUID.randomUUID().toString(),
    val text: String,
    val date: Date = Date(),
    val category: String
)
