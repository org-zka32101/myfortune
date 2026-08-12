package com.yourwish.cometrueaifortune.service

import com.yourwish.cometrueaifortune.model.Fortune
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.functions.FirebaseFunctions
import java.util.Date

/** Thrown when the `analyzeFortune` Cloud Function returns an unexpected shape. */
class FortuneServiceException(message: String) : Exception(message)

/**
 * Fetches today's fortune from the `analyzeFortune` Cloud Function. Mirrors
 * myfortune/Services/FortuneService.swift.
 *
 * The backend generates it from the user's recorded history (or returns
 * today's cached result if one already exists) and persists it server-side —
 * there is no separate save step on the client.
 */
class FortuneService private constructor() {

    private val functions = FirebaseFunctions.getInstance()

    fun fetchFortune(onResult: (Result<Fortune>) -> Unit) {
        ensureSignedIn { signInResult ->
            signInResult.fold(
                onSuccess = { callAnalyzeFortune(onResult) },
                onFailure = { onResult(Result.failure(it)) }
            )
        }
    }

    /** The backend only needs a stable caller identity for per-user
     *  caching/history, so anonymous auth is enough — no sign-in UI. */
    private fun ensureSignedIn(onResult: (Result<Unit>) -> Unit) {
        val auth = FirebaseAuth.getInstance()
        if (auth.currentUser != null) {
            onResult(Result.success(Unit))
            return
        }

        auth.signInAnonymously()
            .addOnSuccessListener { onResult(Result.success(Unit)) }
            .addOnFailureListener { onResult(Result.failure(it)) }
    }

    private fun callAnalyzeFortune(onResult: (Result<Fortune>) -> Unit) {
        functions.getHttpsCallable("analyzeFortune")
            .call()
            .addOnSuccessListener { result ->
                @Suppress("UNCHECKED_CAST")
                val data = result.data as? Map<String, Any?>
                val text = data?.get("text") as? String
                val category = data?.get("category") as? String

                if (text == null || category == null) {
                    onResult(Result.failure(FortuneServiceException("Invalid response from analyzeFortune")))
                } else {
                    onResult(Result.success(Fortune(text = text, date = Date(), category = category)))
                }
            }
            .addOnFailureListener { onResult(Result.failure(it)) }
    }

    companion object {
        @Volatile
        private var instance: FortuneService? = null

        val shared: FortuneService
            get() = instance ?: synchronized(this) {
                instance ?: FortuneService().also { instance = it }
            }
    }
}
