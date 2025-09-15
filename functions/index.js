/**
 * Firebase Cloud Function: Send push notifications when complaint status changes
 */

const { onValueUpdated } = require("firebase-functions/v2/database");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

// ✅ Initialize Admin SDK (auto-detects credentials in deployed env)
admin.initializeApp({
  databaseURL: "https://city-89a1f-default-rtdb.asia-southeast1.firebasedatabase.app",
});

// ✅ Trigger when complaint status updates
exports.onstatusupdate = onValueUpdated(
  {
    ref: "/complaints/{complaintId}",
    region: "asia-southeast1",
  },
  async (event) => {
    const beforeData = event.data.before.val();
    const afterData = event.data.after.val();

    // Exit if no data or status unchanged
    if (!beforeData || !afterData || beforeData.status === afterData.status) {
      logger.log("Status has not changed or data is missing.");
      return;
    }

    const complaintId = event.params.complaintId;
    const newStatus = afterData.status;
    const citizenId = afterData.userId; // for citizen notification

    // --- START: Worker Notification Logic ---
    // If a complaint is assigned, notify the worker.
    if (newStatus === "Assigned" && afterData.assignedTo) {
      const workerId = afterData.assignedTo;
      const workerToken = await getTokenForWorker(workerId);

      if (workerToken) {
        const workerMessage = {
          notification: {
            title: "New Task Assigned",
            body: `You have a new task: Complaint #${complaintId.substring(0, 8)}`,
          },
          data: {
            complaintId: complaintId,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          token: workerToken,
        };

        try {
          await admin.messaging().send(workerMessage);
          logger.log("✅ Notification sent successfully to worker:", workerId);
        } catch (error) {
          logger.error("❌ Error sending notification to worker:", error);
        }
      } else {
        logger.warn("⚠️ No FCM token found for worker:", workerId);
      }
    }
    // --- END: Worker Notification Logic ---

    let title = "";
    let body = "";

    switch (newStatus) {
      case "Assigned":
        title = "Complaint Assigned";
        body = `Your complaint #${complaintId.substring(0, 8)} has been assigned.`;
        break;
      case "In Progress":
        title = "Work In Progress";
        body = `Work has started on your complaint #${complaintId.substring(0, 8)}.`;
        break;
      case "Resolved":
        title = "Complaint Resolved";
        body = `Your complaint #${complaintId.substring(0, 8)} is resolved.`;
        break;
      default:
        logger.log(`No notification configured for status: ${newStatus}`);
        return;
    }

    // ✅ Get the user's FCM token from RTDB
    const targetToken = await getTokenForUser(citizenId);
    logger.log("Resolved FCM token:", targetToken);

    if (!targetToken) {
      logger.warn("⚠️ No FCM token found for user:", citizenId);
      return;
    }

    // ✅ Construct the notification message
    const message = {
      notification: {
        title,
        body,
      },
      data: {
        complaintId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      token: targetToken,
    };

    try {
      const response = await admin.messaging().send(message);
      logger.log("✅ Notification sent successfully:", response);
    } catch (error) {
      logger.error("❌ Error sending notification:", error);
    }
  }
);

/**
 * Helper: Get the FCM token for a given WORKER ID
 */
async function getTokenForWorker(workerId) {
  if (!workerId) return null;
  try {
    const snapshot = await admin.database().ref(`/workers/${workerId}/fcmToken`).once("value");
    return snapshot.val();
  } catch (err) {
    logger.error("Error fetching FCM token for worker:", workerId, err);
    return null;
  }
}

/**
 * Helper: Get the FCM token for a given user ID
 */
async function getTokenForUser(userId) {
  if (!userId) return null;
  try {
    const snapshot = await admin.database().ref(`/users/${userId}/fcmToken`).once("value");
    return snapshot.val();
  } catch (err) {
    logger.error("Error fetching FCM token for user:", userId, err);
    return null;
  }
}
